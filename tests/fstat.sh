#!/bin/bash

touch -amt 197101010101.01 "$0"
touch -d 2002-02-02T02:02:02 "$0"
touch -A -010100 "$0"

while read -r option; do
  linux="$(UNAME=Linux TEST=g /Users/j5pu/rc/bin/fstat "${option}" "$0")"
  darwin="$(UNAME=Darwin /Users/j5pu/rc/bin/fstat "${option}"  "$0")"
  [ "${darwin}" = "${linux}" ] || echo "${option}: ${darwin}, ${linux}"
done < <(fstat --list)
