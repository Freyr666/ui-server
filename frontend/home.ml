open Lwt_react
open Board_ip_dektec_js.Requests
open Hardware_js.Requests
open Components

let return = Lwt.return
let (>>=) = Lwt.(>>=)
let (>|=) = Lwt.(>|=)

let (%) = CCFun.(%)

        
let call addr =
  print_endline "Page called\n";
  Api_js.Requests.get addr >>=
    function
    | Error e -> Lwt.fail_with e
    | Ok s    -> Lwt.return @@ Js.string s

let attach content script (button, addr, js_addr) =
  Lwt.ignore_result @@
    Lwt_js_events.clicks
      button
      (fun _ _ -> call addr >|= (fun s -> content##.innerHTML := s; script##.src := Js.string js_addr))
                            
let onload _ =
  let ac  = Dom_html.getElementById "arbitrary-content" in
  let script = Js.coerce_opt
                 (Js.some @@ Dom_html.getElementById "arbitrary-script")
                 Dom_html.CoerceTo.script
                 (fun _ -> assert false)
  in

  let pipe_button = Dom_html.getElementById "pipeline-button" in
  let hw_button   = Dom_html.getElementById "hardware-button" in

  let attach = attach ac script in

  List.iter
    attach
    [(pipe_button, "api/pipeline", "js/pipeline.js");
     (hw_button, "api/hardware", "js/hardware.js");];
  
  Js._false

let () = Dom_html.addEventListener Dom_html.document
                                   Dom_events.Typ.domContentLoaded
                                   (Dom_html.handler onload)
                                   Js._false
         |> ignore


              (*            
let onload _ =

  (*let streams, push_streams = S.create Js.null in*)

  let doc = Dom_html.document in

  let label    = Dom_html.createH2 doc in
  let button_set = Dom_html.createButton ~_type:(Js.string "button") doc in
  let button_reset = Dom_html.createButton ~_type:(Js.string "button") doc in
  button_set##.value := (Js.string "set");
  button_reset##.value := (Js.string "reset");
  let ev_label = Dom_html.createH2 doc in

  (* test *)

  Lwt.ignore_result @@ Lwt_js_events.clicks button_set (fun _ _ ->
                                              let data = Board_ip_dektec_js.Requests.post_delay 5 101 in
                                              data >>= function
                                              | Error e -> Lwt.return @@ (label##.textContent := Js.some @@ Js.string e)
                                              | Ok devi -> Lwt.return @@ (label##.textContent := Js.some @@ Js.string
                                                                                                 @@ Yojson.Safe.to_string
                                                                                                 @@ Board_ip_dektec_js.Board_types.delay_to_yojson devi));

  Lwt.ignore_result @@ Lwt_js_events.clicks button_reset (fun _ _ -> Lwt.return @@ (label##.textContent := Js.some @@ Js.string ""));

  let _ = React.E.map (fun x -> ev_label##.textContent := Js.some @@ Js.string (Yojson.Safe.to_string @@ Board_ip_dektec_js.Board_types.board_status_to_yojson x)) (Board_ip_dektec_js.Requests.get_status_socket 5) in

  let ac = Dom_html.getElementById "arbitrary-content" in
  Dom.appendChild ac label;
  Dom.appendChild ac button_set;
  Dom.appendChild ac button_reset;
  Dom.appendChild ac ev_label;

  Js._false
               *)
