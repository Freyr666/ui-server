module CSS = struct
  (** Required on the root element. *)
  let root = "mdc-menu"

  (** Used to wrap a group of mdc-list-item elements that will represent
      a selection group. *)
  let selection_group = BEM.add_element root "selection-group"

  (** Required when using a selection group to indicate which item is
      selected. Should contain an icon or svg that indicates the selected
      state of the list item. *)
  let selection_group_icon = BEM.add_element root "selection-group-icon"

  (** Used to indicate which element in a selection group is selected. *)
  let item_selected = BEM.add_modifier "mdc-menu-item" "selected"
end

module Make
    (Xml : Xml_sigs.NoWrap)
    (Svg : Svg_sigs.NoWrap with module Xml := Xml)
    (Html : Html_sigs.NoWrap with module Xml := Xml and module Svg := Svg) =
struct
  module CSS = CSS
  module Menu_surface = Menu_surface.Make (Xml) (Svg) (Html)

  module Item_list = struct
    include Item_list.Make (Xml) (Svg) (Html)

    let create_item = create_item ~role:"menuitem"

    let create = create ~role:"menu"
  end

  let create
      ?(classes = [])
      ?(attrs = [])
      ?fixed
      ?open_
      ?list_children
      ?list
      ?children
      () =
    let classes = CSS.root :: classes in
    let attrs = Html.a_tabindex (-1) :: attrs in
    let children =
      match children with
      | Some _ as x -> x
      | None -> (
        match list with
        | Some x -> Some [x]
        | None -> (
          match list_children with
          | None -> None
          | Some x -> Some [Item_list.create ~children:x ()]))
    in
    Menu_surface.create ~classes ~attrs ?fixed ?open_ ?children ()
end

module Markup = Make (Tyxml.Xml) (Tyxml.Svg) (Tyxml.Html)
