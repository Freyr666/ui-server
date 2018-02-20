open Containers

module Animation = struct

  module Timing = struct
    let pi = 4.0 *. atan 1.0
    let in_out_sine x =  0.5 *. (1. -. (cos (pi *. x)))
  end

  let animate ~(timing   : float -> float)
              ~(draw     : float -> unit)
              ~(duration : float) =
    let start = Unix.gettimeofday () in

    let rec cb = (fun _ ->

        let time          = Unix.gettimeofday () in
        let time_fraction = Float.min ((time -. start) /. duration) 1. in
        let progress      = timing time_fraction in
        let ()            = draw progress in

        if Float.(time_fraction < 1.)
        then
          let _ = Dom_html.window##requestAnimationFrame (Js.wrap_callback cb) in
          ())
    in

    let _ = Dom_html.window##requestAnimationFrame (Js.wrap_callback cb) in
    ()

end

module Scroll_size_listener = struct

  class t ?on_change () =
    let node = Dom_html.createDiv Dom_html.document in
    let ()   = node##.style##.width    := Js.string "100px" in
    let ()   = node##.style##.height   := Js.string "100px" in
    let ()   = node##.style##.position := Js.string "absolute" in
    let ()   = node##.style##.top      := Js.string "-100000px" in
    let ()   = node##.style##.overflow := Js.string "scroll" in
    let ()   = (Js.Unsafe.coerce node##.style)##.msOverflowStyle := Js.string "scrollbar" in
    let elt  = Dom_html.createDiv Dom_html.document in
    let ()   = Dom.appendChild elt node in

    object(self)

      val mutable listener  = None
      val mutable on_change = on_change
      val mutable height    = 0
      val mutable width     = 0

      inherit Widget.widget elt () as super

      method get_on_change   = on_change
      method set_on_change x = on_change <- x

      method get_height = height
      method get_width  = width
      method measure =
        let prev_h = height in
        let prev_w = width in
        height <- node##.offsetHeight - node##.clientHeight;
        width  <- node##.offsetWidth  - node##.clientWidth;
        if prev_h <> height || prev_w <> width
        then Option.iter (fun f -> f width height) on_change;

      method private listen =
        Dom_events.listen Dom_html.window Dom_events.Typ.resize (fun _ _ -> self#measure; true)

      initializer
        (* TODO maybe remove these listeners? *)
        super#set_on_load   @@ Some (fun () -> self#measure;
                                               Option.iter (fun f -> f width height) on_change;
                                               listener <- Some self#listen);
        super#set_on_unload @@ Some (fun () -> Option.iter (fun l -> Dom_events.stop_listen l) listener;
                                               listener <- None)

    end

end
