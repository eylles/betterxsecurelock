#!/bin/sh

if [ -z "$HAS_UTILS" ]; then
    . ./libutils.sh
fi

# type: string
# description: usleep path if available
has_usleep=""
has_usleep=$(command -v usleep)
[ -z "$has_usleep" ] && has_usleep=$(command -v busybox)
# type: string
# description: path if available to sleep that supports floats
has_fsleep=""
if [ -z "$has_usleep" ] && is_program "python"; then
  has_usleep=""
  has_fsleep=$(command -v python)
fi
if [ -z "$has_usleep" ] && is_program "perl"; then
  has_usleep=$(command -v perl)
  has_fsleep=""
fi
if sleep 0.001 2>/dev/null; then
    has_usleep=""
    has_fsleep=$(command -v sleep)
fi

# usage: msleep int
# description: sleep for milliseconds
# return type: void
msleep () {
    milisecs="$1"
      if [ -n "$has_usleep" ]; then
    microsecs="${milisecs}000"
    case "$has_usleep" in
      *usleep)
        $has_usleep "$microsecs" >/dev/null 2>&1
        ;;
      *busybox)
        $has_usleep usleep "$microsecs" >/dev/null 2>&1
        ;;
      *perl)
        $has_usleep -MTime::HiRes=usleep -e 'usleep('"$microsecs"')' \
          >/dev/null 2>&1
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
    case "$has_fsleep" in
      *sleep)
        $has_fsleep "$secs" >/dev/null 2>&1
        ;;
      *python)
        $has_fsleep -c 'import time; time.sleep('"$secs"')' >/dev/null 2>&1
        ;;
    esac
  fi
}
