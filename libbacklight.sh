#!/bin/sh

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
# usage: scale_val value input_range target_range
scale_val () {
    value="$1"
    range_input="$2"
    range_target="$3"
    scale_factor=$(( range_target / range_input ))
    scaled_value=$(( value * scale_factor ))
    printf '%s' $scaled_value
}

# return type: int
# usage: unscale_val value input_range target_range
unscale_val () {
    value="$1"
    range_input="$2"
    range_output="$3"
    scale_factor=$(( range_input / range_output ))
    scaled_value=$(( value / scale_factor ))
    printf '%s' $scaled_value
}

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
    max_val=$(head "$brighntess_max_file")
    # remove float part if any
    max_val="${max_val%.*}"
    value="$2"
    scaled_value=$(scale_val "$value" "$max_brightness" "$max_val")
    printf '%s' "$scaled_value" > "$brightness_file"
    [ -n "$dbgOUT" ] && printf '[%s: %6d]   ' "actual value" "$scaled_value"
}

# return type: void
# usage: set_brightness num
# description:
#    will set the brightness to the passed number
#    brightness values are from 0 to 255
set_brightness() {
    [ -n "$dbgOUT" ] && printf '%s %3d  ' "brightness level:" "$1"
    # set brightness for every screen we can find
    for screen_path in $sysfs_path; do
        if [ -n "$dbgOUT" ]; then
            scp_t="${screen_path%/*}"
            scp_t="${scp_t##*/}"
            printf '%s ' "$scp_t"
        fi
        set_scaled "$screen_path" "$1"
    done
    [ -n "$dbgOUT" ] && printf '\n'
}
