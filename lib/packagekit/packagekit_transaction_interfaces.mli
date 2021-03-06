(* File auto-generated by obus-gen-interface, DO NOT EDIT. *)
open OBus_member

module Org_freedesktop_PackageKit_Transaction : sig
  val interface : OBus_name.interface

  val m_AcceptEula : (string, unit) Method.t

  val m_Cancel : (unit, unit) Method.t

  val m_DependsOn : (int64 * string list * bool, unit) Method.t

  val m_DownloadPackages : (bool * string list, unit) Method.t

  val m_GetCategories : (unit, unit) Method.t

  val m_GetDetails : (string list, unit) Method.t

  val m_GetDetailsLocal : (string list, unit) Method.t

  val m_GetDistroUpgrades : (unit, unit) Method.t

  val m_GetFiles : (string list, unit) Method.t

  val m_GetFilesLocal : (string list, unit) Method.t

  val m_GetOldTransactions : (int32, unit) Method.t

  val m_GetPackages : (int64, unit) Method.t

  val m_GetRepoList : (int64, unit) Method.t

  val m_GetUpdateDetail : (string list, unit) Method.t

  val m_GetUpdates : (int64, unit) Method.t

  val m_InstallFiles : (int64 * string list, unit) Method.t

  val m_InstallPackages : (int64 * string list, unit) Method.t

  val m_InstallSignature : (int32 * string * string, unit) Method.t

  val m_RefreshCache : (bool, unit) Method.t

  val m_RemovePackages : (int64 * string list * bool * bool, unit) Method.t

  val m_RepairSystem : (int64, unit) Method.t

  val m_RepoEnable : (string * bool, unit) Method.t

  val m_RepoRemove : (int64 * string * bool, unit) Method.t

  val m_RepoSetData : (string * string * string, unit) Method.t

  val m_RequiredBy : (int64 * string list * bool, unit) Method.t

  val m_Resolve : (int64 * string list, unit) Method.t

  val m_SearchDetails : (int64 * string list, unit) Method.t

  val m_SearchFiles : (int64 * string list, unit) Method.t

  val m_SearchGroups : (int64 * string list, unit) Method.t

  val m_SearchNames : (int64 * string list, unit) Method.t

  val m_SetHints : (string list, unit) Method.t

  val m_UpdatePackages : (int64 * string list, unit) Method.t

  val m_UpgradeSystem : (int64 * string * int32, unit) Method.t

  val m_WhatProvides : (int64 * string list, unit) Method.t

  val s_Category : (string * string * string * string * string) Signal.t

  val s_Destroy : unit Signal.t

  val s_Details : (string * OBus_value.V.single) list Signal.t

  val s_DistroUpgrade : (int32 * string * string) Signal.t

  val s_ErrorCode : (int32 * string) Signal.t

  val s_EulaRequired : (string * string * string * string) Signal.t

  val s_Files : (string * string list) Signal.t

  val s_Finished : (int32 * int32) Signal.t

  val s_ItemProgress : (string * int32 * int32) Signal.t

  val s_MediaChangeRequired : (int32 * string * string) Signal.t

  val s_Package : (int32 * string * string) Signal.t

  val s_RepoDetail : (string * string * bool) Signal.t

  val s_RepoSignatureRequired :
    (string * string * string * string * string * string * string * int32)
    Signal.t

  val s_RequireRestart : (int32 * string) Signal.t

  val s_Transaction :
    (OBus_path.t * string * bool * int32 * int32 * string * int32 * string)
    Signal.t

  val s_UpdateDetail :
    ( string
    * string list
    * string list
    * string list
    * string list
    * string list
    * int32
    * string
    * string
    * int32
    * string
    * string )
    Signal.t

  val p_AllowCancel : (bool, [ `readable ]) Property.t

  val p_CallerActive : (bool, [ `readable ]) Property.t

  val p_DownloadSizeRemaining : (int64, [ `readable ]) Property.t

  val p_ElapsedTime : (int32, [ `readable ]) Property.t

  val p_LastPackage : (string, [ `readable ]) Property.t

  val p_Percentage : (int32, [ `readable ]) Property.t

  val p_RemainingTime : (int32, [ `readable ]) Property.t

  val p_Role : (int32, [ `readable ]) Property.t

  val p_Speed : (int32, [ `readable ]) Property.t

  val p_Status : (int32, [ `readable ]) Property.t

  val p_TransactionFlags : (int64, [ `readable ]) Property.t

  val p_Uid : (int32, [ `readable ]) Property.t

  type 'a members = {
    m_AcceptEula : 'a OBus_object.t -> string -> unit Lwt.t;
    m_Cancel : 'a OBus_object.t -> unit -> unit Lwt.t;
    m_DependsOn : 'a OBus_object.t -> int64 * string list * bool -> unit Lwt.t;
    m_DownloadPackages : 'a OBus_object.t -> bool * string list -> unit Lwt.t;
    m_GetCategories : 'a OBus_object.t -> unit -> unit Lwt.t;
    m_GetDetails : 'a OBus_object.t -> string list -> unit Lwt.t;
    m_GetDetailsLocal : 'a OBus_object.t -> string list -> unit Lwt.t;
    m_GetDistroUpgrades : 'a OBus_object.t -> unit -> unit Lwt.t;
    m_GetFiles : 'a OBus_object.t -> string list -> unit Lwt.t;
    m_GetFilesLocal : 'a OBus_object.t -> string list -> unit Lwt.t;
    m_GetOldTransactions : 'a OBus_object.t -> int32 -> unit Lwt.t;
    m_GetPackages : 'a OBus_object.t -> int64 -> unit Lwt.t;
    m_GetRepoList : 'a OBus_object.t -> int64 -> unit Lwt.t;
    m_GetUpdateDetail : 'a OBus_object.t -> string list -> unit Lwt.t;
    m_GetUpdates : 'a OBus_object.t -> int64 -> unit Lwt.t;
    m_InstallFiles : 'a OBus_object.t -> int64 * string list -> unit Lwt.t;
    m_InstallPackages : 'a OBus_object.t -> int64 * string list -> unit Lwt.t;
    m_InstallSignature :
      'a OBus_object.t -> int32 * string * string -> unit Lwt.t;
    m_RefreshCache : 'a OBus_object.t -> bool -> unit Lwt.t;
    m_RemovePackages :
      'a OBus_object.t -> int64 * string list * bool * bool -> unit Lwt.t;
    m_RepairSystem : 'a OBus_object.t -> int64 -> unit Lwt.t;
    m_RepoEnable : 'a OBus_object.t -> string * bool -> unit Lwt.t;
    m_RepoRemove : 'a OBus_object.t -> int64 * string * bool -> unit Lwt.t;
    m_RepoSetData : 'a OBus_object.t -> string * string * string -> unit Lwt.t;
    m_RequiredBy : 'a OBus_object.t -> int64 * string list * bool -> unit Lwt.t;
    m_Resolve : 'a OBus_object.t -> int64 * string list -> unit Lwt.t;
    m_SearchDetails : 'a OBus_object.t -> int64 * string list -> unit Lwt.t;
    m_SearchFiles : 'a OBus_object.t -> int64 * string list -> unit Lwt.t;
    m_SearchGroups : 'a OBus_object.t -> int64 * string list -> unit Lwt.t;
    m_SearchNames : 'a OBus_object.t -> int64 * string list -> unit Lwt.t;
    m_SetHints : 'a OBus_object.t -> string list -> unit Lwt.t;
    m_UpdatePackages : 'a OBus_object.t -> int64 * string list -> unit Lwt.t;
    m_UpgradeSystem : 'a OBus_object.t -> int64 * string * int32 -> unit Lwt.t;
    m_WhatProvides : 'a OBus_object.t -> int64 * string list -> unit Lwt.t;
    p_AllowCancel : 'a OBus_object.t -> bool React.signal;
    p_CallerActive : 'a OBus_object.t -> bool React.signal;
    p_DownloadSizeRemaining : 'a OBus_object.t -> int64 React.signal;
    p_ElapsedTime : 'a OBus_object.t -> int32 React.signal;
    p_LastPackage : 'a OBus_object.t -> string React.signal;
    p_Percentage : 'a OBus_object.t -> int32 React.signal;
    p_RemainingTime : 'a OBus_object.t -> int32 React.signal;
    p_Role : 'a OBus_object.t -> int32 React.signal;
    p_Speed : 'a OBus_object.t -> int32 React.signal;
    p_Status : 'a OBus_object.t -> int32 React.signal;
    p_TransactionFlags : 'a OBus_object.t -> int64 React.signal;
    p_Uid : 'a OBus_object.t -> int32 React.signal;
  }

  val make : 'a members -> 'a OBus_object.interface
end
