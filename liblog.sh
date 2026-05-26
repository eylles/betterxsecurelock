#!/bin/sh

# type: int
# description: digit width of the process id number
# default: 6
PIDWIDTH="6"
# use per OS pid length
os_type=$(uname -s)
pw=""
case "${os_type}" in
    Linux)
        pidmax=$(cat /proc/sys/kernel/pid_max)
        pw=${#pidmax}
        ;;
    NetBSD)
        pidmax=30000
        pw=${#pidmax}
        ;;
    OpenBSD|FreeBSD|*BSD)
        pidmax=99999
        pw=${#pidmax}
        ;;
esac
if [ -n "$pw" ]; then
    PIDWIDTH="$pw"
fi
PIDWIDTH="$(( PIDWIDTH + 2 ))"

# Usage: write_log "message text"
# Return: void
# Description:
#   Write message to log file
write_log () {
    name="$myname"
    message="$*"
    printf '[%s] %12s %*s: %s\n' \
        "$(date +'%Y-%m-%d %H:%M:%S')" \
        "$name" \
        "$PIDWIDTH" "[$mypid]" \
        "$message" \
        >> "$LOGFILE"
}
