open Js_of_ocaml
open Js_of_ocaml_tyxml
open Js_of_ocaml_lwt
open Pc_control_types
open Components
open Util_react
open Netlib

(* FIXME remove 4.08 *)
let rec equal_list (f : 'a -> 'a -> bool) l1 l2 = match l1, l2 with
  | [], [] -> true
  | [], _ | _, [] -> false
  | x1 :: l1', x2 :: l2' -> f x1 x2 && equal_list f l1' l2'

let make_routes (_routes : Network_config.address list) =
  let make_route_entry del_route route =
    let (addr,mask) = route in
    let text        = (Ipaddr.V4.to_string addr) ^ "/" ^ (Int32.to_string mask) in
    let del_button  = Button.make ~label:"delete" () in
    let item        = Item_list.Item.make ~meta:del_button text in
    Lwt_js_events.clicks del_button#root (fun _ _ ->
        del_route item route |> Lwt.return) |> Lwt.ignore_result;
    item
  in

  let header = Typography.Text.make ~font:Subtitle_1 "Список статических маршрутов" in
  let list   = Item_list.make [] in

  let address = Textfield.make_textfield ~label:"Адрес" ipv4_validation in
  let mask = Textfield.make_textfield ~label:"Маска подсети" (Integer (Some 0, Some 32)) in
  let add_but = Button.make ~label:"Добавить" () in
  let add_box = Box.make ~dir:`Row [address#widget; mask#widget; add_but#widget] in

  let full_box = Box.make ~dir:`Column [header#widget; list#widget; add_box#widget] in

  let signal, push =
    S.create ~eq:(equal_list Network_config.equal_address) [] in

  let del_route item (addr, mask) =
    list#remove_child item;
    push
    @@ List.filter (fun route -> not (Network_config.equal_address (addr,mask) route))
    @@ S.value signal
  in
  let add_route (addr, mask) =
    let rlst = S.value signal in
    if List.exists (Network_config.equal_address (addr,mask)) rlst
    then failwith "route exists"; (* TODO fix *)
    let entry = make_route_entry del_route (addr, mask) in
    list#append_child entry;
    push ((addr, mask)::rlst)
  in
  let set routes =
    list#remove_children ();
    push [];
    List.iter add_route routes
  in
  let set_disabled flag =
    address#set_disabled flag;
    mask#set_disabled flag;
    add_but#set_disabled flag;
  in
  Lwt_js_events.clicks add_but#root (fun _ _ ->
      begin match address#value, mask#value with
        | Some addr, Some mask -> add_route (addr, Int32.of_int mask)
        | _ -> ()
      end;
      Lwt.return_unit) |> Lwt.ignore_result;
  full_box, signal, set, set_disabled

let make_ipv4 (ipv4 : Network_config.ipv4_conf) =
  let ipv4_head = Card.Primary.make [Card.Primary.make_title "Настройки IP"] in
  let meth = Form_field.make
      ~label:"Автоматическая настройка"
      (Switch.make ()) in
  let address = Textfield.make_textfield ~label:"Адрес" ipv4_validation in
  let mask = Textfield.make_textfield ~label:"Маска подсети" (Integer (Some 0, Some 32)) in
  let gateway = Textfield.make_textfield ~label:"Шлюз" ipv4_validation in
  let dns, dns_s, dns_set, _dns_disable = make_dns ipv4.dns in
  let routes, _routes_s, routes_set, _routes_disable = make_routes ipv4.routes.static in

  let _signal, push = S.create ~eq:Network_config.equal_ipv4_conf ipv4 in

  let set (ipv4 : Network_config.ipv4_conf) =
    meth#input#toggle ~force:(Network_config.equal_meth ipv4.meth Auto) ();
    address#set_value @@ fst ipv4.address;
    mask#set_value (Int32.to_int @@ snd ipv4.address);
    (match ipv4.routes.gateway with
     | None -> ()
     | Some gw -> gateway#set_value gw);
    dns_set ipv4.dns;
    routes_set ipv4.routes.static;
    push ipv4
  in

  (* disable settings on Auto config *)
  (* S.map ~eq:(=) (fun disabled ->
   *     address#set_disabled disabled;
   *     mask#set_disabled disabled;
   *     gateway#set_disabled disabled;
   *     dns_disable disabled;
   *     routes_disable disabled) meth#input#s_state
   * |> S.keep; *)

  (* disable routes on gateway config *)
  (* S.map ~eq:(=) (function
   *     | None -> routes_disable false
   *     | _ -> routes_disable true) gateway#s_input
   * |> S.keep; *)

  let media =
    Card.Media.make
      [Box.make ~dir:`Column
         [ meth#widget
         ; address#widget
         ; mask#widget
         ; gateway#widget
         ; dns#widget
         ; routes#widget
         ]
      ] in
  media#root##.style##.margin := Utils.px_js 15;
  let ipv4_sets = Card.make [ipv4_head#widget; media#widget] in
  let signal =
    (* S.l6 ~eq:Network_config.equal_ipv4_conf
     *   (fun (config : Network_config.ipv4_conf) meth address mask gateway routes ->
     *      let addr = match address with
     *        | None -> fst config.address
     *        | Some x -> x in
     *      let mask = match mask with
     *        | None -> snd config.address
     *        | Some x -> x in
     *      { config with
     *        meth = if meth then Auto else Manual
     *      ; address = (addr, mask)
     *      ; routes = { gateway = gateway; static = routes } }) (\* TODO fix *\)
     *   signal
     *   meth#input_widget#s_state
     *   address#s_input
     *   (S.map ~eq:(equal_option Int32.equal)
     *      (Utils.Option.map Int32.of_int) mask#s_input)
     *   gateway#s_input
     *   routes_s *)
    React.S.const ipv4
  in
  let signal =
    S.l2 ~eq:Network_config.equal_ipv4_conf
      (fun (config : Network_config.ipv4_conf) dns ->
         { config with dns } ) signal dns_s in
  ipv4_sets, signal, set

let page user =
  let is_root = Application_types.User.equal user `Root in
  Pc_control_http_js.get_config () >>= function
  | Error e -> Lwt.return_error (Api_js.Http.error_to_string e)
  | Ok config ->
    let event, push = E.create () in
    let post new_config =
      Pc_control_http_js.set_config new_config
      >>= function
      | Ok _ -> (push new_config; Lwt.return_unit)
      | Error _ ->
        Pc_control_http_js.get_config () >>= function
        | Error _ -> (push config; Lwt.return_unit)
        | Ok config -> (push config; Lwt.return_unit)
    in
    let card, set = make_card is_root post config in
    E.keep @@ E.map (fun config ->
        print_endline (Yojson.Safe.pretty_to_string @@ Network_config.to_yojson config);
        set config) event;
    Lwt.return_ok card