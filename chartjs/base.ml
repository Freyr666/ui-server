[@@@ocaml.warning "-60"]

let (%>) = CCFun.(%>)

module Cast = struct

  let to_number x : Js.number Js.t Js.opt =
    if Js.typeof x = (Js.string "number")
    then Js.some (Js.Unsafe.coerce x)
    else Js.null

  let to_string x : Js.js_string Js.t Js.opt =
    if Js.typeof x = (Js.string "string")
    then Js.some (Js.Unsafe.coerce x)
    else Js.null

  let to_object x =
    if Js.typeof x = (Js.string "object")
    then Js.some (Js.Unsafe.coerce x)
    else Js.null

end

module Canvas = struct

  type line_cap = Butt | Round | Square

  type line_join = Bevel | Round | Miter

  let line_cap_to_string = function
    | Butt -> "butt" | Round -> "round" | Square -> "square"

  let line_join_to_string = function
    | Bevel -> "bevel" | Round -> "round" | Miter -> "miter"

end

module Obj = struct
  let (>|=) x f = Js.Optdef.map x f
  let map x f   = Js.Optdef.option x >|= f |> Js.Unsafe.inject
  let wrap x    = Js.Optdef.option x |> Js.Unsafe.inject

  type 'a opt_field = string * 'a

  let map_cons_option ~f name opt l = CCOpt.map_or ~default:l (fun x -> (name, Js.Unsafe.inject @@ f x) :: l) opt
  let cons_option name opt l        = CCOpt.map_or ~default:l (fun x -> (name, Js.Unsafe.inject x) :: l) opt

  let append_option opt l = CCOpt.map_or ~default:l (fun x -> x @ l) opt
  let map_append_option ~f opt l = CCOpt.map_or ~default:l (fun x -> (f x) @ l) opt

end

type interaction_mode = Point
                      | Nearest
                      | Index
                      | Dataset
                      | X
                      | Y

let interaction_mode_to_string = function
  | Point   -> "point"
  | Nearest -> "nearest"
  | Index   -> "index"
  | Dataset -> "dataset"
  | X       -> "x"
  | Y       -> "y"

type easing = Linear
            | Ease_in of animation_type
            | Ease_out of animation_type
            | Ease_in_out of animation_type
 and animation_type = Quad
                    | Cubic
                    | Quart
                    | Quint
                    | Sine
                    | Expo
                    | Circ
                    | Elastic
                    | Back
                    | Bounce

let animation_type_to_string = function
  | Quad -> "Quad" | Cubic  -> "Cubic" | Quart -> "Quart" | Quint   -> "Quint"
  | Sine -> "Sine" | Expo   -> "Expo"  | Circ  -> "Circ"  | Elastic -> "Elastic"
  | Back -> "Back" | Bounce -> "Bounce"

let easing_to_string = function
  | Linear        -> "linear"
  | Ease_in x     -> "easeIn" ^ animation_type_to_string x
  | Ease_out x    -> "easeOut" ^ animation_type_to_string x
  | Ease_in_out x -> "easeInOut" ^ animation_type_to_string x

type typ = Line
         | Bar
         | Radar
         | Pie
         | Doughnut
         | Polar
         | Bubble
         | Scatter

let typ_to_string = function
  | Line   -> "line"   | Bar      -> "bar"      | Radar -> "radar"
  | Pie    -> "pie"    | Doughnut -> "doughnut" | Polar -> "polarArea"
  | Bubble -> "bubble" | Scatter  -> "scatter"

class type config =
  object
    method duration : int Js.prop
    method lazy_    : bool Js.t Js.prop
    method easing   : Js.js_string Js.t Js.prop
  end

let config_to_obj ?duration ?lazy_ ?easing () : config Js.t =
  Obj.cons_option "duration" duration []
  |> Obj.map_cons_option ~f:Js.bool "lazy" lazy_
  |> Obj.map_cons_option ~f:(easing_to_string %> Js.string) "easing" easing
  |> Array.of_list
  |> Js.Unsafe.obj

class type chart =
  object
    method destroy        : unit -> unit Js.meth
    method update         : config Js.t -> unit Js.meth
    method reset          : unit -> unit Js.meth
    method render         : config Js.t -> unit Js.meth
    method stop           : unit -> chart Js.t Js.meth
    method resize         : unit -> chart Js.t Js.meth
    method clear          : unit -> chart Js.t Js.meth
    method toBase64Image  : unit -> Js.js_string Js.t Js.meth
    method generateLegend : unit -> Js.js_string Js.t Js.meth
  end