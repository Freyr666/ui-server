open Containers
open Components
open Requests
open Lwt_result.Infix
open Wm_types
open Wm_components

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
  let to_grid_item (t:t) (pos:Dynamic_grid.Position.t) =
    let widget = Item_info.make_container_info t in
    Dynamic_grid.Item.to_item ~value:t ~widget ~pos ()
  let position_of_t (t:t) = t.item.position
  let layer_of_t _        = 0
  let size_of_t (_ : t)   = None,None
  let layers_of_t_list _  = [0]
  let update_position (t : t) (p : Wm.position) =
    let op    = t.item.position in
    let nw,nh = p.right - p.left, p.bottom - p.top in
    let ow,oh = op.right - op.left, op.bottom - op.top in
    let item  = match ow <> nw || oh <> nh && not (List.is_empty t.item.widgets) with
      | true  ->
         (* size changed *)
         let rect  = Utils.to_grid_position @@ get_widgets_bounding_rect t.item in
         let np    = Utils.resolution_to_aspect (rect.w,rect.h)
                    |> Dynamic_grid.Position.correct_aspect (Utils.to_grid_position p)
         in
         Printf.printf "np: %s\n" (Wm.position_to_yojson p
                                   |> Yojson.Safe.pretty_to_string);
         Printf.printf "rp: %s\n" (Utils.of_grid_position rect
                                   |> Wm.position_to_yojson |> Yojson.Safe.pretty_to_string);
         Printf.printf "cp: %s\n" (Utils.of_grid_position np
                                   |> Wm.position_to_yojson
                                   |> Yojson.Safe.pretty_to_string);
         let centered = Utils.center ~parent:p ~pos:(Utils.of_grid_position np) () in
         let dx       = centered.left - p.left in
         let dy       = centered.top  - p.top in
         let f (w:Wm.widget) : Wm.widget =
           let pos    = w.position in
           print_endline "";
           Printf.printf "widget pos: %s\n" (Wm.position_to_yojson pos |> Yojson.Safe.pretty_to_string);
           let ax,ay  = Utils.resolution_to_aspect (pos.right - pos.left,pos.bottom - pos.top) in
           let width  = ((pos.right - pos.left) * np.w) / rect.w in
           let height = (width * ay) / ax in
           let width,height = Dynamic_grid.Position.correct_aspect {x=0;y=0;w=width;h=height} (ax,ay)
                              |> (fun (x:Dynamic_grid.Position.t) -> x.w,x.h) in
           let left   = (((pos.left - rect.x) * np.w) / rect.w) + dx in
           let top    = (((pos.top - rect.y) * np.h) / rect.h) + dy in
           Printf.printf "mod left: %d, mod top: %d\n"
                         (((pos.left - rect.x) * np.w) mod rect.w)
                         (((pos.top - rect.y) * np.h) mod rect.h);
           let (pos:Wm.position) = { left
                                   ; right  = left + width
                                   ; top
                                   ; bottom = top + height
                                   }
           in
           { w with position = pos }
         in
         let w    = List.map (fun (s,w) -> s,f w) t.item.widgets in
         print_endline "";
         { t.item with position = p; widgets = w }
      | false -> { t.item with position = p }
    in
    { t with item }
  let update_layer (t : t) _ = t
  let make_item_name (t : t) (other : t list) =
    let rec aux idx other =
      let name = Printf.sprintf "%s #%d" t.name idx in
      match List.partition (fun (x:t) -> String.equal x.name name) other with
      | [],_    -> name
      | _,other -> aux (succ idx) other
    in
    aux 1 other
  let make_item_properties t _ _ = Item_properties.make_container_props t

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
  let to_grid_item (t:t) (pos:Dynamic_grid.Position.t) =
    let widget = Item_info.make_widget_info t in
    Dynamic_grid.Item.to_item ~keep_ar:true ~widget ~value:t ~pos ()
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
  let make_item_properties (t:t React.signal) _ _ = Item_properties.make_widget_props t

end

module Cont = Wm_editor.Make(Container_item)
module Widg = Wm_editor.Make(Widget_item)

let create_widgets_grid ~(container:      Wm.container wm_item)
                        ~(candidates:     Widget_item.t list React.signal)
                        ~(set_candidates: Widget_item.t list -> unit)
                        ~(on_apply:       (string * Wm.widget) list -> unit)
                        ~(on_cancel:      unit -> unit)
                        () =
  let init_cand  = React.S.value candidates in
  let cont_name  = container.name in
  let cont_pos   = Container_item.position_of_t container in
  let resolution = cont_pos.right - cont_pos.left, cont_pos.bottom - cont_pos.top in
  let init       = List.map Widget_item.t_of_layout_item container.item.widgets in
  let apply      = Wm_left_toolbar.make_action { icon = "check"; name = "Применить" } in
  let back       = Wm_left_toolbar.make_action { icon = "arrow_back"; name = "Назад" } in
  let dlg        = new Dialog.t
                       ~actions:[ new Dialog.Action.t ~typ:`Decline ~label:"Отмена" ()
                                ; new Dialog.Action.t ~typ:`Accept ~label:"Ok" ()
                                ]
                       ~title:"Сохранить изменения?"
                       ~content:(`Widgets [])
                       ()
  in
  let ()         = dlg#add_class "wm-confirmation-dialog" in
  let title      = Printf.sprintf "%s. Виджеты" cont_name in
  let w = Widg.make ~title ~init ~candidates ~set_candidates ~resolution ~actions:[back;apply] () in
  let _ = React.E.map (fun _ -> on_apply w.ig#layout_items) apply#e_click in
  let _ = React.E.map (fun _ ->
              (* print_endline "init\n";
               * List.iter (fun x -> Widget_item.to_yojson x
               *                     |> Yojson.Safe.pretty_to_string
               *                     |> print_endline) init;
               * print_endline "changed\n";
               * List.iter (fun x -> Widget_item.to_yojson x
               *                     |> Yojson.Safe.pretty_to_string
               *                     |> print_endline) w.ig#items; *)
              let added   = List.filter (fun x -> not @@ List.mem ~eq:Widget_item.equal x init) w.ig#items in
              let removed = List.filter (fun x -> not @@ List.mem ~eq:Widget_item.equal x w.ig#items) init in
              match added,removed with
              | [],[] -> on_cancel ()
              | _ -> let open Lwt.Infix in
                     dlg#show_await
                     >>= (fun res -> (match res with
                                      | `Accept -> on_apply w.ig#layout_items
                                      | `Cancel -> set_candidates init_cand; on_cancel ());
                                     Lwt.return_unit)
                     |> ignore) back#e_click
  in
  Dom.appendChild w.ig#root dlg#root;
  w

let switch ~grid ~(selected:Container_item.t Dynamic_grid.Item.t) ~s_state_push ~candidates ~set_candidates () =
  let t          = selected#get_value in
  let on_apply widgets =
    selected#set_value { t with item = { t.item with widgets }};
    (* determine min width and height of the container *)
    let rect       = get_widgets_bounding_rect selected#get_value.item in
    let resolution = rect.right - rect.left, rect.bottom - rect.top in
    let positions  = List.map (fun (_,(x:Wm.widget)) : Wm.position ->
                                                       let pos    = x.position in
                                                       let w      = pos.right - pos.left in
                                                       let h      = pos.bottom - pos.top in
                                                       let left   = pos.left - rect.left in
                                                       let right  = left + w in
                                                       let top    = pos.top - rect.top in
                                                       let bottom = top + h in
                                                       { left;top;right;bottom}) widgets in
    (* this is min size of container now *)
    let w,h = Utils.get_grids ~resolution ~positions () |> List.hd in
    let cols,rows = React.S.value grid#s_grid in
    let cw,rh     = fst grid#resolution / cols, snd grid#resolution / rows in
    let div       = fun x y -> let res = x mod y in
                               let div = x / y in
                               if res > 0 then div + 1 else if res < 0 then div - 1 else div
    in
    (match widgets with
     | [] -> selected#set_min_w None;
             selected#set_min_h None
     | _  -> let min_w = div w cw in
             let min_h = div h rh in
             selected#set_min_w @@ Some min_w;
             selected#set_min_h @@ Some min_h);
    s_state_push `Container
  in
  let on_cancel  = fun () -> s_state_push `Container in
  let w = create_widgets_grid ~container:t ~candidates ~set_candidates ~on_apply ~on_cancel () in
  s_state_push (`Widget w)

let serialize ~(cont:Cont.t) () : (string * Wm.container) list =
  List.map (fun (n,(v:Wm.container)) ->
      let widgets = List.map (fun (s,(w:Wm.widget)) ->
                        let position = pos_relative_to_absolute w.position v.position in
                        let nw  = { w with position } in
                        s,nw) v.widgets in
      n,{ v with widgets })
           cont.ig#layout_items

let get_free_widgets containers widgets =
  let used = List.fold_left (fun acc (_,(x:Wm.container)) -> x.widgets @ acc) [] containers in
  List.filter (fun (k,(v:Wm.widget)) ->
      let eq (k1,_) (k2,_) = String.equal k1 k2 in
      not @@ List.mem ~eq (k,v) used)
              widgets

let create ~(init:     Wm.t)
           ~(post:     Wm.t -> unit)
           () =
  (* Convert widgets positions to relative *)
  let conv p = List.map (fun (n,(v:Wm.widget)) -> n,{ v with position = pos_absolute_to_relative v.position p }) in
  let layout = List.map (fun (n,(v:Wm.container)) -> let widgets = conv v.position v.widgets in
                                                     n, { v with widgets })
                        init.layout
  in
  let wc = List.map Widget_item.t_of_layout_item @@ get_free_widgets init.layout init.widgets in
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
  let wz_dlg,wz_e,wz_show  = Wm_wizard.to_dialog init in
  let resolution           = init.resolution in
  let s_state,s_state_push = React.S.create `Container in
  let title                = "Контейнеры" in
  let edit   = Wm_left_toolbar.make_action { icon = "edit"; name = "Редактировать" } in
  let save   = Wm_left_toolbar.make_action { icon = "save"; name = "Сохранить" } in
  let wizard = Wm_left_toolbar.make_action { icon = "brightness_auto"; name = "Авто" } in
  let on_remove = fun (t:Wm.container wm_item) ->
    let ws = List.map Widget_item.t_of_layout_item t.item.widgets in
    List.iter (fun x -> Wm_editor.remove ~eq:Widget_item.equal s_wc s_wc_push x) ws
  in
  let cont = Cont.make ~title ~init:(List.map Container_item.t_of_layout_item layout)
                       ~candidates:s_cc ~set_candidates:s_cc_push
                       ~resolution ~on_remove ~actions:[save;wizard;edit] ()
  in
  let _ = React.E.map (fun _ -> wz_show ()) wizard#e_click in
  let _ = React.S.map (fun x -> edit#set_disabled @@ Option.is_none x) cont.ig#s_selected in
  let _ = React.E.map (fun selected -> switch ~grid:cont.ig
                                              ~s_state_push
                                              ~candidates:s_wc
                                              ~set_candidates:s_wc_push
                                              ~selected
                                              ())
          @@ React.E.select [ cont.ig#e_item_dblclick
                            ; React.E.map (fun _ -> React.S.value cont.ig#s_selected |> Option.get_exn)
                                          edit#e_click
                            ]
  in
  let _ = React.E.map (fun _ -> post { resolution; widgets=[]; layout = serialize ~cont () }) save#e_click in
  let _ = React.E.map (fun l ->
              let layout = List.map (fun (n,(v:Wm.container)) ->
                               let widgets = conv v.position v.widgets in
                               n, { v with widgets }) l
              in
              let layers = Container_item.layers_of_t_list @@ List.map Container_item.t_of_layout_item layout in
              cont.rt#initialize_layers layers;
              s_wc_push @@ List.map Widget_item.t_of_layout_item @@ get_free_widgets layout init.widgets;
              cont.ig#initialize init.resolution @@ List.map Container_item.t_of_layout_item layout) wz_e
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
  in
  let _ = React.S.map (function `Widget (w:Widg.t) -> add_to_view w.lt w.ig w.rt
                              | `Container         -> add_to_view cont.lt cont.ig cont.rt)
                      s_state
  in
  Dom.appendChild cont.ig#root wz_dlg#root;
  let g = new Layout_grid.t ~cells:[lc;mc;rc] () in
  g

class t () = object(self)
  val mutable sock : WebSockets.webSocket Js.t option = None
  inherit Widget.widget (Dom_html.createDiv Dom_html.document) () as super
  method private on_load =
    Requests.get_wm ()
    >>= (fun wm ->
      let id              = "wm-editor" in
      let e_wm,wm_sock    = Requests.get_wm_socket () in
      let post            = (fun w -> Lwt.Infix.(Requests.post_wm w
                                                 >|= (function
                                                      | Ok () -> ()
                                                      | Error e -> print_endline @@ "error post wm" ^ e)
                                                 |> Lwt.ignore_result))
      in
      let _  = React.S.map (fun (s:Wm.t) ->
                   (try Dom.removeChild self#root (Dom_html.getElementById id) with _ -> ());
                   let wm_el = create ~init:s ~post () in
                   let ()    = wm_el#set_id id in
                   Dom.appendChild self#root wm_el#root)
                           (React.S.hold wm e_wm)
      in
      sock <- Some wm_sock;
      Lwt_result.return ())
    |> ignore

  initializer
    self#add_class "wm";
    super#set_on_unload (Some (fun () -> Option.iter (fun x -> x##close; sock <- None) sock));
    super#set_on_load   (Some (fun () -> self#on_load));
end

let page () = new t ()
