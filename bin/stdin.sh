#!/bin/sh

#
# Append stdin lines to arguments if not tty, and either stdin has content or is piped
# Demo: /Users/Shared/JetBrains/scratch/scratches/Shell/shell/stdin show
echo $PATH
set -eu

if { test -p /dev/stdin || test -s /dev/stdin; } && ! test -t 0; then
  while read -r __stdin; do
    set -- "$@" "${__stdin}"
  done
fi

unset __stdin
