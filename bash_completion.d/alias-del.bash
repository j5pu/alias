# shellcheck shell=bash

#######################################
# alias-del completion
# Arguments:
#   1
#   3
# Returns:
#   0 ...
#   1 ...
#######################################
_alias_del() {
    [ "$1" = "$3" ] || return 0
    mapfile -t COMPREPLY < <(compgen -A alias -- "$2")
}

complete -F _alias_del alias-del
