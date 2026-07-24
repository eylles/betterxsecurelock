#!/bin/sh

# SPDX-License-Identifier: Apache-2.0

if [ -z "$HAS_UTILS" ]; then
    . ./libutils.sh
fi

# return type: comma delimited list string
# usage: hexToRgb "#abc123"
# description:
#   Converts hex colors into rgb list joined with comma
#   #ffffff -> 255,255,255
hexToRgb() {
    # Remove '#' character from hex color #fff -> fff
    plain=${1#*#}
    # printf '%s\n' "$plain"
    seg1="${plain%%[A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9]}"
    # printf '%s\n' "$seg1"
    seg2="${plain}"
    seg2="${seg2%%[A-Fa-f0-9][A-Fa-f0-9]}"
    seg2="${seg2##[A-Fa-f0-9][A-Fa-f0-9]}"
    # printf '%s\n' "$seg2"
    seg3="${plain##[A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9]}"
    # printf '%s\n' "$seg3"
    printf '%d,%d,%d\n' 0x"${seg1}" 0x"${seg2}" 0x"${seg3}"
}

# return type: hexrgb string
# usage: lighten "hexrgb color" "percentage int"
lighten () {
    color=$1
    amount=$2
    rgbcol=$(hexToRgb "$color")
    colout=""
    i=0
    for colbit in $(split_list "$rgbcol" ","); do
        modbit=$(( colbit + ( 255 * amount / 100 ) ))
        modbit=$(max_cap "$modbit" 255)
        # printf '%s: %d\n' "$i" "$modbit"
        # printf '%s: %02x\n' "$i" "$modbit"
        colout="${colout}"$(printf '%02x' "$modbit")
        i=$(( i + 1))
    done
    printf '#%s\n' "$colout"
}

# return type: hexrgb string
# usage: darken "hexrgb color" "percentage int"
darken () {
    color=$1
    amount=$2
    rgbcol=$(hexToRgb "$color")
    colout=""
    i=0
    for colbit in $(split_list "$rgbcol" ","); do
        modbit=$(( colbit - ( 255 * amount / 100 ) ))
        modbit=$(min_cap "$modbit" 0)
        # printf '%s: %d\n'   "$i" "$modbit"
        # printf '%s: %02x\n' "$i" "$modbit"
        colout="${colout}"$(printf '%02x' "$modbit")
        i=$(( i + 1))
    done
    printf '#%s\n' "$colout"
}
