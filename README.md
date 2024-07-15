# BetterXsecurelock

a wrapper to xsecurelock

<details>
    <summary>Screenshots</summary>
    <br>
    ![screenshot 1](/screenshots/Screenshot01.png)
    ![screenshot 2](/screenshots/Screenshot02.png)
    ![screenshot 3](/screenshots/Screenshot03.png)
    ![screenshot 4](/screenshots/Screenshot04.png)
    ![screenshot 5](/screenshots/Screenshot05.png)
    ![screenshot 6](/screenshots/Screenshot06.png)
    ![screenshot 7](/screenshots/Screenshot07.png)
    ![screenshot 8](/screenshots/Screenshot08.png)
</details>

this provides wrapping for xss-lock, xsecurelock and multiple programs to use
as screensavers, mpv, nsxiv, xterm with terminal screensavers, integration with
pywal, a status bar inside the screensaver that only shows when the auth dialog
is on screen and shows day, time and battery, a proxy for dbus so that programs
can use the org.freedesktop.ScreenSaver dbus interface to request to lock,
unlock and inhibit the screensaver.

more features are to come but for now this is very alpha software that has been
wrangled to work on my setup.


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
