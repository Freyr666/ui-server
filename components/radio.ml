class t ?(ripple=true) ?input_id ~name () =
  let elt = Markup.Radio.create ?input_id ~name () |> Tyxml_js.To_dom.of_i in
  let input_elt = elt##querySelector (Js.string ("." ^ Markup.Radio.native_control_class))
                  |> Js.Opt.to_option |> CCOpt.get_exn |> Js.Unsafe.coerce in
  object
    inherit Widget.radio_or_cb_widget ~input_elt elt ()
    initializer
      if ripple then Js.Unsafe.global##.mdc##.radio##.MDCRadio##attachTo elt
  end
