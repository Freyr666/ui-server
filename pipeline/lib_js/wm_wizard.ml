open Containers
open Components
open Wm_components

let channel_of_domain = function
  | "s460b38ee-186b-5604-8811-235eb3005960_c1060" -> "Россия К"
  | "s460b38ee-186b-5604-8811-235eb3005960_c1040" -> "НТВ"
  | "s460b38ee-186b-5604-8811-235eb3005960_c1050" -> "5 канал"
  | "s460b38ee-186b-5604-8811-235eb3005960_c1030" -> "МАТЧ ТВ"
  | "s460b38ee-186b-5604-8811-235eb3005960_c1010" -> "Первый канал"
  | "s460b38ee-186b-5604-8811-235eb3005960_c1080" -> "Карусель"
  | "s460b38ee-186b-5604-8811-235eb3005960_c1090" -> "ОТР"
  | "s460b38ee-186b-5604-8811-235eb3005960_c1100" -> "ТВЦ"
  | "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2090" -> "ТНТ"
  | "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2020" -> "Спас"
  | "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2070" -> "Звезда"
  | "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2080" -> "Мир"
  | "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2060" -> "Пятница!"
  | "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2100" -> "МУЗ ТВ"
  | "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2050" -> "ТВ3"
  | "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2040" -> "Домашний"
  | "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2030" -> "СТС"
  | "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2010" -> "РЕН ТВ"
  | "s4b135670-ef01-59b1-be78-4e9bec93461f_c1020" -> "Россия 1"
  | "s930c63bc-0ce2-555c-9a51-09de6b1b85f2_c1070" -> "Россия 24"
  | _ -> ""

let domain_of_channel = function
  | "Россия К"     -> "s460b38ee-186b-5604-8811-235eb3005960_c1060"
  | "НТВ"          -> "s460b38ee-186b-5604-8811-235eb3005960_c1040"
  | "5 канал"      -> "s460b38ee-186b-5604-8811-235eb3005960_c1050"
  | "МАТЧ ТВ"      -> "s460b38ee-186b-5604-8811-235eb3005960_c1030"
  | "Первый канал" -> "s460b38ee-186b-5604-8811-235eb3005960_c1010"
  | "Карусель"     -> "s460b38ee-186b-5604-8811-235eb3005960_c1080"
  | "ОТР"          -> "s460b38ee-186b-5604-8811-235eb3005960_c1090"
  | "ТВЦ"          -> "s460b38ee-186b-5604-8811-235eb3005960_c1100"
  | "ТНТ"          -> "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2090"
  | "Спас"         -> "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2020"
  | "Звезда"       -> "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2070"
  | "Мир"          -> "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2080"
  | "Пятница!"     -> "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2060"
  | "МУЗ ТВ"       -> "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2100"
  | "ТВ3"          -> "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2050"
  | "Домашний"     -> "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2040"
  | "СТС"          -> "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2030"
  | "РЕН ТВ"       -> "s4c953a1b-dbcc-57cc-82f3-7f1c50dbd4d1_c2010"
  | "Россия 1"     -> "s4b135670-ef01-59b1-be78-4e9bec93461f_c1020"
  | "Россия 24"    -> "s930c63bc-0ce2-555c-9a51-09de6b1b85f2_c1070"
  | _ -> ""

let get_items_in_row ~(resolution : int * int) ~(item_ar : int * int) num =
  let resolution_ar = Utils.resolution_to_aspect resolution
                      |> (fun (x,y) -> (float_of_int x) /. (float_of_int y))
  in
(*  let item_ar       = (float_of_int @@ fst item_ar) /. (float_of_int @@ snd item_ar) in*)
  let squares =
    List.map (fun rows ->
        let rows = rows + 1 in
        let cols = ceil (float_of_int num /. float_of_int rows) in
        let w    = float_of_int (fst resolution) /. cols in
        let h    = w /. resolution_ar in
      (*  if Float.((w /. cols *. item_ar) *. float_of_int rows <= h)
        then int_of_float cols, rows, (w /. cols *. w /. cols *. item_ar)
        else int_of_float cols, rows,
             (h /. (float_of_int rows) *. h /. (float_of_int rows) *. item_ar)*)
        if (h *. float_of_int rows >. float_of_int @@ fst resolution)
        then 0, 0, 0.
        else
        ( let squares  = w *. h *. float_of_int num in
          let division = squares /. (float_of_int @@ fst resolution * snd resolution) in
          int_of_float cols, rows, division)) (List.range 0 10) in
  let (cols : int), _, _ =
    List.fold_left (fun acc x ->
        let _, _, sq = x in
        let _, _, gr = acc in
        if Float.(gr > sq) then acc else x)
      (0, 0, 0.) squares in
  cols

let position_widget ~(pos : Wm.position)
    (widget : string * Wm.widget) : string * Wm.widget =
  let s, v = widget in
  let cpos = Utils.to_grid_position pos in
  let wpos = Option.map_or ~default:cpos (Dynamic_grid.Position.correct_aspect cpos) v.aspect in
  let x    = cpos.x + ((cpos.w - wpos.w) / 2) in
  let y    = cpos.y + ((cpos.h - wpos.h) / 2) in
  let pos  = {wpos with x ; y} |> Utils.of_grid_position in

  s, { v with position = pos }

let to_checkboxes (widgets : (string * Wm.widget) list) =
  let domains =
    List.fold_left (fun acc (_, (wdg : Wm.widget)) ->
        if List.exists (fun x -> String.equal x wdg.domain) acc then
          acc
        else
          wdg.domain :: acc) [] widgets
    |> List.rev
  in
  let channels = List.map (fun x -> channel_of_domain x) domains in
  let wds =
    List.map (fun str ->
        let label    = str in
        let checkbox = new Checkbox.t () in
        checkbox#set_id label;
        let form_field = new Form_field.t ~label ~input:checkbox () in
        form_field) channels
  in
  let checkbox  = new Checkbox.t () in
  let check_all = new Form_field.t ~label:"Выбрать все" ~input:checkbox () in
  React.E.map (fun checked ->
      if not checked
      then List.iter (fun x -> x#input_widget#set_checked false) wds
      else List.iter (fun x -> x#input_widget#set_checked true) wds)
  @@ React.S.changes checkbox#s_state |> ignore;
  check_all :: wds

let to_layout ~resolution ~domains ~widgets =
  let ar_x, ar_y   = 16, 9 in
  let domains_num  = List.length domains in
  let items_in_row = get_items_in_row ~resolution ~item_ar:(ar_x, ar_y) domains_num in
  List.mapi (fun i domain ->
      let video_w = (fst resolution) / items_in_row in
      let video_h = (ar_y * video_w) / ar_x in
      let row     = i / items_in_row in
      let video_x = (i - items_in_row * row) * video_w in
      let video_y = row * video_h in
      let (video_pos : Wm.position) =
        { left = video_x
        ; top = video_y
        ; right = video_x + video_w - 30
        ; bottom = video_y + video_h
        }
      in
      let cont_pos : Wm.position =
        { left = video_x
        ; top = video_y
        ; right = video_x + video_w
        ; bottom = video_y + video_h
        }
      in
      let (audio_pos : Wm.position) =
        { left = video_x + video_w - 30
        ; top = video_y
        ; right = video_x + video_w
        ; bottom = video_y + video_h
        }
      in
      let audio =
        List.find_pred (fun (_, (x : Wm.widget)) ->
            String.equal x.domain domain && String.equal x.type_ "soundbar") widgets
      in
      let video =
        List.find_pred (fun (_, (x : Wm.widget)) ->
            String.equal x.domain domain && String.equal x.type_ "video") widgets
      in
      let container = match video, audio with
        | Some video, Some audio ->
          let video_wdg = (fst video, {(snd video) with position = video_pos}) in
          let audio_wdg = (fst audio, {(snd audio) with position = audio_pos}) in
          ({ position = cont_pos
           ; widgets  = [video_wdg; audio_wdg]
           } : Wm.container)
        | None, Some audio ->
          let audio_wdg = (fst audio, {(snd audio) with position = audio_pos}) in
          ({ position = cont_pos
           ; widgets  = [audio_wdg]
           } : Wm.container)
        | Some video, None ->
          let video_wdg = (fst video, {(snd video) with position = video_pos}) in
          ({ position = cont_pos
           ; widgets  = [video_wdg]
           } : Wm.container)
        | _, _ ->
          ({ position = cont_pos
           ; widgets  = []
           } : Wm.container)
      in
      (channel_of_domain domain), container)
    domains

let to_dialog (wm:Wm.t) =
  let e,push     = React.E.create () in
  let checkboxes = to_checkboxes wm.widgets in
  let box        = new Vbox.t ~widgets:checkboxes () in
  let dialog     = new Dialog.t
                       ~title:"Выберите виджеты"
                       ~scrollable:true
                       ~content:(`Widgets [box])
                       ~actions:[ new Dialog.Action.t ~typ:`Decline ~label:"Отмена" ()
                                ; new Dialog.Action.t ~typ:`Accept  ~label:"Применить"  ()
                                ]
                       ()
  in
  let show = fun () ->
    Lwt.bind (dialog#show_await ())
      (function
          | `Accept ->
            let domains =
              List.map (fun x ->
                  domain_of_channel @@ x#input_widget#id) checkboxes
            in
            Lwt.return (push @@ to_layout ~resolution:wm.resolution ~domains ~widgets:wm.widgets)
          | `Cancel -> Lwt.return ())
  in
  dialog, e, show
