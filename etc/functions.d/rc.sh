# shellcheck shell=shell

#
# Functions used by env.

env_source_dir() {
  for _env_source in "$1"/*; do
    case "${_env_source##*/}" in
      .DS_Store | .gitkeep | .localized) continue ;;
    esac
    . "${_env_source}"
  done

  unset _env_source
}

has() { command -v "$1" >/dev/null; }

reenv() {
  unset -f reenv
  PATH="$(echo "${PATH}" | sed "s|${ENV_TOP}/bin:||")"
  unset BASH_COMPLETION_VERSINFO ENV_SOURCED
  . "${ENV?}"
}
