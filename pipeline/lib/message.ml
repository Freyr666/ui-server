open Containers
open Lwt.Infix

module type VALUE = sig
  type t
  val name : string
  val to_yojson : t -> Yojson.Safe.json
  val of_yojson : Yojson.Safe.json -> (t,string) result
end

type 'a msg = { name : string
              ; data : 'a
              } [@@deriving yojson]

type 'a cont_body = { _method : string [@key "method"]
                    ; body : 'a
                    } [@@deriving yojson]

type cont_met = { _method : string [@key "method"]
                } [@@deriving yojson]
            
let get_js (name : string) (send : Yojson.Safe.json -> Yojson.Safe.json Lwt.t) of_ () =
  let msg = msg_to_yojson cont_met_to_yojson { name; data = { _method = "Get" }} in
  send msg >>= function
  | `Assoc [("Fine",rep)] -> begin
      let rep' = cont_body_of_yojson of_ rep in
      match rep' with
      | Error e -> Lwt_io.printf "Received error: %s" (Yojson.Safe.pretty_to_string rep) >>= fun () ->
                   Lwt.return_error e
      | Ok v    -> Lwt.return_ok v.body
    end
  | `Assoc [("Error",`String e)] -> Lwt.return_error e
  | s -> Lwt.return_error ("bad response: " ^ (Yojson.Safe.pretty_to_string s))

let set_js (name : string) (send : Yojson.Safe.json -> Yojson.Safe.json Lwt.t) to_ v =
  let msg = msg_to_yojson (cont_body_to_yojson to_) { name; data = { _method = "Set"; body = v }} in
  send msg >>= fun rep ->
  let rep = msg_of_yojson cont_met_of_yojson rep in
  match rep with
  | Error e -> Lwt.return_error e
  | Ok (_)  -> Lwt.return_ok ()

module Make(V: VALUE) = struct
  type t = V.t
  let create send_js = function
    | `Json ->
       (fun () -> get_js V.name send_js V.of_yojson ()),
       (fun x -> set_js V.name send_js V.to_yojson x)
end

type 'a channel =
  { get : unit -> ('a, string) result Lwt.t
  ; set : 'a -> (unit, string) result Lwt.t
  }