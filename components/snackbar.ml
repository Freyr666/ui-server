type action =
  { handler : unit -> unit
  ; text    : string
  }

type data =
  { message          : string
  ; timeout          : int option
  ; action           : action option
  ; multiline        : bool
  ; action_on_bottom : bool
  }

class type data_obj =
  object
    method actionHandler  : (unit -> unit) Js.optdef Js.readonly_prop
    method actionOnBottom : bool Js.t Js.readonly_prop
    method actionText     : Js.js_string Js.t Js.optdef Js.readonly_prop
    method message        : Js.js_string Js.t Js.readonly_prop
    method multiline      : bool Js.t Js.readonly_prop
    method timeout        : int Js.optdef Js.readonly_prop
  end

let data_to_js_obj x : data_obj Js.t =
  object%js
    val message        = Js.string x.message
    val timeout        = Js.Optdef.option x.timeout
    val actionHandler  = CCOpt.map (fun x -> x.handler) x.action |> Js.Optdef.option
    val actionText     = CCOpt.map (fun x -> Js.string x.text) x.action |> Js.Optdef.option
    val multiline      = Js.bool x.multiline
    val actionOnBottom = Js.bool x.action_on_bottom
  end

class type mdc =
  object
    method show              : data_obj Js.t -> unit Js.meth
    method dismissesOnAction : bool Js.t Js.prop
  end

class t ?start_aligned ?action ~message () =

  let data = { message
             ; action
             ; multiline = false
             ; action_on_bottom = false
             ; timeout = None
             } in

  let elt = Markup.Snackbar.create ?start_aligned () |> Tyxml_js.To_dom.of_div in

  object

    inherit Widget.widget elt () as super

    val mutable data_obj : data_obj Js.t = data_to_js_obj data
    val mutable data     : data = data

    val mdc : mdc Js.t = Js.Unsafe.global##.mdc##.snackbar##.MDCSnackbar##attachTo elt

    method show = mdc##show data_obj

    method set_start_aligned x = Markup.Snackbar.align_start_class
                                 |> (fun c -> if x then super#add_class c else super#remove_class c)

    method get_dismiss_on_action   = Js.to_bool mdc##.dismissesOnAction
    method set_dismiss_on_action x = mdc##.dismissesOnAction := Js.bool x

    method get_data   = data
    method set_data x = data <- x; data_obj <- data_to_js_obj x

    method get_message   = data.message
    method set_message x = let new_data = { data with message = x } in
                           data <- new_data; data_obj <- data_to_js_obj new_data

    method get_timeout   = data.timeout
    method set_timeout x = let new_data = { data with timeout = Some x } in
                           data <- new_data; data_obj <- data_to_js_obj new_data

    method get_action   = data.action
    method set_action x = let new_data = { data with action = Some x } in
                          data <- new_data; data_obj <- data_to_js_obj new_data
    method remove_action = let new_data = { data with action = None } in
                           data <- new_data; data_obj <- data_to_js_obj new_data

    method get_multiline   = data.multiline
    method set_multiline x = let new_data = { data with multiline = x } in
                             data <- new_data; data_obj <- data_to_js_obj new_data

    method get_action_on_bottom   = data.action_on_bottom
    method set_action_on_bottom x = let new_data = { data with action_on_bottom = x } in
                                    data <- new_data; data_obj <- data_to_js_obj new_data

  end
