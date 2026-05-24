#!/bin/sh

has_usleep=""
has_usleep=$(command -v usleep)
[ -z "$has_usleep" ] && has_usleep=$(command -v busybox)
if sleep 0.001 2>/dev/null; then
    has_usleep=""
fi

# usage: msleep int
# description: sleep for milliseconds
# return type: void
msleep () {
    milisecs="$1"
    if [ -n "$has_usleep" ]; then
        microsecs="${milisecs}000"
        case "$has_usleep" in
            */usleep)
                usleep "$microsecs"
                ;;
            */busybox)
                busybox usleep "$microsecs"
                ;;
        esac
    else
        sec_whole=$(( milisecs / 1000 ))
        sec_decim=$(( milisecs % 1000 ))
        if [ "$sec_decim" -lt 10 ]; then
            sec_decim="00${sec_decim}"
        elif [ "$sec_decim" -lt 100 ]; then
            sec_decim="0${sec_decim}"
        fi
        secs="${sec_whole}.${sec_decim}"
        sleep "$secs"
    fi
}
