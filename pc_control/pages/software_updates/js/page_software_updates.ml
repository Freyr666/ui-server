open Js_of_ocaml
open Js_of_ocaml_tyxml
open Components
open Netlib.Uri
module D =
  Page_software_updates_tyxml.Make (Tyxml_js.Xml) (Tyxml_js.Svg) (Tyxml_js.Html)

let ( >>= ) = Lwt.bind

let ( >>=? ) = Lwt_result.bind

let on_loaded (scaffold : Scaffold.t) () =
  let thread =
    let open Lwt_react in
    Pc_control_http_js.Updates.get_state () >>=? fun state ->
    Api_js.Websocket.JSON.open_socket ~path:(Path.Format.of_string "ws") ()
    >>=? fun socket ->
    Pc_control_http_js.Updates.Event.get_state socket >>=? fun (_, state_ev) ->
    let remote_updates = Remote_update.make () in
    let notify =
      E.merge
        (fun _ _ -> ())
        ()
        [ E.map_s (fun x -> remote_updates#notify (`State x)) state_ev ]
    in
    let page =
      Widget.create
      @@ Js_of_ocaml_tyxml.Tyxml_js.To_dom.of_element
      @@ D.create ~children:[ remote_updates#markup ] ()
    in
    page#set_on_destroy (fun () ->
        remote_updates#destroy ();
        E.stop ~strong:true notify;
        E.stop ~strong:true state_ev;
        Api_js.Websocket.close_socket socket);
    (* Initial setup *)
    remote_updates#notify (`State state) >>= fun () -> Lwt.return_ok page
  in
  let (_ : Dom_html.element Js.t) =
    Components_lab.Loader.make_widget_loader ~elt:scaffold#app_content_inner
      thread
  in
  Lwt.return_unit

let () =
  Lwt.async (fun () ->
      let (scaffold : Scaffold.t) = Js.Unsafe.global##.scaffold in
      scaffold#loaded >>= on_loaded scaffold)
