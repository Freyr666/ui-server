open Common.Topology
open Common.User
open Api.Template
open Api

let get_input_name x topo =
  let single = CCList.find_pred (fun input -> input.input = x.input && input.id <> x.id)
                                (topo_inputs topo)
               |> CCOpt.is_none in
  let to_string s = if single then Printf.sprintf "%s" s else Printf.sprintf "%s %d" s x.id in
  match x.input with
  | RF    -> to_string "RF"
  | TSOIP -> to_string "TSoIP"
  | ASI   -> to_string "ASI"

let get_input_href x =
  let name = input_to_string x.input in
  let id   = string_of_int x.id in
  Filename.concat name id

let input topo (topo_input:topo_input) =
  let path = CCList.find_map (fun (i,p) -> if i = topo_input then Some p else None)
                             (topo_paths topo) in
  match path with
  | None      -> failwith "input not found"
  | Some path -> let title  = get_input_name topo_input topo in
                 let boards = CCList.map (fun x -> x.control,x.typ ) path
                              |> boards_to_yojson
                              |> Yojson.Safe.to_string
                 in
                 let template = { title        = Some ("Вход " ^ title)
                                ; pre_scripts  = [ Raw (Printf.sprintf "var boards = %s" boards)
                                                 ; Src "/js/moment.min.js"
                                                 ; Src "/js/Chart.min.js" ]
                                ; post_scripts = [ Src "/js/input.js" ]
                                ; stylesheets  = []
                                ; content      = []
                                } in
                 `Index topo_input.id, Simple { title; href = Path.of_string @@ get_input_href topo_input; template }

let create (hw : Hardware.t) : upper ordered_item list user_table =
  let topo  = React.S.value hw.topo in
  let props = { title        = Some "Конфигурация"
              ; pre_scripts  = []
              ; post_scripts = [ Src "js/hardware.js" ]
              ; stylesheets  = []
              ; content      = []
              } in
  let demo = { title        = Some "Демо"
             ; pre_scripts  = [ Src "/js/moment.min.js"
                              ; Src "/js/Chart.min.js" ]
             ; post_scripts = [ Src "/js/demo.js" ]
             ; stylesheets  = []
             ; content      = []
             }
  in
  let templates = CCList.map (input topo) (Common.Topology.topo_inputs topo) |> CCList.rev in
  let rval = [ `Index 2, Subtree { title = "Входы"; href = Path.of_string "input"; templates }
             ; `Index 3, Simple  { title = "Конфигурация"; href = Path.of_string "hardware"; template = props }
             ; `Index 4, Ref     { title = "Wiki"; absolute = true; href = Path.of_string "wikipedia.org"}
             ; `Index 5, Simple  { title = "Демо"; href = Path.of_string "demo"; template = demo }
             ]
  in { root = rval
     ; operator = rval
     ; guest = rval
     }
