open Js_of_ocaml
open Netlib
open Pipeline_http_js

let ( >>=? ) = Lwt_result.bind

let () =
  let open React in
  let (scaffold : Components.Scaffold.t) = Js.Unsafe.global##.scaffold in
  let thread =
    Http_wm.get_layout () >>=? fun wm ->
    Http_structure.get_streams () >>=? fun streams ->
    Http_structure.get_annotated () >>=? fun structures ->
    Api_js.Websocket.JSON.open_socket ~path:(Uri.Path.Format.of_string "ws") ()
    >>=? fun socket ->
    Http_wm.Event.get socket >>=? fun (_, wm_event) ->
    Http_structure.Event.get_annotated socket >>=? fun (_, structures_event) ->
    let streams = List.map snd streams in
    let editor = Container_editor.make ~scaffold streams structures wm in
    let notif =
      E.merge
        (fun _ -> editor#notify)
        ()
        [
          E.map (fun x -> `Layout x) wm_event;
          E.map (fun x -> `Streams x) structures_event;
        ]
    in
    editor#set_on_destroy (fun () ->
        E.stop ~strong:true notif;
        E.stop ~strong:true wm_event;
        E.stop ~strong:true structures_event;
        Api_js.Websocket.close_socket socket);
    Lwt.return_ok editor
  in
  let loader = Components_lab.Loader.make_widget_loader thread in
  Components.Element.add_class loader "wm";
  scaffold#set_body loader
