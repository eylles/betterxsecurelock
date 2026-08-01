#!/bin/sh

# SPDX-License-Identifier: Apache-2.0

if [ -z "$HAS_BOOL" ]; then
    . ./libbool.sh
fi

HAS_UTILS="$_true"

# Return type: string
# Usage: rm_char_first_occur <str> <char>
# Description:
#   Removes the first (leftmost) occurrence of <char> from string <str>
rm_char_first_occur() {
    str="$1"
    delim="$2"
    right="${str#*"$delim"}"
    left="${str%"$delim$right"*}"
    out="${left}${right}"
    printf '%s' "$out"
}

# Return type: int bool
# Usage: has_char <str> <char>
has_char() {
    str="$1"
    char="$2"
    retval="$_false"
    case "$str" in
        *"$char"*) retval="$_true" ;;
    esac
    return "$retval"
}

# Return type: string
# Usage: rm_all_char <str> <char>
# Description:
#   Loops until all occurrences of <char> are removed from string <str>
rm_all_char() {
    str="$1"
    delim="$2"
    while has_char "$str" "$delim"; do
        str="$(rm_char_first_occur "$str" "$delim")"
    done
    printf '%s' "$str"
}

# usage: is_num "value"
# description: check if passed value is a number
# return type: retval int boolean
is_num() {
    if [ -n "$1" ]; then
        printf %f "$1" >/dev/null 2>&1
    else
        return "$_false"
    fi
}


# usage: is_int "value"
# description: check if passed value is an integer
# return type: retval int boolean
is_int() {
    if [ -n "$1" ]; then
        printf %d "$1" >/dev/null 2>&1
    else
        return "$_false"
    fi
}

# usage: is_perc "value"
# description: check if passed value is an integer percentage
# return type: retval int boolean
is_perc() {
    val="$1"
    case "$val" in
        *'%'*)
            trimmed_val="$(rm_all_char "$val" '%')"
            is_int "$trimmed_val"
            ;;
        *)
            return "$_false"
            ;;
    esac
}

# usage: is_int_or_perc "value"
# description: check if passed value is an integer or an integer percentage
# return type: retval int boolean
is_int_or_perc() {
    if ! is_int "$1" && ! is_perc "$1"; then
        return "$_false"
    fi
}

# usage: min_cap value minimum_value
# description: prevents the value from
#     being lower than the minimum_value.
# return type: stdout int
min_cap () {
    if [ "$1" -lt "$2" ]; then
        result="$2"
    else
        result="$1"
    fi
    printf '%d\n' "$result"
}

# usage: max_cap value maximum_value
# description: prevents the value from
#     being higher than the maximum_value.
# return type: stdout int
max_cap () {
    if [ "$1" -gt "$2" ]; then
        result="$2"
    else
        result="$1"
    fi
    printf '%d\n' "$result"
}

# Usage: getval "KEY" file
# description: read a KEY=VALUE file and retrieve the VALUE of the passed KEY
# return type: stdout string
getval(){
    # Setting 'IFS' tells 'read' where to split the string.
    while IFS='=' read -r key val; do
        # Skip over lines containing comments.
        # (Lines starting with '#').
        [ "${key##\#*}" ] || continue

        # '$key' stores the key.
        # '$val' stores the value.
        if [ "$key" = "$1" ]; then
            printf '%s\n' "$val"
        fi
    done < "$2"
}

# usage: split_str "string" "pattern"
# description: splits string on pattern, outputs a newline separated list.
# taken from:
#   https://github.com/dylanaraps/pure-sh-bible#split-a-string-on-a-delimiter
# return type: stdout string
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

# Return type: int bool
#       Usage: is_program <program>
#     program: name of the program to check if is available
is_program() {
    command -v "$1" >/dev/null || return "$_false"
}

which_awk="$(command -v mawk)"
case "$which_awk" in
    *mawk)
        # thin awk wrapper that will prefer mawk over the system's default awk
        # implementation
        u_awk () { mawk "$@"; }
        ;;
    *)
        # thin awk wrapper that will prefer mawk over the system's default awk
        # implementation
        u_awk () { awk "$@"; }
        ;;
esac

dbgOUT=""
NO_CONTINUE=""
