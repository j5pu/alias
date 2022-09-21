if command -v lsd >/dev/null; then
  alias ls="lsd"
elif [ "$(uname -s)" = Darwin ]; then
  alias ls="ls -G"
else
  alias ls="ls --color=auto"
fi
! command -v gls >/dev/null || alias gls="gls --color=auto"
alias l="ls"
alias la="ls -la"
alias ll="ls -l"
alias lld="ls -ld"
alias caca=caca
