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
    command -v "$1" >/dev/null 2>&1
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
