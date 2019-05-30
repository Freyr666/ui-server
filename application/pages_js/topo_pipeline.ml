open Components
open Lwt_result.Infix
open Application_types

let base_class = "pipeline-settings"

let make_streams (cpu : Topology.topo_cpu) () =
  Application_http_js.get_streams ()
  |> Lwt_result.map_err Api_js.Http.error_to_string
  >>= fun init ->
  let event, set_event = React.E.create () in
  (* Application_http_js.Event.get_streams ~f:(fun _ -> function
   *     | Ok x -> set_event x
   *     | Error _ -> ()) ()
   * >>= fun socket -> *)
  let box = Streams_selector.make ~init ~event cpu () in
  (* box#set_on_destroy (fun () ->
   *     React.E.stop ~strong:true event;
   *     socket##close); *)
  Lwt_result.return box#widget

let make_structure () =
  (Pipeline_http_js.Http_structure.get_streams_with_source ()
   >>= fun init ->
   Pipeline_http_js.Http_structure.get_streams_applied ()
   >>= fun init_applied ->
   Lwt.return_ok (init, init_applied))
  |> Lwt_result.map_err Api_js.Http.error_to_string
  >>= fun (_, _) ->
  let event, set_event = React.E.create () in
  let _, set_event_applied = React.E.create () in
  (* Pipeline_http_js.Http_structure.Event.get_streams_with_source
   *   ~f:(fun _ -> function Ok x -> set_event x | _ -> ()) ()
   * >>= fun socket ->
   * Pipeline_http_js.Http_structure.Event.get_streams_applied
   *   ~f:(fun _ -> function Ok x -> set_event_applied x | _ -> ()) ()
   * >>= fun socket_applied -> *)
  let w = Widget.create_div () in
  (* let w, s, set = Pipeline_js.Ui.Structure.make
   *     ~init ~init_applied ~event ~event_applied () in *)
  let submit = Button.make ~label:"Применить" () in
  let buttons = Card.Actions.make_buttons [submit] in
  let actions = Card.Actions.make [buttons] in
  let box = Box.make ~dir:`Column [w; actions#widget] in
  (* box#set_on_destroy (fun () ->
   *     React.E.stop ~strong:true event;
   *     socket_applied##close;
   *     socket##close); *)
  Lwt_result.return box#widget
(*
let make_settings () =
  Pipeline_api_js.Api_settings.get ()
  |> Lwt_result.map_err Api_js.Http.error_to_string
  >>= fun init ->
  let event, set_event = React.E.create () in
  Pipeline_api_js.Api_settings.Event.get
    ~f:(fun _ -> function Ok x -> set_event x | _ -> ()) ()
  >>= fun socket ->
  let w, s, set = Pipeline_js.Ui.Settings.make ~init ~event () in
  let apply = new Ui_templates.Buttons.Set.t s set () in
  let buttons = new Card.Actions.Buttons.t ~widgets:[apply] () in
  let actions = new Card.Actions.t ~widgets:[buttons] () in
  let box = new Vbox.t ~widgets:[w; actions#widget] () in
  box#set_on_destroy (fun () ->
      React.E.stop ~strong:true event;
      socket##close);
  Lwt_result.return box#widget
 *)
let make (cpu : Topology.topo_cpu) () : (#Widget.t,string) Lwt_result.t =
  let wrap f () = Ui_templates.Loader.create_widget_loader (f ()) in
  let tabs =
    [ (wrap (make_streams cpu)), Tab.make ~label:"Выбор потоков" ()
    ; (wrap (make_structure)), Tab.make ~label:"Выбор PID" ()
    ] in
  let bar, body = Ui_templates.Tabs.create_dynamic tabs in
  let box = Ui_templates.Tabs.wrap bar body in
  body#add_class @@ BEM.add_element base_class "body";
  box#add_class base_class;
  Lwt_result.return box
