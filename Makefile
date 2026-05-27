.POSIX:
PREFIX = ${HOME}/.local
BIN_LOC = $(DESTDIR)$(PREFIX)/bin
LIB_LOC = $(DESTDIR)$(PREFIX)/lib/better-xsecurelock
.PHONY: install uninstall all bin lib clean

all: bin lib

bin: blight delaysleep dim-screen lockerd saver screenlocker screensaverbar

lib: libbool.sh libutils.sh libpidtreesearch.sh libmsleep.sh liblog.sh

libbool.sh: build
	sed "s| ./| $(LIB_LOC)/|g" libbool.sh > build/$@

libutils.sh: build
	sed "s| ./| $(LIB_LOC)/|g" libutils.sh > build/$@

libpidtreesearch.sh: build
	sed "s| ./| $(LIB_LOC)/|g" libpidtreesearch.sh > build/$@

libmsleep.sh: build
	sed "s| ./| $(LIB_LOC)/|g" libmsleep.sh > build/$@

liblog.sh: build
	sed "s| ./| $(LIB_LOC)/|g" liblog.sh > build/$@

build:
	mkdir build

blight: build
	cp -f blight.sh build/$@

delaysleep: build
	cp -f delaysleep.sh build/$@

dim-screen: build
	cp -f dim-screen.sh build/$@

lockerd: build
	cp -f lockerd.sh build/$@

saver: build
	cp -f saver.sh build/$@

screenlocker: build
	cp -f screenlocker.sh build/$@

screensaverbar: build
	cp -f screensaverbar.sh build/$@

clean:
	rm -f build/blight
	rm -f build/delaysleep
	rm -f build/dim-screen
	rm -f build/lockerd
	rm -f build/saver
	rm -f build/screenlocker
	rm -f build/screensaverbar

install:
	mkdir -p $(BIN_LOC)
	cp -vf build/dim-screen     $(BIN_LOC)/
	cp -vf build/lockerd        $(BIN_LOC)/
	cp -vf build/saver          $(BIN_LOC)/
	cp -vf build/screenlocker   $(BIN_LOC)/
	cp -vf build/screensaverbar $(BIN_LOC)/
	cp -vf build/delaysleep     $(BIN_LOC)/

uninstall:
	rm -vf $(BIN_LOC)/dim-screen
	rm -vf $(BIN_LOC)/lockerd
	rm -vf $(BIN_LOC)/saver
	rm -vf $(BIN_LOC)/screenlocker
	rm -vf $(BIN_LOC)/screensaverbar
	rm -vf $(BIN_LOC)/delaysleep

install_on_ac_power:
	cp -vf on_ac_power  $(BIN_LOC)/
uninstall_on_ac_power:
	rm -vf $(BIN_LOC)/on_ac_power
