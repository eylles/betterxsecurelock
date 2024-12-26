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
# sysfs_path="/sys/class/backlight/*/brightness"

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
        cat "$sysfs_path"
    fi
}

# return type: void
# usage: set_brightness num
# description:
#    will set the brightness to the passed number
#    brightness values are from 0 to 255
set_brightness() {
    [ -n "$dbgOUT" ] && printf 'brightness level: %s\n' "$1"
    if [ -z "$sysfs_path" ]; then
        brightnessctl s "$1" >/dev/null
    else
        echo "$1" > "$sysfs_path"
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
    set_brightness "$current_brightness"
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

################
# --- main --- #
################

while [ $# -gt 0 ]; do
    case $1 in
        -step-time)
            if is_num "$2"; then
                fade_step_time=$2
            fi
            ;;
        -dim-step)
            if is_num "$2"; then
                dim_step=$2
            fi
            ;;
        -debug)
            dbgOUT=1
            ;;
        -verbose)
            VERB=1
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
    printf "[%s] %s: PID: %s dimming.\n" "$(date +"%F %T")" "${myname}" "$$"
fi

trap 'sig_handler TERM' TERM
trap 'sig_handler INT' INT
trap 'sig_handler HUP' HUP
trap 'reset_brightness' EXIT
current_brightness=$(get_brightness)
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
