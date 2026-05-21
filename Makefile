.POSIX:
PREFIX = ${HOME}/.local
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
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -vf dim-screen     ${DESTDIR}${PREFIX}/bin/
	cp -vf lockerd        ${DESTDIR}${PREFIX}/bin/
	cp -vf saver          ${DESTDIR}${PREFIX}/bin/
	cp -vf screenlocker   ${DESTDIR}${PREFIX}/bin/
	cp -vf screensaverbar ${DESTDIR}${PREFIX}/bin/
	cp -vf delaysleep     ${DESTDIR}${PREFIX}/bin/

uninstall:
	rm -vf ${DESTDIR}${PREFIX}/bin/dim-screen
	rm -vf ${DESTDIR}${PREFIX}/bin/lockerd
	rm -vf ${DESTDIR}${PREFIX}/bin/saver
	rm -vf ${DESTDIR}${PREFIX}/bin/screenlocker
	rm -vf ${DESTDIR}${PREFIX}/bin/screensaverbar
	rm -vf ${DESTDIR}${PREFIX}/bin/delaysleep

install_on_ac_power:
	cp -vf on_ac_power  ${DESTDIR}${PREFIX}/bin/
uninstall_on_ac_power:
	rm -vf ${DESTDIR}${PREFIX}/bin/on_ac_power
