# shellcheck shell=shell

#
# Functions used by rc.

has() { command -v "$1" >/dev/null; }

rc_source_dir() { for _rc_source_dir in $("$1" "$2"); do . "${_rc_source_dir}"; done; unset _rc_source_dir; }

resh() {
  unset -f resh
  unset BASH_COMPLETION_VERSINFO HOMEBREW_PROFILE_D_SOURCED _RC_PROFILE_D_SOURCED _RC_RC_D_SOURCED _RC_SHELL_SH_SOURCED
  . "${ENV?}"
  rc_source_dir "${RC_COMPLETIONS}"
}
