# shellcheck shell=zsh

#
# Utils Library for ZSH

# Functions:
#   sh(as bash) and bash exported functions are seen when exported in subshells and new shells
#   zsh: functions exported are available in subshells (no need to export them) but not in a new shell
# Arrays:
#   sh(as bash)/bash/zsh: exported arrays are not available in a new shell, but they are in a subshell

echo "ZSH_ARGZERO: ${ZSH_ARGZERO-}"
echo "ZSH_EVAL_CONTEXT: ${ZSH_EVAL_CONTEXT-}"

# RC: utils.zsh has been sourced already
#
: "${_RC_UTILS_ZSH_SOURCED=0}"
[ "${_RC_UTILS_ZSH_SOURCED}" -eq 0 ] || return 0
_RC_UTILS_ZSH_SOURCED=1

# true (bool) if sourced or running in ZSH false if not
#
ZSH=false
if [ "${ZSH_ARGZERO-}" ] || [ "${ZSH_EVAL_CONTEXT-}" ]; then
  ZSH=true
  # <html><h2>Running Shell</h2>
  # <p><strong><code>$SH</code></strong> posix-<ash|busybox|dash|ksh|sh>, zsh, sh for bash sh, bash or bash4.</p>
  # </html>
  SH="zsh"
  # Hook for shell-specific initialization (zsh or bash).
  #
  SH_HOOK="${SH}"
  # RC bin directory
#
  : "${RC_BIN=$(dirname "$0"; pwd -P)}"; export RC_BIN
  # RC Top Repository
  #
  : "${RC=${RC_BIN%/*}}"; export RC
fi


####################################### Source: BASH4, BASH. KSH and SH
#
. "${0%.*}.bash4"


####################################### ZSH
#
$ZSH || return 0
! has zsh_bashcompinit || return 0

#######################################
# bash completions in zsh
# Arguments:
#  None
#######################################
zsh_bashcompinit() { ! has autoload || has bashcompinit || { autoload -U +X bashcompinit && bashcompinit; }; }

echo "BASH4: $BASH4, RC: ${RC}, SH: $SH, SH_HOOK: ${SH_HOOK}, ZSH: $ZSH"
