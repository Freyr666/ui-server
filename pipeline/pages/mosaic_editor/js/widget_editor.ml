open Js_of_ocaml
open Js_of_ocaml_tyxml
open Pipeline_types
open Components

type event =
  [ `Container of Wm.container
  ]

let ( >>= ) = Lwt.bind

module Attr = struct
  let type_ = "data-type"
end

let widget_type_to_string : Wm.widget_type -> string = function
  | Video -> "video"
  | Audio -> "audio"

let widget_type_of_string : string -> Wm.widget_type option = function
  | "video" -> Some Video
  | "audio" -> Some Audio
  | _ -> None

let compare_pair o_x o_y (x1, y1) (x2, y2) =
  let c = o_x x1 x2 in
  if c = 0
  then o_y y1 y2
  else c

let set_tab_index ?prev
    (items : Dom_html.element Js.t list Lazy.t)
    (item : Dom_html.element Js.t) : unit =
  let set (i : int) (elt : Dom_html.element Js.t) =
    Element.set_attribute elt "tabindex" (string_of_int i) in
  (match prev with
   | Some prev -> if not @@ Element.equal item prev then set (-1) prev
   | None ->
     (* If no list item was selected, set first list item's tabindex to -1.
        Generally, tabindex is set to 0 on first list item of list that has
        no preselected items *)
     match Lazy.force items with
     | first :: _ -> if not @@ Element.equal first item then (set (-1) first)
     | _ -> ());
  set 0 item

module Selector = struct
  let item = Printf.sprintf ".%s" Markup.CSS.grid_item
end

let make_item (id, widget : string * Wm.widget) =
  let item = Resizable.make ~classes:[Markup.CSS.grid_item] () in
  let pos = Utils.Option.get widget.position in
  let width = pos.right - pos.left in
  let height = pos.bottom - pos.top in
  item#root##.id := Js.string id;
  item#set_attribute Position.Attr.width (string_of_int width);
  item#set_attribute Position.Attr.height (string_of_int height);
  item#set_attribute Position.Attr.left (string_of_int pos.left);
  item#set_attribute Position.Attr.top (string_of_int pos.top);
  item#set_attribute Attr.type_ (widget_type_to_string widget.type_);
  (match widget.aspect with
   | None -> ()
   | Some (w, h) ->
     let ar = float_of_int w /. float_of_int h in
     item#set_attribute Position.Attr.aspect_ratio (Printf.sprintf "%g" ar));
  item

class t ?grid_overlay ?(widgets = []) (position : Position.t) elt () =
  object(self)
    inherit Widget.t elt () as super
    val aspect = float_of_int position.w /. float_of_int position.h
    val grid_overlay = Grid_overlay.make 10

    val mutable _widgets : (string * Wm.widget) list = widgets
    val mutable _listeners = []
    val mutable _focused_item = None

    method! init () : unit =
      super#init ();
      super#add_class Card.CSS.root;
      super#append_child grid_overlay

    method! initial_sync_with_dom () : unit =
      let _ = Ui_templates.Resize_observer.observe
          ~f:(fun _ -> self#fit ())
          ~node:super#root
          () in
      _listeners <- Events.(
          [ listen_lwt super#root Resizable.Event.input self#handle_item_drag
          ; listen_lwt super#root Resizable.Event.change self#handle_item_change
          ; listen_lwt super#root Resizable.Event.selected self#handle_item_selected
          ; keydowns super#root self#handle_keydown
          ]);
      super#initial_sync_with_dom ()

    method! destroy () : unit =
      List.iter Lwt.cancel _listeners;
      _listeners <- [];
      super#destroy ()

    method! layout () : unit =
      self#fit ();
      grid_overlay#layout ();
      super#layout ()

    method show_grid (x : bool) : unit =
      grid_overlay#set_show_grid x

    method show_snap_lines (x : bool) : unit =
      grid_overlay#set_show_snap_lines x

    method items : Dom_html.element Js.t list =
      self#items_ ()

    method notify : event -> unit = function
      | `Container x ->
        (* TODO add notification if widget layout is changed
           & we have some unsaved work *)
        (* TODO implement simple update *)
        ()

    method value : Wm.container =
      let position =
        { Wm.
          left = position.x
        ; top = position.y
        ; right = position.x + position.w
        ; bottom = position.y + position.h
        } in
      let widgets =
        List.fold_left (fun acc (item : Dom_html.element Js.t) ->
            let id = (Js.to_string item##.id) in
            match List.assoc_opt id _widgets with
            | None -> acc
            | Some x ->
              let left = Position.get_original_left elt in
              let top = Position.get_original_top elt in
              let right = Position.get_original_width elt in
              let bottom = Position.get_original_height elt in
              let position = Some { Wm. left; top; right; bottom } in
              (id, { x with position }) :: acc)
          [] self#items in
      { Wm. position; widgets }

    method fit () : unit =
      let scale_factor = self#scale_factor in
      let width' = int_of_float @@ float_of_int position.w *. scale_factor in
      let height' = int_of_float @@ float_of_int position.h *. scale_factor in
      super#root##.style##.width := Utils.px_js width';
      super#root##.style##.height := Utils.px_js height';
      List.iter (fun item ->
          let w = float_of_int @@ Position.get_original_width item in
          let h = float_of_int @@ Position.get_original_height item in
          let left = float_of_int @@ Position.get_original_left item in
          let top = float_of_int @@ Position.get_original_top item in
          let new_w, new_h =
            let w' = w *. scale_factor in
            (* XXX maybe use item aspect ratio to calculate new height? *)
            let h' = h *. scale_factor in
            w', h' in
          let new_left = (left *. new_w) /. w in
          let new_top = (top *. new_h) /. h in
          item##.style##.top := Utils.px_js @@ Float.to_int @@ Float.floor new_top;
          item##.style##.left := Utils.px_js @@ Float.to_int @@ Float.floor new_left;
          item##.style##.width := Utils.px_js @@ Float.to_int @@ Float.floor new_w;
          item##.style##.height := Utils.px_js @@ Float.to_int @@ Float.floor new_h)
      @@ self#items_ ()

    (* Private methods *)

    method private handle_keydown e _ =
      Js.Opt.iter Dom_html.document##.activeElement (fun active ->
          let items = self#items_ ~sort:true () in
          match Events.Key.of_event e with
          (* Navigation keys *)
          (* TODO Implement as described in https://www.w3.org/TR/wai-aria-practices/#layoutGrid *)
          | `Arrow_left -> ()
          | `Arrow_right -> ()
          | `Arrow_down -> ()
          | `Arrow_up -> ()
          | `Page_up -> () (* XXX optional *)
          | `Page_down -> () (* XXX optional *)
          | `Home -> ()
          | `End -> ()
          (* Other keys *)
          | `Enter | `Space -> () (* XXX maybe move to the next layer here? *)
          | `Delete ->
            Element.remove_child_safe super#root active;
            (match items with
             | hd :: _ ->
               set_tab_index ~prev:active (Lazy.from_val items) hd;
               _focused_item <- Some hd
             | _ -> ())
          | _ -> ());
      Lwt.return_unit

    method private items_ ?(sort = false) () : Dom_html.element Js.t list =
      let items = Element.query_selector_all super#root Selector.item in
      if sort
      then
        List.sort (fun x y ->
            compare_pair compare compare
              (Position.get_original_left x, Position.get_original_top x)
              (Position.get_original_left y, Position.get_original_top y))
          items
      else items

    method private handle_item_selected e _ =
      let target = Dom_html.eventTarget e in
      target##focus;
      set_tab_index ?prev:_focused_item (Lazy.from_fun self#items_) target;
      _focused_item <- Some target;
      Lwt.async (fun () ->
          Events.blur target
          >>= fun _ -> (* TODO do smth *) Lwt.return_unit);
      Lwt.return_unit

    method private handle_item_drag e _ =
      let target = Dom_html.eventTarget e in
      let position =
        Position.of_client_rect
        @@ Widget.event_detail e in
      let aspect_ratio =
        match Element.get_attribute target Position.Attr.keep_aspect_ratio with
        | Some "true" -> Position.get_original_aspect_ratio target
        | _ -> None in
      let adjusted, lines =
        Resizable.Sig.adjust_position
          ?aspect_ratio
          target
          position
          (self#items_ ())
          (super#root##.offsetWidth, super#root##.offsetHeight) in
      grid_overlay#set_snap_lines lines;
      Position.apply_to_element adjusted target;
      Lwt.return_unit

    method private handle_item_change e _ =
      (* let target = Dom_html.eventTarget e in *)
      grid_overlay#set_snap_lines [];
      (* let { Position. x; y; w; h } =
       *   Position.of_client_rect
       *   @@ Widget.event_detail e in
       * let scale = float_of_int position.w /. float_of_int super#root##.offsetWidth in
       * let w' = int_of_float @@ float_of_int w *. scale in
       * let h' = int_of_float @@ float_of_int h *. scale in
       * let x' = int_of_float @@ float_of_int x *. scale in
       * let y' = int_of_float @@ float_of_int y *. scale in
       * Element.set_attribute target Position.Attr.width (Utils.px w');
       * Element.set_attribute target Position.Attr.height (Utils.px h');
       * Element.set_attribute target Position.Attr.left (Utils.px x');
       * Element.set_attribute target Position.Attr.top (Utils.px y'); *)
      Lwt.return_unit

    method private parent_rect : float * float * float =
      Js.Opt.case (Element.get_parent super#root)
        (fun () -> 0., 0., 1.)
        (fun x ->
           let width = float_of_int x##.offsetWidth in
           let height = float_of_int x##.offsetHeight in
           width, height, width /. height)

    method private scale_factor : float =
      let cur_width, cur_height, cur_aspect = self#parent_rect in
      if cur_aspect > aspect
      then cur_height /. float_of_int position.h
      else cur_width /. float_of_int position.w
  end

let make ({ position; widgets } : Wm.container) =
  let items = List.map make_item widgets in
  let elt =
    Tyxml_js.To_dom.of_element
    @@ Markup.create_grid ~content:(List.map Widget.to_markup items) () in
  let position =
    { Position.
      w = position.right - position.left
    ; h = position.bottom - position.top
    ; x = position.left
    ; y = position.top
    } in
  new t ~widgets position elt ()