#!/bin/sh

# SPDX-License-Identifier: Apache-2.0

. ./libbacklight.sh

# type: string
# description: script base name through the idiom "${0##*/}"
myname="${0##*/}"

scale=255
dec_cutoff=50
# return type: int
# usage: perc_to_int "value"
# description:
#    will convert a passed integer percentage to the corresponding in value in
#    range.
perc_to_int() {
    val="$1"
    val="$(rm_all_char "$val" '%')"
    val=$(( val * scale ))
    valint="${val%??}"
    valdec="${val#"${valint}"}"
    if [ "$valdec" -gt "$dec_cutoff" ]; then
        valint=$(( valint + 1 ))
    fi
    printf '%d\n' "$valint"
}

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
    printf '  %s\n' "debug, -debug, -d"
    printf '\t%s\n' "Show debug output."
    printf '  %s\n' "help, -help, -h"
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
                        value=$(perc_to_int "$value")
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
            "debug"|"-debug"|"--debug"|"-d")
                dbgOUT=1
                ;;
            "help"|"-help"|"--help"|"-h")
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
            get_brightness
            ;;
    esac
}

main "$@"
