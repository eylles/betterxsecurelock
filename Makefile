.POSIX:
PREFIX = ${HOME}/.local
.PHONY: install uninstall

install:
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -vf dim-screen.sh  ${DESTDIR}${PREFIX}/bin/
	cp -vf lockerd        ${DESTDIR}${PREFIX}/bin/
	cp -vf saver.sh       ${DESTDIR}${PREFIX}/bin/
	cp -vf screenlocker   ${DESTDIR}${PREFIX}/bin/
	cp -vf screensaverbar ${DESTDIR}${PREFIX}/bin/
	cp -vf delaysleep ${DESTDIR}${PREFIX}/bin/
uninstall:
	rm -vf ${DESTDIR}${PREFIX}/bin/dim-screen.sh
	rm -vf ${DESTDIR}${PREFIX}/bin/lockerd
	rm -vf ${DESTDIR}${PREFIX}/bin/saver.sh
	rm -vf ${DESTDIR}${PREFIX}/bin/screenlocker
	rm -vf ${DESTDIR}${PREFIX}/bin/screensaverbar
	rm -vf ${DESTDIR}${PREFIX}/bin/delaysleep

install_on_ac_power:
	cp -vf on_ac_power  ${DESTDIR}${PREFIX}/bin/
uninstall_on_ac_power:
	rm -vf ${DESTDIR}${PREFIX}/bin/on_ac_power
