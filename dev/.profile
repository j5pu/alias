# shellcheck shell=shell
echo .profile
set -x
( : "${RC?}" ) || return 1

PATH="${RC?}/bin:${RC}/dev:${RC}/generated/bin:${RC}/generated/color:${RC}/tests:\
${RC}/tests/bin:${RC}/tests/run:${RC}/custom/bin:$(/usr/libexec/path_helper -s)"
