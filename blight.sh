#!/bin/sh

# SPDX-License-Identifier: Apache-2.0

. ./libbacklight.sh

# type: string
# description: script base name through the idiom "${0##*/}"
myname="${0##*/}"

scale=255
cutoff=50

show_usage() {
    printf '%s\n' \
        "Usage: ${myname} [-debug] < g | s < NUM | PERC > [ + | - ] >"
}

show_help () {
    show_usage
    printf '%s\n'   "ARGUMENTS"
    printf '  %s\n' "get, g"
    printf '\t%s\n' "Get current brightness value."
    printf '  %s\n' "set, s"
    printf '\t%s\n' "Set brightness value, can receive an INT or an INT"
    printf '\t%s\n' "percentage, the '+' and '-' signs can be passed as"
    printf '\t%s\n' "additional arguments to increase/decrease the brightness."
    printf '%s\n'   "OPTIONS"
    printf '  %s\n' "debug, --debug, -debug, -d, d"
    printf '\t%s\n' "Show debug output."
    printf '  %s\n' "help, --help, -help, -h, h"
    printf '\t%s\n' "Show this help message."
}

main() {
    value=""
    operation=""
    while [ $# -gt 0 ]; do
        case $1 in
            "set"|"s")
                if ! is_int_or_perc "$2"; then
                    printf '%s: %s\n' "$myname" \
                        "value '${2}' is not an int or int perc"
                    show_usage
                    exit 1
                else
                    value=$2
                    if is_perc "$value"; then
                        value=$(perc_to_int "$value" "$scale" "$cutoff")
                    fi
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
            "get"|"g")
                operation="get"
                ;;
            "debug"|"-debug"|"--debug"|"-d"|"d")
                dbgOUT=1
                ;;
            "help"|"-help"|"--help"|"-h"|"h")
                show_help
                exit 0
                ;;
            *)
                printf '%s: %s\n' "$myname" \
                    "unknown argument '${1}'"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
    [ -n "$dbgOUT" ] && printf '%9s: %s\n' "Operation" "$operation"
    if [ -n "$dbgOUT" ] && [ -n "$value" ]; then
        printf '%9s: %s\n' "Value" "$value"
    fi
    case "$operation" in
        "set")
            set_brightness "$value"
            ;;
        "inc")
            inc_brightness "$value"
            ;;
        "dec")
            dec_brightness "$value"
            ;;
        "get")
            if [ -z "$dbgOUT" ]; then
                get_brightness
            else
                b_level="$(get_brightness)"
                b_perc="$(int_to_perc "$b_level" "$scale")"
                printf '%d (%s)\n' "$b_level" "${b_perc}%"
            fi
            ;;
    esac
}

main "$@"
