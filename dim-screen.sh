#!/bin/sh

# type:        string
# description
#   script base name through the idiom "${0##*/}"
myname="${0##*/}"

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

# type: int
sleep_pid=""

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
        while [ "$level" -gt "$min_brightness" ]; do
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
    if kill -0 "$sleep_pid" 2>/dev/null; then
        kill "$sleep_pid"
        { [ -n "$dbgOUT" ] || [ -n "$VERB" ]; } && printf "%s %s: sleep %s killed.\n" "$(date +"%F %T")" "${myname}" "$sleep_pid"
    fi
    exit 0
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

{ [ -n "$dbgOUT" ] || [ -n "$VERB" ]; } && printf "%s %s: PID: %s dimming.\n" "$(date +"%F %T")" "${myname}" "$$"

trap 'sig_handler' TERM INT HUP
trap 'reset_brightness' EXIT
current_brightness=$(get_brightness)
fade_brightness $min_brightness
sleep 2147483647 &
sleep_pid=$!
{ [ -n "$dbgOUT" ] || [ -n "$VERB" ]; } && printf "%s %s: waiting for %s sleep.\n" "$(date +"%F %T")" "${myname}" "$sleep_pid"
wait "$sleep_pid"
