type env = Api.env

type 'a response = 'a Api.response
(*
let is_ws headers = match Cohttp.Header.get headers "upgrade" with
  | Some "websocket" -> true
  | _                -> false
 *)

let env_of_headers headers : env =
  let env : type a. a Api.key -> a option = function
    | Api.Key k ->
       Cohttp.Header.get headers k
    | Api.Auth ->
       match Cohttp.Header.get_authorization headers with
       | Some (`Basic b) -> Some b
       | _ -> None
  in { env }

let respond_need_auth = Cohttp_lwt_unix.Server.respond_need_auth

(*
let respond_not_found = Cohttp_lwt_unix.Server.respond_not_found

let respond_file base path =
  Cohttp_lwt_unix.Server.respond_file
    ~fname:(Filename.concat base path)
 *)
let respond_string ?(status = `OK) body =
  Cohttp_lwt_unix.Server.respond_string ~status ~body
(*
let respond_html_elt ?(status = `OK) body =
  Cohttp_lwt_unix.Server.respond ~status
    ~body:(Cohttp_lwt.Body.of_string
           @@ Format.asprintf "%a" (Tyxml.Html.pp_elt ()) body)

let respond_redirect path =
  Cohttp_lwt_unix.Server.respond_redirect
    ~uri:(Uri.with_path Uri.empty path)
 *)
let respond_error ?(status = `Forbidden) error =
  Cohttp_lwt_unix.Server.respond_error ~status ~body:error

(* TODO make use of Result resp types
  
let respond' ?headers ?flush ?(status = `OK) ~body () =
  let headers = match M.content_type with
    | Some s -> Some (Cohttp.Header.add_opt_unless_exists headers "Content-Type" s)
    | None -> None
  in Cohttp_lwt_unix.Server.respond ?headers ?flush ~status ~body ()

let respond ?headers ?flush ?status x () =
  respond' ?headers ?flush ?status ~body:(to_body x) ()

let respond_result ?(err_status=`Bad_request) = function
  | Ok x -> respond x ()
  | Error x -> respond ~status:err_status x ()

let respond_result_unit ?(err_status=`Bad_request) = function
  | Ok () -> respond' ~body:Cohttp_lwt.Body.empty ()
  | Error x -> respond ~status:err_status x ()

 *)

module Redirect = Redirect
                
module Make (User : Api.USER) (Body : Api.BODY) : sig

  include Api.S
          with type state = Cohttp_lwt_unix.Request.t * Conduit_lwt_unix.flow
           and type user = User.t
           and type body = Body.t
           and type meth = Cohttp.Code.meth
           and type path = Netlib.Uri.t
           and type answer = [ Api.Authorize.error
                             | Body.t response
                             | `Instant of (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t
                             ]
           and type response = (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t
           and type 'a handler =
                      Cohttp.Code.meth * 'a Netlib.Uri.Dispatcher.node

  val make : ?prefix:string
             -> node list
             -> t

  val node : ?doc:string
             -> ?restrict:user list
             -> meth:meth
             -> path:('a, 'b) Netlib.Uri.Path.Format.t
             -> query:('b, user -> body -> env -> state -> answer Lwt.t)
                  Netlib.Uri.Query.format
             -> 'a
             -> node

end = struct

  open Netlib

  module Meth_map = Map.Make (struct
                        type t = Cohttp.Code.meth
                        let compare : t -> t -> int = Pervasives.compare
                      end) 

  type state = Cohttp_lwt_unix.Request.t * Conduit_lwt_unix.flow

  type user = User.t

  type body = Body.t

  type meth = Cohttp.Code.meth

  type path = Netlib.Uri.t

  type answer = [ Api.Authorize.error
                | Body.t response
                | `Instant of (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t
                ] 

  type response = (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t

  type 'a handler =
    Cohttp.Code.meth * 'a Netlib.Uri.Dispatcher.node

  type node =
    (user -> body -> env -> state -> answer Lwt.t) handler

  type t =
    (user -> body -> env -> state -> answer Lwt.t)
      Netlib.Uri.Dispatcher.t
      Meth_map.t 

  let handle (tbl : t) ~state ?(meth=`GET) ?default ~env ~redir uri body =
    let open Lwt.Infix in
    let body = match Body.of_string body with
      | Ok v -> v
      | Error _ -> failwith ""
    in
    let default = match default with
      | None -> fun (_user : user) _body _env _state ->
                Lwt.return (`Error "bad request")
      | Some v -> fun (_user : user) _body _env _state ->
                  Lwt.return (`Instant (v ()))
    in
    redir env >>= function
    | Error #Api.Authorize.error ->
       respond_need_auth ~auth:(`Basic "User Visible Realm") ()
    | Ok user ->
       let ans = match Meth_map.find_opt meth tbl with
         | None ->
            default user body env state
         | Some tbl ->
            Uri.Dispatcher.dispatch ~default tbl uri user body env state
       in ans >>= function (* TODO check resp types *)
          | `Unknown e ->
             respond_error e ()
          | #Api.Authorize.error -> (* TODO check resp types *)
             respond_need_auth ~auth:(`Basic "User Visible Realm") ()
          | `Instant resp ->
             resp
          | `Value body ->
             respond_string (Body.to_string body) ()
          | `Unit ->
             respond_string "" () (* TODO there should be something better that string *)
          | `Not_implemented ->
             respond_error ~status:`Not_implemented "FIXME" ()
          | `Error e ->
             respond_error e ()  

  let make ?prefix nodes =
    let add_node map (meth, node) =
      let node = match prefix with
        | None -> node
        | Some prefix ->
           assert (String.length prefix <> 0);
           Uri.Dispatcher.prepend (Uri.Path.of_string prefix) node
      in
      let update = function
        | None ->
           Some Uri.Dispatcher.(add empty node)
        | Some disp ->
           Some Uri.Dispatcher.(add disp node)
      in Meth_map.update meth update map
    in 
    nodes
    |> List.fold_left add_node Meth_map.empty

  let merge ?prefix handlers =
    let flat _meth l r =
      match l, r with
      | Some tl, Some h -> Some (h::tl)
      | (Some _ as v), None -> v
      | None, Some h -> Some [h]
      | None, None -> None
    in 
    match prefix with
    | None ->
       handlers
       |> List.fold_left (Meth_map.merge flat) Meth_map.empty
       |> Meth_map.map Uri.Dispatcher.concat
    | Some prefix ->
       assert (String.length prefix <> 0);
       let path = Uri.Path.of_string prefix in
       handlers
       |> List.fold_left (Meth_map.merge flat) Meth_map.empty
       |> Meth_map.map (fun disps ->
              Uri.Dispatcher.(merge empty [path, disps]))

  let transform not_allowed f =
    fun user body env state ->
    if not_allowed user
    then Lwt.return (`Error "access denied")
    else f user body env state
    
  let node ?doc ?(restrict=[]) ~meth ~path ~query handler : node =
    let not_allowed id = List.exists (User.equal id) restrict in
    Uri.Dispatcher.make ?docstring:doc ~path ~query handler
    |> Uri.Dispatcher.map_node (transform not_allowed)
    |> fun node -> meth, node 

end
