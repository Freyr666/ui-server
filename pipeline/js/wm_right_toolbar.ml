open Containers
open Components
open Wm_types

module Make(I : Item) = struct

  module It = Wm_items.Make(I)

  class t ~layers ~selected ~candidates ~set_candidates () =
    let items, sel = It.make ~selected ~candidates ~set_candidates () in
    let layers, layers_grid = Wm_layers.make ~init:layers ~max:I.max_layers in
    let _class = "wm-right-toolbar" in
    object
      inherit Vbox.t ~widgets:[items#widget; layers#widget] () as super
      val mutable _s = None

      method! init () : unit =
        super#init ();
        super#add_class _class;
        let s =
          React.S.map (fun i -> if Option.is_some i then sel `Props)
            selected in
        _s <- Some s

      method! destroy () : unit =
        super#destroy ();
        Option.iter (React.S.stop ~strong:true) _s;
        _s <- None

      method e_layers_action : Wm_layers.action React.event = layers_grid#e_layer
      method initialize_layers = layers_grid#initialize
    end

  let make ~layers ~selected = new t ~layers ~selected ()

end