open Components_tyxml
open Application_types
open Board_niitv_tsan_types

module CSS = struct
  include Table_overview.CSS

  let pids = BEM.add_modifier root "pids"
end

type pid_flags = { has_pcr : bool; scrambled : bool }

let compare_pid_flags (a : pid_flags as 'a) (b : 'a) =
  let res = compare a.has_pcr b.has_pcr in
  if res = 0 then compare a.scrambled b.scrambled else res

module Make
    (Xml : Intf.Xml)
    (Svg : Svg_sigs.T with module Xml := Xml)
    (Html : Html_sigs.T with module Xml := Xml and module Svg := Svg) =
struct
  open Xml.W
  include Table_overview.Make (Xml) (Svg) (Html)
  module Fmt = Data_table.Make_fmt (Xml) (Svg) (Html)

  let ( @:: ) x l = cons (return x) l

  let ( ^:: ) x l = Option.fold ~none:l ~some:(fun x -> x @:: l) x

  let pid_type_fmt : MPEG_TS.PID.Type.t Fmt.custom =
    MPEG_TS.PID.Type.
      {
        to_string;
        of_string = (fun _ -> failwith "Not implemented");
        compare;
        is_numeric = false;
      }

  let dec_pid_fmt = Fmt.Int

  let hex_pid_fmt =
    Fmt.Custom
      {
        to_string = Util.pid_to_hex_string;
        of_string = int_of_string;
        compare;
        is_numeric = true;
      }

  let pid_fmt ~hex = if hex then hex_pid_fmt else dec_pid_fmt

  let create_pid_flags ?a { has_pcr; scrambled } =
    let pcr =
      match has_pcr with
      | false -> None
      | true ->
          Some (Icon_markup.SVG.icon ~d:(return Svg_icons.clock_outline) ())
    in
    let scr =
      match scrambled with
      | false -> None
      | true -> Some (Icon_markup.SVG.icon ~d:(return Svg_icons.lock) ())
    in
    let children = scr ^:: pcr ^:: nil () in
    Box_markup.box ?a ~children ()

  let pid_flags_fmt : pid_flags Fmt.custom_elt =
    {
      to_elt = create_pid_flags;
      of_elt = (fun _ -> failwith "Not implemented");
      compare = compare_pid_flags;
      is_numeric = false;
    }

  let pct_fmt =
    Fmt.Custom
      {
        to_string = (fun x -> Printf.sprintf "%.2f" x);
        of_string = float_of_string;
        compare;
        is_numeric = true;
      }

  let create_table_format ?(hex = return false) () : _ Fmt.format =
    let pid_fmt = fmap (fun hex -> pid_fmt ~hex) hex in
    let br_fmt = return (Fmt.Option (Float, "-")) in
    let pct_fmt = return (Fmt.Option (pct_fmt, "-")) in
    Fmt.
      [
        make_column ~sortable:true ~title:(return "PID") pid_fmt;
        make_column ~sortable:true ~title:(return "Тип")
          (return (Custom pid_type_fmt));
        make_column
          ~title:(return "Доп. инфо")
          (return (Custom_elt pid_flags_fmt));
        make_column ~sortable:true ~title:(return "Сервис")
          (return (Option (String, "")));
        make_column ~sortable:true
          ~title:(return "Битрейт, Мбит/с")
          br_fmt;
        make_column ~sortable:true ~title:(return "%") pct_fmt;
        make_column ~sortable:true ~title:(return "Min, Мбит/с") br_fmt;
        make_column ~sortable:true ~title:(return "Max, Мбит/с") br_fmt;
      ]

  let data_of_pid_info ?(bitrate = return None) (pid, (info : PID.t)) :
      _ Fmt.data =
    let flags = { has_pcr = info.has_pcr; scrambled = info.scrambled } in
    Fmt.
      [
        return pid;
        return info.typ;
        return flags;
        return info.service_name;
        fmap
          (function
            | None -> None
            | Some (_, { Bitrate.cur; _ }) ->
                Some (float_of_int cur /. 1_000_000.))
          bitrate;
        fmap
          (function
            | None -> None
            | Some ({ Bitrate.cur = tot; _ }, { Bitrate.cur; _ }) ->
                Some (100. *. float_of_int cur /. float_of_int tot))
          bitrate;
        fmap
          (function
            | None -> None
            | Some (_, { Bitrate.min; _ }) ->
                Some (float_of_int min /. 1_000_000.))
          bitrate;
        fmap
          (function
            | None -> None
            | Some (_, { Bitrate.max; _ }) ->
                Some (float_of_int max /. 1_000_000.))
          bitrate;
      ]

  let row_of_pid_info ?bitrate ~format (pid, (info : PID.t)) =
    let data = data_of_pid_info ?bitrate (pid, info) in
    let cells = Data_table_markup.data_table_cells_of_fmt format data in
    let value = Yojson.Safe.to_string (PID.to_yojson info) in
    Data_table_markup.data_table_row
      ~a:
        [
          Html.a_user_data "value" (return value);
          Html.a_user_data "pid" (return (string_of_int pid));
        ]
      ~children:cells ()

  let create ?a ?dense ?(hex = return false) ?(bitrate = return None)
      ?(init = nil ()) ~control () =
    let format = create_table_format ~hex () in
    let rows =
      Xml.W.map
        (fun ((pid, _) as x) ->
          let bitrate =
            fmap
              (function
                | None -> None
                | Some (rate : Bitrate.ext) -> (
                    match List.assoc_opt pid rate.pids with
                    | None -> None
                    | Some x -> Some (rate.total, x) ))
              bitrate
          in
          row_of_pid_info ~bitrate ~format x)
        init
    in
    create
      ~classes:(return [ CSS.pids ])
      ?a ?dense ~hex
      ~title:(return "Список PID")
      ~format ~rows ~control ()
end

module F = Make (Impl.Xml) (Impl.Svg) (Impl.Html)
