open Lwt_zmq
open Lwt_react
open Lwt.Infix
open Config
open Database

type settings = { bin_name  : string
                ; bin_path  : string
                ; sources   : string list
                ; msg_fmt   : string
                ; sock_in   : string
                ; sock_out  : string
                } [@@deriving yojson]
   
type pipe = { set            : (string * Yojson.Safe.json) list -> unit Lwt.t
            ; get            : string list -> (string * Yojson.Safe.json) list Lwt.t
            ; options_events : Yojson.Safe.json E.t
            ; setting_events : Yojson.Safe.json E.t
            ; graph_events   : Yojson.Safe.json E.t
            ; wm_events      : Yojson.Safe.json E.t
            ; data_events    : Yojson.Safe.json E.t
            }

let settings_default = { bin_name  = "ats3-backend"
                       ; bin_path  = "/home/freyr/Documents/soft/dev/ats-analyzer/build/"
                       ; sources   = ["udp://224.1.2.2:1234"]
                       ; msg_fmt   = "json"
                       ; sock_in   = "ipc:///tmp/ats_qoe_in"
                       ; sock_out  = "ipc:///tmp/ats_qoe_out"
                       }

let domain = "pipeline"

let split_events events =
  let opts, opts_push = E.create () in
  let sets, sets_push = E.create () in
  let grap, grap_push = E.create () in
  let wm  , wm_push   = E.create () in
  let data, data_push = E.create () in
  
  let splt = function
    | `Assoc [("options", tl)] -> opts_push tl
    | `Assoc [("settings", tl)] -> sets_push tl
    | `Assoc [("graph", tl)] -> grap_push tl
    | `Assoc [("wm", tl)] -> wm_push tl
    | `Assoc [("data", tl)] -> data_push tl
    | _ -> ()
  in
  let _ = E.map splt events in
  opts, sets, grap, wm, data

let set sock pairs =
  Socket.send sock (Yojson.Safe.to_string (`Assoc ["set", `Assoc pairs]))
  >>= fun () -> Socket.recv sock
  >>= Lwt_io.printf "Send result: %s\n"

let get sock keys =
  let keys = `List (List.map (fun k -> `String k) keys) in
  Socket.send sock (Yojson.Safe.to_string (`Assoc ["get", keys]))
  >>= fun () -> Socket.recv sock
  >>= (fun js ->
    Yojson.Safe.from_string js
    |> function
      | `Assoc ["ok", `Assoc kvs] -> Lwt.return kvs
      | `Assoc ["error", `String msg] -> Lwt.fail_with msg
      | _ -> Lwt.fail_with ("unknown resp: " ^ js))
              

module type PIPELINE = sig
  type config
  type db
  type t
  val  create   : config -> db -> (t * unit Lwt.t)
  val  finalize : t -> unit
end
       
module Make (C : CONFIG) (Db : DATABASE)
       : (PIPELINE with type t = pipe and type config = C.t and type db = Db.t) = struct

  type config = C.t
  type db     = Db.t
  type t      = pipe

  let get_settings = C.get settings_of_yojson domain settings_default 

  let create config _ =
    let cfg = get_settings config in
    let exec_path = (Filename.concat cfg.bin_path cfg.bin_name) in
    let exec_opts = Array.of_list (cfg.bin_name :: "-m" :: cfg.msg_fmt :: cfg.sources) in
      match Unix.fork () with
    | -1 -> failwith "Ooops, fork faild"
    | 0  -> Unix.execv exec_path exec_opts
    | _  ->     
       let ctx = ZMQ.Context.create () in
       let msg_sock = ZMQ.Socket.create ctx ZMQ.Socket.req in
       let ev_sock  = ZMQ.Socket.create ctx ZMQ.Socket.sub in

       ZMQ.Socket.connect msg_sock cfg.sock_in;
       ZMQ.Socket.connect ev_sock cfg.sock_out;
       ZMQ.Socket.subscribe ev_sock "";

       let msg_sock = Socket.of_socket msg_sock in
       let ev_sock  = Socket.of_socket ev_sock in

       let events, epush = E.create () in
       let options_events,
           setting_events,
           graph_events,
           wm_events,
           data_events = split_events events
       in
       let set = set msg_sock in
       let get = get msg_sock in
       let obj = {set; get; options_events;
                  setting_events; graph_events;
                  wm_events; data_events}
       in
       let rec loop () =
         Socket.recv ev_sock
         >>= fun msg ->
         epush (Yojson.Safe.from_string msg);
         (*Lwt_io.printf "Some %s\n" msg |> ignore;*)
         loop ()
       in
       obj, (loop ())

  let finalize : t -> unit = fun _ -> ()
    
end
  
     
