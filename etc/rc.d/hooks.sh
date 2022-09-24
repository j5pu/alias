# shellcheck shell=sh

[ "${SHELL_HOOK-}" ] || return 0

! has direnv || { eval "$(direnv hook "${SHELL_HOOK}")"; alias allow='direnv allow'; alias reload='direnv reload'; }

for _hook_sh in starship zoxide; do
  ! has "${_hook_sh}" || eval "$("${_hook_sh}" init "${SHELL_HOOK}")"
done

unset _hook_sh
