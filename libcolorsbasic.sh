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
        modbit=""
        modbit=$(( colbit + ( 255 * amount / 100 ) ))
        modbit=$(max_cap "$modbit" 255)
        # printf '%s: %d\n' "$i" "$modbit"
        # printf '%s: %02x\n' "$i" "$modbit"
        colout="${colout}"$(printf '%02x' "$modbit")
        modbit=""
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
        modbit=""
        modbit=$(( colbit - ( 255 * amount / 100 ) ))
        modbit=$(min_cap "$modbit" 0)
        # printf '%s: %d\n'   "$i" "$modbit"
        # printf '%s: %02x\n' "$i" "$modbit"
        colout="${colout}"$(printf '%02x' "$modbit")
        modbit=""
        i=$(( i + 1))
    done
    printf '#%s\n' "$colout"
}

# return type: hexrgb string
# usage: foxify "hex color" "factor"
# description:
#   pywalfox algorithm to lighten
#   a color without destroying saturation
foxify() {
    python - "$@" <<'___HEREDOC'
from sys import argv


def hex_to_rgb(color):
    """Convert a hex color to rgb."""
    return tuple(bytes.fromhex(color.strip("#")))


def rgb_to_hex(color):
    """Convert an rgb color to hex."""
    return "#%02x%02x%02x" % (*color,)


def work(color, f):
    pwf = float(f)
    c = hex_to_rgb(color)
    b = [
        max(c[0], 10),
        max(c[1], 10),
        max(c[2], 10)
        ]
    b[0] = (min((max(0, int(b[0] + (b[0] * pwf)))), 255))
    b[1] = (min((max(0, int(b[1] + (b[1] * pwf)))), 255))
    b[2] = (min((max(0, int(b[2] + (b[2] * pwf)))), 255))
    return rgb_to_hex(b)


print(work(argv[1],argv[2]))
___HEREDOC
}
