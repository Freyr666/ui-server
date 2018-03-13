open Containers
open Components
open Requests
open Lwt_result.Infix
open Wm_types
open Wm_components

let get_widgets_bounding_rect (container:Wm.container) =
  let open Wm in
  match container.widgets with
  | [] -> { left=0;right=0;top=0;bottom=0}
  | hd::tl -> List.fold_left (fun acc (_,(x:Wm.widget)) -> let {left;top;bottom;right} = x.position in
                                                           let left   = min acc.left left in
                                                           let top    = min acc.top top in
                                                           let bottom = max acc.bottom bottom in
                                                           let right  = max acc.right right in
                                                           { left;top;right;bottom})
                             (snd hd).position tl

module Container_item : Item with type item = Wm.container = struct

  type item        = Wm.container  [@@deriving yojson,eq]
  type layout_item = string * item
  type t           = item wm_item  [@@deriving yojson,eq]

  let max_layers = 1

  let t_to_layout_item (t:t) = t.name,t.item
  let t_of_layout_item (k,(v:item)) =
    let icon = "crop_16_9" in
    { icon; name = k; unique = false; item = v }
  let position_of_t (t:t) = t.item.position
  let layer_of_t _        = 0
  let size_of_t (_ : t)   = None,None
  let layers_of_t_list _  = [0]
  let update_position (t : t) (p : Wm.position) =
    let op    = t.item.position in
    let nw,nh = p.right - p.left, p.bottom - p.top in
    let ow,oh = op.right - op.left, op.bottom - op.top in
    let item  = if ow <> nw || oh <> nh
                then { t.item with position = p }  (* Size changed *)
                else { t.item with position = p }  (* Size not changed*)
    in
    { t with item }
  let update_layer (t : t) _ = t
  let make_item_name (t : t) (other : t list) =
    Printf.sprintf "%s #%d" t.name (succ @@ List.length other)
  let make_item_properties x _ _ = Item_properties.make_container_props x

end

module Widget_item : Item with type item = Wm.widget = struct

  type item        = Wm.widget     [@@deriving yojson,eq]
  type layout_item = string * item
  type t           = item wm_item  [@@deriving yojson,eq]

  let max_layers = 10

  let t_to_layout_item (t:t) = t.name,t.item
  let t_of_layout_item (k,(v:item)) =
    let icon = match v.type_ with
      | "video" -> "tv"
      | "audio" -> "audiotrack"
      | _       -> "help"
    in
    { icon; name = k; unique = true; item = v }
  let layer_of_t (t:t)   = t.item.layer
  let size_of_t (t:t)    = Option.(Pair.map return return t.item.aspect)
  let layers_of_t_list l = List.fold_left (fun acc x -> if List.mem ~eq:(=) (layer_of_t x) acc
                                                        then acc else layer_of_t x :: acc) [] l
                           |> List.sort compare
                           |> (fun l -> if List.is_empty l then [0] else l)
  let position_of_t (t:t) = t.item.position
  let update_layer (t:t) (layer:int)              = { t with item = { t.item with layer } }
  let update_position (t:t) (p:Wm.position)       = { t with item = { t.item with position = p }}
  let make_item_name (t:t) _                      = t.name
  let make_item_properties (t:t) (other:t list) _ = Item_properties.make_widget_props t other

end

module Cont = Wm_editor.Make(Container_item)
module Widg = Wm_editor.Make(Widget_item)

let pos_absolute_to_relative (pos:Wm.position) (cont_pos:Wm.position) : Wm.position =
  { left   = pos.left - cont_pos.left
  ; right  = pos.right - cont_pos.left
  ; top    = pos.top - cont_pos.top
  ; bottom = pos.bottom - cont_pos.top
  }

let pos_relative_to_absolute (pos:Wm.position) (cont_pos:Wm.position) : Wm.position =
  { left   = pos.left + cont_pos.left
  ; right  = pos.right + cont_pos.left
  ; top    = pos.top + cont_pos.top
  ; bottom = pos.bottom + cont_pos.top
  }

let create_widgets_grid ~(container:      Wm.container wm_item)
                        ~(candidates:     Widget_item.t list React.signal)
                        ~(set_candidates: Widget_item.t list -> unit)
                        ~(s_conf:         Wm_types.editor_config React.signal)
                        ~(on_apply:       (string * Wm.widget) list -> unit)
                        ~(on_cancel:      unit -> unit)
                        () =
  let cont_name  = container.name in
  let cont_pos   = Container_item.position_of_t container in
  let resolution = cont_pos.right - cont_pos.left, cont_pos.bottom - cont_pos.top in
  let init       = List.map Widget_item.t_of_layout_item container.item.widgets in
  let back       = Wm_left_toolbar.make_action { icon = "arrow_back"; name = "Применить и выйти" } in
  let close      = Wm_left_toolbar.make_action { icon = "close"; name = "Отменить и выйти" } in
  let dlg        = new Dialog.t
                       ~actions:[ new Dialog.Action.t ~typ:`Accept ~label:"Отмена" ()
                                ; new Dialog.Action.t ~typ:`Decline ~label:"Ok" ()
                                ]
                       ~title:"Отменить изменения?"
                       ~content:(`Widgets [])
                       ()
  in
  let ()         = dlg#add_class "wm-confirmation-dialog" in
  let title      = Printf.sprintf "%s. Виджеты" cont_name in
  let w = Widg.make ~title ~init ~candidates ~set_candidates ~resolution ~s_conf ~actions:[back;close] () in
  let _ = React.E.map (fun _ -> on_apply w.ig#layout_items) back#e_click in
  let _ = React.E.map (fun _ -> Lwt.Infix.(dlg#show_await >>= (fun res -> (match res with
                                                                           | `Cancel -> on_cancel ()
                                                                           | `Accept -> ());
                                                                          Lwt.return_unit)
                                           |> ignore)) close#e_click
  in
  Dom.appendChild w.ig#root dlg#root;
  w

let switch ~(cont:Cont.t) ~s_state_push ~candidates ~set_candidates ~s_conf () =
  let selected   = React.S.value cont.ig#s_selected |> Option.get_exn in
  let t          = selected#get_value in
  let on_apply w = selected#set_value { t with item = { t.item with widgets = w }}; s_state_push `Container in
  let on_cancel  = fun () -> s_state_push `Container in
  let w = create_widgets_grid ~container:t ~candidates ~set_candidates ~s_conf ~on_apply ~on_cancel () in
  s_state_push (`Widget w)

let serialize ~(cont:Cont.t) ~s_state () : (string * Wm.container) list =
  (match React.S.value s_state with
   | `Container         -> ()
   | `Widget (w:Widg.t) -> Option.iter (fun selected -> let (t:Wm.container wm_item) = selected#get_value in
                                                        let widgets = w.ig#layout_items in
                                                        let t = { t with item = { t.item with widgets }} in
                                                        selected#set_value t)
                                       (React.S.value cont.ig#s_selected));
  List.map (fun (n,(v:Wm.container)) ->
      let widgets = List.map (fun (s,(w:Wm.widget)) ->
                        let position = pos_relative_to_absolute w.position v.position in
                        let nw  = { w with position } in
                        s,nw) v.widgets in
      n,{ v with widgets })
           cont.ig#layout_items

let create ~(init:     Wm.t)
           ~(post:     Wm.t -> unit)
           ~(s_conf:   editor_config React.signal)
           ~(conf_dlg: Dialog.t)
           () =
  (* Convert widgets positions to relative *)
  let conv p = List.map (fun (n,(v:Wm.widget)) -> n,{ v with position = pos_absolute_to_relative v.position p }) in
  let layout = List.map (fun (n,(v:Wm.container)) -> let widgets = conv v.position v.widgets in
                                                     n, { v with widgets })
                        init.layout
  in
  let used_widgets = List.fold_left (fun acc (_,(x:Wm.container)) -> x.widgets @ acc) [] init.layout in
  let free_widgets = List.filter (fun (k,(v:Wm.widget)) ->
                         let eq (k1,v1) (k2,v2) = Wm.equal_widget v1 v2 && String.equal k1 k2 in
                         not @@ List.mem ~eq (k,v) used_widgets)
                                 init.widgets
  in
  let wc = List.map Widget_item.t_of_layout_item free_widgets in
  let s_wc,s_wc_push = React.S.create wc in
  let s_cc,s_cc_push = React.S.create [({ icon   = "crop_16_9"
                                        ; name   = "Контейнер"
                                        ; unique = false
                                        ; item   = { position = {left=0;right=0;top=0;bottom=0}
                                                   ; widgets  = []
                                                   }
                                        } : Container_item.t)
                                      ]
  in
  let resolution           = init.resolution in
  let init                 = List.map Container_item.t_of_layout_item layout in
  let s_state,s_state_push = React.S.create `Container in
  let title                = "Контейнеры" in
  let conf = Wm_left_toolbar.make_action { icon = "settings"; name = "Настройки" } in
  let edit = Wm_left_toolbar.make_action { icon = "edit";     name = "Редактировать" } in
  let save = Wm_left_toolbar.make_action { icon = "save";     name = "Сохранить" } in
  let on_remove = fun (t:Wm.container wm_item) ->
    let ws = List.map Widget_item.t_of_layout_item t.item.widgets in
    List.iter (fun x -> Wm_editor.remove ~eq:Widget_item.equal (React.S.value s_wc) s_wc_push x) ws
  in
  let cont = Cont.make ~title ~init ~candidates:s_cc ~set_candidates:s_cc_push
                       ~resolution ~s_conf ~on_remove ~actions:[edit] ()
  in
  let _ = React.E.map (fun _ -> conf_dlg#show) conf#e_click in
  let _ = React.S.map (fun x -> edit#set_disabled @@ Option.is_none x) cont.ig#s_selected in
  let _ = React.E.map (fun _ -> switch ~s_state_push ~candidates:s_wc ~set_candidates:s_wc_push ~s_conf ~cont ())
                      edit#e_click
  in
  let _ = React.E.map (fun _ -> let layout = serialize ~cont ~s_state () in
                                post { resolution; widgets=[]; layout };
                                let j = Wm.to_yojson {resolution;layout;widgets=[]} in
                                Printf.printf "%s\n" @@ Yojson.Safe.pretty_to_string j)
                      save#e_click
  in
  let lc = new Layout_grid.Cell.t ~widgets:[] () in
  let mc = new Layout_grid.Cell.t ~widgets:[] () in
  let rc = new Layout_grid.Cell.t ~widgets:[] () in
  lc#set_span_desktop 1; lc#set_span_tablet 1; lc#set_span_phone 4;
  mc#set_span_desktop 8; mc#set_span_tablet 7; mc#set_span_phone 4;
  rc#set_span_desktop 3; rc#set_span_tablet 8; rc#set_span_phone 4;
  let add_to_view lt ig rt =
    Utils.rm_children lc#root; Dom.appendChild lc#root lt#root;
    Utils.rm_children mc#root; Dom.appendChild mc#root ig#root;
    Utils.rm_children rc#root; Dom.appendChild rc#root rt#root;
    Dom.appendChild lt#root save#root;
    Dom.appendChild lt#root conf#root;
  in
  let _ = React.S.map (function `Widget (w:Widg.t) -> add_to_view w.lt w.ig w.rt
                              | `Container         -> add_to_view cont.lt cont.ig cont.rt)
                      s_state
  in
  new Layout_grid.t ~cells:[lc;mc;rc] ()

class t () = object(self)
  val mutable sock : WebSockets.webSocket Js.t option = None
  inherit Widget.widget (Dom_html.createDiv Dom_html.document) () as super
  method private on_load =
    Requests.get_wm ()
    >>= (fun wm ->
      let id              = "wm-editor" in
      let config          = { show_grid_lines = true } in
      let conf_dlg,s_conf = Settings_dialog.make config in
      let e_wm,wm_sock    = Requests.get_wm_socket () in
      let post            = (fun w -> Lwt.Infix.(Requests.post_wm w
                                                 >|= (function
                                                      | Ok () -> ()
                                                      | Error e -> print_endline @@ "error post wm" ^ e)
                                                 |> Lwt.ignore_result))
      in
      let _  = React.S.map (fun (s:Wm.t) ->
                   (try Dom.removeChild self#root (Dom_html.getElementById id) with _ -> ());
                   let wm_el = create ~init:s ~post ~s_conf ~conf_dlg () in
                   let ()    = wm_el#set_id id in
                   Dom.appendChild self#root wm_el#root)
                           (React.S.hold wm e_wm)
      in
      let () = Dom.appendChild self#root conf_dlg#root in
      sock <- Some wm_sock;
      Lwt_result.return ())
    |> ignore

  initializer
    self#add_class "wm";
    super#set_on_unload (Some (fun () -> Option.iter (fun x -> x##close; sock <- None) sock));
    super#set_on_load   (Some (fun () -> self#on_load));
end

let page () = new t ()
