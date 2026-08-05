#!/bin/sh

# SPDX-License-Identifier: Apache-2.0

if [ -z "$HAS_UTILS" ]; then
    . ./libutils.sh
fi

# Making this work with external displays requires the usage of the
# ddcci-driver-linux kernel module
sysfs_path="/sys/class/backlight/*/brightness"

# type: int const
# def: min_brightness=0
# description:
#    The lowest brightness value.
min_brightness=0

# type: int const
# def: 255
# description:
#    The maximum range for brightness.
#    All brightness adjustments are done in the range between min_brightness
#    and this value, meaning a range of 0 to 255 inclusive.
#    The actual value written to each backlight device is scaled according to
#    the device's max_brightness range.
max_brightness=255

# return type: int
# usage: get_scaled brightness_file
# description:
#    will return the scaled brightness value from the given brightness_file
get_scaled () {
    brightness_file="$1"
    brightness_path="${brightness_file%/*}"
    brighntess_max_file="${brightness_path}/max_brightness"
    max_val=$(cat "$brighntess_max_file")
    # remove float part if any
    max_val="${max_val%.*}"
    value=$(cat "$brightness_file")
    # remove float part if any
    value="${value%.*}"
    scaled_value=$(unscale_val "$value" "$max_val" "$max_brightness" )
    printf '%d' "$scaled_value"
}

# return type: int
# usage: get_brightness
# description:
#    will return the current brightness value
#    brightness values are from 0 to 255
get_brightness() {
    c=0
    # get brightness just from the first screen we can find
    for screen_path in $sysfs_path; do
        out=$(get_scaled "$screen_path")
        c=$(( c + 1 ))
        [ "$c" -gt 0 ] && break
    done
    printf '%d\n' "$out"
}

# return type: void
# usage: set_scaled brightness_file value
# description:
#    will write the scaled brightness value onto the brightness_file
set_scaled () {
    brightness_file="$1"
    brightness_path="${brightness_file%/*}"
    brighntess_max_file="${brightness_path}/max_brightness"
    if [ -r "$brighntess_max_file" ]; then
        max_val=$(cat "$brighntess_max_file")
    else
        max_val="$max_brightness"
    fi
    # remove float part if any
    max_val="${max_val%.*}"
    value="$2"
    scaled_value=$(scale_val "$value" "$max_brightness" "$max_val")
    if [ -w "$brightness_file" ]; then
        printf '%s' "$scaled_value" > "$brightness_file"
        if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
            printf '[%s: %6d]   ' "actual value" "$scaled_value"
        fi
    fi
}

# return type: void
# usage: set_brightness num
# description:
#    will set the brightness to the passed number
#    brightness values are from 0 to 255
set_brightness() {
    val="$1"
    perc_val="$(int_to_perc "$val" "$max_brightness")"
    if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
        printf '%s %3d (%s)  ' "brightness level:" "$val" "${perc_val}%"
    fi
    # set brightness for every screen we can find
    for screen_path in $sysfs_path; do
        if [ -n "$dbgOUT" ]; then
            scp_t="${screen_path%/*}"
            scp_t="${scp_t##*/}"
            printf '%s ' "$scp_t"
        fi
        set_scaled "$screen_path" "$val"
    done
    if [ -n "$dbgOUT" ] || [ -n "$VERB" ]; then
        printf '\n'
    fi
}

# return type: void
# usage: inc_brightness num
# description:
#    will increase the brightness by the passed number
#    brightness values are from 0 to 255
inc_brightness() {
    delta="$1"
    cur_br=$(get_brightness)
    new_br=$(( cur_br + delta ))
    if [ "$max_brightness" -lt "$new_br" ]; then
        new_br="$max_brightness"
    fi
    set_brightness "$new_br"
}

# return type: void
# usage: dec_brightness num
# description:
#    will decrease the brightness by the passed number
#    brightness values are from 0 to 255
dec_brightness() {
    delta="$1"
    cur_br=$(get_brightness)
    new_br=$(( cur_br - delta ))
    if [ "$min_brightness" -gt "$new_br" ]; then
        new_br="$min_brightness"
    fi
    set_brightness "$new_br"
}
