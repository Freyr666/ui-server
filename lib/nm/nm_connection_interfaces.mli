(* File auto-generated by obus-gen-interface, DO NOT EDIT. *)
open OBus_member
module Org_freedesktop_NetworkManager_Connection_Active : sig
  val interface : OBus_name.interface
  val s_PropertiesChanged : (string * OBus_value.V.single) list Signal.t
  val s_StateChanged : (int32 * int32) Signal.t
  val p_Connection : (OBus_path.t, [ `readable ]) Property.t
  val p_Default : (bool, [ `readable ]) Property.t
  val p_Default6 : (bool, [ `readable ]) Property.t
  val p_Devices : (OBus_path.t list, [ `readable ]) Property.t
  val p_Dhcp4Config : (OBus_path.t, [ `readable ]) Property.t
  val p_Dhcp6Config : (OBus_path.t, [ `readable ]) Property.t
  val p_Id : (string, [ `readable ]) Property.t
  val p_Ip4Config : (OBus_path.t, [ `readable ]) Property.t
  val p_Ip6Config : (OBus_path.t, [ `readable ]) Property.t
  val p_Master : (OBus_path.t, [ `readable ]) Property.t
  val p_SpecificObject : (OBus_path.t, [ `readable ]) Property.t
  val p_State : (int32, [ `readable ]) Property.t
  val p_Type : (string, [ `readable ]) Property.t
  val p_Uuid : (string, [ `readable ]) Property.t
  val p_Vpn : (bool, [ `readable ]) Property.t
  type 'a members = {
    p_Connection : 'a OBus_object.t -> OBus_path.t React.signal;
    p_Default : 'a OBus_object.t -> bool React.signal;
    p_Default6 : 'a OBus_object.t -> bool React.signal;
    p_Devices : 'a OBus_object.t -> OBus_path.t list React.signal;
    p_Dhcp4Config : 'a OBus_object.t -> OBus_path.t React.signal;
    p_Dhcp6Config : 'a OBus_object.t -> OBus_path.t React.signal;
    p_Id : 'a OBus_object.t -> string React.signal;
    p_Ip4Config : 'a OBus_object.t -> OBus_path.t React.signal;
    p_Ip6Config : 'a OBus_object.t -> OBus_path.t React.signal;
    p_Master : 'a OBus_object.t -> OBus_path.t React.signal;
    p_SpecificObject : 'a OBus_object.t -> OBus_path.t React.signal;
    p_State : 'a OBus_object.t -> int32 React.signal;
    p_Type : 'a OBus_object.t -> string React.signal;
    p_Uuid : 'a OBus_object.t -> string React.signal;
    p_Vpn : 'a OBus_object.t -> bool React.signal;
  }
  val make : 'a members -> 'a OBus_object.interface
end