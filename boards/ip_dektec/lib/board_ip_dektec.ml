open Common.Hardware
open Api.Interaction
open Meta_board
open Board_types

module Api_handler = Api.Handler.Make(Common.User)

module Data = struct
  type t = Board_types.config
  let default = Board_types.config_default
  let dump = Board_types.config_to_string
  let restore = Board_types.config_of_string
end

module Config_storage = Storage.Options.Make (Data)

module Storage : sig
  type _ req =
    | Store_status : Board_types.board_status -> unit Lwt.t req
  include (Storage.Database.STORAGE with type 'a req := 'a req)
end = Db

type 'a request = 'a Board_protocol.request

let create_sm = Board_protocol.SM.create

let create (b:topo_board) send db base step =
  let storage      = Config_storage.create base ["board"; (string_of_int b.control)] in
  let s_state, spush = React.S.create `No_response in
  let events, api, step    = create_sm send storage spush step in
  let s_strms,s_strms_push = React.S.create [] in
  let e_status = React.E.map (fun (x : board_status) -> (if x.asi_bitrate > 0 then [Common.Stream.Single] else [])
                                                        |> s_strms_push) events.status in
  let handlers = Board_api.handlers b.control api events in
  Lwt_main.run @@ Storage.init db;
  let _s = Lwt_react.E.map_p (fun s -> Storage.request db (Storage.Store_status s)) @@ React.E.changes events.status in
  let state = object method s = _s; method e_status = e_status end in
  { handlers       = handlers
  ; control        = b.control
  ; streams_signal = React.S.const []
  ; step           = step
  ; connection     = s_state
  ; ports_active   = (List.fold_left (fun acc (p : topo_port) ->
                          (match p.port with
                           | 0 -> React.S.const true
                           | x -> raise (Invalid_port ("Board_ip_dektec: invalid_port " ^ (string_of_int x))))
                          |> fun x -> Ports.add p.port x acc)
                                     Ports.empty b.ports)
  ; state          = (state :> < >)
  }
