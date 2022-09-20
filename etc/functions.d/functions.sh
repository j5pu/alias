#!/bin/sh

has() { command -v "$1" >/dev/null; }

reenv() {
  PATH="$(echo "${PATH}" | sed "s|${ENV_TOP}/bin:||")"
  unset ENV_SOURCED
  unset -f reenv
  . "${_ENV_FILE}"
}
