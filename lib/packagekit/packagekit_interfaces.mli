(* File auto-generated by obus-gen-interface, DO NOT EDIT. *)
open OBus_member
module Org_freedesktop_PackageKit : sig
  val interface : OBus_name.interface
  val m_CanAuthorize : (string, int32) Method.t
  val m_CreateTransaction : (unit, OBus_path.t) Method.t
  val m_GetDaemonState : (unit, string) Method.t
  val m_GetPackageHistory : (string list * int32, (string * (string * OBus_value.V.single) list list) list) Method.t
  val m_GetTimeSinceAction : (int32, int32) Method.t
  val m_GetTransactionList : (unit, OBus_path.t list) Method.t
  val m_SetProxy : (string * string * string * string * string * string, unit) Method.t
  val m_StateHasChanged : (string, unit) Method.t
  val m_SuggestDaemonQuit : (unit, unit) Method.t
  val s_RepoListChanged : unit Signal.t
  val s_RestartSchedule : unit Signal.t
  val s_TransactionListChanged : string list Signal.t
  val s_UpdatesChanged : unit Signal.t
  val p_BackendAuthor : (string, [ `readable ]) Property.t
  val p_BackendDescription : (string, [ `readable ]) Property.t
  val p_BackendName : (string, [ `readable ]) Property.t
  val p_DistroId : (string, [ `readable ]) Property.t
  val p_Filters : (int64, [ `readable ]) Property.t
  val p_Groups : (int64, [ `readable ]) Property.t
  val p_Locked : (bool, [ `readable ]) Property.t
  val p_MimeTypes : (string list, [ `readable ]) Property.t
  val p_NetworkState : (int32, [ `readable ]) Property.t
  val p_Roles : (int64, [ `readable ]) Property.t
  val p_VersionMajor : (int32, [ `readable ]) Property.t
  val p_VersionMicro : (int32, [ `readable ]) Property.t
  val p_VersionMinor : (int32, [ `readable ]) Property.t
  type 'a members = {
    m_CanAuthorize : 'a OBus_object.t -> string -> int32 Lwt.t;
    m_CreateTransaction : 'a OBus_object.t -> unit -> OBus_path.t Lwt.t;
    m_GetDaemonState : 'a OBus_object.t -> unit -> string Lwt.t;
    m_GetPackageHistory : 'a OBus_object.t -> string list * int32 -> (string * (string * OBus_value.V.single) list list) list Lwt.t;
    m_GetTimeSinceAction : 'a OBus_object.t -> int32 -> int32 Lwt.t;
    m_GetTransactionList : 'a OBus_object.t -> unit -> OBus_path.t list Lwt.t;
    m_SetProxy : 'a OBus_object.t -> string * string * string * string * string * string -> unit Lwt.t;
    m_StateHasChanged : 'a OBus_object.t -> string -> unit Lwt.t;
    m_SuggestDaemonQuit : 'a OBus_object.t -> unit -> unit Lwt.t;
    p_BackendAuthor : 'a OBus_object.t -> string React.signal;
    p_BackendDescription : 'a OBus_object.t -> string React.signal;
    p_BackendName : 'a OBus_object.t -> string React.signal;
    p_DistroId : 'a OBus_object.t -> string React.signal;
    p_Filters : 'a OBus_object.t -> int64 React.signal;
    p_Groups : 'a OBus_object.t -> int64 React.signal;
    p_Locked : 'a OBus_object.t -> bool React.signal;
    p_MimeTypes : 'a OBus_object.t -> string list React.signal;
    p_NetworkState : 'a OBus_object.t -> int32 React.signal;
    p_Roles : 'a OBus_object.t -> int64 React.signal;
    p_VersionMajor : 'a OBus_object.t -> int32 React.signal;
    p_VersionMicro : 'a OBus_object.t -> int32 React.signal;
    p_VersionMinor : 'a OBus_object.t -> int32 React.signal;
  }
  val make : 'a members -> 'a OBus_object.interface
end
module Org_freedesktop_PackageKit_Offline : sig
  val interface : OBus_name.interface
  val m_Cancel : (unit, unit) Method.t
  val m_ClearResults : (unit, unit) Method.t
  val m_GetPrepared : (unit, string list) Method.t
  val m_Trigger : (string, unit) Method.t
  val m_TriggerUpgrade : (string, unit) Method.t
  val p_PreparedUpgrade : ((string * OBus_value.V.single) list, [ `readable ]) Property.t
  val p_TriggerAction : (string, [ `readable ]) Property.t
  val p_UpdatePrepared : (bool, [ `readable ]) Property.t
  val p_UpdateTriggered : (bool, [ `readable ]) Property.t
  val p_UpgradePrepared : (bool, [ `readable ]) Property.t
  val p_UpgradeTriggered : (bool, [ `readable ]) Property.t
  type 'a members = {
    m_Cancel : 'a OBus_object.t -> unit -> unit Lwt.t;
    m_ClearResults : 'a OBus_object.t -> unit -> unit Lwt.t;
    m_GetPrepared : 'a OBus_object.t -> unit -> string list Lwt.t;
    m_Trigger : 'a OBus_object.t -> string -> unit Lwt.t;
    m_TriggerUpgrade : 'a OBus_object.t -> string -> unit Lwt.t;
    p_PreparedUpgrade : 'a OBus_object.t -> (string * OBus_value.V.single) list React.signal;
    p_TriggerAction : 'a OBus_object.t -> string React.signal;
    p_UpdatePrepared : 'a OBus_object.t -> bool React.signal;
    p_UpdateTriggered : 'a OBus_object.t -> bool React.signal;
    p_UpgradePrepared : 'a OBus_object.t -> bool React.signal;
    p_UpgradeTriggered : 'a OBus_object.t -> bool React.signal;
  }
  val make : 'a members -> 'a OBus_object.interface
end
