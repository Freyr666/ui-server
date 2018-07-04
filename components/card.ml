open Containers
open Widget
open Tyxml_js

module Markup = Components_markup.Card.Make(Xml)(Svg)(Html)

(* Sections *)

module Actions = struct

  module Buttons = struct

    class t ~(widgets:#Widget.widget list) () =
      let children = List.map (fun x -> Widget.widget_to_markup x#widget) widgets in
      let elt = Markup.Actions.Buttons.create ~children () |> Tyxml_js.To_dom.of_element in
      object
        inherit Widget.widget elt ()

        initializer
          List.iter (fun x -> x#add_class Markup.Actions.action_class;
                              x#add_class Markup.Actions.action_button_class)
                    widgets

      end

  end

  module Icons = struct

    class t ~(widgets:#Widget.widget list) () =
      let children = List.map (fun x -> Widget.widget_to_markup x#widget) widgets in
      let elt = Markup.Actions.Icons.create ~children () |> Tyxml_js.To_dom.of_element in
      object
        inherit Widget.widget elt ()

        initializer
          List.iter (fun x -> x#add_class Markup.Actions.action_class;
                              x#add_class Markup.Actions.action_icon_class)
                    widgets

      end

  end

  class t ~(widgets:#widget list) () =
    let elt = Markup.Actions.create ~children:(widgets_to_markup widgets) ()
              |> To_dom.of_section in
    object
      val mutable widgets : widget list = List.map (fun x -> (x :> Widget.widget)) widgets
      inherit widget elt () as super
      method widgets = widgets

    end

end

module Primary = struct

  class title ?large text () =
    let elt = Markup.Primary.create_title ?large ~title:text ()
              |> Tyxml_js.To_dom.of_element in
    object
      inherit Widget.widget elt ()
    end

  class subtitle text () =
    let elt = Markup.Primary.create_subtitle ~subtitle:text ()
              |> Tyxml_js.To_dom.of_element in
    object
      inherit Widget.widget elt ()
    end

  class t ~(widgets:#Widget.widget list) () =
    let elt = Markup.Primary.create ~children:(List.map Widget.widget_to_markup widgets) ()
              |> Tyxml_js.To_dom.of_element in
    object
      inherit Widget.widget elt ()
    end

end

module Media = struct

  class t ~(widgets:#widget list) () =
    let elt = Markup.Media.create ~children:(widgets_to_markup widgets) ()
              |> To_dom.of_section in
    object
      val mutable widgets : widget list = List.map (fun x -> (x :> Widget.widget)) widgets
      inherit Widget.widget elt ()
      method widgets = widgets
    end

end

class t ?(form=false) ~(widgets:#Widget.widget list) () =
  let tag = if form then Some Tyxml_js.Html.form else None in
  let elt = Markup.create ?tag ~sections:(List.map Widget.widget_to_markup widgets) ()
            |> Tyxml_js.To_dom.of_element in

  object
    inherit widget elt ()
  end
