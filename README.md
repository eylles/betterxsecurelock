# BetterXsecurelock

a wrapper to xsecurelock

![screenshot 1](/screenshots/Screenshot01.png)
![screenshot 2](/screenshots/Screenshot02.png)
![screenshot 3](/screenshots/Screenshot03.png)
![screenshot 4](/screenshots/Screenshot04.png)
![screenshot 5](/screenshots/Screenshot05.png)
![screenshot 6](/screenshots/Screenshot06.png)
![screenshot 7](/screenshots/Screenshot07.png)
![screenshot 8](/screenshots/Screenshot08.png)


this provides wrapping for xss-lock, xsecurelock and multiple programs to use
as screensavers, mpv, nsxiv, xterm with terminal screensavers, integration with
pywal, a status bar inside the screensaver that only shows when the auth dialog
is on screen and shows day, time and battery, a proxy for dbus so that programs
can use the org.freedesktop.ScreenSaver dbus interface to request to lock,
unlock and inhibit the screensaver.

more features are to come but for now this is very alpha software that has been
wrangled to work on my setup.

## how do i use this

you don't, at least for now as this hasn't even had a v0.0.0 release, but if
you insist be warned i'm still in the process of implementing config options and
what is available now in the sample config file is what is available, everything
else you'll have to use this almost like suckless software,
ie: modifying the source code directly.

first and foremost satisfy the dependencies, you need to have the following
software installed:

|software|use|
|--|--|
|xsecurelock:| the program doing the hard work.|
|xss-lock:| for launching xsecurelock and listening to screen and suspend events|
|nsxiv:| for displaying images.|
|mpv:| for video|
|xterm:|statusbar and terminal screensavers|
|xdotool:|statusbar|
|unimatrix:|matrix screensaver (optional)|
|cmatrix:|matrix screensaver|
|[pipes.sh](https://github.com/pipeseroni/pipes.sh):|pipes screensaver (optional)|
|[sssnake](https://github.com//AngelJumbo/sssnake):|snake screensaver (optional)|
|[fire](https://github.com/kiedtl/fire):|for the fire screensaver (optional)|
|btop:|for the btop screensaver|
|pywal16:|for the theme|
|[on_ac_power](https://salsa.debian.org/debian/powermgmt-base):|show the charge icon on the statusbar|
|xdg-screensaver:|very necessary|
|brightnessctl:|to dim the screen before lock and during screensaver (optional)|
|[systemact](https://github.com/eylles/systemact)|automatic system suspend some time after lock|
|psmisc:|for pstree|
|noto sans cjk jp:|font for the auth dialog|
|python dbus| dbus-screenlock-freedesktop.py |
|python xlib| dbus-screenlock-freedesktop.py |

Once you have everything run make install and the makefile will copy all the
scripts to your path, for xdg-screensaver just use the bundled one, for
on_ac_power if you are not on a debian based distro this repo bundles the script
into the tree just run make install_on_ac_power, on debian and derivates just
install the powermgmt-base package if not already installed, you need to
have a pywal colorscheme or edit the code to change the color definitions as
those colors will be used for the auth dialog and statusbar, i will
eventually add proper themes support just need to define a format.
Then you have to copy the sample config file to
´"${XDG_CONFIG_HOME:-${HOME}/.config}/better-xsecurelock/config"´
and edit the options to your liking, the config is outright sourced by every
script like any other shell script file despite the lack of extension or
shebang, it however has a vim modeline just to be explicit about the syntax

now you just have to run lockerd for the screen locker daemon and
dbus-screenlock-freedesktop.py if you want to allow programs that only speak
dbus to inhibit the screensaver. add them to either your autostart programs or
run them somewehre in your xinitrc or xsessionrc.

If all goes well you should have a xsecurelock similar to the one on my
screenshots.


TODO:
- [ ] wrap and use the screensaver modules provided by xsecurelock
- [ ] add a generic xterm screensaver module to run the terminal based savers
- [ ] define a proper theme format and parse the config for it
- [x] add the ability to configure auth and savers options (fonts, timeout, etc)
- [ ] make the dbus-screenlock-freedesktop search window that inhibits the
      screensaver by caller name and pid instead of just using whatever is
      focused at the time
- [x] make lockerd set the x_screen_saver_extension and dpms times from config
      when the screensaver isn't being inhibited
- [x] eliminate usage of pgrep
