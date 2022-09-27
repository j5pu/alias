#!/usr/bin/env bash
# shellcheck disable=SC2029

#
# Usage:
#   system.awk.sh pro [runs system.awk in pro]
#   system.awk.sh [runs system.awk in all hosts and images]
#   system.awk.sh pro desc [runs "system.awk desc" in pro]
#   system.awk.sh desc [runs "system.awk desc" in all hosts and images]
set -eu

. "$(dirname "$0")"/.sh

host=()
if is_host_image_name "${1-}"; then
  host+=("$1")
  shift
fi

rc.run "${host[@]}" system.awk "$@"

