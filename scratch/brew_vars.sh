#!/bin/bash
# shellcheck disable=SC2016


export HOMEBREW_BREW_FILE=/usr/local/Homebrew/bin/brew
#export HOMEBREW_BREW_DEFAULT_GIT_REMOTE=https://github.com/Homebrew/brew
export HOMEBREW_CORE_DEFAULT_GIT_REMOTE="https://github.com/Homebrew/homebrew-core"
export HOMEBREW_LIBRARY=/usr/local/Homebrew/Library
export HOMEBREW_PREFIX=/usr/local
#env -i HOMEBREW_HOLA=hola ADIOS=adios /bin/bash -c ". /tmp/var; awk -F= '/^HOMEBREW_/ { print \"export " \$1"=\""\$2\" }""
#f() { awk -F= -v i=\" "/^HOMEBREW_/ { print \"export\", \$1 \"=\" i \$2 i }" < <(set); }
#export -f f
#env -i  /bin/bash -c '. /tmp/var; f'
env -i  HOMEBREW_HOLA=hola ADIOS=adios /bin/bash -c '. /tmp/var; /Users/j5pu/rc/scratch/brew.awk'

/Users/j5pu/rc/scratch/brew.awk /Users/j5pu/bbin/Library/Homebrew/brew.sh
source <(awk '/^if \[\[ -n "\${HOMEBREW_BASH_COMMAND}" \]\]/{exit} 1'  )
#. /Users/j5pu/bbin/Library/Homebrew/brew.sh
#set
# [[ -n "${HOMEBREW_BASH_COMMAND}" ]]
#awk '/^if \[\[ -n "\${/{exit} 1' /Users/j5pu/bbin/Library/Homebrew/brew.sh
awk '/^if \[\[ -n "\${HOMEBREW_BASH_COMMAND}" \]\]/{exit} 1' /Users/j5pu/bbin/Library/Homebrew/brew.sh
FILTERED_ENV=("HOMEBREW_HOLA=hola" "USER=joder")
HOMEBREW_LIBRARY="/usr/local/Homebrew/Library"
/usr/bin/env -i "${FILTERED_ENV[@]}" /bin/bash "
source <(/Users/j5pu/rc/scratch/brew.awk \"${HOMEBREW_LIBRARY}/Homebrew/brew.sh\"); /Users/j5pu/rc/scratch/brew.awk env
"
