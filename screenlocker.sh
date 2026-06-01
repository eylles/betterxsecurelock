#!/bin/sh

#####################
# --- conf vars --- #
#####################

blank_timeout="600"
auth_font="Noto Sans CJK JP"
password_prompt="disco"
show_hostname=0
show_username=1
burnin_mitigation=50
burnin_mitigation_pixels=1

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

# color  0
# type: hex string
 color0=""
# color  2
# type: hex string
 color2=""
# color  8
# type: hex string
 color8=""
# color 10
# type: hex string
color10=""
# color 12
# type: hex string
color12=""
# color 15
# type: hex string
color15=""

# type:        int
# description:
#   randomly chosen color index
COLO_OPT=$(shuf -n 1 -e 1 2 3 4 5)

# type:        hex string
# description:
#   color used for auth background
AuthBgColor=""

# type:        hex string
# description:
#   color used for auth foreground
AuthFgColor=""

# type:        int
# description:
#   pid of current xsecurelock instance
xsecurelock_pid=""

# type:        int
# description:
#   pid of launched dimmer
dimmer_pid=""

# type:        int
# description:
#   pid of delayed sleep
delaysleep_pid=""

#####################
# --- functions --- #
#####################

. ./libutils.sh
. ./libpidtreesearch.sh
. ./libmsleep.sh
. ./liblog.sh

# return type: void
# description:
#   kill dim-screen process
#   that may be dangling from previous instances
kill_dangling_dimmers () {
    if pid_tree_search "$LOCKERD_PID" "dim-screen" > /dev/null; then
        dangling_dim_screen_pid=$(pid_tree_search "$LOCKERD_PID" dim-screen)
        dimmer_comm=$(ps -p "$dangling_dim_screen_pid" -o command=)
        kill "$dangling_dim_screen_pid"
        write_log \
            "dangling ${dimmer_comm##*/} PID: $dangling_dim_screen_pid killed."
    fi
}

# return type: void
# description:
#   start xsecurelock and capture it's pid
start_xsecurelock () {
    # from config
    export XSECURELOCK_FONT="$auth_font"
    export XSECURELOCK_PASSWORD_PROMPT="$password_prompt"
    export XSECURELOCK_SHOW_HOSTNAME="$show_hostname"
    export XSECURELOCK_SHOW_USERNAME="$show_username"
    export XSECURELOCK_BURNIN_MITIGATION="$burnin_mitigation"
    export XSECURELOCK_BURNIN_MITIGATION_DYNAMIC="$burnin_mitigation_pixels"
    # defined at runtime
    export XSECURELOCK_AUTH_TIMEOUT="$SAVER_TIMEOUT"
    export XSECURELOCK_AUTH_BACKGROUND_COLOR="$AuthBgColor"
    export XSECURELOCK_AUTH_FOREGROUND_COLOR="$AuthFgColor"
    # constants
    export XSECURELOCK_SAVER="${HOME}/.local/bin/saver"
    export XSECURELOCK_SAVER_RESET_ON_AUTH_CLOSE=1
    export XSECURELOCK_COMPOSITE_OBSCURER=0
    export XSECURELOCK_NO_COMPOSITE=1
    export XSECURELOCK_BLANK_TIMEOUT="$blank_timeout"
    export XSECURELOCK_SAVER_STOP_ON_BLANK=1
    export XSECURELOCK_BLANK_DPMS_STATE=off
    xsecurelock 2>/dev/null &
    xsecurelock_pid=$!
    sleep 1
    if ps -p "$xsecurelock_pid" -o cmd | grep -q "xsecurelock" ; then
        write_log \
            "launched xsecurelock PID: $xsecurelock_pid"
    else
        write_log "xsecurelock start failed, trying again."
        start_xsecurelock
    fi
}

if pid_tree_search "$LOCKERD_PID" "xsecurelock" >/dev/null; then
    instance_pid=$(pid_tree_search "$LOCKERD_PID" "xsecurelock")
    write_log \
        "xsecurelock instance" \
        "$instance_pid" \
        "already running, no new instance will be launched."
    exit
else
    write_log "no xsecurelock instance running."
    write_log "starting screenlocking."
    . "${HOME}/.cache/wal/colors.sh"
    export SAVER_OPT="$COLO_OPT"
    case "${COLO_OPT}" in
        1) export AuthBgColor="$color0" ;;
        2) export AuthBgColor="$color2" ;;
        3) export AuthBgColor="$color8" ;;
        4) export AuthBgColor="$color10" ;;
        5) export AuthBgColor="$color15" ;;
    esac
    case "${COLO_OPT}" in
        1) export AuthFgColor="$color12" ;;
        2) export AuthFgColor="$color15" ;;
        3) export AuthFgColor="$color15" ;;
        4) export AuthFgColor="$color0" ;;
        5) export AuthFgColor="$color8" ;;
    esac

    start_xsecurelock

    kill_dangling_dimmers
    # auth watcher
    while pid_tree_search "$mypid" xsecurelock >/dev/null; do
        if pid_tree_search "$mypid" auth_x11 >/dev/null; then
            # kill_dangling_dimmers
            if kill -0 "$dimmer_pid" 2>/dev/null; then
                dimmer_comm=$(ps -p "$dimmer_pid" -o command=)
                kill -0 "$dimmer_pid" 2>/dev/null && \
                kill "$dimmer_pid" 2>/dev/null && \
                write_log "${dimmer_comm##*/} PID: $dimmer_pid killed."
            fi
            if kill -0 "$delaysleep_pid" 2>/dev/null; then
                kill "$delaysleep_pid" 2>/dev/null && \
                    write_log "delaysleep PID: $delaysleep_pid killed."
            fi
        else
            if ! pid_tree_search "$mypid" delaysleep >/dev/null; then
                delaysleep -watch "$mypid" &
                delaysleep_pid=$(pid_tree_search "$LOCKERD_PID" "delaysleep")
            fi
            if ! pid_tree_search "$mypid" dim-screen >/dev/null; then
                dim-screen -step-time 0.2 &
                dimmer_pid=$(pid_tree_search "$LOCKERD_PID" "dim-screen")
            fi
        fi
        msleep 100
    done
    kill_dangling_dimmers
fi
write_log "screen unlocked."
