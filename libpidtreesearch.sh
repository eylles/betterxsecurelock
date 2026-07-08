#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later

if [ -z "$HAS_BOOL" ]; then
    . ./libbool.sh
fi

if [ -z "$HAS_UTILS" ]; then
    . ./libutils.sh
fi

# usage: pid_tree_search PID NAME
#          PID: the parent pid among whose ps tree we will search
#         NAME: the name of the program whose pid we want
#       return: pid of NAME program
#  return type: stdout integer
# return error: retval _false
pid_tree_search () {
    search_pid="$1"
    search_name="$2"
    word_length="${#search_name}"
    rval=$(
        pstree -Aps "${search_pid}" \
        | u_awk \
            -v name="$search_name" \
            -v wlen="$word_length" \
            '\
                BEGIN { search=name"\\([[:digit:]]*\\)" } \
                match( $0, search )\
                {\
                    print substr($0,RSTART+wlen+1,RLENGTH-wlen-2) \
                }\
            '
        )
    if is_int "$rval"; then
        printf '%s\n' "$rval"
    else
        return "$_false"
    fi
}
