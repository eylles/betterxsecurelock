#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later

. ./libutils.sh

# type:        string
# description
#   script base name through the idiom "${0##*/}"
myname="${0##*/}"

# type:        int
# description
#   current running pid of the script
mypid="$$"

export LOCKERD_PID=$mypid

DBGOUT=""
TIME_TO_LOCK=""
xsslock_pid=""

logdir="${HOME}/.local/state/better-xsecurelock"
if [ ! -f "$logdir" ]; then
    mkdir -p "$logdir"
fi
LOGFILE="${logdir}/${myname}"

# default 600 seconds
# but config value will
# be used if set
TIME=600

# ${HOME}/.config/better-xsecurelock/
CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/better-xsecurelock"
#config file
CONF="${CONFIG_DIR}/config"

# XDG_SESSION_ID wrapper, so that it can be passed by command line if passing by
# environment is not possible for whatever reason
SessionID=""
[ -n "$XDG_SESSION_ID" ] && SessionID="$XDG_SESSION_ID"

show_usage () {
    printf '%s\n' "Usage: ${myname} [debug|-d] [-l LOGFILE] [-c CONFIG] | [-h]"
}

show_help () {
    show_usage
    printf '%s\n'   "OPTIONS"
    printf '  %s\n' "debug, -d"
    printf '\t%s\n' "Show debug output."
    printf '  %s\n' "logfile <LOGFILE>, -l <LOGFILE>"
    printf '\t%s\n' "Specify LOGFILE, it must be a valid writeable file."
    printf '  %s\n' "config <CONFIG>, -c <CONFIG>"
    printf '\t%s\n' "Specify CONFIG file, it must be a valid readable file."
    printf '  %s\n' "session-id <XDG_SESSION_ID>, -s <XDG_SESSION_ID>"
    printf '\t%s\n' "Specify the XDG_SESSION_ID of the program, must be an int."
    printf '\t%s\n' "Use only when XDG_SESSION_ID cannot be passed through ENV."
    printf '  %s\n' "help, -h"
    printf '\t%s\n' "Show this help message."
    printf '%s\n'   "SIGNALS"
    printf '  %s\n' "In addition ${myname} can handle the following signals:"
    printf '  %s' "HUP"
    printf '\t%s\n' "Reload the config."
    printf '  %s' "USR1"
    printf '\t%s\n' "Reload the config."
    printf '  %s' "USR2"
    printf '\t%s\n' "Relaunch the program."
}

opts=""
# input parsing
while [ "$#" -gt 0 ]; do
    case "$1" in
        debug|-d)
            DBGOUT=1
            opts="${1} ${opts}"
            ;;
        logfile|-l)
            if [ -w "$2" ]; then
                LOGFILE="$2"
                opts="${1} ${2} ${opts}"
            else
                printf '%s: %s\n' "${myname}" \
                    "invalid logfile location '${2}', using default: ${LOGFILE}"
            fi
            shift
            ;;
        config|-c)
            if [ -r "$2" ]; then
                CONF="$2"
                opts="${1} ${2} ${opts}"
            else
                printf '%s: %s\n' "${myname}" \
                    "invalid config location '${2}', using default: ${CONF}"
            fi
            shift
            ;;
        session-id|-s)
            if is_int "$2"; then
                SessionID="$2"
            else
                printf '%s: %s\n' "${myname}" \
                    "invalid value type."
            fi
            shift
            ;;
        help|-h)
            show_help
            exit 0
            ;;
        *)
            printf '%s\n' "${myname}: error, invalid argument: ${1}"
            show_usage
            exit 1
            ;;
    esac
    shift
done
export CONF LOGFILE PIDWIDTH

. ./liblog.sh
. ./libmsleep.sh
. ./libpidtreesearch.sh

if [ -z "$SessionID" ]; then
    write_log "could not determine Session ID, exiting..."
    exit 1
fi

started_string="started."
if [ -n "$opts" ]; then
    started_string="started with options: ${opts}"
fi
write_log "$started_string"
[ -n "$DBGOUT" ] && printf '%s %s\n' "$myname" "$started_string"
[ -n "$DBGOUT" ] && printf '%s %s\n' "$myname pid:" "$mypid"

# Usage: load_config
# Return: void
# Description:
#   Load values from the configuration file if it exists.
load_config () {
    if [ -r "$CONF" ]; then
        [ -n "$DBGOUT" ] && printf '%s: %s\n' "$myname" "config $CONF loaded"
        TIME_TO_LOCK=$(getval "TIME_TO_LOCK" "$CONF")
        [ -n "$TIME_TO_LOCK" ] && TIME=$TIME_TO_LOCK
    fi
}

# Usage: set_time
# Return: void
# Description:
#   Sets the screen saver activation and dpms parameters via xset.
set_time () {
    load_config
    [ -n "$DBGOUT" ] && printf '%s: %s\n' "${myname} time" "$TIME"
    c_cycle="$(( TIME / 5 ))"
    c_timeout="$(( TIME - c_cycle ))"
    c_off="$(( TIME * 3 / 2 ))"
    SAVER_TIMEOUT="$c_cycle"
    export SAVER_TIMEOUT
    # screensaver time
    # <timeout> <cycle>
    time_ss="$c_timeout $c_cycle"
    # dpms time
    # <standby> <suspend> <off>
    time_dpms="0 0 $c_off"

    [ -n "$DBGOUT" ] && printf '%20s: %s\n' "time screensaver" "$time_ss"
    [ -n "$DBGOUT" ] && printf '%20s: %s\n' "time dpms" "$time_dpms"

    # we want word splitting here
    # shellcheck disable=SC2086
    xset s ${time_ss}
    # shellcheck disable=SC2086
    xset dpms ${time_dpms}
    write_log "set time s as: ${time_ss} and dpms as: ${time_dpms}"
}

# Usage: outHandler "SIG"
# Return: void
# Description:
#   Handle signals to terminate the program, sets NO_CONTINUE to 1 so that the
#   waiter cycle can terminate.
outHandler () {
    [ "$DBGOUT" = 1 ] && printf '\n%s\n' "exiting on signal: $1"
    # kill "$xsslock_pid"
    NO_CONTINUE=1
    # exit
}

# Usage: relHandler "SIG"
# Return: void
# Description:
#   Handle signals to terminate the program, sets NO_CONTINUE to 2 so that the
#   waiter cycle can terminate and the program can exec "$0" to reload.
relHandler () {
    [ "$DBGOUT" = 1 ] && printf '\n%s\n' "reloading on signal: $1"
    NO_CONTINUE=2
}

# Usage: sigHandler "SIG"
# Return: void
# Description:
#   Handles external signals to the program to reload config and set the screen
#   saver activation times.
#   Writes to log.
sigHandler () {
    [ -n "$DBGOUT" ] && printf '%s: %s\n' "${myname} received signal" "$1"
    write_log "$1 received"
    set_time
}

set_time

if ! pid_tree_search "${mypid}" "xss-lock"; then
    xss-lock -n dim-screen -s "$SessionID" -l -v -- screenlocker 2>&1 \
        | cat >> "$LOGFILE" &
fi
# capture pid
# a simple $! is not enough thanks to using sed...
xsslock_pid=$(pid_tree_search "${mypid}" "xss-lock")
write_log "xss-lock pid captured as ${xsslock_pid}"

trap 'sigHandler "HUP"' HUP
trap 'sigHandler "USR1"' USR1
trap 'relHandler "USR2"' USR2
trap 'outHandler "EXIT"' EXIT
trap 'outHandler "TERM"' TERM
trap 'outHandler "INT"' INT
trap 'outHandler "QUIT"' QUIT

# Usage: fetch_screensaver_vars
# Return: string
# Description:
#   Returns the current screen saver activation times in a string as
#   TIMEOUTxCYCLE, example: 480x120
fetch_screensaver_vars () {
    xset q | u_awk '/timeout/ { print $2"x"$4 }'
}

# Usage: find_suspenders_in_session
# Return: boolean
# Description:
#   Searches the process list for instances of xdg-screensaver that are running
#   with the suspend argument in the current desktop session.
find_suspenders_in_session () {
    ps ax -o'cgroup,user,cmd=CMD' \
        | grep -v "grep" \
        | grep "0::/${SessionID}" \
        | grep " $USER " \
        | grep "xdg-screensaver" \
        | grep -q "suspend"
}

# Usage: should_set_time
# Return: boolean
# Description:
#   Returns 0 when the screen saver activation time is a "correct" value and
#   there's no need to set it again.
#   Returns 1 when the screen saver activation time is a "wrong" value and has
#   to be set again.
should_set_time () {
    retval=0
    t_and_c=$(fetch_screensaver_vars)
    ss_timeout="${t_and_c%%x*}"
    ss_cycle="${t_and_c##*x}"

    if [ "$ss_timeout" -ne 0 ]; then
        if [ "$ss_timeout" -eq "$ss_cycle" ]; then
            retval=1
        fi
    else
        if ! find_suspenders_in_session; then
            retval=1
        fi
    fi
    return "$retval"
}

write_log "waiting for xss-lock"
# 5 cycles per second, 60 seconds per minute, 60 minutes
INTERVAL=$(( 5 * 60 * 60 ))
# 5 cycles per second, 20 seconds
cyc=$(( 5 * 20 ))
MiliSecs=$(shuf -i 200-250 -n 1)
while [ -z "$NO_CONTINUE" ]; do
    # is the count of cycle iterations the same as the interval?
    if [ "$count" = "$INTERVAL" ]; then
        write_log "running"
        # reset the count to 0
        count=0
    fi
    # check if we need to set time
    if [ $(( count % cyc )) -eq 0 ]; then
        if ! should_set_time ; then
            write_log "incorrect time setting detected"
            set_time
        fi
    fi
    # ingrement the count
    count=$(( count + 1 ))
    # the duty cycle of this daemon is 5 iterations per second
    # this is fast enough to feel responsive to signals, yet not hog
    # resources, mainly cpu
    msleep "$MiliSecs"
done

write_log "no continue received"

if kill -0 "$xsslock_pid" >/dev/null; then
    kill "$xsslock_pid"
    write_log "xss-lock killed"
fi
[ -n "$DBGOUT" ] && printf '%s: %s\n' "${myname} killed" "xss-lock"
case "$NO_CONTINUE" in
    1)
        write_log "terminating."
        exit 0
        ;;
    2)
        write_log "reloading."
        if [ -n "$opts" ]; then
            set -- ${opts}
        fi
        exec $0 "$@"
        ;;
esac
