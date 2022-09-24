# shellcheck shell=bash
# FIXME: copied from Archive/shrc/src/shrc

cd "$(dirname "${BASH_SOURCE[0]}")"/../.. || return
source ./libexec/bats.bash
