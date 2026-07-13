.POSIX:
PREFIX = /usr/local
BIN_LOC = $(DESTDIR)$(PREFIX)/bin
LIB_LOC = $(DESTDIR)$(PREFIX)/lib/better-xsecurelock
UDEV_PREFIX = /usr
UDEVDIR = $(UDEV_PREFIX)/lib/udev
UDEV_LOC = $(DESTDIR)$(UDEVDIR)/rules.d
UBIN_LOC = $(DESTDIR)$(UDEVDIR)
.PHONY: install uninstall all bin lib clean

include config.mk

all: bin lib

bin: blight delaysleep dim-screen lockerd saver screenlocker screensaverbar

lib: libbool.sh libutils.sh libpidtreesearch.sh libmsleep.sh liblog.sh \
	libbacklight.sh

libbool.sh: build
	sed "s| \./| $(LIB_LOC)/|g" libbool.sh > build/$@

libutils.sh: build
	sed "s| \./| $(LIB_LOC)/|g" libutils.sh > build/$@

libpidtreesearch.sh: build
	sed "s| \./| $(LIB_LOC)/|g" libpidtreesearch.sh > build/$@

libmsleep.sh: build
	sed "s| \./| $(LIB_LOC)/|g" libmsleep.sh > build/$@

liblog.sh: build
	sed "s| \./| $(LIB_LOC)/|g" liblog.sh > build/$@

libbacklight.sh: build
	sed "s| \./| $(LIB_LOC)/|g" libbacklight.sh > build/$@

build:
	mkdir build

blight: build
	sed "s| \./| $(LIB_LOC)/|g" blight.sh > build/$@
	chmod 755 build/$@

delaysleep: build
	sed "s| \./| $(LIB_LOC)/|g" delaysleep.sh > build/$@
	chmod 755 build/$@

dim-screen: build
	sed "s| \./| $(LIB_LOC)/|g" dim-screen.sh > build/$@
	chmod 755 build/$@

lockerd: build
	sed "s| \./| $(LIB_LOC)/|g" lockerd.sh > build/$@
	chmod 755 build/$@

saver: build
	sed "s| \./| $(LIB_LOC)/|g" saver.sh > build/$@
	chmod 755 build/$@

screenlocker: build
	sed "s| \./| $(LIB_LOC)/|g" screenlocker.sh > build/$@
	chmod 755 build/$@

screensaverbar: build
	sed "s| \./| $(LIB_LOC)/|g" screensaverbar.sh > build/$@
	chmod 755 build/$@

clean:
	rm -f build/blight
	rm -f build/delaysleep
	rm -f build/dim-screen
	rm -f build/lockerd
	rm -f build/saver
	rm -f build/screenlocker
	rm -f build/screensaverbar
	rm -f build/libbool.sh
	rm -f build/libutils.sh
	rm -f build/libpidtreesearch.sh
	rm -f build/libmsleep.sh
	rm -f build/liblog.sh
	rm -f build/libbacklight.sh
	rm -rf build

install:
	mkdir -p $(BIN_LOC)
	cp -vf build/blight              $(BIN_LOC)/
	cp -vf build/dim-screen          $(BIN_LOC)/
	cp -vf build/lockerd             $(BIN_LOC)/
	cp -vf build/saver               $(BIN_LOC)/
	cp -vf build/screenlocker        $(BIN_LOC)/
	cp -vf build/screensaverbar      $(BIN_LOC)/
	cp -vf build/delaysleep          $(BIN_LOC)/
	mkdir -p $(LIB_LOC)
	cp -vf build/libbool.sh          $(LIB_LOC)/
	cp -vf build/libutils.sh         $(LIB_LOC)/
	cp -vf build/libpidtreesearch.sh $(LIB_LOC)/
	cp -vf build/libmsleep.sh        $(LIB_LOC)/
	cp -vf build/liblog.sh           $(LIB_LOC)/
	cp -vf build/libbacklight.sh     $(LIB_LOC)/

uninstall:
	rm -vf $(BIN_LOC)/blight
	rm -vf $(BIN_LOC)/dim-screen
	rm -vf $(BIN_LOC)/lockerd
	rm -vf $(BIN_LOC)/saver
	rm -vf $(BIN_LOC)/screenlocker
	rm -vf $(BIN_LOC)/screensaverbar
	rm -vf $(BIN_LOC)/delaysleep
	rm -vf $(LIB_LOC)/libbool.sh
	rm -vf $(LIB_LOC)/libutils.sh
	rm -vf $(LIB_LOC)/libpidtreesearch.sh
	rm -vf $(LIB_LOC)/libmsleep.sh
	rm -vf $(LIB_LOC)/liblog.sh
	rm -vf $(LIB_LOC)/libbacklight.sh

install_on_ac_power:
	mkdir -p $(BIN_LOC)
	cp -vf on_ac_power  $(BIN_LOC)/
uninstall_on_ac_power:
	rm -vf $(BIN_LOC)/on_ac_power

install_xdg-screensaver:
	mkdir -p $(BIN_LOC)
	cp -vf xdg-screensaver $(BIN_LOC)/
	chmod 755 $(BIN_LOC)/xdg-screensaver
uninstall_xdg-screensaver:
	rm -vf $(BIN_LOC)/xdg-screensaver

install_bright-helper:
	mkdir -p $(UBIN_LOC)
	cp -vf bright-helper $(UBIN_LOC)/
	chmod 755 $(UBIN_LOC)/bright-helper
uninstall_bright-helper:
	rm -vf $(UBIN_LOC)/bright-helper

install_blight.rules:
	mkdir -p $(UDEV_LOC)
	cp -vf 90-blight.rules $(UDEV_LOC)/
	chmod 644 $(UDEV_LOC)/90-blight.rules
uninstall_blight.rules:
	rm -vf $(UDEV_LOC)/90-blight.rules
