open Components_tyxml

module CSS = struct
  include Ui_templates_tyxml.Settings_page.CSS

  let dialog = BEM.add_element section "dialog"

  let empty_placeholder = BEM.add_element section "empty-placeholder"
end

module Make
    (Xml : Xml_sigs.NoWrap)
    (Svg : Svg_sigs.NoWrap with module Xml := Xml)
    (Html : Html_sigs.NoWrap with module Xml := Xml and module Svg := Svg) =
struct
  open Html
  module Floating_label_markup = Floating_label.Make (Xml) (Svg) (Html)
  module Icon_button_markup = Icon_button.Make (Xml) (Svg) (Html)
  module Icon_markup = Icon.Make (Xml) (Svg) (Html)
  module Line_ripple_markup = Line_ripple.Make (Xml) (Svg) (Html)
  module Textfield_markup = Textfield.Make (Xml) (Svg) (Html)
  include Ui_templates_tyxml.Settings_page.Make (Xml) (Svg) (Html)

  let create_remove_button () =
    Icon_button_markup.create
      ~classes:[Item_list.CSS.item_meta]
      ~icon:(Icon_markup.SVG.create ~d:Svg_icons.delete ())
      ()

  let create_textfield ?value ~label ~id () : 'a elt =
    let input_id = id ^ "-input" in
    Textfield_markup.create ?value ~attrs:[a_id id] ~input_id ~label:(`Text label) ()
end

module Markup = Make (Tyxml.Xml) (Tyxml.Svg) (Tyxml.Html)