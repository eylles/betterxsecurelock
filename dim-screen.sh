#!/bin/sh

# type:        string
# description
#   script base name through the idiom "${0##*/}"
myname="${0##*/}"

NO_CONTINUE=""

# Example notifier script -- lowers screen brightness, then waits to be killed
# and restores previous brightness on exit.

# return type: boolean
# usage: is_num "value"
# description: check if passed value is a number
is_num() {
    printf %f "$1" >/dev/null 2>&1
}

## CONFIGURATION ##############################################################

# type: int
# def: min_brightness=0
# description:
#    The lowest brightness value.
#    Brightness will be lowered to this value.
min_brightness=0

# If your video driver works with xbacklight, set -time and -steps for fading
# to $min_brightness here. Setting steps to 1 disables fading.
# fade_time=200
# fade_steps=10

# If you have a driver without RandR backlight property (e.g. radeon), set this
# to use the sysfs interface and create a .conf file in /etc/tmpfiles.d/
# containing the following line to make the sysfs file writable for group
# "users":
#
#     m /sys/class/backlight/acpi_video0/brightness 0664 root users - -
#
# Another option is to just rely on the udev rules from the brightnessctl
# package, in distros like debian the udev rules are a separate package so you
# can install them and just ensure your user is on the video group
#
# Making this work with external displays requires the usage of the
# ddcci-driver-linux kernel module
#
sysfs_path="/sys/class/backlight/*/brightness"

# Time to sleep (in seconds) between increments. If unset or
# empty, fading is disabled.
fade_step_time=0
# the steps to change brightness per cycle. By default is 1.
dim_step=1

###############################################################################

# return type: int
# usage: get_brightness
# description:
#    will return the current brightness value
#    brightness values are from 0 to 255
get_brightness() {
    if [ -z "$sysfs_path" ]; then
        brightnessctl g
    else
        c=0
        # get brightness just from the first screen we can find
        for screen_path in $sysfs_path; do
            out=$(cat "$screen_path")
            c=$(( c + 1 ))
            [ "$c" -gt 0 ] && break
        done
        printf '%d\n' "$out"
    fi
}

# return type: void
# usage: set_brightness num
# description:
#    will set the brightness to the passed number
#    brightness values are from 0 to 255
set_brightness() {
    if [ -z "$sysfs_path" ]; then
        [ -n "$dbgOUT" ] && printf '%s %3d\n' "brightness level:" "$1"
        brightnessctl s "$1" >/dev/null
    else
        [ -n "$dbgOUT" ] && printf '%s %3d  ' "brightness level:" "$1"
        # set brightness for every screen we can find
        for screen_path in $sysfs_path; do
            printf '%d' "$1" > "$screen_path"
            scp_t="${screen_path%/*}"
            scp_t="${scp_t##*/}"
            [ -n "$dbgOUT" ] && printf '%s ' "$scp_t"
        done
        [ -n "$dbgOUT" ] && printf '\n'
    fi
}

# type: int
# def: current_brightness=$(get_brightness)
# description:
#    The current brightness value.
#    Brightness will be restored to this value.
# default: 255
current_brightness=255

# return type: void
# usage: reset_brightness
# description:
#    will run set_brightness
#    on the variable "$current_brightness"
reset_brightness() {
    level="$(get_brightness)"
    if [ "$level" -ne "$current_brightness" ]; then
        [ -n "$dbgOUT" ] && printf '%s %3d\n' \
            "resetting brightness, current level:" \
            "$level"
        set_brightness "$current_brightness"
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
            sleep "$fade_step_time"
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

while [ $# -gt 0 ]; do
    case $1 in
        -step-time)
            if is_num "$2"; then
                fade_step_time=$2
            fi
            shift
        ;;
        -dim-step)
            if is_num "$2"; then
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

case $dim_step in
    0) dim_step=1 ;;
esac

if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
    printf '[%s] %s: PID: %s dimming.\n' "$(date +"%F %T")" "${myname}" "$$"
    printf '%20s: %s\n' "step time" "$fade_step_time"
    printf '%20s: %d\n' "dim step" "$dim_step"
fi

trap 'sig_handler TERM' TERM
trap 'sig_handler INT' INT
trap 'sig_handler HUP' HUP
trap 'sig_handler USR1' USR1
trap 'sig_handler USR2' USR2
trap 'reset_brightness' EXIT
current_brightness=$(get_brightness)
if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
    printf '%20s: %d\n' "starting brightness" "$current_brightness"
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
    # ingrement the count
    count=$(( count + 1 ))
    # the duty cycle of this daemon is 5 iterations per second
    # this is fast enough to feel responsive to signals, yet not hog
    # resources, mainly cpu
    sleep 0.2
done

if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
    printf "[%s] %s: termnating.\n" "$(date +"%F %T")" "${myname}"
fi

reset_brightness
