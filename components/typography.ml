open Containers
open Markup

type font = Display_4
          | Display_3
          | Display_2
          | Display_1
          | Headline
          | Title
          | Subheading_2
          | Subheading_1
          | Body_2
          | Body_1
          | Caption
          | Button

let font_to_class = function
  | Display_4    -> Typography.display4_class
  | Display_3    -> Typography.display3_class
  | Display_2    -> Typography.display2_class
  | Display_1    -> Typography.display1_class
  | Headline     -> Typography.headline_class
  | Title        -> Typography.title_class
  | Subheading_2 -> Typography.subheading2_class
  | Subheading_1 -> Typography.subheading1_class
  | Body_2       -> Typography.body2_class
  | Body_1       -> Typography.body1_class
  | Caption      -> Typography.caption_class
  | Button       -> Typography.button_class

let remove (elt:#Widget.widget) =
  List.iter (fun x -> if String.prefix ~pre:Typography.base_class x then elt#remove_class x)
            elt#get_classes

let set ?(adjust_margin=true) ~font (elt:#Widget.widget) =
  remove elt;
  elt#add_class Typography.base_class;
  elt#add_class @@ font_to_class font;
  if adjust_margin then elt#add_class Typography.adjust_margin_class

module Text = struct

  class t ?(split=false) ?(adjust_margin=true) ?font ~text () =

    let elt =
      let text = if split
                 then List.flatten @@ List.map (fun s -> Tyxml_js.Html.([pcdata s; br ()])) @@ String.lines text
                 else Tyxml_js.Html.([ pcdata text ])in
      Tyxml_js.Html.(span text) |> Tyxml_js.To_dom.of_element in

    object(self)

      inherit Widget.widget elt ()

      val mutable font : font option = font

      method set_font x =
        Option.iter (fun x -> self#remove_class @@ font_to_class x) font;
        self#add_class @@ font_to_class x;
        font <- Some x
      method get_font   = font

      method set_adjust_margin = function
        | true  -> self#add_class Typography.adjust_margin_class
        | false -> self#remove_class Typography.adjust_margin_class
      method get_adjust_margin = self#has_class Typography.adjust_margin_class

      method get_text   = self#get_text_content |> Option.get_or ~default:""
      method set_text s = self#set_text_content s

      initializer
        self#add_class Typography.base_class;
        self#set_adjust_margin adjust_margin;
        Option.iter (fun x -> self#add_class @@ font_to_class x) font

    end

end
