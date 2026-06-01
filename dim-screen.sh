#!/bin/sh

. ./libbacklight.sh

. ./libmsleep.sh

# type:        string
# description
#   script base name through the idiom "${0##*/}"
myname="${0##*/}"

VERB=""

## CONFIGURATION ##############################################################

# Time to sleep (in seconds) between increments. If unset or
# empty, fading is disabled.
fade_step_time=0
# the steps to change brightness per cycle. By default is 1.
dim_step=1

###############################################################################

# type: int
# def: initial_brightness=$(get_brightness)
# description:
#    The initial brightness value.
#    Brightness will be restored to this value upon exit.
# default: 255
initial_brightness=255

# return type: void
# usage: reset_brightness
# description:
#    will run set_brightness
#    on the variable "$initial_brightness"
reset_brightness() {
    current_brightness="$(get_brightness)"
    if [ "$current_brightness" -ne "$initial_brightness" ]; then
        [ -n "$dbgOUT" ] && printf '%s %3d\n' \
            "resetting brightness, current level:" \
            "$current_brightness"
        set_brightness "$initial_brightness"
    fi
}

# return type: void
# usage: fade_brightness "$num"
# description:
#    num will be the value
#    to which the birhgtness
#    will be faded to.
fade_brightness() {
    if [ -z "$fade_step_time" ]; then
        set_brightness "$1"
    else
        # type: int
        # def: level=$(get_brightness)
        # description:
        #    the return value of get_brightness
        level=$(get_brightness)
        while [ "$level" -gt "$min_brightness" ] && [ -z "$NO_CONTINUE" ]; do
            # type: int
            # def: level=$((level-dim_step))
            # description:
            #    value of level minus dim step
            level=$((level-dim_step))
            if [ "$level" -lt 0 ]; then
                level=0
            fi
            set_brightness "$level"
            msleep "$fade_step_time"
        done
    fi
}

sig_handler() {
    NO_CONTINUE=1
    if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
        printf "\n[%s] %s: received signal %s, terminating.\n" \
            "$(date +"%F %T")" "${myname}" "$1"
    fi
    reset_brightness
}

show_usage () {
    printf '%s %s\n' "Usage: ${myname}" \
        "[-debug] [-verbose] [-step-time FLOAT] [-dim-step INT] | [-help]"
}

show_help () {
    show_usage
    printf '%s\n'   "OPTIONS"
    printf '  %s\n' "-debug, -verbose"
    printf '\t%s\n' "Show debug output."
    printf '  %s\n' "-step-time <FLOAT>"
    printf '\t%s\n' "time between steps in seconds, floats are accepted."
    printf '  %s\n' "-dim-step <INT>"
    printf '\t%s\n' "step size, default 1."
    printf '  %s\n' "help, -help, --help, -h"
    printf '\t%s\n' "Show this help message."
}

################
# --- main --- #
################

main () {
    while [ $# -gt 0 ]; do
        case $1 in
            -step-time)
                if is_num "$2"; then
                    fade_step_time=$2
                fi
                shift
            ;;
            -dim-step)
                if is_int "$2"; then
                    dim_step=$2
                fi
                shift
            ;;
            -debug)
                dbgOUT=1
            ;;
            -verbose)
                VERB=1
            ;;
            "help"|"-help"|"--help"|"-h")
                show_help
                exit 0
            ;;
            *)
                printf '%s: %s\n' "$myname" \
                    "unknown argument '${1}'"
                show_usage
                exit 1
            ;;
        esac
        shift
    done
    # ${fade_step_time:-0.1}
    case $fade_step_time in
        0) fade_step_time=0.1 ;;
        0.0*) fade_step_time=0.1 ;;
    esac
    fade_step_time=$(awk -v s="$fade_step_time" 'BEGIN {printf "%d", s*1000}')

    case $dim_step in
        0) dim_step=1 ;;
    esac

    if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
        printf '[%s] %s: PID: %s dimming.\n' "$(date +"%F %T")" "${myname}" "$$"
        printf '%20s: %s\n' "step time" "$fade_step_time milliseconds"
        printf '%20s: %d\n' "dim step" "$dim_step"
    fi

    trap 'sig_handler TERM' TERM
    trap 'sig_handler INT' INT
    trap 'sig_handler HUP' HUP
    trap 'sig_handler USR1' USR1
    trap 'sig_handler USR2' USR2
    trap 'reset_brightness' EXIT
    initial_brightness=$(get_brightness)
    if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
        printf '%20s: %d\n' "starting brightness" "$initial_brightness"
    fi
    fade_brightness $min_brightness

    if [ -n "$dbgOUT" ] || [ -n "$VERB" ] && [ -z "$NO_CONTINUE" ]; then
        printf "[%s] %s: waiting.\n" "$(date +"%F %T")" "${myname}"
    fi

    count=0
    # 5 cycles per second, 60 seconds per minute, 1 minute
    INTERVAL=$(( 5 * 60 ))
    while [ -z "$NO_CONTINUE" ]; do
        # is the count of cycle iterations the same as the interval?
        if [ "$count" = "$INTERVAL" ]; then
            if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
                printf "[%s] %s: waiting for signal.\n" \
                    "$(date +"%F %T")" "${myname}"
            fi
            # reset the count to 0
            count=0
        fi
        # increment the count
        count=$(( count + 1 ))
        # the duty cycle of this daemon is 5 iterations per second
        # this is fast enough to feel responsive to signals, yet not hog
        # resources, mainly cpu
        msleep 200
    done

    if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
        printf "[%s] %s: termnating.\n" "$(date +"%F %T")" "${myname}"
    fi

    reset_brightness
}

main "$@"
