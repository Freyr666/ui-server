module CSS = struct
  let root = "mdc-scaffold"

  let drawer_frame = BEM.add_element root "drawer-frame"

  let app_content = BEM.add_element root "app-content"

  let drawer_frame_full_height = BEM.add_modifier drawer_frame "full-height"

  let drawer_frame_clipped = BEM.add_modifier drawer_frame "clipped"

  let app_content_inner = BEM.add_modifier app_content "inner"

  let app_content_outer = BEM.add_modifier app_content "outer"
end

module Make
    (Xml : Xml_sigs.T)
    (Svg : Svg_sigs.T with module Xml := Xml)
    (Html : Html_sigs.T with module Xml := Xml and module Svg := Svg) =
struct
  open Xml.W
  open Html
  module CSS = CSS

  let scaffold_app_content
      ?(classes = [])
      ?(a = [])
      ?(inner = false)
      ?(outer = false)
      ?(children = nil ())
      () : 'a elt =
    let classes =
      classes
      |> Utils.cons_if inner CSS.app_content_inner
      |> Utils.cons_if outer CSS.app_content_outer
      |> List.cons CSS.app_content
    in
    div ~a:(a_class (return classes) :: a) children

  let scaffold_drawer_frame
      ?(classes = [])
      ?(a = [])
      ?(full_height = false)
      ?(clipped = false)
      ?(children = nil ())
      () : 'a elt =
    let classes =
      classes
      |> Utils.cons_if full_height CSS.drawer_frame_full_height
      |> Utils.cons_if clipped CSS.drawer_frame_clipped
      |> List.cons CSS.drawer_frame
    in
    div ~a:(a_class (return classes) :: a) children

  let scaffold ?(classes = []) ?(a = []) ?(children = nil ()) () : 'a elt =
    let classes = CSS.root :: classes in
    div ~a:(a_class (return classes) :: a) children
end

module Markup = Make (Tyxml.Xml) (Tyxml.Svg) (Tyxml.Html)
