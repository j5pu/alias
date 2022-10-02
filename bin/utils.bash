# shellcheck shell=bash

#
# Utils Library for Bash

# RC: utils.bash has been sourced already
#
: "${_RC_UTILS_BASH_SOURCED=0}"
[ "${_RC_UTILS_BASH_SOURCED}" -eq 0 ] || return 0 2>/dev/null || exit 0
_RC_UTILS_BASH_SOURCED=1

if [ "${BASH-}" ]; then
  # RC bin directory
  #
  : "${RC_BIN=$(dirname "${BASH_SOURCE-}"; pwd -P)}"; export RC_BIN
  # RC Top Repository
  #
  : "${RC=${RC_BIN%/*}}"; export RC
  # <html><h2>Running Shell</h2>
  # <p><strong><code>$SH</code></strong> posix-<ash|busybox|dash|ksh|sh>, zsh, sh for bash sh, bash or bash4.</p>
  # </html>
  : "${SH=${BASH#*/}}"
  # Hook for shell-specific initialization (zsh or bash).
  #
  : "${SH_HOOK=bash}"
  # Shared array to copy array used by cparray(), getkey(), getvalue() and inarray()
#
  declare -p _ARRAY &>/dev/null || declare -axg _ARRAY
fi

####################################### Source: KSH and SH
#
. "${BASH_SOURCE%.*}.sh"


####################################### BASH
#
[ "${BASH-}" ] || $ZSH || return 0 2>/dev/null || exit 0
! has cparray || return 0 2>/dev/null || exit 0

#######################################
# copy array name to _ARRAY
# Globals:
#   _ARRAY
# Arguments:
#   [array]     array name (default: COMP_WORDS)
# Returns:
#   1 if invalid array name or type
#######################################
cparray() {
  local declare
  if declare="$(declare -p "${1:-COMP_WORDS}" 2>&1)"; then
    [[ "${declare}" =~ "declare "-[a,A] ]] || { >&2 echo "cparray: undefined array: ${declare}"; return 1; }
    eval "_ARRAY=$(cut -d '=' -f 2- <<< "${declare}")"
  else
    >&2 echo "cparray: ${declare}"
    return 1
  fi
}

#######################################
# export all functions
# Arguments:
#  None
#######################################
export_funcs_all() {
  [ "${BASH_VERSION-}" ] || return 0
  # shellcheck disable=SC2046,SC3045,SC3044
  export -f $(compgen -A function)
}

#######################################
# export file or files functions
# Arguments:
#  Files or Directories to search for functions
#######################################
export_funcs_path() {
  [ "${BASH_VERSION-}" ] || return 0
  # shellcheck disable=SC2046,SC3045
  export -f $(filefuncs  "$@")
}

#######################################
# export public functions (not starting with _)
# Arguments:
#  None
#######################################
export_funcs_public() {
  [ "${BASH_VERSION-}" ] || return 0
  # shellcheck disable=SC2046,SC3045,SC3044
  export -f $(compgen -A function | grep -v '^_')
}

#######################################
# check if value in array exists and return index
# Globals:
#   _ARRAY
# Arguments:
#   value       the value to search
#   [array]     array name (default: COMP_WORDS)
# Returns:
#   1 if value not in array, or invalid array
#######################################
getkey() {
  local index
  cparray "${2-}" || return 1
  for index in "${!_ARRAY[@]}"; do
    [ "${1?}" != "${_ARRAY[${index}]}" ] || { printf '%s' "${index}"; return; }
  done
  >&2 echo "getkey: Value: '$1', not in Array: '${2:-COMP_WORDS}'"
}

#######################################
# check if key in array and shows value or nothing with no errors (former name: default)
# Globals:
#   _ARRAY
# Arguments:
#   key         the value to search
#   [array]     array name (default: COMP_WORDS)
# Returns:
#   1 if invalid array
#######################################
getvalue() {
  cparray "${2-}" || return 1
  printf '%s' "${_ARRAY["${1?}"]}" 2>/dev/null || true
}

#######################################
# check if value in array exists
# Globals:
#   _ARRAY
# Arguments:
#   value       the value to search
#   [array]     array name (default: COMP_WORDS)
# Returns:
#   1 if value not in array, or invalid array
#######################################
inarray() {
  getkey "$@" >/dev/null
}

echo antes
export_funcs_path "${BASH_SOURCE%.*}.sh" "${BASH_SOURCE[0]}" "${BASH_SOURCE%.*}4" "${BASH_SOURCE%.*}.zsh"
echo despues
echo "BASH4: $BASH4, RC: ${RC}, SH: $SH, SH_HOOK: ${SH_HOOK}, ZSH: $ZSH"
