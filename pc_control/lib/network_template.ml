open Common.User
open Api.Template
open Api

module Icon = Components_markup.Icon.Make(Tyxml.Xml)(Tyxml.Svg)(Tyxml.Html)

let create () : upper ordered_item list user_table =
  let props = { title        = None
              ; pre_scripts  = [ Src "/js/janus.nojquery.js"
                               ; Src "/js/adapter.min.js" ]
              ; post_scripts = [ Src "/js/network.js" ]
              ; stylesheets  = []
              ; content      = []
              }
  in
  let icon x =
    let open Icon.SVG in
    let path = create_path x () in
    let icon = create [path] () in
    Tyxml.Html.toelt icon in
  let network_pages =
    [`Index 10,
     Simple { title    = "Параметры сети"
            ; icon     = Some (icon Icon.SVG.Path.lan)
            ; href     = Path.of_string "network"
            ; template = props }] in
  { root =
      [ `Index 5,
        Subtree { title     = "Настройки"
                ; icon      = Some (icon Icon.SVG.Path.settings)
                ; href      = Path.of_string "settings"
                ; templates = network_pages } ]
  ; operator = []
  ; guest    = []
  }
