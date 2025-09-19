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
uninstall:
	rm -vf ${DESTDIR}${PREFIX}/bin/dim-screen.sh
	rm -vf ${DESTDIR}${PREFIX}/bin/lockerd
	rm -vf ${DESTDIR}${PREFIX}/bin/saver.sh
	rm -vf ${DESTDIR}${PREFIX}/bin/screenlocker
	rm -vf ${DESTDIR}${PREFIX}/bin/screensaverbar

