open Containers
open Board_types
open Types
open Structure_types
open Lwt.Infix
open Storage.Options
open Api.Handler
open Meta_board
open Meta_board.Msg

include Board_parser

let io x = Lwt_io.printf "%s\n" x |> ignore

let to_period x step_duration  = x * int_of_float (1. /. step_duration)

module SM = struct

  type structs_and_br =
    { structs  : ts_structs
    ; bitrates : Types.bitrates
    }

  let request_id = ref (-1)
  let jitter_ptr = ref (-1l)

  let get_id ()  = incr request_id; !request_id

  let wakeup_timeout (_,t) = t.pred `Timeout |> ignore

  type push_events = { devinfo        : devinfo_response      -> unit
                     ; group          : group                 -> unit
                     ; board_errors   : board_errors          -> unit
                     ; structs        : ts_structs            -> unit
                     ; bitrates       : ts_structs            -> unit
                     ; t2mi_info      : t2mi_info             -> unit
                     ; jitter         : jitter_measures       -> unit
                     ; jitter_session : jitter_session        -> unit
                     }

  module Events_handler : sig
    val handle          : event list -> group option -> group list * event list
    val update_versions : from:group -> group -> group
    val get_req_stack   : group -> group option -> event_response event_request list
    val to_ts_errors    : group -> ts_error list
    val to_ts_states    : group -> ts_state list
    val to_t2mi_errors  : group -> t2mi_error list
    val to_t2mi_states  : group -> t2mi_state list
  end = struct

    let merge_ts_errors l =
      List.filter_map (function `Ts_errors x -> Some x | _ -> None) l |> List.concat
      |> List.sort (fun (x:ts_error) y -> Int32.compare x.packet y.packet)

    let merge_t2mi_errors l =
      List.filter_map (function `T2mi_errors x -> Some x | _ -> None) l |> List.concat

    let update_versions ~(from:group) (t:group) : group =
      { t with status = { t.status with versions = from.status.versions }}

    let split_by l sep =
      let res,acc = List.fold_left (fun (res,acc) x ->
                        if Equal.poly x sep then (((List.rev acc) :: res),[]) else (res,x::acc))
                                   ([],[]) l in
      (List.rev res),(List.rev acc)

    (** Returns merged groups and unmerged events. Last group received is head of list **)
    let handle (events:event list) (prev_group:group option) =
      let groups,rest = split_by events `End_of_errors in
      let groups =
        List.filter (function
                     | `Status _ :: `Streams_event _ :: _ -> true
                     | _                                  -> false) groups
        |> List.fold_left (fun (acc:group list) (x:event list) ->
               let prev_status = (match acc with
                                  | [] -> Option.(prev_group >|= (fun x -> x.status))
                                  | x :: _ -> Some x.status) in
               match x with
               | `Status status :: `Streams_event streams :: events ->
                  ({ status = { status with streams = streams }
                   ; prev_status
                   ; events } : group) :: acc
               | _ -> assert false) []
      in groups,rest

    let get_req_stack ({ status; _ }:group) (prev_t:group option) =
      let bitrate_req    = Get_bitrates (get_id ()) in
      let jitter_req     = Get_jitter { request_id = get_id (); pointer = !jitter_ptr } in
      let board_errs_req = if status.errors then [ Get_board_errors (get_id ()) ] else [] in
      [ bitrate_req; jitter_req ]
      @ board_errs_req
      @ (match prev_t with
         | Some old -> (if old.status.versions.ts_ver_com <> status.versions.ts_ver_com
                        then [ Get_ts_structs (get_id ()) ] else [])
                       @ (List.map (fun id -> Get_t2mi_info { request_id = get_id (); stream_id = id })
                                   (List.foldi (fun acc i x ->
                                        if (x <> (List.nth old.status.versions.t2mi_ver_lst i))
                                           && List.mem ~eq:(=) i status.t2mi_sync
                                        then i :: acc
                                        else acc) [] status.versions.t2mi_ver_lst))
         | None -> [ Get_ts_structs (get_id ()) ]
                   @ (if List.is_empty status.t2mi_sync then []
                      else (List.map (fun id -> Get_t2mi_info { request_id = get_id (); stream_id = id })
                                     status.t2mi_sync)))

    let to_ts_errors (g:group) = merge_ts_errors g.events
    let to_ts_states (g:group) =
      let eq = Common.Stream.equal_id in
      let ts_found =
        (match g.prev_status with
         | Some o -> List.filter (fun x -> not @@ List.mem ~eq x o.streams) g.status.streams
         | None   -> g.status.streams)
        |> List.map (fun x -> { stream_id = x
                              ; timestamp = g.status.status.timestamp
                              ; present   = true })
      in
      let ts_lost =
        (match g.prev_status with
         | Some o -> List.filter (fun x -> not @@ List.mem ~eq x g.status.streams) o.streams
         | None   -> [])
        |> List.map (fun x -> { stream_id = x
                              ; timestamp = g.status.status.timestamp
                              ; present   = false })
      in ts_found @ ts_lost

    let to_t2mi_errors (g:group) = merge_t2mi_errors g.events
    let to_t2mi_states (g:group) = match g.status.t2mi_mode with
      | Some m ->
         let eq   = Int.equal in
         let conv = fun p s -> { stream_id      = m.stream
                               ; timestamp      = g.status.status.timestamp
                               ; t2mi_stream_id = s
                               ; present        = p
                               }
         in
         let lost = (match g.prev_status with
                     | Some o -> List.filter (fun x -> not @@ List.mem ~eq x o.t2mi_sync) g.status.t2mi_sync
                     | None   -> g.status.t2mi_sync)
                    |> List.map (conv true)
         in
         let found = (match g.prev_status with
                      | Some o -> List.filter (fun x -> not @@ List.mem ~eq x g.status.t2mi_sync) o.t2mi_sync
                      | None   -> [])
                     |> List.map (conv false)
         in
         lost @ found
      | None   -> []

  end

  module Pids = CCMap.Make(Int)

  let merge_service_and_bitrates (m:int Pids.t) (s:service) =
    let ecm     = List.map (fun (ecm:ecm) -> { ecm with bitrate = Pids.get ecm.pid m }) s.ecm in
    let es      = List.map (fun (es:es) -> { es with bitrate = Pids.get es.pid m }) s.es in
    let bitrate = List.fold_left (fun acc (x:es) -> match acc,x.bitrate with
                                                    | None,Some x     -> Some x
                                                    | Some acc,Some x -> Some (acc + x)
                                                    | Some acc, None  -> Some acc
                                                    | None, None      -> None) None es in
    { s with bitrate; ecm; es }

  let merge_struct_and_bitrates (s:ts_struct) (b:Types.bitrate) =
    let open Types in
    let pids_m = List.fold_left (fun m {pid;bitrate} -> Pids.add pid bitrate m) Pids.empty b.pids in
    let pids   = List.map (fun (pid:pid) -> { pid with bitrate = Pids.get pid.pid pids_m }) s.pids in
    let emm    = List.map (fun (emm:emm) -> { emm with bitrate = Pids.get emm.pid pids_m }) s.emm in
    let services = List.map (merge_service_and_bitrates pids_m) s.services in
    let update_table_common (c:table_common) = { c with bitrate = Pids.get c.pid pids_m } in
    let tables = List.map (function
                           | PAT x     -> PAT { x with common = update_table_common x.common }
                           | CAT x     -> CAT (update_table_common x)
                           | PMT x     -> PMT { x with common = update_table_common x.common }
                           | TSDT x    -> TSDT (update_table_common x)
                           | NIT x     -> NIT { x with common = update_table_common x.common }
                           | SDT x     -> SDT { x with common = update_table_common x.common }
                           | BAT x     -> BAT { x with common = update_table_common x.common }
                           | EIT x     -> EIT { x with common = update_table_common x.common }
                           | TDT x     -> TDT (update_table_common x)
                           | RST x     -> RST (update_table_common x)
                           | ST  x     -> ST (update_table_common x)
                           | TOT x     -> TOT (update_table_common x)
                           | DIT x     -> DIT (update_table_common x)
                           | SIT x     -> SIT (update_table_common x)
                           | Unknown x -> Unknown (update_table_common x)) s.tables
    in
    { s with bitrate = Some b.ts_bitrate; pids; services; emm; tables; timestamp = b.timestamp }

  let merge_structs_and_bitrates (s:ts_structs) (b:Types.bitrates) =
    let open Types in
    List.map (fun (s:ts_struct) ->
        match List.find_pred (fun (x:bitrate) -> Common.Stream.equal_id x.stream_id s.stream_id) b with
        | Some x -> merge_struct_and_bitrates s x
        | None   -> s) s

  let send_msg (type a) sender (msg : a request) : unit Lwt.t =
    (match msg with
     | Get_board_info       -> Get_board_info.to_cbuffer ()
     | Get_board_mode       -> Get_board_mode.to_cbuffer ()
     | Get_t2mi_frame_seq x -> Get_t2mi_frame_seq.to_cbuffer x
     | Get_section x        -> Get_section.to_cbuffer x)
    |> sender

  let send_event (type a) sender (msg : a event_request) : unit Lwt.t =
    (match msg with
     | Get_board_errors id -> Get_board_errors.to_cbuffer id
     | Get_jitter req      -> Get_jitter.to_cbuffer req
     | Get_ts_structs req  -> Get_ts_structs.to_cbuffer req
     | Get_bitrates req    -> Get_bitrates.to_cbuffer req
     | Get_t2mi_info req   -> Get_t2mi_info.to_cbuffer req)
    |> sender

  let send_instant (type a) sender (msg : a instant_request) : unit Lwt.t =
    (match msg with
     | Reset             -> to_complex_req ~msg_code:0x0111 ~body:(Cbuffer.create 0) ()
     | Set_board_mode x  ->
        let t2mi = Option.get_or ~default:{ enabled        = false
                                          ; pid            = 0
                                          ; t2mi_stream_id = 0
                                          ; stream         = Single
                                          }
                                 x.t2mi in
        let body = Cbuffer.create sizeof_board_mode in
        let () = input_to_int x.input
                 |> (lor) (if t2mi.enabled then 4 else 0)
                 |> (lor) 8 (* disable board storage by default *)
                 |> set_board_mode_mode body in
        let () = set_board_mode_t2mi_pid body t2mi.pid in
        let () = set_board_mode_t2mi_stream_id body (Common.Stream.id_to_int32 t2mi.stream) in
        to_simple_req ~msg_code:0x0082 ~body ()
     | Set_jitter_mode x ->
        let req  = match x with
          | Some x -> x
          | None   -> { pid = 0x1fff; stream = Single }
        in
        let body = Cbuffer.create sizeof_req_set_jitter_mode in
        let () = set_req_set_jitter_mode_stream_id body (Common.Stream.id_to_int32 req.stream) in
        let () = set_req_set_jitter_mode_pid body req.pid in
        to_complex_req ~msg_code:0x0112 ~body ())
    |> sender

  let enqueue (type a) msgs sender (msg : a request) timeout exn : a Lwt.t =
    (* no instant msgs *)
    let t,w = Lwt.wait () in
    let pred = function
      | `Timeout -> Lwt.wakeup_exn w (Failure "msg timeout"); None
      | l        -> Option.( is_response msg l >|= Lwt.wakeup w ) in
    let send = fun () -> send_msg sender msg in
    msgs := Await_queue.append !msgs { send; pred; timeout; exn };
    t

  let enqueue_instant (type a) msgs sender (storage:config storage) (msg : a instant_request) : unit Lwt.t =
    let t,w = Lwt.wait () in
    let send = fun () -> (send_instant sender msg) >>= (fun x -> Lwt.return @@ Lwt.wakeup w x) in
    let pred = fun _  -> None in
    let conf = storage#get in
    let _    = match msg with
      | Set_board_mode  mode -> storage#store { conf with t2mi_mode = mode.t2mi; input = mode.input }
      | Set_jitter_mode x    -> storage#store { conf with jitter_mode = x }
      | Reset                       -> ()
    in
    msgs := Queue.append !msgs { send; pred; timeout = 0; exn = None };
    t

  let push_event_response (pe:push_events) = function
    | Board_errors x -> pe.board_errors x
    | Bitrate _      -> ()
    | Struct  x      -> pe.structs x
    | T2mi_info x    -> pe.t2mi_info x
    | Jitter x       -> jitter_ptr := x.next_ptr; pe.jitter x.measures

  let step msgs imsgs sender (storage : config storage) step_duration push_state push_events =
    let period         = to_period 5 step_duration in
    (* let section_period = to_period 120 step_duration in *)

    let handle_msgs rsps =
      if Await_queue.has_pending !msgs
      then (msgs := fst @@ Await_queue.responsed !msgs rsps;
            let new_msgs,tout = Await_queue.step !msgs in
            msgs := new_msgs;
            (match tout with
             | [] -> ()
             | l  -> List.iter (fun x -> x.pred `Timeout |> ignore) l));
      if not @@ Await_queue.empty !msgs
      then msgs := fst @@ Await_queue.send !msgs () in

    let rec first_step () =
      Await_queue.iter !msgs wakeup_timeout;
      msgs := Await_queue.create [];
      imsgs := Queue.create [];
      push_state `No_response;
      send_msg sender Get_board_info |> ignore;
      `Continue (step_detect period None)

    and step_detect p acc recvd =
      let _, _, rsps, _, acc = deserialize [] (Meta_board.concat_acc acc recvd) in
      match List.find_map (is_response Get_board_info) rsps with
      | Some info -> push_state `Init;
                     push_events.devinfo (Some info);
                     let config = storage#get in
                     send_instant sender (Set_board_mode { t2mi  = config.t2mi_mode
                                                         ; input = config.input }) |> ignore;
                     send_instant sender (Set_jitter_mode config.jitter_mode)
                     |> ignore;
                     (* send_instant sender Reset |> ignore; *)
                     `Continue (step_normal_idle period None [] [] None)
      | None      -> if p < 0 then first_step ()
                     else `Continue (step_detect (pred p) acc)

    and step_normal_idle p prev_group prev_events parts acc recvd =
      let events,_,rsps,parts,acc = deserialize parts (Meta_board.concat_acc acc recvd) in
      if Option.is_none @@ List.find_map (is_response Get_board_info) rsps
      then
        let events = prev_events @ events in
        let ()     = handle_msgs rsps in
        let _      = Queue.send !imsgs () (* FIXME *) in
        let ()     = imsgs := Queue.next !imsgs in
        (match Events_handler.handle events prev_group with
         | [],events ->
            if p < 0 then first_step ()
            else `Continue (step_normal_idle (pred p) prev_group events parts acc)
         | (hd::_) as groups,events ->
            push_state `Fine;
            List.iter (fun x -> push_events.group x) @@ List.rev groups;
            let pool = Pool.create @@ List.map (fun req -> { send    = (fun () -> send_event sender req)
                                                           ; pred    = (is_event req)
                                                           ; timeout = period
                                                           ; exn     = None
                                               })
                                               (Events_handler.get_req_stack hd prev_group) in
            let sb = { structs = []; bitrates = [] } in
            step_normal_probes_send sb pool hd hd events parts acc)
      else (io "Got board info in step normal idle"; first_step ())

    and step_normal_probes_send sb pool prev_idle_gp gp events parts acc =
      if Pool.empty pool
      then `Continue (step_normal_idle period (Some gp) events parts acc)
      else (Pool.send pool () |> ignore;
            `Continue (step_normal_probes_wait sb pool period prev_idle_gp gp events parts acc))

    and step_normal_probes_wait sb pool p prev_idle_gp gp prev_events parts acc recvd =
      let events,ev_rsps,rsps,parts,acc = deserialize parts (Meta_board.concat_acc acc recvd) in
      let () = handle_msgs rsps in
      let gp,events = match Events_handler.handle (prev_events @ events) (Some gp) with
        | [],e           -> gp,e
        | (hd::_) as l,e -> List.iter (fun x -> push_events.group x) @@ List.rev l; hd,e
      in
      try
        (match Pool.responsed pool ev_rsps with
         | None   ->
            `Continue (step_normal_probes_wait sb (Pool.step pool) (pred p) prev_idle_gp gp events parts acc)
         | Some x ->
            push_event_response push_events x;
            let sb = match x with Struct s  -> { sb with structs  = s }
                                | Bitrate b -> { sb with bitrates = b }
                                | _         -> sb
            in
            if Pool.last pool
            then (push_events.bitrates (merge_structs_and_bitrates sb.structs sb.bitrates);
                  `Continue (step_normal_idle period
                                              (Some (Events_handler.update_versions ~from:prev_idle_gp gp))
                                              prev_events
                                              parts
                                              acc))
            else step_normal_probes_send sb (Pool.next pool) prev_idle_gp gp events parts acc)
      with
      | Timeout -> (io "Got timeout in step normal probes wait"; first_step ())

    in first_step ()

  let to_input_e (group:group React.event) : input React.event =
    React.E.changes ~eq:equal_input @@ React.E.map (fun (x:group) -> x.status.input) group

  let to_status_e (group:group React.event) : Board.status React.event =
    React.E.changes ~eq:Board.equal_status @@ React.E.map (fun (x:group) -> x.status.status) group

  let to_reset_e (group:group React.event) : Board.reset_ts React.event =
    React.E.map (fun (x:group) : Board.reset_ts -> { timestamp = x.status.status.timestamp }) group

  let to_ts_errors_e (group:group React.event) : ts_error list React.event =
    React.E.map Events_handler.to_ts_errors group

  let to_ts_states_e (group:group React.event) : ts_state list React.event =
    React.E.map Events_handler.to_ts_states group

  let to_t2mi_errors_e (group:group React.event) : t2mi_error list React.event =
    React.E.map Events_handler.to_t2mi_errors group

  let to_t2mi_states_e (group:group React.event) : t2mi_state list React.event =
    React.E.map Events_handler.to_t2mi_states group

  let create sender (storage : config storage) push_state step_duration =
    let msgs   = ref (Await_queue.create []) in
    let imsgs  = ref (Queue.create []) in
    let group,group_push               = React.E.create () in
    let config,push_config             = React.E.create () in
    let devinfo,devinfo_push           = React.S.create None in
    let board_errors,board_errors_push = React.E.create () in
    let streams,streams_push           = React.S.create [] in
    let structs,structs_push           = React.S.create ~eq:(fun _ _ -> false) [] in
    let bitrates,bitrates_push         = React.S.create ~eq:(fun _ _ -> false) [] in
    let t2mi_info,t2mi_info_push       = React.E.create () in
    let jitter,jitter_push             = React.E.create () in
    let jitter_s,jitter_s_push         = React.E.create () in
    let (events : events) = { config       = React.E.changes ~eq:equal_config config
                            ; status       = to_status_e group
                            ; input        = to_input_e group
                            ; reset        = to_reset_e group
                            ; streams
                            ; ts_states    = to_ts_states_e group
                            ; ts_errors    = to_ts_errors_e group
                            ; t2mi_states  = to_t2mi_states_e group
                            ; t2mi_errors  = to_t2mi_errors_e group
                            ; board_errors
                            ; structs      = React.S.changes structs
                            ; bitrates     = React.S.changes bitrates
                            ; t2mi_info
                            ; jitter
                            ; jitter_session = React.E.changes ~eq:equal_jitter_session jitter_s
                            }
    in
    let push_events = { devinfo        = devinfo_push
                      ; group          = group_push
                      ; board_errors   = board_errors_push
                      ; structs        = structs_push
                      ; bitrates       = bitrates_push
                      ; t2mi_info      = t2mi_info_push
                      ; jitter         = jitter_push
                      ; jitter_session = jitter_s_push
                      }
    in
    let api =
      { set_input       = (fun input -> let mode : Types.mode = { t2mi = storage#get.t2mi_mode; input } in
                                        enqueue_instant imsgs sender storage (Set_board_mode mode))
      ; set_t2mi_mode   = (fun t2mi  -> let mode : Types.mode = { input = storage#get.input; t2mi } in
                                        enqueue_instant imsgs sender storage (Set_board_mode mode))
      ; set_jitter_mode = (fun m     -> enqueue_instant imsgs sender storage (Set_jitter_mode m)
                                        >>= (fun () -> push_config storage#get; Lwt.return_unit))
      ; get_devinfo     = (fun ()    -> Lwt.return @@ React.S.value devinfo)
      ; reset           = (fun ()    -> enqueue_instant imsgs sender storage Reset)
      ; get_structs     = (fun ()    -> Lwt.return @@ React.S.value structs)
      ; get_bitrates    = (fun ()    -> Lwt.return @@ React.S.value bitrates)
      ; get_section     = (fun r     -> enqueue msgs sender
                                                (Get_section { request_id = get_id ()
                                                             ; params     = r })
                                                (to_period 125 step_duration)
                                                None)
      ; get_t2mi_seq    = (fun s     -> enqueue msgs sender
                                                (Get_t2mi_frame_seq { request_id = get_id ()
                                                                    ; seconds    = s })
                                                (to_period (s + 10) step_duration)
                                                None)
      ; config          = (fun () -> Lwt.return storage#get)
      } in
    events,
    api,
    (step msgs imsgs sender storage step_duration push_state push_events)

end
