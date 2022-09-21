# shellcheck shell=sh

#
# System-wide POSIX profile
# Generated by /Users/j5pu/rc/bin/rc.sh

unset ENV

: "${RC_TRACE=0}"; [ "${RC_TRACE}" -eq 0 ] || set -x

if ! command -v resh >/dev/null; then
  . "/Users/j5pu/rc/etc/functions.d/rc.sh.sh"

  rc_source_dir "/Users/j5pu/rc/etc/functions.d/00-common"
  rc_source_dir "/Users/j5pu/rc/etc/functions.d/Darwin"
  rc_source_dir "/Users/j5pu/rc/etc/functions.d/pro"
fi

#
# RC: profile.d for interactive shells has been sourced already
: "${RC_PROFILE_D_SOURCED=0}"; export RC_PROFILE_D_SOURCED

if [ "${RC_PROFILE_D_SOURCED}" -eq 0 ]; then
  RC_PROFILE_D_SOURCED=1

  export BASH_COMPLETION_USER_DIR="/Users/j5pu/rc/custom"
  export CLT="/Library/Developer/CommandLineTools"
  export ID_LIKE=""
  export MACOS="true"
  export RC_COMPLETIONS="/Users/j5pu/rc/custom/completions"
  export RC_CUSTOM="/Users/j5pu/rc/custom"
  export RC_CUSTOM_PROFILE_D="/Users/j5pu/rc/custom/profile.d"
  export RC_CUSTOM_RC_D="/Users/j5pu/rc/custom/rc.d"
  export RC_ETC="/Users/j5pu/rc/etc"
  export RC_ETC_ALIASES="/Users/j5pu/rc/etc/aliases.d"
  export RC_ETC_FUNCTIONS="/Users/j5pu/rc/etc/functions.d"
  export RC_ETC_PROFILE_D="/Users/j5pu/rc/etc/profile.d"
  export RC_ETC_RC_D="/Users/j5pu/rc/etc/rc.d"
  export RC_GENERATED="/Users/j5pu/rc/generated"
  export RC_GENERATED_PROFILE_D="/Users/j5pu/rc/generated/profile.d"
  export RC_GENERATED_RC_D="/Users/j5pu/rc/generated/rc.d"
  export RC_SEARCH="00-common pro Darwin"
  export RC_SUPPORTED="00-common arch Darwin debian fedora Linux rhel rhel_fedora pro"
  export RC_TOP="/Users/j5pu/rc"
  export SUDO="/usr/bin/sudo"
  export UNAME="Darwin"
  export VGA="1"
  export pro_IP="192.168.0.24"

  unset INFOPATH MANPATH
  if $MACOS; then
    eval "$(/usr/libexec/path_helper -s)"
    PATH="${PATH}:${CLT}/usr/bin"
  else
    PATH="/home/linuxbrew/.linuxbrew/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  fi
  ! has brew || eval "$(brew shellenv)"
  export PATH="/Users/j5pu/rc/bin:${PATH}"

  : "${HOSTNAME=$(hostname)}"; export HOSTNAME

  rc_source_dir "/Users/j5pu/rc/etc/profile.d/constants.d/00-common"
  rc_source_dir "/Users/j5pu/rc/etc/profile.d/constants.d/Darwin"
  rc_source_dir "/Users/j5pu/rc/etc/profile.d/constants.d/pro"
  rc_source_dir "/Users/j5pu/rc/etc/profile.d/vars.d/00-common"
  rc_source_dir "/Users/j5pu/rc/etc/profile.d/vars.d/Darwin"
  rc_source_dir "/Users/j5pu/rc/etc/profile.d/vars.d/pro"

  rc_source_dir "/Users/j5pu/rc/etc/profile.d/hooks.d/00-common/bash"
  rc_source_dir "/Users/j5pu/rc/etc/profile.d/hooks.d/00-common/sh"
  rc_source_dir "/Users/j5pu/rc/etc/profile.d/hooks.d/Darwin/bash"
  rc_source_dir "/Users/j5pu/rc/etc/profile.d/hooks.d/Darwin/sh"
  rc_source_dir "/Users/j5pu/rc/etc/profile.d/hooks.d/pro/bash"
  rc_source_dir "/Users/j5pu/rc/etc/profile.d/hooks.d/pro/sh"

  . "/Users/j5pu/rc/generated/profile.d/00-common.sh"
  . "/Users/j5pu/rc/generated/profile.d/Darwin.sh"
  . "/Users/j5pu/rc/generated/profile.d/pro.sh"

  rc_source_dir "/Users/j5pu/rc/custom/profile.d"
fi

#
# Homebrew profile.d has been sourced already
: "${HOMEBREW_PROFILE_D_SOURCED=0}"

if test -d "${HOMEBREW_PREFIX}/etc/profile.d" && [ "${HOMEBREW_PROFILE_D_SOURCED}" -eq 0 ]; then
  HOMEBREW_PROFILE_D_SOURCED=1
  rc_source_dir "${HOMEBREW_PREFIX}/etc/profile.d"
fi

#
# RC: rc.d for interactive shells has been sourced already
: "${RC_RC_D_SOURCED=0}"

if { [ "${PS1-}" ] || echo "$-" | grep -q i; } && [ "${RC_RC_D_SOURCED}" -eq 0 ]; then
  RC_RC_D_SOURCED=1

  unalias cp egrep fgrep grep l l. la ll lld ls mv rm xzegrep xzfgrep xzgrep zegrep zfgrep zgrep 2>/dev/null



  rc_source_dir "/Users/j5pu/rc/etc/rc.d/hooks.d/00-common/bash"
  rc_source_dir "/Users/j5pu/rc/etc/rc.d/hooks.d/00-common/sh"
  rc_source_dir "/Users/j5pu/rc/etc/rc.d/hooks.d/Darwin/bash"
  rc_source_dir "/Users/j5pu/rc/etc/rc.d/hooks.d/Darwin/sh"
  rc_source_dir "/Users/j5pu/rc/etc/rc.d/hooks.d/pro/bash"
  rc_source_dir "/Users/j5pu/rc/etc/rc.d/hooks.d/pro/sh"

  . "/Users/j5pu/rc/etc/aliases.d/00-common.sh"

  . "/Users/j5pu/rc/generated/rc.d/00-common/dirs.sh"
  . "/Users/j5pu/rc/generated/rc.d/Darwin/dirs.sh"
  . "/Users/j5pu/rc/generated/rc.d/pro/dirs.sh"

  if [ "${SUDO-}" ]; then
    . "/Users/j5pu/rc/generated/rc.d/00-common/sudo.sh"
    . "/Users/j5pu/rc/generated/rc.d/Darwin/sudo.sh"
    . "/Users/j5pu/rc/generated/rc.d/pro/sudo.sh"
  fi

  rc_source_dir "/Users/j5pu/rc/custom/rc.d"
fi

export ENV="/Users/j5pu/rc/.rc.sh.sh"

[ "${RC_TRACE}" -eq 0 ] || set +x
