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
you insist be warned you'll have to use this almost like suckless software,
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
|xdg-screensaver:|very necessary|
|brightnessctl:|to dim the screen before lock and during screensaver|
|psmisc:|for pstree|
|procps:|for pgrep|
|noto sans cjk jp:|font for the auth dialog|
|python dbus| dbus-screenlock-freedesktop.py |
|python xlib| dbus-screenlock-freedesktop.py |

Once you have everyithing you need copy all the scripts to your path, for
xdg-screensaver just use the bundled one, you need to have a pywal colorscheme
as those colors will be used for the auth dialog and statusbar, i will
eventually add proper themes support but for now do this. Then you have to
edit saver.sh, edit `saver_list_1` to `saver_list_5` to set which screensavers
will show randomly, then you need to edit the following variables:

|var|default|
|--|--|
|term_font| "BlexMono Nerd Font Mono" |
|wallpaper| "${HOME}/.local/share/bg" |
|live_walls| "${HOME}/Videos/live-walls" |
|wall_dir|"${HOME}/Pictures/wallpapers"|

now you just have to run lockerd for the screen locker daemon and
dbus-screenlock-freedesktop.py if you want to allow programs that only speak dbus
to inhibit the screensaver. add them to either your autostart programs or run them
somewehre in your xinitrc or xsessionrc.

If all goes well you should have a xsecurelock similar to the one on my screenshots.


TODO:
- [ ] wrap and use the screensaver modules provided by xsecurelock
- [ ] add a generic xterm screensaver module to run the terminal based savers
- [ ] define a proper theme format and parse the config for it
- [ ] add the ability to configure auth and savers options (fonts, timeout, etc)
- [ ] make the dbus-screenlock-freedesktop search window that inhibits the
      screensaver by caller name and pid instead of just using whatever is
      focused at the time
- [ ] make lockerd set the x_screen_saver_extension and dpms times from config
      when the screensaver isn't being inhibited
- [ ] eliminate usage of pgrep
