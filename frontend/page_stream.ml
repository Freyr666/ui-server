open Containers
open Components
open Lwt_result
open Common

let ( % ) = Fun.( % )

let cpu_of_yojson =
  Common.Json.(
    Option.of_yojson String.of_yojson)

let boards_of_yojson =
  Common.Json.(
    List.of_yojson @@ Pair.of_yojson Int.of_yojson String.of_yojson)

let dummy_tab = fun () ->
  let div = Widget.create_div () in
  Ui_templates.Placeholder.under_development ()

let get_board_tabs (stream : Stream.ID.t)
      (input : Topology.topo_input)
      (control : int)
      (name : string) =
  match name with
  | "TS" ->
     let open Board_qos_niit_js in
     let log =
       "QoS",
       "qos_log",
       (fun () -> Page_log.make stream control) in
     let services =
       "Сервисы",
       "qos_services",
       (fun () -> Page_services.make stream control) in
     let pids =
       "PIDs",
       "qos_pids",
       (fun () -> Page_pids.make stream control) in
     let tables =
       "SI/PSI",
       "qos_tables",
       (fun () -> Page_tables.make stream control) in
     [services; pids; tables; log]
  | "DVB" ->
     let open Board_dvb_niit_js in
     let measures =
       "RF",
       "rf",
       Widget.coerce % fun () -> Page_stream.make stream control in
     [measures]
  | _ -> []

let get_cpu_tabs (stream : Stream.ID.t)
      (input : Topology.topo_input)
      (name : string option) =
  match name with
  | Some "pipeline" ->
     let open Pipeline_js in
     let log =
       "QoE",
       "qoe_log",
       Widget.coerce % Page_channels.make stream in
     [log]
  | _ -> []

let make_tabs stream input (boards : (int * string) list) cpu =
  let boards_tabs =
    List.flat_map (fun (control, name) ->
        get_board_tabs stream input control name) boards in
  let cpu_tabs = get_cpu_tabs stream input cpu in
  let tabs = boards_tabs @ cpu_tabs in
  List.map (fun (name, hash, f) ->
      new Tab.t ~value:(hash, f) ~content:(Text name) ()) tabs

let () =
  let open Stream in
  let uri = Dom_html.window##.location##.pathname
            |> Js.to_string in
  let fmt = Uri.Path.Format.("input" @/ String ^/ Int ^/ ID.fmt ^/ empty) in
  let (input : Topology.topo_input) =
    Js.Unsafe.global##.input
    |> Js.to_string
    |> Topology.Show_topo_input.of_string in
  let (boards : (int * string) list) =
    Yojson.Safe.from_string @@ Js.to_string
    @@ Js_of_ocaml.Json.output @@ Js.Unsafe.global##.boards
    |> boards_of_yojson
    |> Result.get_exn in
  let (cpu : string option) =
    Yojson.Safe.from_string @@ Js.to_string
    @@ Js_of_ocaml.Json.output @@ Js.Unsafe.global##.cpu
    |> cpu_of_yojson
    |> Result.get_exn in
  let stream_id =
    Uri.Path.Format.scan_unsafe (Uri.Path.of_string uri)
      fmt (fun _ _ c -> c) in
  Application_js.Requests.HTTP.get_stream_source ~stream_id ()
  >>= (fun source ->
    let info = Stream.Source.to_string source.info in
    let w = Widget.create_div () in
    let tabs = make_tabs stream_id input boards cpu in
    let page = new Ui_templates.Page.t (`Dynamic tabs) () in
    let title = page#title ^ " / " ^ info in
    page#set_title title;
    Lwt_result.return ())
  |> Lwt.ignore_result
