
# bin and libraries install prefix
PREFIX = /usr/local
# bin location
BIN_LOC = $(DESTDIR)$(PREFIX)/bin
# libraries location
LIB_LOC = $(DESTDIR)$(PREFIX)/lib/better-xsecurelock
# manpage location
MAN_LOC = $(DESTDIR)$(PREFIX)/share/man
# docs and examples location
DOC_LOC = $(DESTDIR)$(PREFIX)/share/doc/better-xsecurelock
# udev prefix
UDEV_PREFIX = /usr
# udev base directory
UDEVDIR = $(UDEV_PREFIX)/lib/udev
# udev rules location
UDEV_LOC = $(DESTDIR)$(UDEVDIR)/rules.d
# udev bin helper location
UBIN_LOC = $(DESTDIR)$(UDEVDIR)

