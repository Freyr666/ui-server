open Application_types
open Board_niitv_ts2ip_types

let full devinfo (mode : udp_mode list) =
  match devinfo with
  | None -> Error `Forbidden
  | Some info ->
    let len = List.length mode in
    if len > info.packers_num
    then Error (`Limit_exceeded (info.packers_num, len))
    else Ok mode

let succ_mcast addr =
  Netlib.Ipaddr.(V4.of_int32 @@ Int32.add (V4.to_int32 addr) 1l)

let simple ports devinfo (streams : Stream.t list) =
  let settings =
    let rec pack dst_ip dst_port acc = function
      | [] -> acc
      | (stream : Stream.t) :: tl ->
        let id = match stream.orig_id with
          | Stream.TS_raw -> Some (Stream.Multi_TS_ID.of_int32_pure 0l)
          | TS_multi id -> Some id
          | _ -> None in
        match id, stream_to_socket ports stream with
        | Some id, Some socket ->
          let s =
            { dst_ip
            ; dst_port
            ; enabled = true
            ; stream = id
            ; stream_id = Some stream.id
            ; self_port = 2027
            ; socket
            } in
          pack (succ_mcast dst_ip) (succ dst_port) (s :: acc) tl
        | _ -> pack dst_ip dst_port acc tl in
    pack (Netlib.Ipaddr.V4.make 224 1 2 2) 1234 [] streams
  in
  full devinfo settings
