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
_env() {
  _init_completion -n :=/ || return
  local aliases=true c=1 action actions commands=true dirs=true helps=true i w=()


  >&2 echo "$cword"
  return
  act=(add clean del hook sync)
  h=(-h --help help)

  test "${cword}" -lt 3 || return
  while [ "$c" -lt "${cword}" ]; do
    i="${words[c]}"
    case "${i}" in
      -h|--help|help) return ;;
      add|clean|del|sync|hook) actions=true; helps=(); action="${i}" ;;
      *)
        case "${action-}" in
          add) actions=false; w+=("${i}") ;;
          clean) actions=false;  w+=("${i}") ;;
          del) actions=false; w+=("${i}") ;;
          hook) actions=false; w+=("${i}") ;;
          sync) actions=false; w+=("${i}") ;;
        esac
        ! test -f "${i}" || change=()
        dirs=false; files=false; helps=() ;;
    esac
    ((c++))
  done

    [ "$1" = "$3" ] || return 0
    mapfile -t COMPREPLY < <(compgen -A alias -- "$2")
}

complete -F _env env
