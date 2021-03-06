open Js_of_ocaml
open Js_of_ocaml_lwt
open Js_of_ocaml_tyxml
open Components
open Pipeline_types
include Page_mosaic_editor_tyxml.List_of_widgets
module D = Make (Tyxml_js.Xml) (Tyxml_js.Svg) (Tyxml_js.Html)

let domain_to_string : Wm.domain -> string = function
  | Wm.Nihil -> "Без группы"
  | Chan { stream; channel } ->
      Printf.sprintf "Поток %s, Канал %d"
        (Application_types.Stream.ID.to_string stream)
        channel

module Selector = struct
  let item = Printf.sprintf ".%s" CSS.item

  let domain _class = function
    | Wm.Nihil ->
        Printf.sprintf ".%s:not([%s]):not([%s])" _class Widget_utils.Attr.stream
          Widget_utils.Attr.channel
    | Chan x ->
        Printf.sprintf ".%s[%s=\"%s\"][%s=\"%s\"]" _class
          Widget_utils.Attr.stream
          (Page_mosaic_editor_tyxml.Widget.stream_attr_value x.stream)
          Widget_utils.Attr.channel
          (Page_mosaic_editor_tyxml.Widget.channel_attr_value x.channel)

  let list = domain Item_list.CSS.root

  let subheader = domain Item_list.CSS.group_subheader
end

let format = "application/json"

let ( % ) f g x = f (g x)

let get f l =
  let rec aux acc = function
    | [] -> (None, l)
    | x :: tl -> if f x then (Some x, List.rev acc @ tl) else aux (x :: acc) tl
  in
  aux [] l

class t (scaffold : Scaffold.t) (elt : Dom_html.element Js.t) =
  object (self)
    inherit Widget.t elt () as super

    val placeholder =
      Components_lab.Placeholder.make
        ~icon:Icon.SVG.(D.icon ~d:Path.information ())
        ~text:(`Text "Нет доступных виджетов") ()

    val mutable listeners = []

    val mutable drag_target = Js.null

    method! init () : unit =
      Dom.appendChild super#root placeholder#root;
      listeners <-
        Lwt_js_events.
          [
            dragstarts super#root self#handle_dragstart;
            dragends super#root self#handle_dragend;
          ];
      super#init ()

    method! initial_sync_with_dom () : unit =
      ( match self#items with
      | [] -> ()
      | _ -> placeholder#add_class CSS.placeholder_hidden );
      super#initial_sync_with_dom ()

    method! destroy () : unit =
      List.iter Lwt.cancel listeners;
      listeners <- [];
      super#destroy ()

    method items : Dom_html.element Js.t list =
      Element.query_selector_all super#root Selector.item

    method remove_item (item : Dom_html.element Js.t) =
      Js.Opt.iter (Element.get_parent item) (fun list ->
          Dom.removeChild list item;
          ( match Element.children list with
          | [] ->
              (* Remove corresponding subheader. *)
              Option.iter (Dom.removeChild super#root)
              @@ Element.query_selector super#root
              @@ Selector.subheader
              @@ Widget_utils.Attr.get_domain list;
              Dom.removeChild super#root list
          | _ -> () );
          self#handle_change ())

    method remove_by_id (id : string) =
      let selector =
        Printf.sprintf ".%s[%s=\"%s\"]" CSS.item Widget_utils.Attr.id id
      in
      match Element.query_selector super#root selector with
      | None -> ()
      | Some x -> self#remove_item x

    method append_item ((id, w) : string * Wm.widget) =
      (* Hide the empty placeholder *)
      placeholder#add_class CSS.placeholder_hidden;
      let elt = Tyxml_js.To_dom.of_element @@ D.create_item ~id w in
      (* TODO insert to DOM according to sorting? *)
      match Element.query_selector super#root (Selector.list w.domain) with
      (* If a list for the corresponding domain already present, just
         append the widget item. *)
      | Some l -> Dom.appendChild l elt
      (* If no corresponding list was found, create one. *)
      | None ->
          let items = [ D.create_item ~id w ] in
          let subheader =
            Tyxml_js.To_dom.of_element
            @@ D.create_subheader w.domain
            @@ domain_to_string w.domain
          in
          let list =
            Tyxml_js.To_dom.of_element @@ D.create_list w.domain items
          in
          Dom.appendChild super#root subheader;
          Dom.appendChild super#root list

    method sync (widgets : (string * Wm.widget) list) =
      let rest =
        List.fold_left
          (fun acc (elt : Dom_html.element Js.t) ->
            let id = Widget_utils.Attr.get_id elt in
            let w, rest = get (String.equal id % fst) acc in
            ( match w with
            | Some (_, w) -> Widget_utils.set_attributes elt w
            | None -> self#remove_item elt );
            rest)
          widgets self#items
      in
      List.iter self#append_item rest

    method private handle_change () : unit =
      let placeholder_hidden = placeholder#has_class CSS.placeholder_hidden in
      match self#items with
      | [] ->
          if placeholder_hidden then
            placeholder#remove_class CSS.placeholder_hidden
      | _ ->
          if not placeholder_hidden then
            placeholder#add_class CSS.placeholder_hidden

    method private handle_dragstart e _ =
      let target = Dom_html.eventTarget e in
      drag_target <- e##.target;
      let to_yojson (id, w) : Yojson.Safe.t =
        `List [ `String id; Wm.widget_to_yojson w ]
      in
      let data =
        Js.string
        @@ Yojson.Safe.to_string
        @@ to_yojson
        @@ Widget_utils.widget_of_element target
      in
      e##.dataTransfer##.effectAllowed := Js.string "move";
      e##.dataTransfer##setData (Js.string format) data;
      target##.style##.opacity := Js.def @@ Js.string "0.5";
      target##.style##.zIndex := Js.string "5";
      match scaffold#side_sheet with
      | None -> Lwt.return_unit
      | Some x -> (
          match scaffold#side_sheet_type with
          | Modal -> x#toggle ~force:false ()
          | Dismissible | Permanent -> Lwt.return_unit )

    method private handle_dragend e _ =
      let target = Dom_html.eventTarget e in
      target##.style##.opacity := Js.def @@ Js.string "";
      target##.style##.zIndex := Js.string "";
      if
        Element.has_class target Item_list.CSS.item
        && not (Js.some target == drag_target)
      then Dom.preventDefault e;
      Lwt.return_unit
  end

module Domains = Map.Make (struct
  type t = Wm.domain

  let compare (a : t) (b : t) =
    match (a, b) with
    | Wm.Nihil, Nihil -> 0
    | Nihil, Chan _ -> -1
    | Chan _, Nihil -> 1
    | Chan x, Chan y ->
        let r = Application_types.Stream.ID.compare x.stream y.stream in
        if r = 0 then compare x.channel y.channel else r
end)

let group_by_domain (widgets : (string * Wm.widget) list) =
  let map = Domains.empty in
  List.fold_left
    (fun acc ((_id, w) as x : string * Wm.widget) ->
      Domains.update w.domain
        (function None -> Some [ x ] | Some l -> Some (x :: l))
        acc)
    map widgets

let make (scaffold : Scaffold.t) (widgets : (string * Wm.widget) list) : t =
  let grouped = group_by_domain widgets in
  let items =
    Domains.map (List.map (fun (id, x) -> D.create_item ~id x)) grouped
  in
  let content =
    List.concat
    @@ List.map (fun (domain, items) ->
           let subheader = domain_to_string domain in
           D.[ create_subheader domain subheader; create_list domain items ])
    @@ Domains.bindings items
  in
  let (elt : Dom_html.element Js.t) =
    Tyxml_js.To_dom.of_element @@ D.create content
  in
  new t scaffold elt
