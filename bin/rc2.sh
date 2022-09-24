#!/bin/sh

#
# Generates system-wide .env.sh profile

set -eu

# Hosts supported
#
HOSTS="book imac mini1 mini512 msi pro"

# Force creation of .env.sh (can be set with --force) [Variable Not added to file]
# Use when:
#   hostname changes,
#   brew is installed,
: "${RC_FORCE=0}"

# PATH [Value not added to file]
#
PATH="${RC_PATH_ADD}:${PATH}"

# 'true' if 'DIST_ID' is 'alpine' and not: nix or busybox
#
: "${ALPINE=false}"
# 'true' if 'DIST_ID' is 'alpine'
#
: "${ALPINE_LIKE=false}"
# 'true' if 'DIST_ID' is 'arch' for archlinux
#
: "${ARCH=false}"
# 'true' if not '/etc/os-release' and not '/sbin'.
#
: "${BUSYBOX=false}"
# 'true' if 'DIST_ID' is 'centos'.
#
: "${CENTOS=false}"
# 'true' if running in docker container.
#
: "${CONTAINER=false}"
# 'true' if 'DIST_ID' is 'debian'.
#
: "${DEBIAN=false}"
# 'true' if 'DIST_ID_LIKE is 'debian'.
#
: "${DEBIAN_LIKE=false}"
# <html><h2>Distribution Codename</h2>
# <p><strong><code>$DIST_CODENAME</code></strong> (always exported).</p>
# <ul>
# <li><code>Catalina</code></li>
# <li><code>Big Sur</code></li>
# <li><code>kali-rolling</code></li>
# <li><code>focal</code></li>
# <li><code>etc.</code></li>
# </ul>
# </html>
: "${DIST_CODENAME=Monterey}"
# <html><h2>Distribution ID</h2>
# <p><strong><code>$DIST_ID</code></strong> (always exported).</p>
# <ul>
# <li><code>alpine</code></li>
# <li><code>centos</code></li>
# <li><code>debian</code></li>
# <li><code>kali</code></li>
# <li><code>macOS</code></li>
# <li><code>ubuntu</code></li>
# </ul>
# </html>
: "${DIST_ID=macOS}"
# <alpine|debian|rhel fedora>.
#
: "${DIST_ID_LIKE=}"
# 'true' if 'DIST_ID' is unknown.
#
: "${DIST_UNKNOWN=false}"
# <html><h2>Distribution Version</h2>
# <p><strong><code>$DIST_ID</code></strong> (always exported).</p>
# <ul>
# <li><code>macOS</code>: 10.15.1, 10.16 ...</li>
# <li><code>kali</code>: 2021.2, ...</li>
# <li><code>ubuntu</code> 20.04, ...</li>
# </ul>
# </html>
: "${DIST_VERSION=}"
# 'true' if 'DIST_ID' is 'fedora'.
#  # Any file under  "*/${supported}/*" and any file "*/${supported}.*" inside "${type}"
#  # Darwin/Linux.sh pasaría, o sea, absurdo si pongo un Linux.sh debajo de un Darwin...
#  #
#  type="$1"; shift
#  SH="$2"; shift
##  SH=""
#  set -- find "${RC_CUSTOM}" "${RC_ETC}" "${RC_GENERATED}" \( -type f -or -type l \) -path "*/${type}/*" \(
#
#  or=""
#  for supported in 00-common "${HOSTNAME}" "${ID_LIKE}" "${UNAME}"; do
#    [ "${supported-}" ] || continue
#    # shellcheck disable=SC2086
#    set -- "$@" ${or} -path "*/${supported}/*" -or -path "*/${supported}.*"
#    or="-or"
#  done
#
#  set -- "$@" \) -not \( -name ".*"
#
#  case "${SH}" in
#    bash) set -- "$@" -or -path "*/zsh/*" -or -path "*/bash-4/*" ;;
#    bash-4) set -- "$@" -or -path "*/zsh/*" ;;
#    zsh) set -- "$@" -or -path "*/bash*/*" ;;
#    *) set -- "$@" -or -path "*/zsh/*" -or -path "*/bash*/*" ;;
#  esac
#
#  set -- "$@" \)
#  echo "$@"
#  "$@"
: "${FEDORA=false}"
# 'true' if 'DIST_ID' is 'fedora' or 'fedora' in 'DIST_ID_LIKE'.
#
: "${FEDORA_LIKE=false}"


: "${HOMEBREW_LOGS=${HOME}/Library/Logs/Homebrew}"
# Homebrew install in $UNAME Darwin.
#
: "${HOMEBREW_MACOS=1}"

# Homebrew tmp
#
: "${HOMEBREW_TEMP=/private/tmp}"
# GIT System Config
#
#
: "${GIT_CONFIG_SYSTEM=${RC_CONFIG_GIT}/gitconfig}"
# GIT Init Template Directory
#
: "${GIT_TEMPLATE_DIR=${RC_CONFIG_GIT}/template}"
# IPython directory for user data (looks for profile_*),
# ipython_config.py should be in  /etc/ipython, /usr/local/etc/ipython or profile_*, not in
# $IPYTHON_DIR/ipython_config.py
: "${IPYTHONDIR=~/.ipython}"
# 'true' if 'DIST_ID' is 'kali'.
#
: "${KALI=false}"
# <html><h2>Is MACOS?</h2>
# <p><strong><code>$MACOS</code></strong> (always exported).</p>
# <p><strong><code>Boolean</code></strong></p>
# <ul>
# <li><code>1</code>: $UNAME is darwin</li>
# <li><code>0</code>: $UNAME is linux</li>
# </ul>
# </html>
: "${MACOS=true}"
# 'true' if 'DIST_ID' is 'alpine' and '/etc/nix'.
#
: "${NIXOS=false}"
# <html><h2>Default Package Manager</h2>
# <p><strong><code>$PM</code></strong> (always exported).</p>
# <ul>
# <li><code>apk</code></li>
# <li><code>apt</code></li>
# <li><code>brew</code></li>
# <li><code>nix</code></li>
# <li><code>yum</code></li>
# </ul>
# </html>
: "${PM=brew}"
# <html><h2>Default Package Manager Command with Install Options</h2>
# <p><strong><code>$PM_INSTALL</code></strong> (always exported).</p>
# <p><strong><code>Quiet and no cache (for containers)</code></strong>.</p>
# <ul>
# <li><code>apk</code></li>
# <li><code>apt</code></li>
# <li><code>brew</code></li>
# <li><code>nix</code></li>
# <li><code>yum</code></li>
# </ul>
# </html>
: "${PM_INSTALL=${PM} install}"
# <html><h2>Default Package Manager Command with Upgrade and Cleanup</h2>
# <p><strong><code>$PM_UPGRADE</code></strong> (always exported).</p>
# <p><strong><code>Quiet and no cache (for containers)</code></strong>.</p>
# <ul>
# <li><code>apk</code></li>
# <li><code>apt</code></li>
# <li><code>brew</code></li>
# <li><code>nix</code></li>
# <li><code>yum</code></li>
# </ul>
# </html>
: "${PM_UPGRADE=${PM} upgrade}"
# Python Interactive Startup File
#
: "${PYTHONSTARTUP=${RC_BIN}/pythonstartup}"
# 'true' if 'DIST_ID' is 'rhel'.
#
#
: "${RHEL=false}"
# 'true' if 'DIST_ID' is 'rhel' or 'rhel' in 'DIST_ID_LIKE'.
#
#
: "${RHEL_LIKE=false}"
# Path with sudo command
# https://linuxhandbook.com/run-alias-as-sudo/
#
: "${SUDOC=/usr/bin/sudo}"
# 'true' if 'DIST_ID' is 'ubuntu'.
#
#
: "${UBUNTU=false}"
# <html><h2>Operating System Name</h2>
# <p><strong><code>$UNAME</code></strong> (always exported).</p>
# <ul>
# <li><code>Darwin</code></li>
# <li><code>Linux</code></li>
# </ul>
# </html>
: "${UNAME=${HOMEBREW_SYSTEM}}"
# <html><h2>Machine name</h2>
# <p><strong><code>$UNAME</code></strong> (always exported).</p>
# <ul>
# <li><code>x86_64</code></li>
# <li><code>arm (for new mac)</code></li>
# </ul>
# </html>
: "${UNAME_MACHINE=${HOMEBREW_PROCESSOR}}"
# Username if not defined  [Variable Not added to file]
# idea from brew install.sh
: "${USER=$(chomp "$(id -un)")}"
# <html><h2>Have an VGA card</h2>
# <p><strong><code>$VGA</code></strong> 'true' if has an VGA card.</p>
# </html>
: "${VGA=true}"

# TODO: Aqui lo dejo
die() {
  echo >&2 "$*"
  exit 1
}

#######################################
# system main
#######################################
_system() {

  #######################################
  # distribution ID
  #######################################
  _dist_id() {
    case "${DIST_ID}" in
      alpine)
        # TODO: check if nix is really alpine !!!
        ALPINE_LIKE=true
        DIST_ID_LIKE="${DIST_ID}"
        if [ -r "/etc/nix" ]; then
          NIXOS=true
          PM="nix-env"
        else
          ALPINE=true
          PM="apk"
        fi
        ;;
      arch)
        ARCH=true
        PM="pacman"
        ;;
      centos)
        CENTOS=true
        PM="yum"
        ;;
      debian)
        DEBIAN=true
        DEBIAN_LIKE=true
        DIST_ID_LIKE="${DIST_ID}"
        ;;
      fedora)
        FEDORA=true
        FEDORA_LIKE=true
        PM="dnf"
        ;;
      kali) KALI=true ;;
      rhel)
        RHEL=true
        RHEL_LIKE=true
        PM="yum"
        ;;
      ubuntu) UBUNTU=true ;;
      *) DIST_UNKNOWN=true ;;
    esac
  }

  #######################################
  # distribution ID like
  #######################################
  _dist_id_like() {
    case "${DIST_ID_LIKE}" in
      debian)
        DEBIAN_LIKE=true
        PM="apt"
        ;;
      *fedora*) FEDORA_LIKE=true ;;
      *rhel*) RHEL_LIKE=true ;;
    esac
  }

  #######################################
  # strip quotes
  #######################################
  _strip() { echo "${value}" | sed 's/^"//;s/"$//'; }

  if [ "${UNAME}" = "Darwin" ]; then
    BASH_SILENCE_DEPRECATION_WARNING=1
    CLT="/Library/Developer/CommandLineTools"
    DIST_ID="$(command -p sw_vers -ProductName)"
    DIST_VERSION="$(command -p sw_vers -ProductVersion)"
    case "$(echo "${DIST_VERSION}" | command awk -F. '{ print $1 $2 }')" in
      1013) DIST_CODENAME="High Sierra" ;;
      1014) DIST_CODENAME="Mojave" ;;
      1015) DIST_CODENAME="Catalina" ;;
      11*) DIST_CODENAME="Big Sur" ;;
      12*) DIST_CODENAME="Monterey" ;;
      *) DIST_CODENAME="Other" ;;
    esac
    if [ "${HOMEBREW_PROCESSOR}" = "arm64" ]; then
      HOMEBREW_PREFIX="/opt/homebrew"
      HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}"
    fi
  else
    if [ -f "/etc/os-release" ]; then
      while IFS="=" read -r name value; do
        case "${name}" in
          ID)
            DIST_ID="$(_strip)"
            _dist_id
            ;;
          ID_LIKE)
            DIST_ID_LIKE="$(_strip)"
            _dist_id_like
            ;;
          VERSION_ID) DIST_VERSION="$(_strip)" ;;
          VERSION_CODENAME) DIST_CODENAME="$(_strip)" ;;
        esac
      done <"/etc/os-release"
    else
      BUSYBOX=true
      PM=""
      DIST_ID="busybox"
    fi
    COMPLETIONS_HELPER="/usr/share/bash-completion/bash_completion"
    LINUXBREW="/home/linuxbrew/.linuxbrew"

    HOMEBREW_CACHE="${HOME}/.cache/Homebrew"
    HOMEBREW_LINUX=1
    HOMEBREW_MACOS=""
    HOMEBREW_LOGS="${HOMEBREW_CACHE}/Logs"
    HOMEBREW_PREFIX="${LINUXBREW}"
    HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
    HOMEBREW_TEMP="/tmp"

    MACOS=false
    [ -x /usr/bin/sudo ] || export SUDOC=
    VGA="$(command lspci 2>/dev/null | command awk '/VGA/ { print 1 }')"
  fi

  # TODO: Aqui lo dejo, meter esto en generated y el system. Poner la variable de Git Actions.
  # Homebrew Cellar where built products are store`
  #
  : "${HOMEBREW_CELLAR="${HOMEBREW_REPOSITORY}/Cellar"}"
  # Homebrew Library where Taps (i.e.: homebrew/homebrew-core) are stored and Homebrew's internal ruby code is located
  #
  : "${HOMEBREW_LIBRARY="${HOMEBREW_REPOSITORY}/Library"}"
  # Homebrew Taps (i.e.: homebrew/homebrew-core) are stored
  #
  : "${HOMEBREW_TAPS="${HOMEBREW_LIBRARY}/Taps"}"
  # Homebrew core repository path
  #
  : "${HOMEBREW_CORE="${HOMEBREW_TAPS}/homebrew/homebrew-core"}"

  [ ! "${GITHUB_RUN_ID-}" ] || VGA=false

  if [ "${PM-}" ]; then
    case "${PM}" in
      # pacman -Sy (like apt update)
      apk)
        PM_INSTALL="sudo ${PM} ${PM} add -q --no-progress"
        NO_CACHE="--no-cache"
        ;;
      apt)
        PM_INSTALL="sudo ${PM} -qq update -y && ${PM} -qq install -y"
        PM_UPGRADE="${PM} -qq full-upgrade -y && ${PM} -qq auto-remove -y && ${PM} -qq clean"
        ;;
      brew) PM_INSTALL="${PM} install --quiet" ;;
      dnf) PM_INSTALL="sudo ${PM} install -y -q" ;;
      nix) PM_INSTALL="sudo ${PM} --install -A" ;; # nixos -> nixos.curl, no nixos --> nixpkgs.curl
      pacman) PM_INSTALL="sudo ${PM} -Sy && ${PM} -S --noconfirm" ;;
      yum) PM_INSTALL="sudo ${PM} install -y -q" ;;
      *) PM_INSTALL="" ;;
    esac
  fi
}
#######################################
# Adds variable to RC_VARS to be stored in RC_FILE
# Globals:
#   RC_VARS
# Arguments:
#   1
#   2
#######################################
_var() {
  RC_VARS="${RC_VARS:+${RC_VARS} }${1}"
  [ ! "${2-}" ] || mkdir -p "${2}"
}

#######################################
# Adds all variables to RC_VARS to be stored in RC_FILE and make directories
# Globals:
#   RC_VARS
# Arguments:
#   1
#   2
#######################################
_vars() {
  for _var in \
    HOST HOST_UPPER HOSTNAME HOSTNAME_DOMAIN HOSTS \
    RC_FILE RC_SUPPORTED \
    \
    ALPINE ALPINE_LIKE ARCH \
    BUSYBOX \
    CENTOS \
    CONTAINER \
    DEBIAN DEBIAN_LIKE DIST_CODENAME DIST_ID DIST_ID_LIKE DIST_UNKNOWN DIST_VERSION \
    FEDORA FEDORA_LIKE \
    HOMEBREW_CACHE HOMEBREW_CORE HOMEBREW_LINUX HOMEBREW_LOGS \
    HOMEBREW_MACOS HOMEBREW_PREFIX HOMEBREW_PHYSICAL_PROCESSOR \
    HOMEBREW_PROCESSOR HOMEBREW_REPOSITORY HOMEBREW_SYSTEM \
    GIT_CONFIG_SYSTEM \
    KALI \
    MACOS \
    NIXOS \
    PM PM_INSTALL PM_UPGRADE PYTHONSTARTUP \
    RHEL RHEL_LIKE \
    SUDOC \
    UBUNTU UNAME UNAME_MACHINE \
    VGA \
    \
    HOMEBREW_CELLAR HOMEBREW_LIBRARY HOMEBREW_TAPS HOMEBREW_CORE; do
    _var "${_var}"
  done

  for _var in \
    BASH_COMPLETION_USER_DIR \
    GIT_TEMPLATE_DIR \
    IPYTHONDIR \
    RC \
    RC_BIN \
    RC_CONFIG RC_CONFIG_GIT \
    RC_CUSTOM RC_CUSTOM_COMPLETIONS RC_CUSTOM_PROFILE_D RC_CUSTOM_RC_D \
    RC_ETC RC_ETC_FUNCTIONS_D RC_ETC_PROFILE_D RC_ETC_RC_D \
    RC_GENERATED \
    RC_GENERATED_BIN RC_GENERATED_PROFILE_D RC_GENERATED_PROFILE_HOSTS_D RC_GENERATED_RC_D RC_GENERATED_RC_ALIASES_D; do
    _var "${_var}" 1
  done
}

main() {
  _vars=false
  [ "${ENV-}" = "${RC_FILE}" ] || {
    _vars
    _vars=true
  }

  if ! test -f "${RC_FILE}" || [ "${RC_FORCE}" -eq 1 ]; then
    $_vars || _vars
    ! test -f "${RC_FILE}" || [ "$(fstat "${RC_FILE}")" = "${USER}" ] || die "${RC_FILE} is not owned by ${USER}"
  fi
}
