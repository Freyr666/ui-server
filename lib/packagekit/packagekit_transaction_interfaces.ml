(* File auto-generated by obus-gen-interface, DO NOT EDIT. *)
open OBus_value
open OBus_value.C
open OBus_member
open OBus_object

module Org_freedesktop_PackageKit_Transaction = struct
  let interface = "org.freedesktop.PackageKit.Transaction"

  let m_AcceptEula =
    {
      Method.interface;
      Method.member = "AcceptEula";
      Method.i_args = arg1 (Some "eula_id", basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_Cancel =
    {
      Method.interface;
      Method.member = "Cancel";
      Method.i_args = arg0;
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_DependsOn =
    {
      Method.interface;
      Method.member = "DependsOn";
      Method.i_args =
        arg3
          (Some "filter", basic_uint64)
          (Some "package_ids", array basic_string)
          (Some "recursive", basic_boolean);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_DownloadPackages =
    {
      Method.interface;
      Method.member = "DownloadPackages";
      Method.i_args =
        arg2
          (Some "store_in_cache", basic_boolean)
          (Some "package_ids", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_GetCategories =
    {
      Method.interface;
      Method.member = "GetCategories";
      Method.i_args = arg0;
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_GetDetails =
    {
      Method.interface;
      Method.member = "GetDetails";
      Method.i_args = arg1 (Some "package_ids", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_GetDetailsLocal =
    {
      Method.interface;
      Method.member = "GetDetailsLocal";
      Method.i_args = arg1 (Some "files", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_GetDistroUpgrades =
    {
      Method.interface;
      Method.member = "GetDistroUpgrades";
      Method.i_args = arg0;
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_GetFiles =
    {
      Method.interface;
      Method.member = "GetFiles";
      Method.i_args = arg1 (Some "package_ids", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_GetFilesLocal =
    {
      Method.interface;
      Method.member = "GetFilesLocal";
      Method.i_args = arg1 (Some "files", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_GetOldTransactions =
    {
      Method.interface;
      Method.member = "GetOldTransactions";
      Method.i_args = arg1 (Some "number", basic_uint32);
      Method.o_args = arg0;
      Method.annotations = [];
    }

  let m_GetPackages =
    {
      Method.interface;
      Method.member = "GetPackages";
      Method.i_args = arg1 (Some "filter", basic_uint64);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_GetRepoList =
    {
      Method.interface;
      Method.member = "GetRepoList";
      Method.i_args = arg1 (Some "filter", basic_uint64);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_GetUpdateDetail =
    {
      Method.interface;
      Method.member = "GetUpdateDetail";
      Method.i_args = arg1 (Some "package_ids", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_GetUpdates =
    {
      Method.interface;
      Method.member = "GetUpdates";
      Method.i_args = arg1 (Some "filter", basic_uint64);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_InstallFiles =
    {
      Method.interface;
      Method.member = "InstallFiles";
      Method.i_args =
        arg2
          (Some "transaction_flags", basic_uint64)
          (Some "full_paths", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_InstallPackages =
    {
      Method.interface;
      Method.member = "InstallPackages";
      Method.i_args =
        arg2
          (Some "transaction_flags", basic_uint64)
          (Some "package_ids", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_InstallSignature =
    {
      Method.interface;
      Method.member = "InstallSignature";
      Method.i_args =
        arg3
          (Some "sig_type", basic_uint32)
          (Some "key_id", basic_string)
          (Some "package_id", basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_RefreshCache =
    {
      Method.interface;
      Method.member = "RefreshCache";
      Method.i_args = arg1 (Some "force", basic_boolean);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_RemovePackages =
    {
      Method.interface;
      Method.member = "RemovePackages";
      Method.i_args =
        arg4
          (Some "transaction_flags", basic_uint64)
          (Some "package_ids", array basic_string)
          (Some "allow_deps", basic_boolean)
          (Some "autoremove", basic_boolean);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_RepairSystem =
    {
      Method.interface;
      Method.member = "RepairSystem";
      Method.i_args = arg1 (Some "transaction_flags", basic_uint64);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_RepoEnable =
    {
      Method.interface;
      Method.member = "RepoEnable";
      Method.i_args =
        arg2 (Some "repo_id", basic_string) (Some "enabled", basic_boolean);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_RepoRemove =
    {
      Method.interface;
      Method.member = "RepoRemove";
      Method.i_args =
        arg3
          (Some "transaction_flags", basic_uint64)
          (Some "repo_id", basic_string)
          (Some "autoremove", basic_boolean);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_RepoSetData =
    {
      Method.interface;
      Method.member = "RepoSetData";
      Method.i_args =
        arg3
          (Some "repo_id", basic_string)
          (Some "parameter", basic_string)
          (Some "value", basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_RequiredBy =
    {
      Method.interface;
      Method.member = "RequiredBy";
      Method.i_args =
        arg3
          (Some "filter", basic_uint64)
          (Some "package_ids", array basic_string)
          (Some "recursive", basic_boolean);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_Resolve =
    {
      Method.interface;
      Method.member = "Resolve";
      Method.i_args =
        arg2 (Some "filter", basic_uint64) (Some "packages", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_SearchDetails =
    {
      Method.interface;
      Method.member = "SearchDetails";
      Method.i_args =
        arg2 (Some "filter", basic_uint64) (Some "values", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_SearchFiles =
    {
      Method.interface;
      Method.member = "SearchFiles";
      Method.i_args =
        arg2 (Some "filter", basic_uint64) (Some "values", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_SearchGroups =
    {
      Method.interface;
      Method.member = "SearchGroups";
      Method.i_args =
        arg2 (Some "filter", basic_uint64) (Some "values", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_SearchNames =
    {
      Method.interface;
      Method.member = "SearchNames";
      Method.i_args =
        arg2 (Some "filter", basic_uint64) (Some "values", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_SetHints =
    {
      Method.interface;
      Method.member = "SetHints";
      Method.i_args = arg1 (Some "hints", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_UpdatePackages =
    {
      Method.interface;
      Method.member = "UpdatePackages";
      Method.i_args =
        arg2
          (Some "transaction_flags", basic_uint64)
          (Some "package_ids", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_UpgradeSystem =
    {
      Method.interface;
      Method.member = "UpgradeSystem";
      Method.i_args =
        arg3
          (Some "transaction_flags", basic_uint64)
          (Some "distro_id", basic_string)
          (Some "upgrade_kind", basic_uint32);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let m_WhatProvides =
    {
      Method.interface;
      Method.member = "WhatProvides";
      Method.i_args =
        arg2 (Some "filter", basic_uint64) (Some "values", array basic_string);
      Method.o_args = arg0;
      Method.annotations = [ ("org.freedesktop.DBus.GLib.Async", "") ];
    }

  let s_Category =
    {
      Signal.interface;
      Signal.member = "Category";
      Signal.args =
        arg5
          (Some "parent_id", basic_string)
          (Some "cat_id", basic_string)
          (Some "name", basic_string)
          (Some "summary", basic_string)
          (Some "icon", basic_string);
      Signal.annotations = [];
    }

  let s_Destroy =
    {
      Signal.interface;
      Signal.member = "Destroy";
      Signal.args = arg0;
      Signal.annotations = [];
    }

  let s_Details =
    {
      Signal.interface;
      Signal.member = "Details";
      Signal.args = arg1 (Some "data", dict string variant);
      Signal.annotations =
        [ ("org.qtproject.QtDBus.QtTypeName.Out0", "QVariantMap") ];
    }

  let s_DistroUpgrade =
    {
      Signal.interface;
      Signal.member = "DistroUpgrade";
      Signal.args =
        arg3
          (Some "type", basic_uint32)
          (Some "name", basic_string)
          (Some "summary", basic_string);
      Signal.annotations = [];
    }

  let s_ErrorCode =
    {
      Signal.interface;
      Signal.member = "ErrorCode";
      Signal.args =
        arg2 (Some "code", basic_uint32) (Some "details", basic_string);
      Signal.annotations = [];
    }

  let s_EulaRequired =
    {
      Signal.interface;
      Signal.member = "EulaRequired";
      Signal.args =
        arg4
          (Some "eula_id", basic_string)
          (Some "package_id", basic_string)
          (Some "vendor_name", basic_string)
          (Some "license_agreement", basic_string);
      Signal.annotations = [];
    }

  let s_Files =
    {
      Signal.interface;
      Signal.member = "Files";
      Signal.args =
        arg2
          (Some "package_id", basic_string)
          (Some "file_list", array basic_string);
      Signal.annotations = [];
    }

  let s_Finished =
    {
      Signal.interface;
      Signal.member = "Finished";
      Signal.args =
        arg2 (Some "exit", basic_uint32) (Some "runtime", basic_uint32);
      Signal.annotations = [];
    }

  let s_ItemProgress =
    {
      Signal.interface;
      Signal.member = "ItemProgress";
      Signal.args =
        arg3 (Some "id", basic_string)
          (Some "status", basic_uint32)
          (Some "percentage", basic_uint32);
      Signal.annotations = [];
    }

  let s_MediaChangeRequired =
    {
      Signal.interface;
      Signal.member = "MediaChangeRequired";
      Signal.args =
        arg3
          (Some "media_type", basic_uint32)
          (Some "media_id", basic_string)
          (Some "media_text", basic_string);
      Signal.annotations = [];
    }

  let s_Package =
    {
      Signal.interface;
      Signal.member = "Package";
      Signal.args =
        arg3
          (Some "info", basic_uint32)
          (Some "package_id", basic_string)
          (Some "summary", basic_string);
      Signal.annotations = [];
    }

  let s_RepoDetail =
    {
      Signal.interface;
      Signal.member = "RepoDetail";
      Signal.args =
        arg3
          (Some "repo_id", basic_string)
          (Some "description", basic_string)
          (Some "enabled", basic_boolean);
      Signal.annotations = [];
    }

  let s_RepoSignatureRequired =
    {
      Signal.interface;
      Signal.member = "RepoSignatureRequired";
      Signal.args =
        arg8
          (Some "package_id", basic_string)
          (Some "repository_name", basic_string)
          (Some "key_url", basic_string)
          (Some "key_userid", basic_string)
          (Some "key_id", basic_string)
          (Some "key_fingerprint", basic_string)
          (Some "key_timestamp", basic_string)
          (Some "type", basic_uint32);
      Signal.annotations = [];
    }

  let s_RequireRestart =
    {
      Signal.interface;
      Signal.member = "RequireRestart";
      Signal.args =
        arg2 (Some "type", basic_uint32) (Some "package_id", basic_string);
      Signal.annotations = [];
    }

  let s_Transaction =
    {
      Signal.interface;
      Signal.member = "Transaction";
      Signal.args =
        arg8
          (Some "object_path", basic_object_path)
          (Some "timespec", basic_string)
          (Some "succeeded", basic_boolean)
          (Some "role", basic_uint32)
          (Some "duration", basic_uint32)
          (Some "data", basic_string)
          (Some "uid", basic_uint32)
          (Some "cmdline", basic_string);
      Signal.annotations = [];
    }

  let s_UpdateDetail =
    {
      Signal.interface;
      Signal.member = "UpdateDetail";
      Signal.args =
        arg12
          (Some "package_id", basic_string)
          (Some "updates", array basic_string)
          (Some "obsoletes", array basic_string)
          (Some "vendor_urls", array basic_string)
          (Some "bugzilla_urls", array basic_string)
          (Some "cve_urls", array basic_string)
          (Some "restart", basic_uint32)
          (Some "update_text", basic_string)
          (Some "changelog", basic_string)
          (Some "state", basic_uint32)
          (Some "issued", basic_string)
          (Some "updated", basic_string);
      Signal.annotations = [];
    }

  let p_AllowCancel =
    {
      Property.interface;
      Property.member = "AllowCancel";
      Property.typ = basic_boolean;
      Property.access = Property.readable;
      Property.annotations = [];
    }

  let p_CallerActive =
    {
      Property.interface;
      Property.member = "CallerActive";
      Property.typ = basic_boolean;
      Property.access = Property.readable;
      Property.annotations = [];
    }

  let p_DownloadSizeRemaining =
    {
      Property.interface;
      Property.member = "DownloadSizeRemaining";
      Property.typ = basic_uint64;
      Property.access = Property.readable;
      Property.annotations = [];
    }

  let p_ElapsedTime =
    {
      Property.interface;
      Property.member = "ElapsedTime";
      Property.typ = basic_uint32;
      Property.access = Property.readable;
      Property.annotations = [];
    }

  let p_LastPackage =
    {
      Property.interface;
      Property.member = "LastPackage";
      Property.typ = basic_string;
      Property.access = Property.readable;
      Property.annotations = [];
    }

  let p_Percentage =
    {
      Property.interface;
      Property.member = "Percentage";
      Property.typ = basic_uint32;
      Property.access = Property.readable;
      Property.annotations = [];
    }

  let p_RemainingTime =
    {
      Property.interface;
      Property.member = "RemainingTime";
      Property.typ = basic_uint32;
      Property.access = Property.readable;
      Property.annotations = [];
    }

  let p_Role =
    {
      Property.interface;
      Property.member = "Role";
      Property.typ = basic_uint32;
      Property.access = Property.readable;
      Property.annotations = [];
    }

  let p_Speed =
    {
      Property.interface;
      Property.member = "Speed";
      Property.typ = basic_uint32;
      Property.access = Property.readable;
      Property.annotations = [];
    }

  let p_Status =
    {
      Property.interface;
      Property.member = "Status";
      Property.typ = basic_uint32;
      Property.access = Property.readable;
      Property.annotations = [];
    }

  let p_TransactionFlags =
    {
      Property.interface;
      Property.member = "TransactionFlags";
      Property.typ = basic_uint64;
      Property.access = Property.readable;
      Property.annotations = [];
    }

  let p_Uid =
    {
      Property.interface;
      Property.member = "Uid";
      Property.typ = basic_uint32;
      Property.access = Property.readable;
      Property.annotations = [];
    }

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

  let make members =
    OBus_object.make_interface_unsafe interface []
      [|
        method_info m_AcceptEula members.m_AcceptEula;
        method_info m_Cancel members.m_Cancel;
        method_info m_DependsOn members.m_DependsOn;
        method_info m_DownloadPackages members.m_DownloadPackages;
        method_info m_GetCategories members.m_GetCategories;
        method_info m_GetDetails members.m_GetDetails;
        method_info m_GetDetailsLocal members.m_GetDetailsLocal;
        method_info m_GetDistroUpgrades members.m_GetDistroUpgrades;
        method_info m_GetFiles members.m_GetFiles;
        method_info m_GetFilesLocal members.m_GetFilesLocal;
        method_info m_GetOldTransactions members.m_GetOldTransactions;
        method_info m_GetPackages members.m_GetPackages;
        method_info m_GetRepoList members.m_GetRepoList;
        method_info m_GetUpdateDetail members.m_GetUpdateDetail;
        method_info m_GetUpdates members.m_GetUpdates;
        method_info m_InstallFiles members.m_InstallFiles;
        method_info m_InstallPackages members.m_InstallPackages;
        method_info m_InstallSignature members.m_InstallSignature;
        method_info m_RefreshCache members.m_RefreshCache;
        method_info m_RemovePackages members.m_RemovePackages;
        method_info m_RepairSystem members.m_RepairSystem;
        method_info m_RepoEnable members.m_RepoEnable;
        method_info m_RepoRemove members.m_RepoRemove;
        method_info m_RepoSetData members.m_RepoSetData;
        method_info m_RequiredBy members.m_RequiredBy;
        method_info m_Resolve members.m_Resolve;
        method_info m_SearchDetails members.m_SearchDetails;
        method_info m_SearchFiles members.m_SearchFiles;
        method_info m_SearchGroups members.m_SearchGroups;
        method_info m_SearchNames members.m_SearchNames;
        method_info m_SetHints members.m_SetHints;
        method_info m_UpdatePackages members.m_UpdatePackages;
        method_info m_UpgradeSystem members.m_UpgradeSystem;
        method_info m_WhatProvides members.m_WhatProvides;
      |]
      [|
        signal_info s_Category;
        signal_info s_Destroy;
        signal_info s_Details;
        signal_info s_DistroUpgrade;
        signal_info s_ErrorCode;
        signal_info s_EulaRequired;
        signal_info s_Files;
        signal_info s_Finished;
        signal_info s_ItemProgress;
        signal_info s_MediaChangeRequired;
        signal_info s_Package;
        signal_info s_RepoDetail;
        signal_info s_RepoSignatureRequired;
        signal_info s_RequireRestart;
        signal_info s_Transaction;
        signal_info s_UpdateDetail;
      |]
      [|
        property_r_info p_AllowCancel members.p_AllowCancel;
        property_r_info p_CallerActive members.p_CallerActive;
        property_r_info p_DownloadSizeRemaining members.p_DownloadSizeRemaining;
        property_r_info p_ElapsedTime members.p_ElapsedTime;
        property_r_info p_LastPackage members.p_LastPackage;
        property_r_info p_Percentage members.p_Percentage;
        property_r_info p_RemainingTime members.p_RemainingTime;
        property_r_info p_Role members.p_Role;
        property_r_info p_Speed members.p_Speed;
        property_r_info p_Status members.p_Status;
        property_r_info p_TransactionFlags members.p_TransactionFlags;
        property_r_info p_Uid members.p_Uid;
      |]
end
