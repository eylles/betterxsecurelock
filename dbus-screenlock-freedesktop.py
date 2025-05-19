#!/usr/bin/python3
# Provide DBus service to call xdg-screensaver
# http://ubuntuforums.org/showthread.php?t=1865593&s=1c7f28c50a3f258e1d3404e41f098a0b&p=11418175#post11418175

import dbus
import dbus.service
from gi.repository import GLib
import subprocess

import Xlib
import Xlib.display
import signal
import sys
import os
from dbus.mainloop.glib import DBusGMainLoop

DBusGMainLoop(set_as_default=True)


myname = "{}:".format(os.path.basename(sys.argv[0]))

argc = len(sys.argv)

DBG_OUT = False

if argc > 1:
    i = 1
    while i < argc:
        if sys.argv[i] == "debug":
            DBG_OUT = True
        # else:
        #     print(myname, "unknown arg: {}".format(sys.argv[i]))
        i = i + 1

msg_inhibit = (
    "Inhibit called for inhibitor window id: {} hex: {} by: {} reason: {}"
)
msg_uninhibit = "UnInhibit called for inhibitor {} hex: {}"


def terminateProcess(signalNumber, frame):
    # print(signalNumber)
    print()
    if signalNumber != 2:
        print("terminating the process")
    sys.exit()


def readConfiguration(signalNumber, frame):
    print("(SIGHUP) reading configuration")
    return


class ScreenDbusObj(dbus.service.Object):
    def __init__(self):
        session_bus = dbus.SessionBus()
        bus_name = dbus.service.BusName(
            "org.freedesktop.ScreenSaver", bus=session_bus
        )
        dbus.service.Object.__init__(
            self, bus_name, "/org/freedesktop/ScreenSaver"
        )
        # self._get_procid = session_bus.get_object(
        #     'org.freedesktop.DBus', '/').GetConnectionUnixProcessID
        self.disp = Xlib.display.Display()
        self.root = self.disp.screen().root
        self.NET_ACTIVE_WINDOW = self.disp.intern_atom("_NET_ACTIVE_WINDOW")

    @dbus.service.method("org.freedesktop.ScreenSaver")
    def Lock(self):
        subprocess.Popen(["xdg-screensaver", "lock"])

    @dbus.service.method(
        "org.freedesktop.ScreenSaver", sender_keyword="dbus_sender"
    )
    def Inhibit(
        self, caller: dbus.String, reason: dbus.String, dbus_sender: str
    ):
        winid = self.root.get_full_property(
            self.NET_ACTIVE_WINDOW, Xlib.X.AnyPropertyType
        ).value[0]
        xid = hex(winid)
        if DBG_OUT:
            print(myname, msg_inhibit.format(winid, xid, caller, reason))
        subprocess.call(["xdg-screensaver", "suspend", xid])
        return dbus.UInt32(winid)

    @dbus.service.method("org.freedesktop.ScreenSaver")
    def UnInhibit(self, inhibitor_id):
        xid = hex(inhibitor_id)
        if DBG_OUT:
            print(myname, msg_uninhibit.format(inhibitor_id, xid))
        subprocess.call(["xdg-screensaver", "resume", xid])


if __name__ == "__main__":
    signal.signal(signal.SIGINT, terminateProcess)
    signal.signal(signal.SIGTERM, terminateProcess)
    signal.signal(signal.SIGHUP, readConfiguration)

    object = ScreenDbusObj()
    GLib.MainLoop().run()
