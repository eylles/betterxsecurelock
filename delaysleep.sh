#!/bin/sh

. ./libbool.sh
. ./libutils.sh
. ./libpidtreesearch.sh
. ./libmsleep.sh

#####################
# -- config vars -- #
#####################

# seconds to wait before suspend
delay_suspend=900

suspend_on_ac=1

if [ -r "$CONF" ]; then
    # yes, we just outright source the config file without caring...
    # you can only override things written before this, so no arbitrary
    # functions from config
    . "$CONF"
fi

#####################
# --- variables --- #
#####################

# type:        string
# description
#   script base name through the idiom "${0##*/}"
myname="${0##*/}"

# type:        int
# description
#   current running pid of the script
mypid="$$"

. ./liblog.sh

VERB=""
watch_pid=""

# 1000 milliseconds
one_second=1000

# 4 cycles per second
cycles=4

# one_second / cycles
cycle_time=$(( one_second / cycles ))

count=$(( delay_suspend * cycles ))

do_suspend () {
    if [ -x "$(command -v systemact)" ]; then
        systemact -N sleep
    fi
}

sig_handler() {
    NO_CONTINUE=1
    if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
        printf "\n[%s] %s: received signal %s, terminating.\n" \
            "$(date +"%F %T")" "${myname}" "$1"
    fi
}

can_suspend() {
    # |on_ac_power|suspend_on_ac|suspend|
    # |     T     |     T       |   T   |
    # |     T     |     F       |   F   |
    # |     F     |     T       |   T   |
    # |     F     |     F       |   T   |
    if [ "$suspend_on_ac" -eq "$_true" ] && on_ac_power; then
        if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
            echo "suspend on ac is: $suspend_on_ac"
            echo "returning $_true"
        fi
        return $_true
    else
        if on_ac_power; then
            if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
                echo "on ac power is: $_true"
                echo "returning $_false"
            fi
            return $_false
        else
            if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
                echo "on ac power is: $_false"
                echo "returning $_true"
            fi
            return $_true
        fi
    fi
}

while [ $# -gt 0 ]; do
    case $1 in
        -debug)
            dbgOUT=1
        ;;
        -verbose)
            VERB=1
        ;;
        "help"|"-help"|"--help"|"-h")
            # show_help
            exit $_true
        ;;
        -watch)
            shift
            if is_int "$1"; then
                watch_pid=$1
            fi
        ;;
        *)
            printf '%s: %s\n' "$myname" \
                "unknown argument '${1}'"
            # show_usage
            exit $_false
        ;;
    esac
    shift
done

trap 'sig_handler TERM' TERM
trap 'sig_handler INT' INT
trap 'sig_handler HUP' HUP
trap 'sig_handler USR1' USR1
trap 'sig_handler USR2' USR2

c=0
while [ -z "$NO_CONTINUE" ]; do
    if [ -n "$watch_pid" ]; then
        if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
            echo "watching pid $watch_pid"
        fi
        if ! pid_tree_search "$watch_pid" "$myname" >/dev/null ; then
            c=0
            NO_CONTINUE=1
            if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
                echo "preparing to exit"
            fi
        fi
    fi
    if [ "$c" = "$count" ]; then
        c=0
        if can_suspend; then
            if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
                echo "can suspend"
            fi
            do_suspend
        else
            if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
                echo "cannot suspend"
            fi
        fi
    fi
    c=$(( c + 1))
    if [ -n "$VERB" ]; then
        printf '%s: %3d\n' "$myname" "$c"
    fi
    msleep "$cycle_time"
done
