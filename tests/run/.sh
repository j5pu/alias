#!/usr/bin/env bash

set -eu

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

. ./.sh
. base-images.bash

#######################################
# description
# Globals:
#   BBIN_IMAGES
#   IMAGE
#   key
# Arguments:
#  None
#######################################
is_host_image_name () {
  for key in "${!BBIN_IMAGES[@]}" book imac msi pro; do
    [ "$1" != "${key}" ] || return 0
  done
  return 1
}
