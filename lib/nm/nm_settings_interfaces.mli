(* File auto-generated by obus-gen-interface, DO NOT EDIT. *)
open OBus_member

module Org_freedesktop_NetworkManager_Settings_Connection : sig
  val interface : OBus_name.interface

  val m_ClearSecrets : (unit, unit) Method.t

  val m_Delete : (unit, unit) Method.t

  val m_GetSecrets :
    (string, (string * (string * OBus_value.V.single) list) list) Method.t

  val m_GetSettings :
    (unit, (string * (string * OBus_value.V.single) list) list) Method.t

  val m_Save : (unit, unit) Method.t

  val m_Update :
    ((string * (string * OBus_value.V.single) list) list, unit) Method.t

  val m_UpdateUnsaved :
    ((string * (string * OBus_value.V.single) list) list, unit) Method.t

  val s_PropertiesChanged : (string * OBus_value.V.single) list Signal.t

  val s_Removed : unit Signal.t

  val s_Updated : unit Signal.t

  val p_Unsaved : (bool, [ `readable ]) Property.t

  type 'a members = {
    m_ClearSecrets : 'a OBus_object.t -> unit -> unit Lwt.t;
    m_Delete : 'a OBus_object.t -> unit -> unit Lwt.t;
    m_GetSecrets :
      'a OBus_object.t ->
      string ->
      (string * (string * OBus_value.V.single) list) list Lwt.t;
    m_GetSettings :
      'a OBus_object.t ->
      unit ->
      (string * (string * OBus_value.V.single) list) list Lwt.t;
    m_Save : 'a OBus_object.t -> unit -> unit Lwt.t;
    m_Update :
      'a OBus_object.t ->
      (string * (string * OBus_value.V.single) list) list ->
      unit Lwt.t;
    m_UpdateUnsaved :
      'a OBus_object.t ->
      (string * (string * OBus_value.V.single) list) list ->
      unit Lwt.t;
    p_Unsaved : 'a OBus_object.t -> bool React.signal;
  }

  val make : 'a members -> 'a OBus_object.interface
end
