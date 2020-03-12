(* File auto-generated by obus-gen-interface, DO NOT EDIT. *)
open OBus_member

module Org_freedesktop_DBus_Introspectable : sig
  val interface : OBus_name.interface

  val m_Introspect : (unit, string) Method.t

  type 'a members = { m_Introspect : 'a OBus_object.t -> unit -> string Lwt.t }

  val make : 'a members -> 'a OBus_object.interface
end

module Org_freedesktop_DBus_Peer : sig
  val interface : OBus_name.interface

  val m_GetMachineId : (unit, string) Method.t

  val m_Ping : (unit, unit) Method.t

  type 'a members = {
    m_GetMachineId : 'a OBus_object.t -> unit -> string Lwt.t;
    m_Ping : 'a OBus_object.t -> unit -> unit Lwt.t;
  }

  val make : 'a members -> 'a OBus_object.interface
end

module Org_freedesktop_DBus_Properties : sig
  val interface : OBus_name.interface

  val m_Get : (string * string, OBus_value.V.single) Method.t

  val m_GetAll : (string, (string * OBus_value.V.single) list) Method.t

  val m_Set : (string * string * OBus_value.V.single, unit) Method.t

  val s_PropertiesChanged :
    (string * (string * OBus_value.V.single) list * string list) Signal.t

  type 'a members = {
    m_Get : 'a OBus_object.t -> string * string -> OBus_value.V.single Lwt.t;
    m_GetAll :
      'a OBus_object.t -> string -> (string * OBus_value.V.single) list Lwt.t;
    m_Set :
      'a OBus_object.t -> string * string * OBus_value.V.single -> unit Lwt.t;
  }

  val make : 'a members -> 'a OBus_object.interface
end

module Org_freedesktop_login1_Manager : sig
  val interface : OBus_name.interface

  val m_ActivateSession : (string, unit) Method.t

  val m_ActivateSessionOnSeat : (string * string, unit) Method.t

  val m_AttachDevice : (string * string * bool, unit) Method.t

  val m_CanHalt : (unit, string) Method.t

  val m_CanHibernate : (unit, string) Method.t

  val m_CanHybridSleep : (unit, string) Method.t

  val m_CanPowerOff : (unit, string) Method.t

  val m_CanReboot : (unit, string) Method.t

  val m_CanRebootParameter : (unit, string) Method.t

  val m_CanRebootToBootLoaderEntry : (unit, string) Method.t

  val m_CanRebootToBootLoaderMenu : (unit, string) Method.t

  val m_CanRebootToFirmwareSetup : (unit, string) Method.t

  val m_CanSuspend : (unit, string) Method.t

  val m_CanSuspendThenHibernate : (unit, string) Method.t

  val m_CancelScheduledShutdown : (unit, bool) Method.t

  val m_CreateSession :
    ( int32
      * int32
      * string
      * string
      * string
      * string
      * string
      * int32
      * string
      * string
      * bool
      * string
      * string
      * (string * OBus_value.V.single) list,
      string
      * OBus_path.t
      * string
      * Unix.file_descr
      * int32
      * string
      * int32
      * bool )
    Method.t

  val m_FlushDevices : (bool, unit) Method.t

  val m_GetSeat : (string, OBus_path.t) Method.t

  val m_GetSession : (string, OBus_path.t) Method.t

  val m_GetSessionByPID : (int32, OBus_path.t) Method.t

  val m_GetUser : (int32, OBus_path.t) Method.t

  val m_GetUserByPID : (int32, OBus_path.t) Method.t

  val m_Halt : (bool, unit) Method.t

  val m_Hibernate : (bool, unit) Method.t

  val m_HybridSleep : (bool, unit) Method.t

  val m_Inhibit : (string * string * string * string, Unix.file_descr) Method.t

  val m_KillSession : (string * string * int32, unit) Method.t

  val m_KillUser : (int32 * int32, unit) Method.t

  val m_ListInhibitors :
    (unit, (string * string * string * string * int32 * int32) list) Method.t

  val m_ListSeats : (unit, (string * OBus_path.t) list) Method.t

  val m_ListSessions :
    (unit, (string * int32 * string * string * OBus_path.t) list) Method.t

  val m_ListUsers : (unit, (int32 * string * OBus_path.t) list) Method.t

  val m_LockSession : (string, unit) Method.t

  val m_LockSessions : (unit, unit) Method.t

  val m_PowerOff : (bool, unit) Method.t

  val m_Reboot : (bool, unit) Method.t

  val m_ReleaseSession : (string, unit) Method.t

  val m_ScheduleShutdown : (string * int64, unit) Method.t

  val m_SetRebootParameter : (string, unit) Method.t

  val m_SetRebootToBootLoaderEntry : (string, unit) Method.t

  val m_SetRebootToBootLoaderMenu : (int64, unit) Method.t

  val m_SetRebootToFirmwareSetup : (bool, unit) Method.t

  val m_SetUserLinger : (int32 * bool * bool, unit) Method.t

  val m_SetWallMessage : (string * bool, unit) Method.t

  val m_Suspend : (bool, unit) Method.t

  val m_SuspendThenHibernate : (bool, unit) Method.t

  val m_TerminateSeat : (string, unit) Method.t

  val m_TerminateSession : (string, unit) Method.t

  val m_TerminateUser : (int32, unit) Method.t

  val m_UnlockSession : (string, unit) Method.t

  val m_UnlockSessions : (unit, unit) Method.t

  val s_PrepareForShutdown : bool Signal.t

  val s_PrepareForSleep : bool Signal.t

  val s_SeatNew : (string * OBus_path.t) Signal.t

  val s_SeatRemoved : (string * OBus_path.t) Signal.t

  val s_SessionNew : (string * OBus_path.t) Signal.t

  val s_SessionRemoved : (string * OBus_path.t) Signal.t

  val s_UserNew : (int32 * OBus_path.t) Signal.t

  val s_UserRemoved : (int32 * OBus_path.t) Signal.t

  val p_BlockInhibited : (string, [ `readable ]) Property.t

  val p_BootLoaderEntries : (string list, [ `readable ]) Property.t

  val p_DelayInhibited : (string, [ `readable ]) Property.t

  val p_Docked : (bool, [ `readable ]) Property.t

  val p_EnableWallMessages : (bool, [ `readable | `writable ]) Property.t

  val p_HandleHibernateKey : (string, [ `readable ]) Property.t

  val p_HandleLidSwitch : (string, [ `readable ]) Property.t

  val p_HandleLidSwitchDocked : (string, [ `readable ]) Property.t

  val p_HandleLidSwitchExternalPower : (string, [ `readable ]) Property.t

  val p_HandlePowerKey : (string, [ `readable ]) Property.t

  val p_HandleSuspendKey : (string, [ `readable ]) Property.t

  val p_HoldoffTimeoutUSec : (int64, [ `readable ]) Property.t

  val p_IdleAction : (string, [ `readable ]) Property.t

  val p_IdleActionUSec : (int64, [ `readable ]) Property.t

  val p_IdleHint : (bool, [ `readable ]) Property.t

  val p_IdleSinceHint : (int64, [ `readable ]) Property.t

  val p_IdleSinceHintMonotonic : (int64, [ `readable ]) Property.t

  val p_InhibitDelayMaxUSec : (int64, [ `readable ]) Property.t

  val p_InhibitorsMax : (int64, [ `readable ]) Property.t

  val p_KillExcludeUsers : (string list, [ `readable ]) Property.t

  val p_KillOnlyUsers : (string list, [ `readable ]) Property.t

  val p_KillUserProcesses : (bool, [ `readable ]) Property.t

  val p_LidClosed : (bool, [ `readable ]) Property.t

  val p_NAutoVTs : (int32, [ `readable ]) Property.t

  val p_NCurrentInhibitors : (int64, [ `readable ]) Property.t

  val p_NCurrentSessions : (int64, [ `readable ]) Property.t

  val p_OnExternalPower : (bool, [ `readable ]) Property.t

  val p_PreparingForShutdown : (bool, [ `readable ]) Property.t

  val p_PreparingForSleep : (bool, [ `readable ]) Property.t

  val p_RebootParameter : (string, [ `readable ]) Property.t

  val p_RebootToBootLoaderEntry : (string, [ `readable ]) Property.t

  val p_RebootToBootLoaderMenu : (int64, [ `readable ]) Property.t

  val p_RebootToFirmwareSetup : (bool, [ `readable ]) Property.t

  val p_RemoveIPC : (bool, [ `readable ]) Property.t

  val p_RuntimeDirectorySize : (int64, [ `readable ]) Property.t

  val p_ScheduledShutdown : (string * int64, [ `readable ]) Property.t

  val p_SessionsMax : (int64, [ `readable ]) Property.t

  val p_UserStopDelayUSec : (int64, [ `readable ]) Property.t

  val p_WallMessage : (string, [ `readable | `writable ]) Property.t

  type 'a members = {
    m_ActivateSession : 'a OBus_object.t -> string -> unit Lwt.t;
    m_ActivateSessionOnSeat : 'a OBus_object.t -> string * string -> unit Lwt.t;
    m_AttachDevice : 'a OBus_object.t -> string * string * bool -> unit Lwt.t;
    m_CanHalt : 'a OBus_object.t -> unit -> string Lwt.t;
    m_CanHibernate : 'a OBus_object.t -> unit -> string Lwt.t;
    m_CanHybridSleep : 'a OBus_object.t -> unit -> string Lwt.t;
    m_CanPowerOff : 'a OBus_object.t -> unit -> string Lwt.t;
    m_CanReboot : 'a OBus_object.t -> unit -> string Lwt.t;
    m_CanRebootParameter : 'a OBus_object.t -> unit -> string Lwt.t;
    m_CanRebootToBootLoaderEntry : 'a OBus_object.t -> unit -> string Lwt.t;
    m_CanRebootToBootLoaderMenu : 'a OBus_object.t -> unit -> string Lwt.t;
    m_CanRebootToFirmwareSetup : 'a OBus_object.t -> unit -> string Lwt.t;
    m_CanSuspend : 'a OBus_object.t -> unit -> string Lwt.t;
    m_CanSuspendThenHibernate : 'a OBus_object.t -> unit -> string Lwt.t;
    m_CancelScheduledShutdown : 'a OBus_object.t -> unit -> bool Lwt.t;
    m_CreateSession :
      'a OBus_object.t ->
      int32
      * int32
      * string
      * string
      * string
      * string
      * string
      * int32
      * string
      * string
      * bool
      * string
      * string
      * (string * OBus_value.V.single) list ->
      ( string
      * OBus_path.t
      * string
      * Unix.file_descr
      * int32
      * string
      * int32
      * bool )
      Lwt.t;
    m_FlushDevices : 'a OBus_object.t -> bool -> unit Lwt.t;
    m_GetSeat : 'a OBus_object.t -> string -> OBus_path.t Lwt.t;
    m_GetSession : 'a OBus_object.t -> string -> OBus_path.t Lwt.t;
    m_GetSessionByPID : 'a OBus_object.t -> int32 -> OBus_path.t Lwt.t;
    m_GetUser : 'a OBus_object.t -> int32 -> OBus_path.t Lwt.t;
    m_GetUserByPID : 'a OBus_object.t -> int32 -> OBus_path.t Lwt.t;
    m_Halt : 'a OBus_object.t -> bool -> unit Lwt.t;
    m_Hibernate : 'a OBus_object.t -> bool -> unit Lwt.t;
    m_HybridSleep : 'a OBus_object.t -> bool -> unit Lwt.t;
    m_Inhibit :
      'a OBus_object.t ->
      string * string * string * string ->
      Unix.file_descr Lwt.t;
    m_KillSession : 'a OBus_object.t -> string * string * int32 -> unit Lwt.t;
    m_KillUser : 'a OBus_object.t -> int32 * int32 -> unit Lwt.t;
    m_ListInhibitors :
      'a OBus_object.t ->
      unit ->
      (string * string * string * string * int32 * int32) list Lwt.t;
    m_ListSeats : 'a OBus_object.t -> unit -> (string * OBus_path.t) list Lwt.t;
    m_ListSessions :
      'a OBus_object.t ->
      unit ->
      (string * int32 * string * string * OBus_path.t) list Lwt.t;
    m_ListUsers :
      'a OBus_object.t -> unit -> (int32 * string * OBus_path.t) list Lwt.t;
    m_LockSession : 'a OBus_object.t -> string -> unit Lwt.t;
    m_LockSessions : 'a OBus_object.t -> unit -> unit Lwt.t;
    m_PowerOff : 'a OBus_object.t -> bool -> unit Lwt.t;
    m_Reboot : 'a OBus_object.t -> bool -> unit Lwt.t;
    m_ReleaseSession : 'a OBus_object.t -> string -> unit Lwt.t;
    m_ScheduleShutdown : 'a OBus_object.t -> string * int64 -> unit Lwt.t;
    m_SetRebootParameter : 'a OBus_object.t -> string -> unit Lwt.t;
    m_SetRebootToBootLoaderEntry : 'a OBus_object.t -> string -> unit Lwt.t;
    m_SetRebootToBootLoaderMenu : 'a OBus_object.t -> int64 -> unit Lwt.t;
    m_SetRebootToFirmwareSetup : 'a OBus_object.t -> bool -> unit Lwt.t;
    m_SetUserLinger : 'a OBus_object.t -> int32 * bool * bool -> unit Lwt.t;
    m_SetWallMessage : 'a OBus_object.t -> string * bool -> unit Lwt.t;
    m_Suspend : 'a OBus_object.t -> bool -> unit Lwt.t;
    m_SuspendThenHibernate : 'a OBus_object.t -> bool -> unit Lwt.t;
    m_TerminateSeat : 'a OBus_object.t -> string -> unit Lwt.t;
    m_TerminateSession : 'a OBus_object.t -> string -> unit Lwt.t;
    m_TerminateUser : 'a OBus_object.t -> int32 -> unit Lwt.t;
    m_UnlockSession : 'a OBus_object.t -> string -> unit Lwt.t;
    m_UnlockSessions : 'a OBus_object.t -> unit -> unit Lwt.t;
    p_BlockInhibited : 'a OBus_object.t -> string React.signal;
    p_BootLoaderEntries : 'a OBus_object.t -> string list React.signal;
    p_DelayInhibited : 'a OBus_object.t -> string React.signal;
    p_Docked : 'a OBus_object.t -> bool React.signal;
    p_EnableWallMessages :
      ('a OBus_object.t -> bool React.signal)
      * ('a OBus_object.t -> bool -> unit Lwt.t);
    p_HandleHibernateKey : 'a OBus_object.t -> string React.signal;
    p_HandleLidSwitch : 'a OBus_object.t -> string React.signal;
    p_HandleLidSwitchDocked : 'a OBus_object.t -> string React.signal;
    p_HandleLidSwitchExternalPower : 'a OBus_object.t -> string React.signal;
    p_HandlePowerKey : 'a OBus_object.t -> string React.signal;
    p_HandleSuspendKey : 'a OBus_object.t -> string React.signal;
    p_HoldoffTimeoutUSec : 'a OBus_object.t -> int64 React.signal;
    p_IdleAction : 'a OBus_object.t -> string React.signal;
    p_IdleActionUSec : 'a OBus_object.t -> int64 React.signal;
    p_IdleHint : 'a OBus_object.t -> bool React.signal;
    p_IdleSinceHint : 'a OBus_object.t -> int64 React.signal;
    p_IdleSinceHintMonotonic : 'a OBus_object.t -> int64 React.signal;
    p_InhibitDelayMaxUSec : 'a OBus_object.t -> int64 React.signal;
    p_InhibitorsMax : 'a OBus_object.t -> int64 React.signal;
    p_KillExcludeUsers : 'a OBus_object.t -> string list React.signal;
    p_KillOnlyUsers : 'a OBus_object.t -> string list React.signal;
    p_KillUserProcesses : 'a OBus_object.t -> bool React.signal;
    p_LidClosed : 'a OBus_object.t -> bool React.signal;
    p_NAutoVTs : 'a OBus_object.t -> int32 React.signal;
    p_NCurrentInhibitors : 'a OBus_object.t -> int64 React.signal;
    p_NCurrentSessions : 'a OBus_object.t -> int64 React.signal;
    p_OnExternalPower : 'a OBus_object.t -> bool React.signal;
    p_PreparingForShutdown : 'a OBus_object.t -> bool React.signal;
    p_PreparingForSleep : 'a OBus_object.t -> bool React.signal;
    p_RebootParameter : 'a OBus_object.t -> string React.signal;
    p_RebootToBootLoaderEntry : 'a OBus_object.t -> string React.signal;
    p_RebootToBootLoaderMenu : 'a OBus_object.t -> int64 React.signal;
    p_RebootToFirmwareSetup : 'a OBus_object.t -> bool React.signal;
    p_RemoveIPC : 'a OBus_object.t -> bool React.signal;
    p_RuntimeDirectorySize : 'a OBus_object.t -> int64 React.signal;
    p_ScheduledShutdown : 'a OBus_object.t -> (string * int64) React.signal;
    p_SessionsMax : 'a OBus_object.t -> int64 React.signal;
    p_UserStopDelayUSec : 'a OBus_object.t -> int64 React.signal;
    p_WallMessage :
      ('a OBus_object.t -> string React.signal)
      * ('a OBus_object.t -> string -> unit Lwt.t);
  }

  val make : 'a members -> 'a OBus_object.interface
end
