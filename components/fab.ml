open Containers
open Tyxml_js

module Markup = Components_markup.Fab.Make(Xml)(Svg)(Html)

class t ?(ripple=true) ?(mini=false) ~icon () =
  let elt  = Markup.create ~icon:(Widget.to_markup icon) () |> Tyxml_js.To_dom.of_button in
  object(self)
    val mutable _ripple = None
    inherit Widget.button_widget elt () as super

    method button_element : Dom_html.buttonElement Js.t = elt

    method mini : bool =
      super#has_class Markup.mini_class
    method set_mini (x:bool) : unit =
      super#add_or_remove_class x Markup.mini_class

    method disabled : bool =
      Js.to_bool self#button_element##.disabled
    method set_disabled (x:bool) : unit =
      self#button_element##.disabled := Js.bool x

    method layout () = super#layout (); Option.iter (fun r -> r##layout ()) _ripple

    (** Private methods **)

    initializer
      icon#add_class Markup.icon_class;
      self#set_mini mini;
      if ripple then _ripple <- Some (Ripple.attach self)
  end
