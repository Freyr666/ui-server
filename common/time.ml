open Containers

include Ptime

module Clock = struct

  let now () = match of_float_s @@ Unix.gettimeofday () with
    | Some x -> x
    | None   -> assert false

end

let span_to_yojson (v:span) : Yojson.Safe.json =
  let d,ps = Span.to_d_ps v in
  `List [ `Int d;`Intlit (Int64.to_string ps) ]

let span_of_yojson (j:Yojson.Safe.json) : (span,string) result =
  let to_err j = Printf.sprintf "span_of_yojson: bad json value (%s)" @@ Yojson.Safe.to_string j in
  match j with
  | `List [ `Int d; `Intlit ps] -> (match Int64.of_string_opt ps with
                                    | Some ps -> Result.of_opt (Span.of_d_ps (d,ps))
                                    | None    -> Error (to_err j))
  | _ -> Error (to_err j)

let to_yojson (v:t) : Yojson.Safe.json =
  let d,ps = Ptime.to_span v |> Ptime.Span.to_d_ps in
  `List [ `Int d;`Intlit (Int64.to_string ps) ]

let of_yojson (j:Yojson.Safe.json) : (t,string) result =
  let to_err j = Printf.sprintf "of_yojson: bad json value (%s)" @@ Yojson.Safe.to_string j in
  match j with
  | `List [ `Int d; `Intlit ps] -> (match Int64.of_string_opt ps with
                                    | Some ps -> Ok (v (d,ps))
                                    | None    -> Error (to_err j))
  | _ -> Error (to_err j)

module RFC3339 = struct
  type t = Ptime.t

  let of_string s =
    of_rfc3339 s |> function Ok (v,_,_) -> v | Error _ -> failwith (Printf.sprintf "RFC3339.of_string: bad input %s" s)

  let to_string = to_rfc3339

  let of_yojson = function
    | `String s -> begin match of_rfc3339 s with
                   | Ok(v,_,_) -> Ok v
                   | Error _   -> Error (Printf.sprintf "RFC3339.of_yojson: bad input %s" s)
                   end
    | _ -> Error (Printf.sprintf "RFC3339.of_yojson: bad input, expected a string")

  let to_yojson v = `String (to_string v)

end

module Useconds = struct
  type t = Ptime.t

  let of_useconds s =
    let s = Int64.(s / 1000000L |> to_int) in
    Ptime.add_span Ptime.epoch (Ptime.Span.of_int_s s)

  let to_useconds v =
    let s = Option.get_exn @@ Ptime.Span.to_int_s @@ Ptime.to_span v in
    Int64.(of_int s * 1000000L)

  let of_yojson = function
    | `Int x    -> begin
        Int64.of_int x
        |> of_useconds
        |> function Some v -> Ok v | None -> Error (Printf.sprintf "Useconds.of_yojson: bad input int %d" x)
      end
    | `Intlit x -> begin
        Option.(Int64.of_string x >>= of_useconds)
        |> function Some v -> Ok v | None -> Error ("Useconds.of_yojson: bad input intlit " ^ x)
      end
    | js -> Error ("Useconds.of_yojson: bad input " ^ (Yojson.Safe.pretty_to_string js))

  let to_yojson v = `Intlit (Int64.to_string @@ to_useconds v)

end
               
module Seconds = struct
  type t = Ptime.t
         
  let of_seconds s =
    Ptime.add_span Ptime.epoch (Ptime.Span.of_int_s s)

  let of_seconds64 s =
    Int64.to_int s |> of_seconds

  let to_seconds v = Option.get_exn @@ Ptime.Span.to_int_s @@ Ptime.to_span v

  let to_seconds64 v = Int64.of_int @@ to_seconds v

  let to_string v =
    to_seconds v |> string_of_int

  let of_string_opt s =
    Option.(int_of_string_opt s >>= of_seconds)

  let of_string s = Option.get_exn @@ of_string_opt s
                  
  let of_yojson = function
    | `Int x -> begin match of_seconds x with
                | Some v -> Ok v
                | None   -> Error "Seconds.of_yojson: bad input"
                end
    | _ -> Error "Seconds.of_yojson: bad input"

  let to_yojson v = `Int (to_seconds v)

end

module Hours = struct
  type t = Ptime.t
  
  let of_hours s = Ptime.add_span Ptime.epoch (Ptime.Span.of_int_s (3600 * s))

  let to_hours v = (Option.get_exn @@ Ptime.Span.to_int_s @@ Ptime.to_span v) / 3600

  let to_string v =
    to_hours v |> string_of_int

  let of_string_opt s =
    Option.(int_of_string_opt s >>= of_hours)

  let of_string s = Option.get_exn @@ of_string_opt s
                   
  let of_yojson = function
    | `Int x -> begin match of_hours x with
                | Some v -> Ok v
                | None   -> Error "Hours.of_yojson: bad input"
                end
    | _ -> Error "Hours.of_yojson: bad input"

  let to_yojson v = `Int (to_hours v)

end

module Period = struct

  module Hours = struct
    type t = Ptime.span
           
    let of_hours s = Ptime.Span.of_int_s (3600 * s)

    let to_hours v = (Option.get_exn @@ Ptime.Span.to_int_s v) / 3600

    let to_string v =
      to_hours v |> string_of_int

    let of_string_opt s =
      Option.(int_of_string_opt s >|= of_hours)

    let of_string s = Option.get_exn @@ of_string_opt s
                    
    let of_yojson = function
      | `Int x -> Ok (of_hours x)
      | _ -> Error "Hours.of_yojson: bad input"

    let to_yojson v = `Int (to_hours v)

  end
  
end
