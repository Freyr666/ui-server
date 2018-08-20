open Containers
open Common.Topology
open Common.User
open Api.Template
open Api

module Icon = Components_markup.Icon.Make(Tyxml.Xml)(Tyxml.Svg)(Tyxml.Html)

let make_icon path =
  let open Icon.SVG in
  let path = create_path path () in
  let icon = create [path] () in
  Tyxml.Html.toelt icon

let get_input_href x =
  let name = input_to_string x.input in
  let id   = string_of_int x.id in
  Filename.concat name id

let input topo (topo_input:topo_input) =
  let path = List.find_map (fun (i, p, c) ->
                 if Common.Topology.equal_topo_input i topo_input
                 then Some (p, c) else None)
               (Common.Topology.paths topo) in
  match path with
  | None              -> failwith "input not found"
  | Some (boards, cpu) ->
     let title  = Common.Topology.get_input_name topo_input in
     let boards = List.map (fun x -> x.control, x.typ) boards
                  |> boards_to_yojson |> Yojson.Safe.to_string in
     let cpu    = Option.map (fun x -> x.process) cpu
                  |> cpu_opt_to_yojson |> Yojson.Safe.to_string in
     let input  = Common.Topology.Show_topo_input.to_string topo_input in
     let template =
       { title = Some title
       ; pre_scripts  = [ Raw (Printf.sprintf "var input = \"%s\";\
                                               var boards = %s;\
                                               var cpu = %s;"
                                 input boards cpu)
                        ; Src "/js/moment.min.js"
                        ; Src "/js/Chart.min.js"
                        ; Src "/js/Chart.PieceLabel.min.js"]
       ; post_scripts = [ Src "/js/input.js" ]
       ; stylesheets = []
       ; content = []
       } in
     `Index topo_input.id,
     Simple { title
            ; icon = None
            ; href = Path.of_string @@ get_input_href topo_input
            ; template }

let create (app : Application.t) : upper ordered_item list user_table =
  let topo  = React.S.value app.topo in
  let props =
    { title        = Some "Конфигурация"
    ; pre_scripts  = []
    ; post_scripts = [ Src "js/topology.js" ]
    ; stylesheets  = [ "/css/topology.min.css" ]
    ; content      = []
    } in
  let demo_props =
    { title        = Some "UI Демо"
    ; pre_scripts  = [ Src "/js/moment.min.js"
                     ; Src "/js/Chart.min.js" ]
    ; post_scripts = [ Src "/js/demo.js" ]
    ; stylesheets  = [ ]
    ; content      = [ ]
    } in
  let inputs    = Common.Topology.inputs topo in
  let templates = List.rev_map (input topo) inputs in
  let rval =
    [ `Index 2,
      Subtree { title = "Входы"
              ; icon  = Some (make_icon Icon.SVG.Path.arrow_right_box)
              ; href  = Path.of_string "input"
              ; templates }
    ; `Index 3,
      Simple  { title = "Конфигурация"
              ; icon  = Some (make_icon Icon.SVG.Path.tournament)
              ; href  = Path.of_string "application"
              ; template = props }
    ; `Index 4,
      Simple  { title = "UI Демо"
              ; icon  = Some (make_icon Icon.SVG.Path.material_design)
              ; href  = Path.of_string "demo"
              ; template = demo_props }
    ]
  in
  let proc = match app.proc with
    | None -> Common.User.empty_table
    | Some p -> p#template ()
  in
  Common.User.concat_table [ Responses.home_template ()
                           ; User_template.create ()
                           ; Pc_control.Network_template.create ()
                           ; proc
                           ; { root = rval; operator = rval; guest = rval }
    ]
