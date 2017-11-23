open Lwt_react
open Components
open Tyxml_js

let of_dom el = Tyxml_js.Of_dom.of_element (el :> Dom_html.element Js.t)

let demo_section ?(style="") ?(classes=[]) title content =
  Html.section ~a:[ Html.a_style ("margin: 24px; padding: 24px;\
                                   border: 1px solid rgba(0, 0, 0, .12);" ^ style)
                  ; Html.a_class classes ]
               ( Html.h2 ~a:[ Html.a_class [Typography.font_to_class Headline]] [Html.pcdata title]
                 :: content)
  |> Tyxml_js.To_dom.of_element

let subsection name elt = Html.div [ Html.h3 ~a:[Html.a_class [Typography.font_to_class Subheading_2]]
                                             [Html.pcdata name]
                                   ; elt ]

let button_demo () =
  let raised     = new Button.t ~label:"raised" () in
  let flat       = new Button.t ~raised:false ~label:"flat" () in
  let unelevated = new Button.t ~label:"unelevated" () in
  let stroked    = new Button.t ~label:"stroked" ~raised:false () in
  let ripple     = new Button.t ~label:"ripple" ~ripple:true () in
  let dense      = new Button.t ~label:"dense" () in
  let compact    = new Button.t ~label:"compact" () in
  let icon       = new Button.t ~label:"icon" ~icon:"favorite" () in
  raised#raised; unelevated#unelevated; stroked#stroked; dense#dense; compact#compact;
  demo_section ~style:"display:flex; \
                       flex-direction:column;\
                       justify-content:flex-start;\
                       align-items:flex-start"
               "Button"
               (List.map (fun x -> x#style##.margin := Js.string "10px"; of_dom x#root)
                         [raised;flat;unelevated;stroked;ripple;dense;compact;icon])

let fab_demo () =
  let fab    = subsection "General" @@ of_dom @@ (new Fab.t ~icon:"favorite" ())#root in
  let mini   = subsection "Mini"    @@ of_dom @@ (let b = new Fab.t ~icon:"favorite" () in b#mini; b#root) in
  let ripple = subsection "Ripple"  @@ of_dom @@ (new Fab.t ~ripple:true ~icon:"favorite" ())#root in
  demo_section "FAB" [fab;mini;ripple]

let radio_demo () =
  let radio1 = new Radio.t ~name:"radio" () in
  let radio2 = new Radio.t ~name:"radio" () in
  let radio3 = new Radio.t ~name:"radio" () in
  radio2#disable;
  demo_section "Radio button" [ of_dom radio1#root; of_dom radio2#root; of_dom radio3#root ]

let checkbox_demo () =
  let checkbox   = new Checkbox.t ~input_id:"checkbox-demo" () in
  let form_field = new Form_field.t ~label:"checkbox label" ~input:checkbox () in
  let raw        = subsection "Checkbox (css only)" @@ of_dom (new Checkbox.t ~ripple:false ())#root in
  let labelled   = subsection "Checkbox with label" (of_dom form_field#root) in
  demo_section "Checkbox" [ labelled; raw ]

let switch_demo () =
  let switch   = new Switch.t ~input_id:"demo-switch" () in
  let form     = new Form_field.t ~label:"switch label" ~input:switch () in
  let raw      = subsection "Switch" @@ of_dom (new Switch.t ())#root in
  let labelled = subsection "Switch with label" (of_dom form#root) in
  Dom_html.addEventListener switch#input
                            Dom_events.Typ.change
                            (Dom_html.handler (fun _ -> "Switch is " ^ (if switch#checked then "on" else "off")
                                                        |> fun s -> print_endline s; Js._false))
                            Js._false |> ignore;
  demo_section "Switch" [ raw; labelled ]

let toggle_demo () =
  let toggle = new Icon_toggle.t
                   ~on_data:{ icon = "favorite"; label = None; css_class = None }
                   ~off_data:{ icon = "favorite_border"; label = None; css_class = None }
                   () in
  Dom_html.addEventListener toggle#root
                            Icon_toggle.events.change
                            (Dom_html.handler (fun _ ->
                                 print_endline ("Icon Toggle is " ^ (if toggle#is_on then "on" else "off"));
                                 Js._false))
                            Js._false |> ignore;
  demo_section "Icon toggle" [ of_dom toggle#root ]

let card_demo () =
  let card = Card.create ~sections:[ Card.Media.create ~style:"background-image: url(\"https://maxcdn.icons8.com/app/uploads/2016/03/material-1-1000x563.jpg\");\
                                                               background-size: cover;\
                                                               background-repeat: no-repeat;\
                                                               height: 12.313rem;"
                                                       ~children:[]
                                                       ()
                                   ; Card.Primary.create
                                       ~children:[ Card.Primary.create_title ~large:true ~title:"Demo card title" ()
                                                 ; Card.Primary.create_subtitle ~subtitle:"Subtitle" ()]
                                       ()
                                   ; Card.Supporting_text.create
                                       ~children:[Html.pcdata "Supporting text"]
                                       ()
                                   ; Card.Actions.create
                                       ~children:[ (let b = new Button.t ~label:"action 1" () in
                                                    b#add_class Card.Actions.action_class;
                                                    b#compact;
                                                    of_dom b#root)
                                                 ; (let b = new Button.t ~label:"action 2" () in
                                                    b#add_class Card.Actions.action_class;
                                                    b#compact;
                                                    of_dom b#root)
                                                 ]
                                       ()]
                         ~style:"width:320px;"
                         () in
  demo_section "Card" [ card ]

let slider_demo () =
  let listen elt name =
    Dom_html.addEventListener elt
                              Slider.events.input
                              (Dom_html.handler (fun _ -> print_endline (Printf.sprintf "Input on %s slider!" name);
                                                          Js._false))
                              Js._false |> ignore;
    Dom_html.addEventListener elt
                              Slider.events.change
                              (Dom_html.handler (fun e -> print_endline ((Printf.sprintf "Change on %s slider! " name)
                                                                         ^ (e##.detail##.value |> string_of_float));
                                                          Js._false))
                              Js._false |> ignore in
  let continuous   = new Slider.t () in
  let discrete     = new Slider.t ~discrete:true () in
  let with_markers = new Slider.t ~discrete:true ~markers:true () in
  let disabled     = new Slider.t () in
  disabled#disable;
  listen continuous#root "continuous";
  listen discrete#root "discrete";
  listen with_markers#root "markered";
  Dom_html.setTimeout (fun () -> continuous#layout; discrete#layout; with_markers#layout) 100. |> ignore;
  demo_section "Slider" [ subsection "Continuous slider"            @@ of_dom continuous#root
                        ; subsection "Discrete slider"              @@ of_dom discrete#root
                        ; subsection "Discrete slider with markers" @@ of_dom with_markers#root
                        ; subsection "Disabled slider"              @@ of_dom disabled#root ]

let grid_list_demo () =
  let tiles = List.map (fun x -> new Grid_list.Tile.t
                                     ~src:"https://cs5-3.4pda.to/5290239.png"
                                     ~title:("My tile " ^ (string_of_int x))
                                     ~support_text:"Some text here"
                                     ())
                       (CCList.range 0 4) in
  let grid  = new Grid_list.t ~tiles () in
  demo_section "Grid list" [ of_dom grid#root ]

let ripple_demo () =
  let bounded        = new Widget.widget (Html.div ~a:[Html.a_style "height: 200px; width: 200px; margin: 20px"] []
                                          |> To_dom.of_element) () in
  Elevation.set_elevation bounded 5; Ripple.attach bounded |> ignore;
  let bounded_sect   = subsection "Bounded ripple. Click me!" @@ of_dom bounded#root in
  let unbounded      = new Icon.Font.t ~icon:"favorite" () in
  Ripple.attach unbounded |> ignore; Ripple.set_unbounded unbounded;
  let unbounded_sect = subsection "Unbounded ripple. Click me!" @@ of_dom unbounded#root in
  demo_section "Ripple" [ bounded_sect; unbounded_sect ]

let layout_grid_demo () =
  let cells = List.map (fun x -> let w = Html.div ~a:[Html.a_style "box-sizing: border-box;\
                                                                    background-color: #666666;\
                                                                    height: 200px;\
                                                                    padding: 8px;\
                                                                    color: white;\
                                                                    font-size: 1.5em;"]
                                                  [Html.pcdata ( "id=" ^ (string_of_int x)
                                                                 ^ "\nspan="
                                                                 ^ (string_of_int (if x = 3
                                                                                   then 2
                                                                                   else 1)))]
                                       |> Tyxml_js.To_dom.of_element
                                       |> (fun x -> new Widget.widget x ()) in
                                 new Layout_grid.Cell.t ~content:[w] ()
                                 |> (fun x -> x#set_span 1; x))
                       (CCList.range 0 15) in
  let btn2 = new Button.t ~label:"set span 1" () in
  let btn4 = new Button.t ~label:"set span 2" () in
  Dom_html.addEventListener btn2#root
                            Dom_events.Typ.click
                            (Dom_html.handler (fun _ -> (CCList.get_at_idx_exn 4 cells)
                                                        |> (fun cell -> cell#set_span 1);
                                                        Js._false))
                            Js._false |> ignore;
  Dom_html.addEventListener btn4#root
                            Dom_events.Typ.click
                            (Dom_html.handler (fun _ -> (CCList.get_at_idx_exn 4 cells)
                                                        |> (fun cell -> cell#set_span 2);
                                                        Js._false))
                            Js._false |> ignore;
  let layout_grid = new Layout_grid.t ~cells () in
  demo_section "Layout grid" [ of_dom layout_grid#root ; of_dom btn2#root; of_dom btn4#root ]

let dialog_demo () =
  let dialog = new Dialog.t
                   ~title:"This is dialog"
                   ~content:(`String "Dialog body")
                   ~actions:[ new Dialog.Action.t ~typ:`Decline ~label:"Decline" ()
                            ; new Dialog.Action.t ~typ:`Accept  ~label:"Accept" ()
                            ]
                   () in
  let button = new Button.t ~label:"show dialog" () in
  Dom_html.addEventListener button#root
                            Dom_events.Typ.click
                            (Dom_html.handler (fun _ -> dialog#show; Js._false))
                            Js._false |> ignore;
  Dom_html.addEventListener dialog#root
                            Dialog.events.accept
                            (Dom_html.handler (fun _ -> print_endline "Dialog accepted!"; Js._false))
                            Js._false |> ignore;
  Dom_html.addEventListener dialog#root
                            Dialog.events.cancel
                            (Dom_html.handler (fun _ -> print_endline "Dialog cancelled!"; Js._false))
                            Js._false |> ignore;
  demo_section "Dialog" [ of_dom dialog#root; of_dom button#root ]

let list_demo () =
  let items = List.map (fun x -> if x = 3
                                 then `Divider (new List_.Divider.t ())
                                 else `Item (new List_.Item.t
                                                 ~text:("List item " ^ (string_of_int x))
                                                 ~secondary_text:"some subtext here"
                                                 ~start_detail:(new Avatar.Letter.t ~text:"A" ())
                                                 ~ripple:true
                                                 ()))
                       (CCList.range 0 5) in
  let list = new List_.t ~avatar:true ~items () in
  list#style##.maxWidth := Js.string "400px";
  let list1 = new List_.t
                  ~items:[ `Item (new List_.Item.t ~text:"Item 1" ~secondary_text:"Subtext" ())
                         ; `Item (new List_.Item.t ~text:"Item 2" ~secondary_text:"Subtext" ())
                         ; `Item (new List_.Item.t ~text:"Item 3" ~secondary_text:"Subtext" ())
                         ]
                  () in
  let list2 = new List_.t
                  ~items:[ `Item (new List_.Item.t ~text:"Item 1" ~secondary_text:"Subtext" ())
                         ; `Item (new List_.Item.t ~text:"Item 2" ~secondary_text:"Subtext" ())
                         ; `Item (new List_.Item.t ~text:"Item 3" ~secondary_text:"Subtext" ())
                         ]
                  () in
  let group = new List_.List_group.t
                  ~content:[ { subheader = Some "Group 1"; list = list1 }
                           ; { subheader = Some "Group 2"; list = list2 }
                           ]
                  () in
  group#style##.maxWidth := Js.string "400px";
  demo_section "List" [ of_dom list#root; of_dom group#root ]

let tree_demo () =
  let item x = new Tree.Item.t
                   ~text:("Item " ^ string_of_int x)
                   ~nested:(new Tree.t
                                ~items:[ new Tree.Item.t ~text:"Item 0" ()
                                       ; new Tree.Item.t ~text:"Item 1" ()
                                       ; new Tree.Item.t ~text:"Item 2" () ]
                                ())
                   () in
  let tree = new Tree.t
                 ~items:(List.map (fun x -> item x) (CCList.range 0 5))
                 () in
  tree#style##.maxWidth := Js.string "400px";
  demo_section "Tree" [ of_dom tree#root ]

let menu_demo () =
  let items    = List.map (fun x -> if x != 2
                                    then `Item (new Menu.Item.t ~text:("Menu item " ^ (string_of_int x)) ())
                                    else `Divider (new Menu.Divider.t ()))
                          (CCList.range 0 5) in
  let anchor  = new Button.t ~label:"Open menu" () in
  anchor#style##.marginBottom := Js.string "50px";
  let menu    = new Menu.t ~items () in
  let wrapper = new Menu.Wrapper.t ~menu ~anchor () in
  menu#dense;
  let icon_anchor = new Icon.Font.t ~icon:"more_horiz" () in
  let icon_menu   = new Menu.t
                        ~items:[ `Item (new Menu.Item.t ~text:"Item 1" ())
                               ; `Item (new Menu.Item.t ~text:"Item 2" ())
                               ; `Item (new Menu.Item.t ~text:"Item 3" ()) ]
                        () in
  let icon_wrapper = new Menu.Wrapper.t ~menu:icon_menu ~anchor:icon_anchor () in
  Dom_html.addEventListener anchor#root
                            Dom_events.Typ.click
                            (Dom_html.handler (fun _ -> menu#show; Js._false))
                            Js._false
  |> ignore;
  Dom_html.addEventListener icon_anchor#root
                            Dom_events.Typ.click
                            (Dom_html.handler (fun _ -> icon_menu#show; Js._false))
                            Js._false
  |> ignore;
  Dom_html.addEventListener menu#root
                            Menu.events.selected
                            (Dom_html.handler (fun d ->
                                 print_endline ("Selected menu item is " ^ (d##.detail##.index
                                                                            |> string_of_int));
                                 Js._false))
                            Js._false
  |> ignore;
  Dom_html.addEventListener menu#root
                            Menu.events.cancel
                            (Dom_html.handler (fun _ -> print_endline "Menu cancelled"; Js._false))
                            Js._false
  |> ignore;
  demo_section "Menu" [ of_dom wrapper#root; of_dom icon_wrapper#root ]

let linear_progress_demo () =
  let linear_progress = new Linear_progress.t () in
  linear_progress#indeterminate;
  let listen x h = Dom_html.addEventListener x#root
                                             Dom_events.Typ.click
                                             (Dom_html.handler (fun _ -> h (); Js._false))
                                             Js._false |> ignore in
  let ind_btn   = new Button.t ~label:"indeterminate" () in
  let det_btn   = new Button.t ~label:"determinate" () in
  let pgs0_btn  = new Button.t ~label:"progress 0" () in
  let pgs20_btn = new Button.t ~label:"progress 20" () in
  let pgs60_btn = new Button.t ~label:"progress 60" () in
  let buf10_btn = new Button.t ~label:"buffer 10" () in
  let buf30_btn = new Button.t ~label:"buffer 30" () in
  let buf70_btn = new Button.t ~label:"buffer 70" () in
  let open_btn  = new Button.t ~label:"open" () in
  let close_btn = new Button.t ~label:"close" () in
  listen ind_btn   (fun () -> linear_progress#indeterminate);
  listen det_btn   (fun () -> linear_progress#determinate);
  listen pgs0_btn  (fun () -> linear_progress#set_progress 0.);
  listen pgs20_btn (fun () -> linear_progress#set_progress 0.2);
  listen pgs60_btn (fun () -> linear_progress#set_progress 0.6);
  listen buf10_btn (fun () -> linear_progress#set_buffer 0.1);
  listen buf30_btn (fun () -> linear_progress#set_buffer 0.3);
  listen buf70_btn (fun () -> linear_progress#set_buffer 0.7);
  listen open_btn  (fun () -> linear_progress#show);
  listen close_btn (fun () -> linear_progress#hide);
  let cells = List.map (fun x -> new Layout_grid.Cell.t ~content:[x] ()
                                 |> (fun x -> x#set_span 12; x))
                       [ind_btn  ; det_btn  ; pgs0_btn ; pgs20_btn; pgs60_btn;
                        buf10_btn; buf30_btn; buf70_btn; open_btn ; close_btn ] in
  let btn_grid = new Layout_grid.t ~cells () in
  demo_section "Linear progress" [ of_dom btn_grid#root; of_dom linear_progress#root ]

let tabs_demo () =
  let icon_bar  = [ new Tabs.Tab.t ~icon:"pets" ()
                  ; new Tabs.Tab.t ~icon:"favorite" ()
                  ; new Tabs.Tab.t ~icon:"grade" ()
                  ; new Tabs.Tab.t ~icon:"room" () ]
                  |> (fun tabs -> new Tabs.Tab_bar.t ~tabs ()) in
  let icon_sect = subsection "With icon labels" @@ of_dom icon_bar#root in
  let text_bar  = List.map (fun x -> new Tabs.Tab.t ~text:("Tab " ^ (string_of_int x)) ())
                           (CCList.range 0 3)
                  |> (fun tabs -> new Tabs.Tab_bar.t ~tabs ()) in
  let text_sect = subsection "With text labels" @@ of_dom text_bar#root in
  let both_bar  = [ new Tabs.Tab.t ~text:"Tab 0" ~icon:"pets" ()
                  ; new Tabs.Tab.t ~text:"Tab 1" ~icon:"favorite" ()
                  ; new Tabs.Tab.t ~text:"Tab 2" ~icon:"grade" ()
                  ; new Tabs.Tab.t ~text:"Tab 3" ~icon:"room" () ]
                  |> (fun tabs -> new Tabs.Tab_bar.t ~tabs ()) in
  let both_sect = subsection "With icon and text labels" @@ of_dom both_bar#root in
  let scrl_bar  = List.map (fun x -> new Tabs.Tab.t ~text:("Tab " ^ (string_of_int x)) ())
                           (CCList.range 0 15)
                  |> (fun tabs -> new Tabs.Scroller.t ~tabs ()) in
  let scrl_sect = subsection "With scroller" @@ of_dom scrl_bar#root in
  (* let btn       = new Button.t ~label:"add" () in
   * Dom_html.addEventListener
   *   btn#root
   *   Dom_events.Typ.click
   *   (Dom_html.handler (fun _ -> both_bar#add_tab (new Tabs.Tab.t ~text:"Tab 0" ~icon:"pets" ()); Js._false))
   *   Js._false |> ignore; *)
  demo_section "Tabs" [ text_sect; icon_sect; both_sect; scrl_sect(* ; of_dom btn#root *) ]

let snackbar_demo () =
  let listen x h = Dom_html.addEventListener x#root
                                             Dom_events.Typ.click
                                             (Dom_html.handler (fun _ -> h (); Js._false))
                                             Js._false |> ignore in
  let snackbar = new Snackbar.t
                     ~message:"I am a snackbar"
                     ~action:{ handler = (fun () -> print_endline "Clicked on snackbar action")
                             ; text    = "Action"}
                     () in
  let aligned  = new Snackbar.t
                     ~start_aligned:true
                     ~message:"I am a snackbar"
                     ~action:{ handler = (fun () -> print_endline "Clicked on snackbar action")
                             ; text    = "Action"}
                     () in
  let snackbar_btn = new Button.t ~label:"Open snackbar" () in
  let aligned_btn  = new Button.t ~label:"Open start-aligned snackbar" () in
  listen snackbar_btn (fun () -> snackbar#show);
  listen aligned_btn (fun () -> aligned#show);
  demo_section "Snackbar" [of_dom snackbar#root    ; of_dom aligned#root;
                           of_dom snackbar_btn#root; of_dom aligned_btn#root ]

let textfield_demo () =
  (* CSS only textbox *)
  let css      = new Textfield.Pure.t ~placeholder:"placeholder" ~input_id:"demo-css-textfield" () in
  let css_form = new Form_field.t ~label:"css textfield label: " ~input:css ~align_end:true () in
  let css_sect = subsection "CSS only textfield" @@ of_dom css_form#root in
  (* Full-featured js textbox *)
  let js       = new Textfield.t
                     ~label:"js textfield label"
                     ~help_text:{ validation = true
                                ; persistent = false
                                ; text       = "This field must not be empty"
                                }
                     () in
  js#required;
  let js_sect  = subsection "JS textfield" @@ of_dom js#root in
  (* Dense js textbox with *)
  let dense    = new Textfield.t
                     ~label:"dense textfield label"
                     ~input_type:`Email
                     ~help_text:{ validation = true
                                ; persistent = false
                                ; text       = "Provide valid e-mail"
                                }
                     () in
  dense#dense;
  let dense_sect = subsection "Dense textfield (with email validation)" @@ of_dom dense#root in
  (* Textboxes with icons *)
  let lead_icon  = new Textfield.t
                       ~label:"textfield label"
                       ~icon:{ icon      = "event"
                             ; clickable = false
                             ; pos       = `Leading }
                       () in
  let trail_icon = new Textfield.t
                       ~label:"textfield label"
                       ~icon:{ icon      = "delete"
                             ; clickable = false
                             ; pos       = `Trailing }
                       () in
  let icon_sect   = subsection "With icons" @@ Html.div ~a:([Html.a_style "display: flex;\
                                                                           max-width: 300px;\
                                                                           flex-direction: column;"])
                                                        [ of_dom lead_icon#root
                                                        ; of_dom trail_icon#root ] in
  (* Textareas *)
  let css_textarea      = new Textarea.Pure.t ~placeholder:"Enter something" ~rows:8 ~cols:40 () in
  let textarea          = new Textarea.t ~label:"textarea label" ~rows:8 ~cols:40 () in
  let css_textarea_sect = subsection "Textarea (css only)" @@ of_dom css_textarea#root in
  let textarea_sect     = subsection "Textarea"            @@ of_dom textarea#root in
  demo_section "Textfield" [ css_sect; js_sect; dense_sect; icon_sect; css_textarea_sect; textarea_sect ]

let select_demo () =
  let js      = new Select.Base.t
                    ~placeholder:"Pick smth"
                    ~items:(List.map (fun x -> new Select.Base.Item.t
                                                   ~id:("index " ^ (string_of_int x))
                                                   ~text:("Select item " ^ (string_of_int x))
                                                   ())
                                     (CCList.range 0 5))
                    () in
  js#dense;
  let js_sect = subsection "Full-fidelity select" @@ of_dom js#root in
  let pure    = new Select.Pure.t
                    ~items:[ `Group (new Select.Pure.Group.t
                                         ~label:"Group 1"
                                         ~items:[ new Select.Pure.Item.t ~text:"Item 1" ()
                                                ; new Select.Pure.Item.t ~text:"Item 2" ()
                                                ; new Select.Pure.Item.t ~text:"Item 3" ()]
                                         ())
                           ; `Item (new Select.Pure.Item.t ~text:"Item 1" ())
                           ; `Item (new Select.Pure.Item.t ~text:"Item 2" ())
                           ; `Item (new Select.Pure.Item.t ~text:"Item 3" ())
                           ]
                    () in
  let pure_sect = subsection "Pure (css-only) select" @@ of_dom pure#root in
  let multi = [ `Group (new Select.Multi.Group.t
                            ~label:"Group 1"
                            ~items:(List.map (fun x -> let text = "Group item " ^ (string_of_int x) in
                                                       new Select.Multi.Item.t ~text ())
                                             (CCList.range 0 2))
                            ())
              ; `Divider (new Select.Multi.Divider.t ())
              ; `Group (new Select.Multi.Group.t
                            ~label:"Group 2"
                            ~items:(List.map (fun x -> let text = "Group item " ^ (string_of_int x) in
                                                       new Select.Multi.Item.t ~text ())
                                             (CCList.range 0 2))
                            ())
              ; `Divider (new Select.Multi.Divider.t ())
              ; `Item (new Select.Multi.Item.t ~text:"Item 1" ())
              ; `Item (new Select.Multi.Item.t ~text:"Item 2" ()) ]
              |> (fun items -> new Select.Multi.t ~items ~size:12 ()) in
  let multi_sect = subsection "CSS-only multi select" @@ of_dom multi#root in
  demo_section "Select" [ js_sect; pure_sect; multi_sect ]

let toolbar_demo (drawer : Drawer.Persistent.t Js.t) () =
  let last_row = Toolbar.Row.create
                   ~content:[ Toolbar.Row.Section.create
                                ~align:`Start
                                ~content:[ Html.i ~a:[Html.a_class [ "material-icons"
                                                                   ; Toolbar.Row.Section.icon_class]
                                                     ; Html.a_onclick (fun _ -> if drawer##.open_ |> Js.to_bool
                                                                                then drawer##.open_ := Js._false
                                                                                else drawer##.open_ := Js._true
                                                                              ; true)]
                                                  [Html.pcdata "menu"]
                                         ; Toolbar.Row.Section.create_title ~title:"Widgets demo page" () ]
                                ()
                            ; Toolbar.Row.Section.create
                                ~align:`End
                                ~content:[Html.i ~a:[Html.a_class [ "material-icons"
                                                                  ; Toolbar.Row.Section.icon_class]]
                                                 [Html.pcdata "favorite"]]
                                ()
                            ]
                   () in
  let toolbar = Toolbar.create ~content:[ last_row ]
                               ~id:"toolbar"
                               ~waterfall:true
                               ~flexible:true
                               ~fixed:true
                               () in
  To_dom.of_element toolbar

let elevation_demo () =
  let d = new Widget.widget (Html.div ~a:[Html.a_style "height: 200px; width: 200px; margin: 20px"]
                                      []
                             |> To_dom.of_element) () in
  let btn2 = new Button.t ~label:"elevation 2" () in
  let btn8 = new Button.t ~label:"elevation 8" () in
  Dom_html.addEventListener btn2#root
                            Dom_events.Typ.click
                            (Dom_html.handler (fun _ -> Elevation.set_elevation d 2; Js._false))
                            Js._false |> ignore;
  Dom_html.addEventListener btn8#root
                            Dom_events.Typ.click
                            (Dom_html.handler (fun _ -> Elevation.set_elevation d 8; Js._false))
                            Js._false |> ignore;
  demo_section "Elevation" [of_dom d#root; of_dom btn2#root; of_dom btn8#root]

let drawer_demo () =
  Drawer.Temporary.create ~content:[Drawer.Temporary.Toolbar_spacer.create ~content:[Html.pcdata "Demo"]
                                                                           ()]
                          ()
  |> Drawer.Temporary.attach

let chart_demo () =
  Chartjs.create_canvas () |> Tyxml_js.To_dom.of_canvas

let add_demos demos =
  Html.div ~a:[ Html.a_id "demo-div" ]
           @@ CCList.map (fun x -> Of_dom.of_element (x :> Dom_html.element Js.t)) demos
  |> To_dom.of_element

let onload _ =
  let doc = Dom_html.document in
  let body = doc##.body in
  let drawer  = drawer_demo () in
  let toolbar = toolbar_demo drawer () in
  let canvas = chart_demo () in
  let demos = add_demos [ button_demo ()
                        ; Tyxml_js.Html.div ~a:[ Html.a_style "max-width:700px"]
                                            [canvas |> Tyxml_js.Of_dom.of_canvas]
                          |> Tyxml_js.To_dom.of_element
                        ; fab_demo ()
                        ; radio_demo ()
                        ; checkbox_demo ()
                        ; switch_demo ()
                        ; toggle_demo ()
                        ; elevation_demo ()
                        ; select_demo ()
                        ; textfield_demo ()
                        ; card_demo ()
                        ; slider_demo ()
                        ; grid_list_demo ()
                        ; ripple_demo ()
                        ; layout_grid_demo ()
                        ; dialog_demo ()
                        ; list_demo ()
                        ; tree_demo ()
                        ; menu_demo ()
                        ; snackbar_demo ()
                        ; linear_progress_demo ()
                        ; tabs_demo ()
                        ] in
  Dom.appendChild body toolbar;
  Dom.appendChild body drawer##.root__;
  Dom.appendChild body demos;
  Dom.appendChild body toolbar;
  let js_toolbar = Toolbar.attach toolbar in
  js_toolbar##.fixedAdjustElement := demos;
  let open Chartjs.Line in
  Random.init (Unix.time () |> int_of_float);
  let data = Data.to_obj ~datasets:[ Data.Dataset.to_obj ~label:"My data 1"
                                                         ~fill:(Bool false)
                                                         ~border_color:"rgba(255,0,0,1)"
                                                         ~data:(Points (List.map
                                                                          (fun x -> ({ x = (float_of_int x)
                                                                                     ; y = Random.float 10.
                                                                                     } : Data.Dataset.xy))
                                                                          (CCList.range 0 20))
                                                                : Data.Dataset.data)
                                                         ()
                                   ; Data.Dataset.to_obj ~label:"My data 2"
                                                         ~fill:(Bool false)
                                                         ~border_color:"rgba(0,255,0,1)"
                                                         ~data:(Points (List.map
                                                                          (fun x -> ({ x = (float_of_int x)
                                                                                     ; y = Random.float 50.
                                                                                     } : Data.Dataset.xy))
                                                                          (CCList.range 0 20))
                                                                : Data.Dataset.data)
                                                         ()
                                   ]
                         ~labels:(CCList.range 0 20 |> List.map string_of_int)
                         () in
  let open Chartjs in
  let _ = Chartjs.Line.attach
             ~data
             ~options:(Options.to_obj
                         ~on_hover:(fun e (a:'a Js.js_array Js.t) ->
                           print_endline ("hover! type: "
                                          ^ (Js.to_string @@ e##._type)
                                          ^ ", array length: "
                                          ^ (string_of_int @@ a##.length)))
                         ~on_click:(fun e (a:'a Js.js_array Js.t) ->
                           print_endline ("click! type: "
                                          ^ (Js.to_string @@ e##._type)
                                          ^ ", array length: "
                                          ^ (string_of_int @@ a##.length)))
                         ~hover:(Options.Hover.to_obj ~mode:Index
                                                      ~intersect:false
                                                      ())
                         ~tooltips:(Options.Tooltip.to_obj ~mode:Index
                                                           ~intersect:false
                                                           ())
                         ~scales:(Options.Axes.to_obj
                                    ~x_axes:[ Options.Axes.Cartesian.Linear.to_obj
                                                ~scale_label:(Options.Axes.Scale_label.to_obj
                                                                ~display:true
                                                                ~label_string:"My x axis"
                                                                ())
                                                ()
                                            ]
                                    ())
                         ())
             canvas in
  Js._false

let () = Dom_html.addEventListener Dom_html.document
                                   Dom_events.Typ.domContentLoaded
                                   (Dom_html.handler onload)
                                   Js._false
         |> ignore