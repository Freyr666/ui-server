(* File auto-generated by obus-gen-interface, DO NOT EDIT. *)
open OBus_value
open OBus_value.C
open OBus_member
open OBus_object
module Org_freedesktop_timedate1 =
struct
  let interface = "org.freedesktop.timedate1"
  let m_ListTimezones = {
    Method.interface = interface;
    Method.member = "ListTimezones";
    Method.i_args = (arg0);
    Method.o_args = (arg1
                       (None, array basic_string));
    Method.annotations = [];
  }
  let m_SetLocalRTC = {
    Method.interface = interface;
    Method.member = "SetLocalRTC";
    Method.i_args = (arg3
                       (None, basic_boolean)
                       (None, basic_boolean)
                       (None, basic_boolean));
    Method.o_args = (arg0);
    Method.annotations = [];
  }
  let m_SetNTP = {
    Method.interface = interface;
    Method.member = "SetNTP";
    Method.i_args = (arg2
                       (None, basic_boolean)
                       (None, basic_boolean));
    Method.o_args = (arg0);
    Method.annotations = [];
  }
  let m_SetTime = {
    Method.interface = interface;
    Method.member = "SetTime";
    Method.i_args = (arg3
                       (None, basic_int64)
                       (None, basic_boolean)
                       (None, basic_boolean));
    Method.o_args = (arg0);
    Method.annotations = [];
  }
  let m_SetTimezone = {
    Method.interface = interface;
    Method.member = "SetTimezone";
    Method.i_args = (arg2
                       (None, basic_string)
                       (None, basic_boolean));
    Method.o_args = (arg0);
    Method.annotations = [];
  }
  let p_CanNTP = {
    Property.interface = interface;
    Property.member = "CanNTP";
    Property.typ = basic_boolean;
    Property.access = Property.readable;
    Property.annotations = [(OBus_introspect.emits_changed_signal, "false")];
  }
  let p_LocalRTC = {
    Property.interface = interface;
    Property.member = "LocalRTC";
    Property.typ = basic_boolean;
    Property.access = Property.readable;
    Property.annotations = [];
  }
  let p_NTP = {
    Property.interface = interface;
    Property.member = "NTP";
    Property.typ = basic_boolean;
    Property.access = Property.readable;
    Property.annotations = [];
  }
  let p_NTPSynchronized = {
    Property.interface = interface;
    Property.member = "NTPSynchronized";
    Property.typ = basic_boolean;
    Property.access = Property.readable;
    Property.annotations = [(OBus_introspect.emits_changed_signal, "false")];
  }
  let p_RTCTimeUSec = {
    Property.interface = interface;
    Property.member = "RTCTimeUSec";
    Property.typ = basic_uint64;
    Property.access = Property.readable;
    Property.annotations = [(OBus_introspect.emits_changed_signal, "false")];
  }
  let p_TimeUSec = {
    Property.interface = interface;
    Property.member = "TimeUSec";
    Property.typ = basic_uint64;
    Property.access = Property.readable;
    Property.annotations = [(OBus_introspect.emits_changed_signal, "false")];
  }
  let p_Timezone = {
    Property.interface = interface;
    Property.member = "Timezone";
    Property.typ = basic_string;
    Property.access = Property.readable;
    Property.annotations = [];
  }
  type 'a members = {
    m_ListTimezones : 'a OBus_object.t -> unit -> string list Lwt.t;
    m_SetLocalRTC : 'a OBus_object.t -> bool * bool * bool -> unit Lwt.t;
    m_SetNTP : 'a OBus_object.t -> bool * bool -> unit Lwt.t;
    m_SetTime : 'a OBus_object.t -> int64 * bool * bool -> unit Lwt.t;
    m_SetTimezone : 'a OBus_object.t -> string * bool -> unit Lwt.t;
    p_CanNTP : 'a OBus_object.t -> bool React.signal;
    p_LocalRTC : 'a OBus_object.t -> bool React.signal;
    p_NTP : 'a OBus_object.t -> bool React.signal;
    p_NTPSynchronized : 'a OBus_object.t -> bool React.signal;
    p_RTCTimeUSec : 'a OBus_object.t -> int64 React.signal;
    p_TimeUSec : 'a OBus_object.t -> int64 React.signal;
    p_Timezone : 'a OBus_object.t -> string React.signal;
  }
  let make members =
    OBus_object.make_interface_unsafe interface
      [
      ]
      [|
        method_info m_ListTimezones members.m_ListTimezones;
        method_info m_SetLocalRTC members.m_SetLocalRTC;
        method_info m_SetNTP members.m_SetNTP;
        method_info m_SetTime members.m_SetTime;
        method_info m_SetTimezone members.m_SetTimezone;
      |]
      [|
      |]
      [|
        property_r_info p_CanNTP members.p_CanNTP;
        property_r_info p_LocalRTC members.p_LocalRTC;
        property_r_info p_NTP members.p_NTP;
        property_r_info p_NTPSynchronized members.p_NTPSynchronized;
        property_r_info p_RTCTimeUSec members.p_RTCTimeUSec;
        property_r_info p_TimeUSec members.p_TimeUSec;
        property_r_info p_Timezone members.p_Timezone;
      |]
end