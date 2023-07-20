#!/usr/bin/python3
# Provide DBus service to call xscreensaver
# http://ubuntuforums.org/showthread.php?t=1865593&s=1c7f28c50a3f258e1d3404e41f098a0b&p=11418175#post11418175

import dbus
import dbus.service
import dbus.glib
from gi.repository import GObject
import subprocess

import psutil
import Xlib
import Xlib.display

class ScreenDbusObj(dbus.service.Object):
    def __init__(self):
        session_bus = dbus.SessionBus()
        bus_name = dbus.service.BusName("org.freedesktop.ScreenSaver", bus=session_bus)
        dbus.service.Object.__init__(self, bus_name, '/org/freedesktop/ScreenSaver')
        # self._get_procid = session_bus.get_object('org.freedesktop.DBus', '/').GetConnectionUnixProcessID
        self.disp = Xlib.display.Display()
        self.root = self.disp.screen().root
        self.NET_ACTIVE_WINDOW = self.disp.intern_atom('_NET_ACTIVE_WINDOW')

    @dbus.service.method("org.freedesktop.ScreenSaver")
    def Lock(self):
        subprocess.Popen(['xdg-screensaver', 'lock'])

    @dbus.service.method("org.freedesktop.ScreenSaver", sender_keyword='dbus_sender')
    def Inhibit(self, caller: dbus.String, reason: dbus.String, dbus_sender: str):
        winid = self.root.get_full_property(self.NET_ACTIVE_WINDOW, Xlib.X.AnyPropertyType).value[0]
        xid = hex(winid)
        print("Inhibit called for inhibitor window id: {} hex: {}".format(winid, xid))
        subprocess.call(['xdg-screensaver', 'suspend', xid])
        return dbus.UInt32(winid)

    @dbus.service.method("org.freedesktop.ScreenSaver")
    def UnInhibit(self, inhibitor_id):
        xid = hex(inhibitor_id)
        print("UnInhibit called for inhibitor {} hex: {}".format(inhibitor_id, xid))
        subprocess.call(['xdg-screensaver', 'resume', xid])


if __name__ == '__main__':
    object = ScreenDbusObj()
    GObject.MainLoop().run()
