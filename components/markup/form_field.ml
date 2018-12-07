open Utils

module Make(Xml : Xml_sigs.NoWrap)
         (Svg : Svg_sigs.NoWrap with module Xml := Xml)
         (Html : Html_sigs.NoWrap
          with module Xml := Xml
           and module Svg := Svg) = struct
  open Html

  let base_class = "mdc-form-field"
  let align_end_class = CSS.add_modifier base_class "align-end"

  let create_label ?(classes = []) ?attrs ?for_id ~label () : 'a elt =
    Html.label ~a:([a_class classes]
                   |> map_cons_option a_label_for for_id <@> attrs)
      [txt label]

  let create ?(classes = []) ?attrs
        ?(align_end = false) ~input ~label () : 'a elt =
    let (classes : string list) =
      classes
      |> cons_if align_end align_end_class
      |> List.cons base_class in
    div ~a:([a_class classes] <@> attrs) [input; label]

end
