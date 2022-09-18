#!/bin/sh

#
# sources files in alias repository

set -eu

: "${UNAME=$(uname -s)}"; export UNAME
: "${HOSTNAME=$(hostname)}"; export HOSTNAME

ALIAS="$(cd "$(dirname "$0")/.." && pwd -P)"; export ALIAS
ID_LIKE="$(id-like)"; export ID_LIKE
! echo "${PATH}" | grep -q "${ALIAS}/bin:" || PATH="${ALIAS}/bin:${PATH}"
export SUDO=true; test -x /usr/bin/sudo || SUDO=false


echo_var() { echo "export ${1}=\"${2}\""; }

echo_dir() {
  test -d "$1" || return 0

  for file in "$1"/*.*; do
    { [ "${file##*/}" != sudo.sh ] || $SUDO; } || continue
    echo "  . \"${file}\""
  done
}

echo_source_dir() {
  for arg in aliases.d generated/common \
    "generated/${HOSTNAME}" "generated/${UNAME}" \
    $([ ! "${ID_LIKE-}" ] || echo "generated/${ID_LIKE}") \
    $(! has complete || echo bash_completion.d) vars.d; do
    echo_dir "${ALIAS}/${arg}"
  done
  echo_dir ~/.aliases.d
}

has() { command -v "$1" >/dev/null; }

cat <<EOF
$(echo_var PATH "${PATH}")

$(echo_var ALIAS "${ALIAS}")
$(echo_var HOSTNAME "${HOSTNAME}")
$(echo_var ID_LIKE "${ID_LIKE}")
$(echo_var UNAME "${UNAME}")

if [ "\${PS1-}" ]; then
  unalias cp egrep fgrep grep l l. la ll lld ls mv rm xzegrep xzfgrep xzgrep zegrep zfgrep zgrep 2>/dev/null
$(echo_source_dir)
fi
EOF
