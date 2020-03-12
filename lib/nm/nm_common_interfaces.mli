(* File auto-generated by obus-gen-interface, DO NOT EDIT. *)
open OBus_member

module Org_freedesktop_NetworkManager : sig
  val interface : OBus_name.interface

  val m_ActivateConnection :
    (OBus_path.t * OBus_path.t * OBus_path.t, OBus_path.t) Method.t

  val m_AddAndActivateConnection :
    ( (string * (string * OBus_value.V.single) list) list
      * OBus_path.t
      * OBus_path.t,
      OBus_path.t * OBus_path.t )
    Method.t

  val m_CheckConnectivity : (unit, int32) Method.t

  val m_CheckpointCreate :
    (OBus_path.t list * int32 * int32, OBus_path.t) Method.t

  val m_CheckpointDestroy : (OBus_path.t, unit) Method.t

  val m_CheckpointRollback : (OBus_path.t, (string * int32) list) Method.t

  val m_DeactivateConnection : (OBus_path.t, unit) Method.t

  val m_Enable : (bool, unit) Method.t

  val m_GetAllDevices : (unit, OBus_path.t list) Method.t

  val m_GetDeviceByIpIface : (string, OBus_path.t) Method.t

  val m_GetDevices : (unit, OBus_path.t list) Method.t

  val m_GetLogging : (unit, string * string) Method.t

  val m_GetPermissions : (unit, (string * string) list) Method.t

  val m_Reload : (int32, unit) Method.t

  val m_SetLogging : (string * string, unit) Method.t

  val m_Sleep : (bool, unit) Method.t

  val m_state : (unit, int32) Method.t

  val s_CheckPermissions : unit Signal.t

  val s_DeviceAdded : OBus_path.t Signal.t

  val s_DeviceRemoved : OBus_path.t Signal.t

  val s_PropertiesChanged : (string * OBus_value.V.single) list Signal.t

  val s_StateChanged : int32 Signal.t

  val p_ActivatingConnection : (OBus_path.t, [ `readable ]) Property.t

  val p_ActiveConnections : (OBus_path.t list, [ `readable ]) Property.t

  val p_AllDevices : (OBus_path.t list, [ `readable ]) Property.t

  val p_Capabilities : (int32 list, [ `readable ]) Property.t

  val p_Connectivity : (int32, [ `readable ]) Property.t

  val p_Devices : (OBus_path.t list, [ `readable ]) Property.t

  val p_GlobalDnsConfiguration :
    ((string * OBus_value.V.single) list, [ `readable | `writable ]) Property.t

  val p_Metered : (int32, [ `readable ]) Property.t

  val p_NetworkingEnabled : (bool, [ `readable ]) Property.t

  val p_PrimaryConnection : (OBus_path.t, [ `readable ]) Property.t

  val p_PrimaryConnectionType : (string, [ `readable ]) Property.t

  val p_Startup : (bool, [ `readable ]) Property.t

  val p_State : (int32, [ `readable ]) Property.t

  val p_Version : (string, [ `readable ]) Property.t

  val p_WimaxEnabled : (bool, [ `readable | `writable ]) Property.t

  val p_WimaxHardwareEnabled : (bool, [ `readable ]) Property.t

  val p_WirelessEnabled : (bool, [ `readable | `writable ]) Property.t

  val p_WirelessHardwareEnabled : (bool, [ `readable ]) Property.t

  val p_WwanEnabled : (bool, [ `readable | `writable ]) Property.t

  val p_WwanHardwareEnabled : (bool, [ `readable ]) Property.t

  type 'a members = {
    m_ActivateConnection :
      'a OBus_object.t ->
      OBus_path.t * OBus_path.t * OBus_path.t ->
      OBus_path.t Lwt.t;
    m_AddAndActivateConnection :
      'a OBus_object.t ->
      (string * (string * OBus_value.V.single) list) list
      * OBus_path.t
      * OBus_path.t ->
      (OBus_path.t * OBus_path.t) Lwt.t;
    m_CheckConnectivity : 'a OBus_object.t -> unit -> int32 Lwt.t;
    m_CheckpointCreate :
      'a OBus_object.t -> OBus_path.t list * int32 * int32 -> OBus_path.t Lwt.t;
    m_CheckpointDestroy : 'a OBus_object.t -> OBus_path.t -> unit Lwt.t;
    m_CheckpointRollback :
      'a OBus_object.t -> OBus_path.t -> (string * int32) list Lwt.t;
    m_DeactivateConnection : 'a OBus_object.t -> OBus_path.t -> unit Lwt.t;
    m_Enable : 'a OBus_object.t -> bool -> unit Lwt.t;
    m_GetAllDevices : 'a OBus_object.t -> unit -> OBus_path.t list Lwt.t;
    m_GetDeviceByIpIface : 'a OBus_object.t -> string -> OBus_path.t Lwt.t;
    m_GetDevices : 'a OBus_object.t -> unit -> OBus_path.t list Lwt.t;
    m_GetLogging : 'a OBus_object.t -> unit -> (string * string) Lwt.t;
    m_GetPermissions : 'a OBus_object.t -> unit -> (string * string) list Lwt.t;
    m_Reload : 'a OBus_object.t -> int32 -> unit Lwt.t;
    m_SetLogging : 'a OBus_object.t -> string * string -> unit Lwt.t;
    m_Sleep : 'a OBus_object.t -> bool -> unit Lwt.t;
    m_state : 'a OBus_object.t -> unit -> int32 Lwt.t;
    p_ActivatingConnection : 'a OBus_object.t -> OBus_path.t React.signal;
    p_ActiveConnections : 'a OBus_object.t -> OBus_path.t list React.signal;
    p_AllDevices : 'a OBus_object.t -> OBus_path.t list React.signal;
    p_Capabilities : 'a OBus_object.t -> int32 list React.signal;
    p_Connectivity : 'a OBus_object.t -> int32 React.signal;
    p_Devices : 'a OBus_object.t -> OBus_path.t list React.signal;
    p_GlobalDnsConfiguration :
      ('a OBus_object.t -> (string * OBus_value.V.single) list React.signal)
      * ('a OBus_object.t -> (string * OBus_value.V.single) list -> unit Lwt.t);
    p_Metered : 'a OBus_object.t -> int32 React.signal;
    p_NetworkingEnabled : 'a OBus_object.t -> bool React.signal;
    p_PrimaryConnection : 'a OBus_object.t -> OBus_path.t React.signal;
    p_PrimaryConnectionType : 'a OBus_object.t -> string React.signal;
    p_Startup : 'a OBus_object.t -> bool React.signal;
    p_State : 'a OBus_object.t -> int32 React.signal;
    p_Version : 'a OBus_object.t -> string React.signal;
    p_WimaxEnabled :
      ('a OBus_object.t -> bool React.signal)
      * ('a OBus_object.t -> bool -> unit Lwt.t);
    p_WimaxHardwareEnabled : 'a OBus_object.t -> bool React.signal;
    p_WirelessEnabled :
      ('a OBus_object.t -> bool React.signal)
      * ('a OBus_object.t -> bool -> unit Lwt.t);
    p_WirelessHardwareEnabled : 'a OBus_object.t -> bool React.signal;
    p_WwanEnabled :
      ('a OBus_object.t -> bool React.signal)
      * ('a OBus_object.t -> bool -> unit Lwt.t);
    p_WwanHardwareEnabled : 'a OBus_object.t -> bool React.signal;
  }

  val make : 'a members -> 'a OBus_object.interface
end
