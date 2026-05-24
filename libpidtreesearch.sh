#!/bin/sh

# usage: pid_tree_search PID NAME
#      PID: the parent pid among whose ps tree we will search
#     NAME: the name of the program whose pid we want
# return type: integer
# return error: standard error return value 1
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
        return 1
    fi
}
