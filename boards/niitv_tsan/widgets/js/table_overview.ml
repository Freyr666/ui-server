open Js_of_ocaml
open Js_of_ocaml_tyxml
open Components
open Board_niitv_tsan_http_js
include Board_niitv_tsan_widgets_tyxml.Table_overview
module D = Make (Impl.Xml) (Impl.Svg) (Impl.Html)

let ( >>= ) = Lwt.bind

module Attr = struct
  let data_control = "data-control"

  let data_id_mode = "data-id-mode"
end

module Selector = struct
  let title = Printf.sprintf ".%s" CSS.title

  let header = Printf.sprintf ".%s" CSS.header

  let menu_icon = Printf.sprintf ".%s" CSS.menu_icon

  let placeholder = Printf.sprintf ".%s" Components_lab.Placeholder.CSS.root

  let table = Printf.sprintf ".%s" CSS.table

  let menu = Printf.sprintf ".%s" Menu.CSS.root

  let row = Printf.sprintf ".%s" Data_table.CSS.row

  let back_action = Printf.sprintf ".%s" CSS.back_action
end

class virtual ['a] t ?set_hex elt () =
  let hex =
    match Element.get_attribute elt Attr.data_id_mode with
    | Some "dec" -> false
    | Some "hex" -> true
    | _ -> false
  in
  object (self)
    val control : int =
      match Element.get_attribute elt Attr.data_control with
      | None ->
          failwith
            (Printf.sprintf "%s: no `%s` attribute found on root element"
               CSS.root Attr.data_control)
      | Some x -> int_of_string x

    val title = Element.query_selector elt Selector.title

    val header = Element.query_selector_exn elt Selector.header

    val menu : Menu.t option =
      Option.map Menu.attach @@ Element.query_selector elt Selector.menu

    val menu_icon : Icon_button.t option =
      Option.map Icon_button.attach
      @@ Element.query_selector elt Selector.menu_icon

    val placeholder =
      match Element.query_selector elt Selector.placeholder with
      | Some x -> x
      | None -> Tyxml_js.To_dom.of_div @@ D.create_empty_placeholder ()

    val mutable hex = hex

    val mutable listeners = []

    inherit Widget.t elt () as super

    method! init () : unit =
      Option.iter (fun menu -> menu#set_quick_open true) menu;
      super#init ()

    method! initial_sync_with_dom () : unit =
      listeners <-
        ( match (menu, menu_icon) with
        | Some menu, Some menu_icon ->
            Js_of_ocaml_lwt.Lwt_js_events.
              [
                clicks menu_icon#root (fun _ _ -> menu#reveal ());
                Menu.Lwt_js_events.selects menu#root
                  self#handle_menu_selection_change;
              ]
        | _ -> [] )
        @ listeners;
      super#initial_sync_with_dom ()

    method! destroy () : unit =
      Option.iter Widget.destroy menu;
      Option.iter Widget.destroy menu_icon;
      List.iter Lwt.cancel listeners;
      super#destroy ()

    method set_state (state : [ Application_types.Topology.state | `No_sync ]) =
      let no_sync, no_response =
        match state with
        | `Fine -> (false, false)
        | `No_sync -> (true, false)
        | `Detect | `Init | `No_response -> (false, true)
      in
      Element.toggle_class_unit ~force:no_sync super#root CSS.no_sync;
      Element.toggle_class_unit ~force:no_response super#root CSS.no_response
    (** Updates widget state *)

    method title : string =
      match title with
      | None -> ""
      | Some x ->
          Option.fold ~none:"" ~some:Js.to_string
            (Js.Opt.to_option x##.textContent)

    method set_title (s : string) =
      match title with
      | Some x -> x##.textContent := Js.some (Js.string s)
      | None ->
          let title =
            Tyxml_js.To_dom.of_element @@ D.create_title ~title:s ()
          in
          Element.insert_child_at_index header 1 title

    method private reset_bitrate_stats () : unit Lwt.t =
      let (scaffold : Scaffold.t) = Js.Unsafe.global##.scaffold in
      let rec aux () =
        Http_monitoring.reset_bitrate_stats control >>= function
        | Ok () ->
            let snackbar =
              Snackbar.make
                ~label:
                  (`Text
                    "Статистика битрейта сброшена")
                ~dismiss:`True ()
            in
            scaffold#show_snackbar
              ~on_close:(fun _ -> snackbar#destroy ())
              snackbar
        | Error (`Msg msg) ->
            let snackbar =
              Snackbar.make
                ~label:
                  (`Text
                    (Printf.sprintf
                       "Не удалось сбросить \
                        статистику битрейта. %s"
                       msg))
                ~action:(`Text "Повторить") ()
            in
            scaffold#show_snackbar
              ~on_close:(fun reason ->
                (match reason with Action -> Lwt.async aux | _ -> ());
                snackbar#destroy ())
              snackbar
      in
      aux ()

    method private handle_menu_selection_change e _ : unit Lwt.t =
      let detail = Widget.event_detail e in
      if Element.has_class detail##.item CSS.bitrate_reset then
        self#reset_bitrate_stats ()
      else (
        ( match Element.get_attribute detail##.item Attr.data_id_mode with
        | Some "hex" ->
            Option.iter (fun f -> f true) set_hex;
            hex <- true
        | Some "dec" ->
            Option.iter (fun f -> f false) set_hex;
            hex <- false
        | _ -> () );
        Lwt.return_unit )
  end

class virtual ['a] with_details ?set_hex (elt : Dom_html.element Js.t) () =
  object (self)
    val back_action : Icon_button.t =
      Icon_button.attach @@ Element.query_selector_exn elt Selector.back_action

    inherit ['a] t ?set_hex elt () as super

    method! initial_sync_with_dom () : unit =
      listeners <-
        Js_of_ocaml_lwt.Lwt_js_events.(
          [ clicks super#root self#handle_table_body_click ] @ listeners);
      super#initial_sync_with_dom ()

    method! destroy () : unit =
      back_action#destroy ();
      super#destroy ()

    method virtual private handle_row_action
        : Dom_html.tableRowElement Js.t -> unit Lwt.t

    method private handle_table_body_click e _ =
      if super#has_class CSS.with_details then
        let target = Dom.eventTarget e in
        let row =
          Js.Opt.bind (Element.closest target Selector.row) (fun row ->
              Dom_html.CoerceTo.tr row)
        in
        Js.Opt.case row Lwt.return (fun row ->
            super#add_class CSS.details_view;
            self#handle_row_action row >>= fun () ->
            super#remove_class CSS.details_view;
            Lwt.return_unit)
      else Lwt.return_unit
  end
