#!/bin/sh

#
# Installs awk and to /usr/bin to have /usr/bin/awk and not to use shebang with env

set -eu

nix-channel --update --quiet 2>/dev/null
nix-env -iA nixpkgs.gawk --quiet

src="${HOME}/.nix-profile/bin/awk"
if ! test -e /usr/bin/awk; then
    ln -s "${src}" /usr/bin/awk
fi
command -v awk >/dev/null || { >&2 echo "awk not found"; exit 1; }
