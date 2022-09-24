# shellcheck shell=shell

#
# Functions used by env.

has() { command -v "$1" >/dev/null; }

rc_source_dir() {
  test -n "$(find "$1" \( -type f -or -type l \) -not -name ".*")" || return 0
  for _rc_source in "$1"/*; do
    case "${_rc_source##*/}" in
      .DS_Store | .gitkeep | .keep | .localized) continue ;;
    esac
    . "${_rc_source}"
  done

  unset _rc_source
}

resh() {
  unset -f resh
  unset BASH_COMPLETION_VERSINFO HOMEBREW_PROFILE_D_SOURCED RC_PROFILE_D_SOURCED RC_RC_D_SOURCED _RC_SHELL_SH_SOURCED
  . "${ENV?}"
  rc_source_dir "${RC_COMPLETIONS}"
}
