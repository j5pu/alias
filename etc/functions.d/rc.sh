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

resh() {
  unset -f resh
  unset BASH_COMPLETION_VERSINFO HOMEBREW_PROFILE_D_SOURCED RC_PROFILE_D_SOURCED RC_RC_D_SOURCED
  . "${ENV?}"
}
#commands() {
#  brew_bin="$(brew --prefix)/bin"
#  cd "$(brew --prefix bash-completion@2)/share/bash-completion/completions"
#  complete -p $(find "${brew_bin}" \( -type f -or -type l \) -name 'g*' | sed "s|${brew_bin}/g||g" | sort) 2>/dev/null || true
#}
#export -f commands
#bash -li -c commands
#

brew_bin="$(brew --prefix)/bin"
commands="$(find "${brew_bin}" \( -type f -or -type l \) -name 'g*' | sed "s|${brew_bin}/g||g")"
#
#cd "$(brew --prefix bash-completion@2)/share/bash-completion/completions"
#bash -li -c "complete -p ${commands}"

readarray -t commands < <(find "${brew_bin}" \( -type f -or -type l \) -name 'g*' | sed "s|${brew_bin}/g||g" | grep -v "\[")

cd "$(brew --prefix bash-completion@2)/share/bash-completion/completions"
(
  PS1='> '
  . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
  for i in "${commands[@]}"; do
  complete -p "${i}" 2>/dev/null | sed "s|${i}$|g${i}|g"
done

)
#printf "%s\n" "${commands[@]}"
#for i in "${commands[@]}"; do
#  complete -p "${i}" 2>/dev/null | sed "s|${i}$|g${i}|g"
#done
