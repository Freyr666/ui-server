open Containers
open Components
open Common

module Storage = Ui_templates.Storage.Local_storage

let key : string =
  Js.to_string Dom_html.window##.location##.href

let make_default (stream : Stream.ID.t)
    : Widget_factory.item Dashboard.Item.positioned_item list =
  let duration = Common.Time.Span.of_int_s 120 in
  let conf t =
    (Some { typ = t
          ; ids = [stream]
          ; duration
          ; settings = None } : Widget_chart.config option) in
  [ { item = Stream_chart (conf `Power)
    ; position = { x = 0; y = 0; w = 4; h = 2 }
    }
  ; { item = Stream_chart (conf `Mer)
    ; position = { x = 0; y = 2; w = 4; h = 2 }
    }
  ; { item = Stream_chart (conf `Ber)
    ; position = { x = 0; y = 4; w = 4; h = 2 }
    }
  ; { item = Stream_chart (conf `Freq)
    ; position = { x = 0; y = 6; w = 4; h = 2 }
    }
  ; { item = Stream_chart (conf `Bitrate)
    ; position = { x = 0; y = 8; w = 4; h = 2 }
    }
  ]

let make (stream : Stream.ID.t) (control:int) =
  let factory = new Widget_factory.t control () in
  let (init : 'a Dashboard.init) = match Storage.get key with
    | None -> Items (make_default stream)
    | Some x -> Serialized x in
  new Dashboard.t
    ~on_edit:(Storage.put key)
    ~edit_caps:(Partial { add = false; remove = false })
    ~init
    factory
    ()
