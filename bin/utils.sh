# shellcheck shell=sh

#
# Change Directory Posix Utils Library

# RC: utils.sh has been sourced already
#
: "${_RC_UTILS_SH_SOURCED=0}"
[ "${_RC_UTILS_SH_SOURCED}" -eq 0 ] || return 0 2>/dev/null || exit 0
_RC_UTILS_SH_SOURCED=1

case "${0##*/}" in
  ash|busybox|dash|ksh|sh)
    if [ "${SH-}" ]; then
       # <html><h2>Running Shell</h2>
  # <p><strong><code>$SH</code></strong> posix-<ash|busybox|dash|ksh|sh>, zsh, sh for bash sh, bash or bash4.</p>
  # </html>
      SH="$(basename "$("$(command -v realpath || command -v readlink)" "$(command -v "$0")")")"
       # Hook for shell-specific initialization (zsh or bash).
  #
      SH_HOOK=""
    fi
    ;;
  *)
    :
    ;;
esac

export PATH="${RC_TOP}/bin:${RC_TOP}/generated/bin:${RC_TOP}/generated/color:${PATH}"


####################################### SH
#

# Git Repository Top Path if exist for cd_top() and cd_top_exit()
#
export GIT_TOP=""

#######################################
# change to git repository top path
# Arguments:
#  None
# Returns:
#   1 if not git repository
#######################################
cd_top() {
  if GIT_TOP="$(git rev-parse --show-toplevel 2>&1)"; then
    cd "${GIT_TOP}" || return 1
    return
  else
    >&2 echo "cd_top: ${PWD}: ${GIT_TOP}"
    GIT_TOP=""
    return 1
  fi
}

#######################################
# change to git repository top path and exit if not git repository
# Arguments:
#  None
# Returns:
#   1 if not git repository (exit)
#######################################
cd_top_exit() { cd_top || exit; }

#######################################
# command or commands exists
# Arguments:
#  command [command]    command or commands
# Returns:
#  1 if any of the command does not exist
#######################################
hasall() {
  _help="$(cat <<EOF
usage: hasall [command...]
       . utils.sh; hasall [function...]
       hasall [-h|--help|help]

command, builtin, function, alias exists

Arguments:
  [command...]          command, builtin and function or alias when sourced

Commands:
   -h, --help, help     display this help and exit.

Returns:
   1 if at least one of commands does not exist
EOF
)"
  if test $# -eq 0; then
    echo "${_help}"; exit 1
  else
    case "$1" in
      -h|--help|help) echo "${_help}"; exit 0 ;;
    esac
  fi

  if [ $# -eq 1 ]; then
    type "$1" >/dev/null 2>&1
  else
    tmp="$(mktemp)"
    type "$@" >/dev/null 2>"${tmp}"
    ! test -s "${tmp}" || grep -qv "not found" "${tmp}"
  fi
}

#######################################
# has alias, command or function
# Arguments:
#   1   alias, command or function name
# Returns:
#   1   parameter null or not set
#######################################
has() { type "$@" 1>/dev/null 2>&1; }

#######################################
# description
# Arguments:
#  None
# Returns:
#   $__history_prompt_rc ...
#######################################
history_prompt() {
  # shellcheck disable=SC3043
  local __history_prompt_rc=$?
  history -a; history -c; history -r; hash -r
  return $__history_prompt_rc
}

#######################################
# add/prepend directory to variable (PATH, MANPATH, etc.) removing previous entries
# Globals:
#   PATH
# Arguments:
#   1   directory to add
#   2   variable name (default: PATH)
# Returns:
#   1   parameter null or not set
#######################################
path_add() {
  path_pop "${1:-${PWD}}" "${2-}"
  _path_add_value="$(eval echo "\$${2:-PATH}")"
  _path_add_value="${_path_add_value:+:${_path_add_value}}"
  [ "${2:-PATH}" != "MANPATH" ] || [ "${_path_add_value-}" ] || _path_add_value=":"
  _path_add_real="$("${BBIN_PREFIX}/bin/pwd_p" "${1:-${PWD}}" )"
  eval "export ${2:-PATH}='${_path_add_real}${_path_add_value}'"
  unset _path_add_value _path_add_real
}

#######################################
# add/prepend dir/sbin:dir/bin:dir/libexec, dir/share/info and dir/share/man removing previous entries
# Globals:
#   PATH
# Arguments:
#   1   directory
# Returns:
#   1   parameter null or not set
#######################################
path_add_all() {
  for _path_add_all in libexec bin sbin; do
    path_add "${1:-${PWD}}/${_path_add_all}"
  done
  path_add "${1:-${PWD}}/share/man" MANPATH
  path_add "${1:-${PWD}}/share/info" INFOPATH
  unset _path_add_all
}

#######################################
# add/prepend directory to variable (PATH, MANPATH, etc.) removing previous entries if directory exists
# Arguments:
#   1   directory to add
#   2   variable name (default: PATH)
# Returns:
#   1   parameter null or not set
#######################################
path_add_exist() { path_pop "${1:-${PWD}}" "${2-}"; [ ! -d "${1:-${PWD}}" ] || path_add "${1:-${PWD}}" "${2-}"; }

#######################################
# add/prepend dir/sbin:dir/bin:dir/libexec, dir/share/info and dir/share/man removing previous entries if exist
# Globals:
#   PATH
# Arguments:
#   1   directory
# Returns:
#   1   parameter null or not set
#######################################
path_add_exist_all() {
  for _path_add_exist_all in libexec bin sbin; do
    path_add_exist "${1:-${PWD}}/${_path_add_exist_all}"
  done
  path_add_exist "${1:-${PWD}}/share/man" MANPATH
  path_add_exist "${1:-${PWD}}/share/info" INFOPATH
  unset _path_add_exist_all
}

#######################################
# append directory to variable (PATH, MANPATH, etc.) removing previous entry
# Arguments:
#   1   directory to append
#   2   variable name (default: PATH)
# Returns:
#   1   parameter null or not set
#######################################
path_append() {
  path_pop "${1:-${PWD}}" "${2-}"
  _path_append_value="$(eval echo "\$${2:-PATH}")"
  if [ "${2:-PATH}" = "MANPATH" ]; then
    _path_append_last=":"
  elif [ "${_path_append_value-}" ]; then
    _path_append_first=":"
  fi
  _path_append_real="$("${BBIN_PREFIX}/bin/pwd_p" "${1:-${PWD}}")"
  eval "export ${2:-PATH}='${_path_append_value}${_path_append_first-}${_path_append_real}${_path_append_last-}'"
  unset _path_append_first _path_append_last _path_append_real _path_append_value
}

#######################################
# append directory to variable (PATH, MANPATH, etc.) removing previous entry
# Arguments:
#   1   directory to append
#   2   variable name (default: PATH)
# Returns:
#   1   parameter null or not set
#######################################
path_append_exist() { path_pop "${1:-${PWD}}" "${2-}"; [ ! -d "${1:-${PWD}}" ] || path_append "${1:-${PWD}}" "${2-}"; }

#######################################
# remove duplicates from variable (PATH, MANPATH, etc.)
# Arguments:
#   1   variable name (default: PATH)
#######################################
path_dedup() {
  [ "${1:-PATH}" = "MANPATH" ] || _path_dedup_strip=":"
  _path_dedup_value="$(eval echo "\$${1:-PATH}" |  tr ':' '\n' | awk '!NF || !seen[$0]++' | \
    sed -n "H;\${x;s|\n|:|g;s|^:||;s|${_path_dedup_strip-}$||;p;}")"
  [ "${_path_dedup_value}" != ":" ] || _path_dedup_value=""
  eval "export ${1:-PATH}='${_path_dedup_value}'"
  unset _path_dedup_strip _path_dedup_value
}

#######################################
# is directory in variable (PATH, MANPATH, etc)
# Globals:
#   PATH
# Arguments:
#   1   directory to check
#   2   variable name (default: PATH)
# Returns:
#   0 if directory in $PATH
#   1 if directory not in $PATH, parameter null or parameter not set
#######################################
path_in() {
  [ "${2:-PATH}" = "MANPATH" ] || _path_in_add=":"
  _path_in_real="$("${BBIN_PREFIX}/bin/pwd_p" "${1:-${PWD}}")"
  case ":$(eval echo "\$${2:-PATH}")${_path_in_add-}" in
    *:"${_path_in_real}":*) unset _path_in_add _path_in_real; return 0 ;;
    *) unset _path_in_add _path_in_real; return 1 ;;
  esac
}

#######################################
# removes directory from variable (PATH, MANPATH, etc.)
# Globals:
#   PATH
# Arguments:
#   1   directory to remove
#   2   variable name (default: PATH)
# Returns:
#   1   parameter null or not set
#######################################
path_pop() {
  [ "${2:-PATH}" = "MANPATH" ] || _path_pop_strip=":"
  _path_pop_real="$("${BBIN_PREFIX}/bin/pwd_p" "${1:-${PWD}}")"
  _path_pop_value="$(eval echo "\$${2:-PATH}" | sed 's/:$//' | tr ':' '\n' | \
    grep -v "^${_path_pop_real}$" | tr '\n' ':' | sed "s|${_path_pop_strip-}$||")"
  [ "${_path_pop_value}" != ":" ] || _path_pop_value=""
  eval "export ${2:-PATH}='${_path_pop_value}'"
  unset _path_pop_real _path_pop_strip _path_pop_value
}
