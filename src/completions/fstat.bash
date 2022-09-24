# shellcheck shell=bash

#######################################
# fstat completion
# Arguments:
#   1
#   3
# Returns:
#   0 ...
#   1 ...
#######################################
_fstat() {
  _init_completion -n :=/ || return

  [[ ! "${words[1]}" =~ -h|--help|--list ]] || return 0

  [ "$cword" -ne 1 ] || mapfile -t \
      COMPREPLY < <(compgen -o nospace -W "-h --help $(fstat --list)" -- "${cur}")
  _filedir
  _filedir -d
}

complete -F _fstat fstat
