#!/bin/sh

# SPDX-License-Identifier: Apache-2.0

. ./libbacklight.sh

# type: string
# description: script base name through the idiom "${0##*/}"
myname="${0##*/}"

inc_brightness() {
    delta="$1"
    cur_br=$(get_brightness)
    new_br=$(( cur_br + delta ))
    if [ "$max_brightness" -lt "$new_br" ]; then
        new_br="$max_brightness"
    fi
    set_brightness "$new_br"
}

dec_brightness() {
    delta="$1"
    cur_br=$(get_brightness)
    new_br=$(( cur_br - delta ))
    if [ "$min_brightness" -gt "$new_br" ]; then
        new_br="$min_brightness"
    fi
    set_brightness "$new_br"
}

main() {
    value=""
    operation=""
    while [ $# -gt 0 ]; do
        case $1 in
            "s")
                if ! is_int "$2"; then
                    printf '%s: %s\n' "$myname" \
                        "value '${2}' is not an int"
                    exit 1
                else
                    value=$2
                fi
                case "$3" in
                    "+")
                        operation="inc"
                        shift ;;
                    "-")
                        operation="dec"
                        shift ;;
                    "")
                        operation="set"
                        ;;
                    *)
                        operation="set"
                        printf '%s: %s\n' "$myname" \
                            "unknown operation '${3}'"
                        ;;
                esac
                shift
            ;;
            "g")
                operation="get"
                ;;
            "debug"|"-debug"|"--debug")
                dbgOUT=1
                ;;
            *)
                printf '%s: %s\n' "$myname" \
                    "unknown argument '${1}'"
                exit 1
            ;;
        esac
        shift
    done
    case "$operation" in
        "set")
            set_brightness "$value"
            exit 0
            ;;
        "inc")
            inc_brightness "$value"
            exit 0
            ;;
        "dec")
            dec_brightness "$value"
            exit 0
            ;;
        "get")
            get_brightness
            ;;
    esac
}

main "$@"
