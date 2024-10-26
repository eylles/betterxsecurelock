#!/bin/sh

#####################
# --- variables --- #
#####################

# type:        string
# description
#   script base name through the idiom "${0##*/}"
myname="${0##*/}"

# type:        string
# description:
#   screen saver module to use
Screen_Saver=""

saver_list_1="walldir,livewall"
saver_list_2="currwall,snake"
saver_list_3="matrix,pipes,snake"
saver_list_4="walldir,livewall"
saver_list_5="livewall"

term_font="BlexMono Nerd Font Mono"

wallpaper="${HOME}/.local/share/bg"

live_walls="${HOME}/Videos/live-walls"

wall_dir="${HOME}/Pictures/wallpapers"

# type:        int bool
# description:
#   C like int bool, whether to print debug output.
#   0 = false
#   1 = true
DBGOUT=""
# type:        int bool
# description:
#   C like int bool, whether to dry run.
#   0 = false
#   1 = true
DRYRUN=""

# type:        string
# description:
#   x11 screen geometry string WIDTHxHEIGHT
geometry=$(xdpyinfo | grep 'dimensions:' | cut -d' ' -f7)

# type:        int
# description:
#   current screen saver module pid
#   used by sig_handler to kill the running screen saver module.
saver_pid=""

# type:        int
# description:
#   current screen saver bar pid
#   used by auth watcher to kill the running screen saver bar.
ssbar_pid=""

#####################
# --- functions --- #
#####################

# return type: string
# usage: split_str "string" "pattern"
# description:
#   splits string on pattern returns
#   a newline separated list.
# taken from:
#   https://github.com/dylanaraps/pure-sh-bible#split-a-string-on-a-delimiter
split_str() {
    # Disable globbing.
    # This ensures that the word-splitting is safe.
    set -f

    # Store the current value of 'IFS' so we
    # can restore it later.
    old_ifs=$IFS

    # Change the field separator to what we're
    # splitting on.
    IFS=$2

    # Create an argument list splitting at each
    # occurrence of '$2'.
    #
    # This is safe to disable as it just warns against
    # word-splitting which is the behavior we expect.
    # shellcheck disable=2086
    set -- $1

    # Print each list value on its own line.
    printf '%s\n' "$@"

    # Restore the value of 'IFS'.
    IFS=$old_ifs

    # Re-enable globbing.
    set +f
}

roll_saver() {
  [ "$DBGOUT" = 1 ] && printf '%s\n' "SAVER_OPT: $SAVER_OPT"
  if [ -z "$SAVER_OPT" ]; then
    if [ -z "$Screen_Saver" ]; then
      Screen_Saver=$(shuf -n 1 -e walldir currwall livewall)
    fi
  else
    case "${SAVER_OPT}" in
      0)  Screen_Saver=$(split_str "$saver_list_1" "," | shuf -n 1) ;;
      2)  Screen_Saver=$(split_str "$saver_list_2" "," | shuf -n 1) ;;
      10) Screen_Saver=$(split_str "$saver_list_3" "," | shuf -n 1) ;;
      8)  Screen_Saver=$(split_str "$saver_list_4" "," | shuf -n 1) ;;
      15) Screen_Saver=$(split_str "$saver_list_5" "," | shuf -n 1) ;;
    esac
  fi
  [ "$DBGOUT" = 1 ] && printf '%s\n' "Screen_Saver: $Screen_Saver"
}

# return type: void
# usage: run_saver
# description:
#   will run the screen saver module specified by the
#   Screen_Saver variable, and set the saver_pid variable
#   after that it will wait until the screen saver module
#   is terminated.
run_saver() {
    roll_saver
    if [ "$DRYRUN" = 1 ]; then
        printf '%s\n' "${myname}: dry run mode, no saver started."
    else
        # printf '%s\n' "${myname}: saver module $Screen_Saver selected."
        case "$Screen_Saver" in
        matrix)
            [ "$DBGOUT" = 1 ] && printf '%s\n' \
                "${myname}: starting saver $Screen_Saver"
            # try to use unimatrix first
            matrix_cmd=$(command -v unimatrix)
            # fallback to cmatrix
            [ -z "$matrix_cmd" ] && matrix_cmd=$(command -v cmatrix)
            if [ -z "$matrix_cmd" ]; then
                return 1
            else
                case "$matrix_cmd" in
                    *unimatrix)
                        flags="-af -s 95"
                    ;;
                    *cmatrix)
                        flags="-ba"
                    ;;
                esac
                xterm \
                    -fa "$term_font" -fs 12 -into "$XSCREENSAVER_WINDOW" \
                    -g "$geometry" -e $matrix_cmd "$flags" &
                saver_pid=$!
                [ "$DBGOUT" = 1 ] && printf '%s\n' "${myname}: saver pid $saver_pid"
            fi
            ;;
        pipes)
            np=$(shuf -n 1 -e 1 2 3 4)
            [ "$DBGOUT" = 1 ] && printf '%s\n' \
                "${myname}: starting saver $Screen_Saver"
            xterm \
                -fa "$term_font" -fs 30 -into "$XSCREENSAVER_WINDOW" \
                -g "$geometry" -e pipes.sh -p "$np" -f 60 -R -r 1000 &
            saver_pid=$!
            [ "$DBGOUT" = 1 ] && printf '%s\n' "${myname}: saver pid $saver_pid"
            ;;
        btop)
            [ "$DBGOUT" = 1 ] && printf '%s\n' \
                "${myname}: starting saver $Screen_Saver"
            xterm \
                -fa "$term_font" -fs 12 -into "$XSCREENSAVER_WINDOW" \
                -g "$geometry" -e btop &
            saver_pid=$!
            [ "$DBGOUT" = 1 ] && printf '%s\n' "${myname}: saver pid $saver_pid"
            ;;
        snake)
            sl=$(shuf -n 1 -e fancy dots)
            [ "$DBGOUT" = 1 ] && printf '%s\n' \
                "${myname}: starting saver $Screen_Saver"
            xterm \
                -fa "$term_font" -fs 30 -into "$XSCREENSAVER_WINDOW" \
                -g "$geometry" -e sssnake -m screensaver -s 15 -l "$sl" &
            saver_pid=$!
            [ "$DBGOUT" = 1 ] && printf '%s\n' "${myname}: saver pid $saver_pid"
            ;;
        fire)
            [ "$DBGOUT" = 1 ] && printf '%s\n' \
                "${myname}: starting saver $Screen_Saver"
            xterm \
                -into "$XSCREENSAVER_WINDOW" \
                -g "$geometry" -e fire -l 300 -t -s 10 -f 3 &
            saver_pid=$!
            [ "$DBGOUT" = 1 ] && printf '%s\n' "${myname}: saver pid $saver_pid"
            ;;
        walldir)
            [ "$DBGOUT" = 1 ] && printf '%s\n' \
                "${myname}: starting saver $Screen_Saver"
            delay=$(shuf -n 1 -e 0.5 1 1.5 2 2.5 3)
            find "$wall_dir" -type f | shuf | nsxiv -i -bfq -S "$delay"\
            -e "$XSCREENSAVER_WINDOW" -g "$geometry" -s F 2>/dev/null &
            saver_pid=$!
            [ "$DBGOUT" = 1 ] && printf '%s\n' "${myname}: saver pid $saver_pid"
            # find ~/Pictures/wallpapers -type f | shuf |\
            # mpv --no-input-terminal --loop=inf --no-stop-screensaver\
            # --wid="${XSCREENSAVER_WINDOW}" --no-config --hwdec=auto\
            # --vo=gpu --image-display-duration="$delay"
            ;;
        currwall)
            [ "$DBGOUT" = 1 ] && printf '%s\n' \
                "${myname}: starting saver $Screen_Saver"
            nsxiv -bfq -e "$XSCREENSAVER_WINDOW" -g "$geometry"\
            -s F "$wallpaper" 2>/dev/null &
            saver_pid=$!
            [ "$DBGOUT" = 1 ] && printf '%s\n' "${myname}: saver pid $saver_pid"
            # mpv --no-input-terminal --loop=inf --no-stop-screensaver\
            # --wid="${XSCREENSAVER_WINDOW}" --no-config --hwdec=auto\
            # --vo=gpu --video-unscaled=yes ~/.local/share/bg
            ;;
        livewall)
            [ "$DBGOUT" = 1 ] && printf '%s\n' \
                "${myname}: starting saver $Screen_Saver"
            mpv --no-input-terminal --loop=inf --no-stop-screensaver \
            --wid="${XSCREENSAVER_WINDOW}" --no-config --hwdec=auto \
            --really-quiet --no-audio \
            --vo=gpu "$(shuf -n 1 -e "${live_walls}"/* )" 2>/dev/null &
            saver_pid=$!
            [ "$DBGOUT" = 1 ] && printf '%s\n' "${myname}: saver pid $saver_pid"
            ;;
        esac
        if kill -0 "$saver_pid"; then
            # show screensaver bar
            while kill -0 "$saver_pid"; do
                sleep 0.1
                if pgrep auth_x11 >/dev/null; then
                    if ! kill -0 "$ssbar_pid"; then
                        # if [ -n "$XSECURELOCK_FONT" ]; then
                        #   bar_font="$XSECURELOCK_FONT"
                        # else
                        #   bar_font="BlexMono Nerd Font Mono"
                        # fi
                        bar_font="BlexMono Nerd Font Mono"
                        xterm \
                            -into "$XSCREENSAVER_WINDOW" \
                            -g "98x1" -fa "$bar_font" -fs 20 -b 0 \
                            -e screensaverbar &
                        ssbar_pid=$!
                    fi
                    # wait
                fi
            done
        else
            printf '%s\n' "${myname}: saver module failed, re-running."
            run_saver
        fi
    fi
}

# return type: void
# usage: trap 'sig_handler' SIGNAL
# description:
#   kills the current screen saver module with it's pid
#   and then calls the run_saver function.
#   it is called on the USR1 signal
sig_handler() {
    kill $saver_pid
    if [ -n "$ssbar_pid" ]; then
        kill $ssbar_pid
        ssbar_pid=""
    fi
    roll_saver
    run_saver
}

################
# --- main --- #
################

while [ "$#" -gt 0 ]; do
    case "$1" in
        -debug)   DBGOUT=1  ;;
        -dryrun)  DRYRUN=1  ;;
        # xsecurelock passes to every saver on /usr/libexec/xsecurelock
        # it is really only used on saver_xscreensaver tho.
        -root)    :         ;;
        *)
            printf '%s\n' "${myname}: error, invalid argument: ${1} ignored."
            # exit 1
            ;;
    esac
    shift
done

[ "$DBGOUT" = 1 ] && printf '%s\n' "saver list 1: $saver_list_1"
[ "$DBGOUT" = 1 ] && printf '%s\n' "saver list 2: $saver_list_2"
[ "$DBGOUT" = 1 ] && printf '%s\n' "saver list 3: $saver_list_3"
[ "$DBGOUT" = 1 ] && printf '%s\n' "saver list 4: $saver_list_4"
[ "$DBGOUT" = 1 ] && printf '%s\n' "saver list 5: $saver_list_5"

trap 'sig_handler' USR1

run_saver
