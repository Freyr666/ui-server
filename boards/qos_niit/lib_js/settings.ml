open Board_types
open Components

let t2mi_mode ~(init  : config)
              ~(event : config React.event) =
  let enabled = new Switch.t () in
  let pid     = new Textfield.t  ~input_type:(Integer (Some (0,8192))) ~label:"T2-MI PID" () in
  let en_form = new Form_field.t ~input:enabled ~label:"Включить анализ" ~align_end:true () in
  pid#set_required true;
  (match init.mode.t2mi with
   | Some mode -> enabled#set_checked mode.enabled;
                  pid#fill_in mode.pid;
   | None      -> enabled#set_checked false);
  let s = React.S.l2 (fun en pid -> match pid with
                                    | Some pid -> Ok { enabled = en
                                                     ; pid
                                                     ; stream_id = Common.Stream.Single }
                                    | None     -> Error "pid value not provided")
                     enabled#s_state pid#s_input in
  let _ = React.E.map (fun config ->
              match config.mode.t2mi with
              | Some t2mi -> enabled#set_checked t2mi.enabled;
                             pid#fill_in t2mi.pid
              | None      -> enabled#set_checked false;
                             pid#clear) event
  in
  new Box.t ~widgets:[ en_form#widget; pid#widget ] (), s

let card control
         ~(init  : config)
         ~(event : config React.event) =
  let title       = new Card.Title.t ~title:"Настройки" () in
  let primary     = new Card.Primary.t ~widgets:[title] () in
  let asi         = new Select.Base.Item.t ~text:"ASI" ~value:ASI () in
  let spi         = new Select.Base.Item.t ~text:"SPI" ~value:SPI () in
  let inp         = new Select.Base.t ~label:"Вход" ~items:[asi;spi] () in
  let _           = inp#select_value init.mode.input in
  let t2mi,s_t2mi = t2mi_mode ~init ~event in
  let common_sect = new Card.Media.t ~widgets:[inp#widget] () in
  let t2mi_sect   = new Card.Media.t ~widgets:[t2mi#widget] () in
  let apply       = new Button.t ~label:"Применить" () in
  let actions     = new Card.Actions.t ~widgets:[ apply ] () in
  title#add_class "color--primary-on-primary";
  primary#add_class "background--primary";
  let card    = new Card.t ~sections:[ `Primary primary
                                     ; `Primary (let title = new Card.Title.t ~title:"Общие настройки" () in
                                                 new Card.Primary.t ~widgets:[title] ())
                                     ; `Media   common_sect
                                     ; `Primary (let title = new Card.Title.t ~title:"Настройки T2-MI" () in
                                                 new Card.Primary.t ~widgets:[title] ())
                                     ; `Media   t2mi_sect
                                     ; `Actions actions
                                     ] ()
  in
  let s = React.S.l2 (fun inp t2mi ->
              match inp,t2mi with
              | Some input, Ok t2mi -> Ok { input; t2mi = Some t2mi }
              | _, Error e          -> Error (Printf.sprintf "t2mi settings error: %s" e)
              | _                   -> Error "input not provided") inp#s_selected s_t2mi
  in
  let _ = React.E.map (fun config -> inp#select_value config.mode.input) event in
  let _ = React.E.map (fun () -> match React.S.value s with
                                 | Ok mode -> Requests.post_mode control mode
                                 | Error e -> Lwt_result.fail e) apply#e_click
  in
  card

let layout control
           ~(init  : config)
           ~(event : config React.event) =
  let card = card control ~init ~event in
  let cell = new Layout_grid.Cell.t ~widgets:[card] () in
  let grid = new Layout_grid.t ~cells:[cell] () in
  grid

let page control =
  let open Lwt_result.Infix in
  let div = Dom_html.createDiv Dom_html.document in
  let t   =
    Requests.get_config control
    >>= (fun init ->
      let event,sock = Requests.get_config_ws control in
      Dom.appendChild div(layout control ~init ~event)#root;
      Lwt_result.return sock)
  in
  div,(fun () -> t >>= (fun x -> x##close; Lwt_result.return ()) |> ignore)