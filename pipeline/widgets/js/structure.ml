open Js_of_ocaml
open Js_of_ocaml_tyxml
open Components
open Application_types
open Pipeline_types

type selected = (Stream.ID.t * (int * int list) list) list

module CSS = struct
  let root = "pipeline-structure"

  let checkbox_spacer = BEM.add_element root "checkbox-spacer"
end

module Attr = struct
  let aria_checked = "aria-checked"
end

(* TODO rewrite *)
let get_checked ?(filter_empty = false) children =
  let children =
    if filter_empty then
      let child_wrapper_selector =
        Printf.sprintf ".%s" Treeview.CSS.node_children
      in
      List.filter
        (fun x ->
          let child_wrapper =
            Element.query_selector
              (Tyxml_js.To_dom.of_element x)
              child_wrapper_selector
          in
          match child_wrapper with
          | None -> false
          | Some x -> (
              match Element.children x with [] -> false | _ -> true ))
        children
    else children
  in
  let checked =
    match children with
    | [] -> false
    | children ->
        List.for_all
          (fun x ->
            let aria_checked =
              Element.get_attribute
                (Tyxml_js.To_dom.of_element x)
                Attr.aria_checked
            in
            match aria_checked with Some "true" -> true | _ -> false)
          children
  in
  let indeterminate =
    (not checked)
    && Option.is_some
       @@ List.find_opt
            (fun x ->
              let aria_checked =
                Element.get_attribute
                  (Tyxml_js.To_dom.of_element x)
                  Attr.aria_checked
              in
              match aria_checked with
              | Some "mixed" | Some "true" -> true
              | _ -> false)
            children
  in
  (checked, indeterminate)

let contains pattern value =
  let len = String.length value in
  if len > String.length pattern then false
  else
    let sub = String.sub pattern 0 len in
    String.uppercase_ascii sub = String.uppercase_ascii value

let make_checkbox_spacer () =
  Tyxml_js.Html.(
    span ~a:[ a_class [ Item_list.CSS.item_graphic; CSS.checkbox_spacer ] ] [])

let make_pid ((state : Structure.Annotated.state), (pid : Structure.pid)) =
  let text =
    Printf.sprintf "PID %d (0x%04X), %s" pid.pid pid.pid pid.stream_type_name
  in
  (* FIXME we should match by pid type, but it is not working at the moment *)
  let checked, graphic =
    if
      contains pid.stream_type_name "video"
      || contains pid.stream_type_name "audio"
    then
      let checked =
        match state with
        | `Stored | `Active_and_stored -> true
        | `Avail -> false
      in
      (* FIXME do not instantiate checkbox js object *)
      ( Some checked,
        (Checkbox.make ~classes:[ Item_list.CSS.item_graphic ] ~checked ())
          #markup )
    else (None, make_checkbox_spacer ())
  in
  Treeview.D.treeview_node ~value:(string_of_int pid.pid) ~graphic ?checked
    ~primary_text:(`Text text) ()

let make_channel
    ((_state : Structure.Annotated.state), (ch : Structure.Annotated.channel)) =
  let service_name =
    match ch.service_name with
    | "" -> Printf.sprintf "Программа %d" ch.number
    | s -> s
  in
  let text =
    match ch.provider_name with
    | "" -> service_name
    | s -> Printf.sprintf "%s (%s)" service_name s
  in
  let child_nodes = List.map make_pid ch.pids in
  let checked, indeterminate = get_checked child_nodes in
  let graphic =
    match ch.pids with
    | [] -> make_checkbox_spacer ()
    | _ ->
        (* FIXME do not instantiate checkbox js object*)
        (Checkbox.make
           ~classes:[ Item_list.CSS.item_graphic ]
           ~checked ~indeterminate ())
          #markup
  in
  Treeview.D.treeview_node ~value:(string_of_int ch.number) ~graphic ~checked
    ~indeterminate ~child_nodes ~primary_text:(`Text text) ()

let make_stream (get_label : Stream.ID.t -> string)
    ( (_state : Structure.Annotated.state),
      ({ id; channels; _ } : Structure.Annotated.structure) ) =
  (* FIXME stream name *)
  let text = get_label id in
  let compare (_, (a : Structure.Annotated.channel as 'a)) (_, (b : 'a)) =
    compare a.number b.number
  in
  let child_nodes = List.map make_channel @@ List.sort compare channels in
  let checked, indeterminate = get_checked ~filter_empty:true child_nodes in
  (* FIXME do not instantiate checkbox js object*)
  let checkbox =
    Checkbox.make
      ~classes:[ Item_list.CSS.item_graphic ]
      ~checked ~indeterminate ()
  in
  Treeview.D.treeview_node ~value:(Stream.ID.to_string id)
    ~graphic:checkbox#markup ~checked ~indeterminate ~child_nodes
    ~primary_text:(`Text text) ()

let make_treeview get_label (structure : Structure.Annotated.t) =
  let children = List.map (make_stream get_label) structure in
  Treeview.make ~dense:true ~children ()

type event = [ `Structure of Structure.Annotated.t ]

module Streams = Map.Make (Stream.ID)
module Channels = Map.Make (Int)

let merge acc ((stream : Stream.ID.t), (chan : int), (pid : int)) =
  Streams.update stream
    (function
      | None ->
          let empty = Channels.empty in
          Some (Channels.add chan [ pid ] empty)
      | Some x ->
          Some
            (Channels.update chan
               (function None -> Some [ pid ] | Some x -> Some (pid :: x))
               x))
    acc

let merge_with_structures (structures : Structure.Annotated.t)
    (selected : int list Channels.t Streams.t) : Structure.t list =
  let open Structure.Annotated in
  List.filter_map
    (fun (id, channels) ->
      match
        List.find_opt
          (fun (_, (s : structure)) -> Stream.ID.equal id s.id)
          structures
      with
      | None -> None
      | Some (_, (x : structure)) -> (
          let channels =
            List.filter_map (fun (chan, pids) ->
                match
                  List.find_opt
                    (fun (_, (ch : channel)) -> ch.number = chan)
                    x.channels
                with
                | None -> None
                | Some (_, (ch : channel)) -> (
                    match
                      List.filter_map
                        (fun (_, (pid : Structure.pid)) ->
                          if List.mem pid.pid pids then Some pid else None)
                        ch.pids
                    with
                    | [] -> None
                    | pids ->
                        Some
                          {
                            Structure.number = ch.number;
                            provider_name = ch.provider_name;
                            service_name = ch.service_name;
                            pids;
                          } ))
            @@ Channels.bindings channels
          in
          match channels with
          | [] -> None
          | channels -> Some { Structure.id = x.id; uri = x.uri; channels } ))
    (Streams.bindings selected)

let merge_trees ~(old : Treeview.t) ~(cur : Treeview.t) =
  let active = Dom_html.document##.activeElement in
  let try_focus ~old ~cur =
    Js.Opt.to_option
    @@ Js.Opt.bind active (fun active ->
           if Element.equal old active then Js.some cur else Js.null)
  in
  let rec merge acc old_nodes cur_nodes =
    List.fold_left
      (fun acc x ->
        match cur#node_value x with
        | None -> acc
        | Some v -> (
            match
              List.find_opt
                (fun x ->
                  match old#node_value x with
                  | None -> false
                  | Some v' -> String.equal v v')
                old_nodes
            with
            | None -> acc
            | Some node ->
                let attr = Treeview.Attr.aria_expanded in
                ( match Element.get_attribute node attr with
                | None -> ()
                | Some a -> Element.set_attribute x attr a );
                let acc =
                  match try_focus ~old:node ~cur:x with
                  | None -> acc
                  | Some _ as x -> x
                in
                merge acc (old#node_children node) (cur#node_children x) ))
      acc cur_nodes
  in
  merge None old#root_nodes cur#root_nodes

(*
 * TODO
 * Add Streams update notification via notify
 *)
class t (streams : Stream.t list) (structure : Structure.Annotated.t) () =
  let submit = Button.make ~label:"Применить" () in
  let buttons = Card.D.card_action_buttons ~children:[ submit#markup ] () in
  let actions = Card.D.card_actions ~children:[ buttons ] () in
  let get_stream_label id =
    match List.find_opt (fun (s : Stream.t) -> s.id = id) streams with
    | None -> Stream.ID.to_string id
    | Some s -> Stream.Source.to_string s.source.info
  in
  object (self)
    val placeholder =
      Components_lab.Placeholder.make
        ~icon:Icon.SVG.(D.icon ~d:Path.information ())
        ~text:(`Text "Потоки не обнаружены") ()

    val mutable _treeview = make_treeview get_stream_label structure

    val mutable _structure : Structure.Annotated.t = structure

    val mutable _on_submit = None

    inherit Widget.t Dom_html.(createDiv document) () as super

    method! init () : unit =
      super#init ();
      super#add_class CSS.root;
      super#add_class Box.CSS.root;
      super#add_class Box.CSS.vertical;
      if _treeview#is_empty then super#append_child placeholder
      else super#append_child _treeview;
      Dom.appendChild super#root
        (Js_of_ocaml_tyxml.Tyxml_js.To_dom.of_element actions);
      _on_submit <-
        Some
          (Js_of_ocaml_lwt.Lwt_js_events.clicks submit#root (fun _ _ ->
               Lwt.map ignore @@ self#submit ()))

    method! destroy () : unit =
      super#destroy ();
      submit#destroy ();
      placeholder#destroy ();
      Option.iter Lwt.cancel _on_submit;
      _on_submit <- None

    method submit () =
      let req = Pipeline_http_js.Http_structure.apply_structures self#value in
      submit#set_loading_lwt req;
      req

    method value : Structure.Many.t =
      let selected = _treeview#selected_leafs in
      print_endline @@ Printf.sprintf "selected: %d" @@ List.length selected;
      merge_with_structures _structure
      @@ List.fold_left
           (fun acc node ->
             let ( >>= ) x f = match x with None -> None | Some x -> f x in
             let value =
               _treeview#node_value node >>= int_of_string_opt >>= fun pid ->
               Js.Opt.to_option @@ _treeview#node_parent node
               >>= fun channel' ->
               _treeview#node_value channel' >>= int_of_string_opt
               >>= fun channel ->
               Js.Opt.to_option @@ _treeview#node_parent channel'
               >>= _treeview#node_value
               >>= Stream.ID.of_string_opt
               >>= fun stream -> Some (stream, channel, pid)
             in
             match value with None -> acc | Some v -> merge acc v)
           Streams.empty selected

    method notify : event -> unit =
      function
      | `Structure x ->
          _structure <- x;
          let old = _treeview in
          let cur = make_treeview get_stream_label x in
          let focus_target = merge_trees ~old ~cur in
          super#remove_child old;
          old#destroy ();
          if cur#is_empty then self#append_treeview placeholder
          else (
            self#append_treeview cur;
            super#remove_child placeholder );
          Option.iter (fun x -> x##focus) focus_target;
          _treeview <- cur

    method private append_treeview : 'a. (#Widget.t as 'a) -> unit =
      super#insert_child_at_idx 0
  end

let make (streams : Stream.t list) (structure : Structure.Annotated.t) () =
  new t streams structure ()
