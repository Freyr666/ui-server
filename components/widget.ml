open Containers

type rect =
  { top : float
  ; right : float
  ; bottom : float
  ; left : float
  ; width : float option
  ; height : float option
  }

let to_rect (x : Dom_html.clientRect Js.t) =
  { top = x##.top
  ; right = x##.right
  ; bottom = x##.bottom
  ; left = x##.left
  ; width = Js.Optdef.to_option x##.width
  ; height = Js.Optdef.to_option x##.height
  }

module Event = struct

  include Dom_events.Typ

  class type wheelEvent =
    object
      inherit Dom_html.mouseEvent
      method deltaX : int
      method deltaY : int
      method deltaZ : int
      method deltaMode : int
    end

  let wheel : wheelEvent Js.t typ = make "wheel"

end

class t (elt : #Dom_html.element Js.t) () = object(self)

  val mutable _on_destroy = None
  val mutable _on_load = None
  val mutable _on_unload = None
  val mutable _in_dom = false
  val mutable _observer = None
  val mutable _listeners_lwt = []

  val mutable _e_storage : unit React.event list = []
  val mutable _s_storage : unit React.signal list = []

  method root : Dom_html.element Js.t =
    (elt :> Dom_html.element Js.t)

  method node : Dom.node Js.t =
    (elt :> Dom.node Js.t)

  method markup : Tyxml_js.Xml.elt =
    Tyxml_js.Of_dom.of_element self#root
    |> Tyxml_js.Html.toelt

  method widget : t = (self :> t)

  method set_on_destroy f = _on_destroy <- f

  method init () : unit =
    ()

  method destroy () : unit =
    self#set_on_load None;
    self#set_on_unload None;
    List.iter (React.S.stop ~strong:true) _s_storage;
    List.iter (React.E.stop ~strong:true) _e_storage;
    _s_storage <- [];
    _e_storage <- [];
    List.iter (fun x -> try Lwt.cancel x with _ -> ()) _listeners_lwt;
    _listeners_lwt <- [];
    Option.iter (fun f -> f ()) _on_destroy

  method layout () = ()

  method get_child_element_by_class x =
    self#root##querySelector (Js.string ("." ^ x))
    |> Js.Opt.to_option

  method get_child_element_by_id x =
    self#root##querySelector (Js.string ("#" ^ x))
    |> Js.Opt.to_option

  method get_attribute a =
    self#root##getAttribute (Js.string a)
    |> Js.Opt.to_option
    |> Option.map Js.to_string

  method set_attribute a v =
    self#root##setAttribute (Js.string a) (Js.string v)

  method remove_attribute a =
    self#root##removeAttribute (Js.string a)

  method has_attribute a =
    self#root##hasAttribute (Js.string a)
    |> Js.to_bool

  method inner_html =
    Js.to_string self#root##.innerHTML

  method outer_html =
    Js.to_string self#root##.outerHTML

  method set_inner_html s =
    self#root##.innerHTML := Js.string s

  method text_content : string option =
    self#root##.textContent
    |> Js.Opt.to_option
    |> Option.map Js.to_string

  method set_text_content s =
    self#root##.textContent := Js.some @@ Js.string s

  method id : string =
    Js.to_string self#root##.id

  method set_id (id : string) : unit =
    self#root##.id := Js.string id

  method style = self#root##.style

  method class_string =
    Js.to_string @@ self#root##.className

  method classes =
    String.split_on_char ' ' @@ self#class_string

  method add_class _class =
    self#root##.classList##add (Js.string _class)

  method remove_class _class =
    self#root##.classList##remove (Js.string _class)

  method toggle_class _class =
    self#root##.classList##toggle (Js.string _class)
    |> Js.to_bool

  method has_class _class =
    Js.to_bool (self#root##.classList##contains (Js.string _class))

  method find_classes pre =
    List.find_all (String.prefix ~pre) self#classes

  method add_or_remove_class x _class =
    if x then self#add_class _class
    else self#remove_class _class

  method client_left : int =
    self#root##.clientLeft

  method client_top : int =
    self#root##.clientTop

  method client_width : int =
    self#root##.clientWidth

  method client_height : int =
    self#root##.clientHeight

  method offset_left : int =
    self#root##.offsetLeft

  method offset_top : int =
    self#root##.offsetTop

  method offset_width : int =
    self#root##.offsetWidth

  method offset_height : int =
    self#root##.offsetHeight

  method scroll_left : int =
    self#root##.scrollLeft

  method scroll_top : int =
    self#root##.scrollTop

  method scroll_width : int =
    self#root##.scrollWidth

  method scroll_height : int =
    self#root##.scrollHeight

  method set_scroll_left (x : int) : unit =
    self#root##.scrollLeft := x

  method set_scroll_top (x : int) : unit =
    self#root##.scrollTop := x

  method set_scroll_width (x : int) : unit =
    self#root##.scrollWidth := x

  method set_scroll_height (x : int) : unit =
    self#root##.scrollHeight := x

  method append_child : 'a. (< node : Dom.node Js.t;
                             layout : unit -> unit;
                             .. > as 'a) -> unit =
    fun x ->
    Dom.appendChild self#root x#node;
    x#layout ()

  method insert_child_at_idx : 'a. int ->
                               (< node : Dom.node Js.t; .. > as 'a) -> unit =
    fun index x ->
    let child = self#root##.childNodes##item index in
    Dom.insertBefore self#root x#node child

  method remove_child : 'a. (< node : Dom.node Js.t; .. > as 'a) -> unit =
    fun x ->
    try Dom.removeChild self#root x#node
    with _ -> ()

  method listen : 'a. (#Dom_html.event as 'a) Js.t Event.typ ->
                  (Dom_html.element Js.t -> 'a Js.t -> bool) ->
                  Dom_events.listener =
    Dom_events.listen self#root

  method listen_once_lwt : 'a. ?use_capture:bool ->
                           (#Dom_html.event as 'a) Js.t Event.typ ->
                           'a Js.t Lwt.t =
    fun ?use_capture x ->
    Lwt_js_events.make_event x ?use_capture self#root

  method listen_lwt : 'a. ?store:bool ->
                      ?cancel_handler:bool ->
                      ?use_capture:bool ->
                      (#Dom_html.event as 'a) Js.t Event.typ ->
                      ('a Js.t -> unit Lwt.t -> unit Lwt.t) ->
                      unit Lwt.t =
    fun ?(store = false) ?cancel_handler ?use_capture x f ->
    let (t : unit Lwt.t) =
      Lwt_js_events.seq_loop (Lwt_js_events.make_event x)
        ?cancel_handler ?use_capture self#root f in
    if store then _listeners_lwt <- t :: _listeners_lwt;
    t

  method listen_click_lwt
         : ?store:bool ->
           ?cancel_handler:bool ->
           ?use_capture:bool ->
           (Dom_html.mouseEvent Js.t -> unit Lwt.t -> unit Lwt.t) ->
           unit Lwt.t =
    fun ?(store = false) ?cancel_handler ?use_capture f ->
    let t = self#listen_lwt ?cancel_handler ?use_capture Event.click f in
    if store then _listeners_lwt <- t :: _listeners_lwt;
    t

  method set_empty () =
    Dom.list_of_nodeList @@ self#root##.childNodes
    |> List.iter (fun x -> Dom.removeChild self#root x)

  method bounding_client_rect =
    (self#root##getBoundingClientRect)
    |> (fun x ->
      { top = x##.top
      ; right = x##.right
      ; bottom = x##.bottom
      ; left = x##.left
      ; width = Js.Optdef.to_option x##.width
      ; height = Js.Optdef.to_option x##.height })

  method set_on_load (f : (unit -> unit) option) =
    _on_load <- f;
    self#_observe_if_needed

  method set_on_unload (f : (unit -> unit) option) =
    _on_unload <- f;
    self#_observe_if_needed

  method emit ?(should_bubble = false)
           (evt_type : string)
           (evt_data : Js.Unsafe.any) : unit =
    let custom : (Js.js_string Js.t -> 'b Js.t -> 'c Js.t) Js.constr =
      Js.Unsafe.global##.CustomEvent in
    let evt = match Js.to_string
                    @@ Js.typeof (Js.Unsafe.global##.CustomEvent) with
      | "function" ->
         let obj =
           object%js
             val detail = evt_data
             val bubbles = should_bubble
           end in
         new%js custom (Js.string evt_type) obj
      | _ ->
         let doc = Js.Unsafe.coerce Dom_html.document in
         let evt = doc##createEvent (Js.string "CustomEvent") in
         evt##initCustomEvent (Js.string evt_type)
           (Js.bool should_bubble)
           Js._false
           evt_data in
    (Js.Unsafe.coerce self#root)##dispatchEvent evt

  (* Private methods *)

  method private _keep_s : 'a. 'a React.signal -> unit = fun s ->
    _s_storage <- React.S.map ignore s :: _s_storage

  method private _keep_e : 'a. 'a React.event -> unit  = fun e ->
    _e_storage <- React.E.map ignore e :: _e_storage

  method private _observe_if_needed =
    let init () =
      MutationObserver.observe
        ~node:Dom_html.document
        ~f:(fun _ _ ->
          let in_dom_new =
            (Js.Unsafe.coerce Dom_html.document)##contains self#root in
          if _in_dom && (not in_dom_new)
          then CCOpt.iter (fun f -> f ()) _on_unload
          else if (not _in_dom) && in_dom_new
          then CCOpt.iter (fun f -> f ()) _on_load;
          _in_dom <- in_dom_new)
        ~child_list:true
        ~subtree:true
        ()
    in
    match _on_load, _on_unload, _observer with
    | None, None, Some o -> o##disconnect; _observer <- None
    | _, _, None -> _observer <- Some (init ())
    | _ -> ()

  initializer
    self#init ()

end

class button_widget ?on_click elt () =
object(self)
  val mutable _listener = None
  inherit t elt ()

  initializer
    match on_click with
    | None -> ()
    | Some f -> self#listen_lwt Event.click (fun e _ -> f e)
                |> fun l -> _listener <- Some l
end

class input_widget ~(input_elt : Dom_html.inputElement Js.t) elt () =
  let s_disabled, s_disabled_push = React.S.create false in
  object

    inherit t elt ()

    method disabled =
      Js.to_bool input_elt##.disabled
    method set_disabled x =
      input_elt##.disabled := Js.bool x;
      s_disabled_push x

    method input_id = match Js.to_string input_elt##.id with
      | "" -> None
      | s  -> Some s
    method set_input_id x =
      input_elt##.id := Js.string x

    method s_disabled = s_disabled

    method input_element = input_elt

    (* Private methods *)

    method private _set_value x = input_elt##.value := Js.string x
    method private _value = Js.to_string input_elt##.value

  end

class radio_or_cb_widget ?on_change ?state ~input_elt elt () =
  let () = match state with
    | Some true ->
       input_elt##.checked := Js.bool true
    | Some false | None -> () in
  let s_state, s_state_push =
    React.S.create ~eq:Equal.bool @@ Option.get_or ~default:false state in
  object(self)

    val _on_change : (bool -> unit) option = on_change

    inherit input_widget ~input_elt elt ()

    method set_checked (x : bool) : unit =
      input_elt##.checked := Js.bool x;
      Option.iter (fun f -> f x) _on_change;
      s_state_push x

    method checked : bool =
      Js.to_bool input_elt##.checked

    method toggle () : unit =
      self#set_checked @@ not self#checked

    method s_state = s_state

    initializer
      Dom_events.listen input_elt Event.change (fun _ _ ->
          Option.iter (fun f -> f self#checked) _on_change;
          s_state_push self#checked; false) |> ignore;

  end

let equal (x : (#t as 'a)) (y : 'a) =
  Equal.physical x#root y#root

let coerce (x : #t) = (x :> t)

let to_markup (x : #t) = Tyxml_js.Of_dom.of_element x#root

open Dom_html

let create x = new t x ()

let create_div ?(widgets = []) () =
  let div = create @@ createDiv document in
  List.iter div#append_child widgets;
  div

let create_span ?(widgets = []) () =
  let span = create @@ createSpan document in
  List.iter span#append_child widgets;
  span
