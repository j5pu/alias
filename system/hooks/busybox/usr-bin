#!/bin/sh

#
# Symlink of /bin to /usr/bin to have /usr/bin/awk and not to use shebang with env

set -eu

test -e /usr/bin || ln -s /bin /usr/bin
command -v awk >/dev/null || { >&2 echo "awk not found"; exit 1; }
