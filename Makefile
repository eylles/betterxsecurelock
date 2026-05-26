.POSIX:
PREFIX = ${HOME}/.local
BIN_LOC = $(DESTDIR)$(PREFIX)/bin
.PHONY: install uninstall all clean

all: blight delaysleep dim-screen lockerd saver screenlocker screensaverbar

blight:
	cp -f blight.sh $@

delaysleep:
	cp -f delaysleep.sh $@

dim-screen:
	cp -f dim-screen.sh $@

lockerd:
	cp -f lockerd.sh $@

saver:
	cp -f saver.sh $@

screenlocker:
	cp -f screenlocker.sh $@

screensaverbar:
	cp -f screensaverbar.sh $@

clean:
	rm -f blight
	rm -f delaysleep
	rm -f dim-screen
	rm -f lockerd
	rm -f saver
	rm -f screenlocker
	rm -f screensaverbar

install:
	mkdir -p $(BIN_LOC)
	cp -vf dim-screen     $(BIN_LOC)/
	cp -vf lockerd        $(BIN_LOC)/
	cp -vf saver          $(BIN_LOC)/
	cp -vf screenlocker   $(BIN_LOC)/
	cp -vf screensaverbar $(BIN_LOC)/
	cp -vf delaysleep     $(BIN_LOC)/

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
