# shellcheck shell=shell

#
# Functions used by env.

rc_source_dir() {
  for _rc_source in "$1"/*; do
    case "${_rc_source##*/}" in
      .DS_Store | .gitkeep | .keep | .localized) continue ;;
    esac
    . "${_rc_source}"
  done

  unset _rc_source
}

has() { command -v "$1" >/dev/null; }

rebash() {
  unset -f rebash
  PATH="$(echo "${PATH}" | sed "s|${RC_TOP}/bin:||")"
  unset BASH_COMPLETION_VERSINFO HOMEBREW_PROFILE_D_SOURCED RC_SOURCED
  . "${ENV?}"
}
