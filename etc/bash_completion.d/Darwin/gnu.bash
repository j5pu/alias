# shellcheck shell=bash

for __gnu_completion in cat cp csplit; do
  complete -F _longopt "g${__gnu_completion}"
done

for __gnu_completion in chgrp chmod chown; do
  complete -F "${__gnu_completion}" "g${__gnu_completion}"
done

unset __gnu_completion

no_spaces() {
  awk '!/#/ && /complete / {$1=$1;print}' \
    /usr/local/Cellar/bash-completion@2/2.11/share/bash-completion/completions/* | \
    sed 's/shopt -u hostcomplete \&\& //g' | sort -u
}

commands() {
  find /usr/local/bin \( -type f -or -type l \) -name "g*" | sed 's|/usr/local/bin/g||g' | sort

}
#no_spaces
#commands
while read -r completion; do
  completion -p "${completion}" 2>/dev/null || true
done < <(commands)
#while read -r command; do
#  grep -hRE "complete .* ${command}" /usr/local/Cellar/bash-completion@2/2.11/share/bash-completion/completions/ 2>/dev/null | grep -vE "#|COMPR"
#done < /tmp/commands
#| grep -vE "#|COMPR" > /tmp/c
