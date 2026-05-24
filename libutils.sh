#!/bin/sh


if [ -z "$HAS_BOOL" ]; then
    . ./libbool.sh
fi

HAS_UTILS="$_true"

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
