#!/bin/sh

# SPDX-License-Identifier: Apache-2.0

if [ -z "$VERSION" ]; then
    . ./libversion.sh
fi

. ./libutils.sh

if [ -z "$LOG_LEVEL" ]; then
    LOG_LEVEL=$(getval "LOG_LEVEL" "$CONF")
    if [ -z "$LOG_LEVEL" ]; then
        LOG_LEVEL=1
    fi
    export LOG_LEVEL
fi

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

# Usage: write_log "priority" "message text"
# Return: void
# Arguments:
#    priority: one of { inf, err, dbg }
# Description:
#   Write message to log file
write_log () {
    priority=""
    case "$1" in
        "inf"|"err"|"dbg")
            priority="$1"
            shift
            ;;
        *)
            priority="inf"
            ;;
    esac
    should_log="$_false"
    name="$myname"
    message="$*"
    case "$priority" in
      inf)
        if [ "$LOG_LEVEL" -gt 0 ]; then
          should_log="$_true"
        fi
        ;;
      err)
        if [ "$LOG_LEVEL" -gt 1 ]; then
          should_log="$_true"
        fi
        ;;
      dbg)
        if [ "$LOG_LEVEL" -gt 2 ]; then
          should_log="$_true"
        fi
        ;;
    esac
    if [ "$should_log" -eq "$_true" ]; then
        printf '[%s] %12s %*s %s: %s\n' \
            "$(date +'%Y-%m-%d %H:%M:%S')" \
            "$name" \
            "$PIDWIDTH" "[$mypid]" \
            "$VERSION" \
            "$message" \
            >> "$LOGFILE"
    fi
}
