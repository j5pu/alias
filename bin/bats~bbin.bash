#!/usr/bin/env bash
# shellcheck disable=SC2155,SC2046

# TODO: envrc

if ! command -v has >/dev/null; then
  export BBIN_PREFIX="$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd -P)"
  . "${BBIN_PREFIX}/bin/profile.sh" || return 2>/dev/null || exit
fi
command -v filefuncs >/dev/null || return 2>/dev/null || exit

# Bashpro Bats Formatter
#
export BATS_BASHPRO_FORMATTER="bashpro"

# Command Executed (variable set by: bats).
#
export BATS_COMMAND

# Gather the output of failing *and* passing tests as files in directory (variable set by: bats).
#
export BATS_GATHER

# Path to the test directory, passed as argument or found by 'bats' (variable set by: bats).
#
export BATS_TEST_DIR

# Array of tests found (variable set by: bats).
#
export BATS_TESTS

#######################################
# assert -h, --help, help with $HELPS_LINE
# Globals:
#   HELPS_LINE
# Arguments:
#   1   HELPS_LINE
# Examples:
# @test "assert::helps starts Docker daemon if not running" {
#  ${BATS_TEST_DESCRIPTION}
#}
#
# @test "assert::helps starts Docker daemon if not running" {
#  bats::success
#}
# setup_file() { HELPS_LINE="foo" }
#@test "assert::helps" {
#  bats::success
#}
#######################################
assert::helps() {
  local helps_line option run
  run="$(bats::basename)"
  helps_line="${HELPS_LINE:-$@}"
  assert [ -n "${helps_line}" ]
  for option in -h --help help; do
    run "${run}" "${option}"
    assert_success
    assert_line "${helps_line}"
  done
}

#######################################
# creates $BATS_ARRAY array from $BATS_TEST_DESCRIPTION or argument
# Globals:
#   BATS_ARRAY
#   BATS_TEST_DESCRIPTION
#######################################
# shellcheck disable=SC2086
bats::array() { mapfile -t BATS_ARRAY < <(xargs printf '%s\n' <<<${BATS_TEST_DESCRIPTION}); }

#######################################
# Bats Test File Basename Without Suffix
# Globals:
#   BATS_ARRAY
#   BATS_TEST_DESCRIPTION
#######################################
bats::basename() { basename "${BATS_TEST_FILENAME-}" .bats; }

#######################################
# Changes to top repository path \$BATS_TOP and top path found, otherwise changes to the \$BATS_TESTS
# Globals:
#   BATS_ROOT
#   BATS_TESTS
#   BATS_TOP
#######################################
bats::cd() { cd "${BATS_TOP:-${BATS_TESTS:-.}}" || return; }

#######################################
# Restores $PATH to $BATS_SAVED_PATH and sources .envrc.
# Globals:
#   PATH
# Arguments:
#  None
#######################################
bats::env() {
  bats::cd

  PATH="${BATS_START_PATH}"
  MANPATH="${BATS_START_MANPATH}"
  INFOPATH="${BATS_START_INFOPATH}"
  path_add_exist_all "${BATS_TOP}"
  ! test -f "${BATS_TOP}/.env" || source "${BATS_TOP}/.env"
  BATS_SAVED_PATH="${PATH}"
  BATS_SAVED_MANPATH="${MANPATH}"
  BATS_SAVED_INFOPATH="${INFOPATH}"

  # TODO: envfile
  #  . "$(dirname "${BASH_SOURCE[0]}")/envfile.sh"
  #  envfile
}

#######################################
# run description array and asserts if failure
# Globals:
#   BATS_ARRAY
# Arguments:
#  None
# Caution:
#  Do not se it with single quotes ('echo "1 2" 3 4'), use double quotes ("echo '1 2' 3 4")
#######################################
bats::failure() {
  bats::run
  assert_failure
}

#######################################
# create a remote, a local temporary directory and change to local repository directory (no commits added)
# Globals:
#   BATS_REMOTE
# Arguments:
#  1  directory name (default: random name)
#######################################
bats::remote() {
  local pwd_p="$(pwd_p "$(bats::tmp "${1:-$RANDOM}")")"
  local pwd_p_git="$(pwd_p "$(bats::tmp "${1:-$RANDOM}.git")")"
  BATS_REMOTE=("${pwd_p}" "${pwd_p_git}"); export BATS_REMOTE
  git -C "${BATS_REMOTE[1]}" init --bare --quiet
  cd "${BATS_REMOTE[0]}" || return
  git init --quiet
  git branch -M main
  git remote add origin "${BATS_REMOTE[1]}"
  git config branch.main.remote origin
  git config branch.main.merge refs/heads/main
  git config user.name "${BATS_BASENAME}"
  git config user.email "${BATS_BASENAME}@example.com"
}

#######################################
# run description array
# Globals:
#   BATS_ARRAY
# Arguments:
#  None
# Caution:
#  Do not se it with single quotes ('echo "1 2" 3 4'), use double quotes ("echo '1 2' 3 4")
#######################################
bats::run() {
  bats::array
  run "${BATS_ARRAY[@]}"
}

#######################################
# run description array and asserts if success
# Globals:
#   BATS_ARRAY
# Arguments:
#  None
# Caution:
#  Do not se it with single quotes ('echo "1 2" 3 4'), use double quotes ("echo '1 2' 3 4")
#######################################
bats::success() {
  bats::run
  assert_success
}

#######################################
# create a temporary directory in $BATS_FILE_TMPDIR if arg is provided
# Globals:
#   BATS_FILE_TMPDIR
# Arguments:
#  1  directory name (default: returns $BATS_FILE_TMPDIR)
# Outputs:
#  new temporary directory or $BATS_FILE_TMPDIR
#######################################
bats::tmp() {
  local GENERATED="${BATS_FILE_TMPDIR}${1:+/$1}"
  [ ! "${1-}" ] || mkdir -p "${GENERATED}"
  echo "${GENERATED}"
}

#######################################
# skip if GitHub action
# Arguments:
#  None
#######################################
skip::if::action() {
  ! isaction || skip "GitHub action"
}

#######################################
# bashpro patch
# Arguments:
#  None
#######################################
_bashpro() {
  local bats_dst plugin properties
  while read -r properties; do
    test -f "${properties}" || continue

    plugin="$(awk -F '=' '/idea.plugins.path=/ { print $2 }' "${properties}")/bashsupport-pro/bats-core"
    test -d "${plugin}" || continue
    bats_dst="${plugin}/bin/bats"
    if ! grep -q "${BATS_BASHPRO_FORMATTER}" "${bats_dst}"; then
      test -f "${bats_dst}.bak" || cp "${bats_dst}" "${bats_dst}.bak"
      cat >"${bats_dst}" <<EOF
#!/usr/bin/env bash

for arg do
  shift
  [ "\${arg}" != "${BATS_BASHPRO_FORMATTER}" ] || \
arg="\$(dirname "\$(dirname "\$0")")/libexec/bats-core/bats-format-bashpro"
  set -- "\$@" "\${arg}"
done

exec bats "\$@"
EOF
      chmod +x "${bats_dst}"
      _ok "${bats_dst}: updated"
    fi

  done < <(env | awk -F '=' '/^[A-Z].*_PROPERTIES=/ { print $2 }')
}


#######################################
# bats libs
# Globals:
#   BASH_SOURCE
#   __brew_lib
#   i
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
_bats_libs() {
  local file i
  for i in ${BATS_LIBS}; do
    file="${BATS_SHARE}/${i}/load.bash"
    . "${file}" || RETURN="return" _die "${file}: sourcing error"
  done
}

#######################################
# die with return or exit
# Globals:
#   RETURN
# Arguments:
#   None
#######################################
_die() {
  local rc=$?
  printf >&2 '%b\n' "\033[1;31m✘\033[0m ${BASH_SOURCE[0]##*/}: $*"
  "${RETURN:-exit}" $rc
}

#######################################
# find tests in directory "*.bats" and adds to BATS_TESTS
# Globals:
#   BATS_TESTS
# Arguments:
#   1 directory
#   2 message to exit if not found
# Returns:
#  1 if not tests found
#######################################
_directory() {
  local tests
  [ "$(realpath "$1")" != "$(realpath "${HOME}")" ] || _die "$1" "is home directory"
  mapfile -t tests < <(find "$(realpath "$1")" \( -type f -o -type l \) -name "*.bats")
  [ "${tests-}" ] || return
  BATS_TESTS+=("${tests[@]}")
}

#######################################
# start docker
# Globals:
#   BATS_DOCKER_CONTEXT
#   BATS_LOCAL
# Arguments:
#   0
# Returns:
#   1 ...
#######################################
_docker() {
  ! [[ "${1-}" =~ -h|--help|--man|--man7|-v|--version|bashpro|commands|help|functions|list  ]] || return 0

  if isaction || ! has docker; then
    BATS_LOCAL=1
  elif test $BATS_LOCAL -eq 0; then
    if [ ! "${BATS_DOCKER_CONTEXT-}" ]; then
      if ismacos; then
        BATS_DOCKER_CONTEXT="default"
      else
        BATS_DOCKER_CONTEXT="default"
      fi
    fi

    if [ "$(docker context show)" != "${BATS_DOCKER_CONTEXT}" ]; then
      docker context use "${BATS_DOCKER_CONTEXT}" >/dev/null || \
        { >&2 echo "Docker: Change context to: ${BATS_DOCKER_CONTEXT}: failed"; return 1; }
      ! fd3 || >&3 echo "${0##*/}: Docker: Changed context to: ${BATS_DOCKER_CONTEXT}"
    fi

    if ! docker-running; then
      ! fd3 || >&3 echo "${0##*/}: Docker: Starting"
      docker-start
      ! fd3 || >&3 echo "${0##*/}: Docker: Started"

      if ! docker-running; then
        ! fd3 || >&3 echo "${0##*/}: Error: Starting Docker"
        >&2 echo "${0##*/}: Error: Starting Docker"; return 1 2>/dev/null || exit
      fi
    fi
  fi
}

#######################################
# check if is file suffix is "*.bats" and adds to BATS_TESTS
# Globals:
#   BATS_TESTS
# Arguments:
#   1 file
# Returns:
#  1 invalid file
#######################################
_file() {
  [ "${1##*.}" = bats ] || return
  BATS_TESTS+=("$(realpath "$1")")
}

#######################################
# export bats functions
# Globals:
#   ${BATS_FUNCTIONS[@]}
#   BASH_SOURCE
#   BATS_FUNCTIONS
#   BATS_SHARE
# Arguments:
#  None
#######################################
_functions() {
  mapfile -t BATS_FUNCTIONS < <(
    filefuncs "${BATS_SHARE}"/bats-*/src/*.bash \
      && filefuncs "${BASH_SOURCE[0]}"
  )

  # bashsupport disable=BP2001
  export -f "${BATS_FUNCTIONS[@]}" && funcexported assert && funcexported bats::env
}

#######################################
# show help and exit
# Arguments:
#   None
#######################################
_help() {
  local rc=$? script="${0##*/}"
  local sh="${script/.sh/}.sh"
  [ ! "${1-}" ] || {
    echo -e "${0##*/}: ${1}: ${2}\n"
    rc=1
  }
  cat <<EOF
usage: ${script} [<tests>] [<options>]
   or: ${sh} [<tests>] [<options>]
   or: ${script} -h|-help|commands|help|functions|verbose
   or: ${sh} -h|-help|commands|help|functions|verbose
   or: . ${script}
   or: . ${sh}

bats testing wrapper and helper functions when "${script}" or "${sh}" sourced

<tests> is the path to a Bats test file, or the path to a directory containing Bats
test files (ending with ".bats"). If no <tests> run for: first directory found with ".bats"
files in working directory, or either 'tests', 'test' or '__tests__' under top repository path.

Changes to top repository path \$BATS_TOP when running tests and top path found, otherwise changes
to the \$BATS_TEST_DIR

Adds top repository path: sbin, bin and libexec to \$PATH and sources .env

Commands:
  -h, --help, help          display this help and exit
  bashpro                   patches bashpro plugin (remove in run configuration to add to PATH)
  commands                  display ${script}' commands
  functions                 display functions available when ${script} is sourced
  list                      display tests found relative to current working directory

Options:
  --dry-run                 show command that would be executed and globals
  --man                     show bats(1) man page
  --man7                    show bats(7) man page
  --one                     run only one job in parallel instead of \$BATS_NUMBER_OF_PARALLEL_JOBS
  --verbose                 run bats tests showing all outputs, with trace and not cleaning the tempdir

Bats options:
$(awk '/--count/,0' < <("${BATS_EXECUTABLE}" --help))

Globals:
   BATS_COMMAND             Command Executed.
   BATS_GATHER              Gather the output of failing *and* passing tests as
                            files in directory [--gather-test-outputs-in].
   BATS_OUTPUT              Directory to write report files [-o|--output].
   BATS_TEST_DIR            Path to the test directory, passed as argument or found by '${script}'.
   BATS_TESTS               Array of tests found.

$("${BATS_EXECUTABLE}" --version)
EOF
  exit $rc
}

#######################################
# ok message
# Arguments:
#   1  message
#######################################
_ok() { printf >&2 '%b\n' "\033[1;32m✔\033[0m ${BASH_SOURCE[0]##*/}: $*"; }

#######################################
# unsets functions
# Arguments:
#  None
#######################################
_unsets() {
  unset -f _bats_clone _bats_libs _bats_pull _die _directory _file _help _main _unsets
}

#######################################
# parse arguments when is executed and run bats  (private used by bats.bash)
# Globals:
#   OPTS_BACK
# Arguments:
#   None
#######################################
_main() {
  local sourced=false
  [ "${BASH_SOURCE##*/}" = "${0##*/}" ] || sourced=true

  ! $sourced || { $sourced && ! funcexported assert 2>/dev/null; } || {
    _unsets
    return
  }

  _bats_libs || return
  _functions || return

  bats::env || return
  _docker "$@" || return

  ! $sourced || {
    _unsets
    return
  }

  set -eu
  shopt -s inherit_errexit

  local outputs
  outputs="$(realpath "${BATS_TOP:-.}/.${0##*/}")"

  local directory
  local dry=false
  local gather_test_outputs_in=false
  local gather_dir=("${outputs}/test")
  local jobs=()
  local list=false
  local no_parallelize_across_files=()
  local no_parallelize_within_files=()
  local no_tempdir_cleanup=false
  local options=()
  local one=false
  local output=false
  local output_dir=("${outputs}/output")
  local print_output_on_failure=(--print-output-on-failure)
  local show_output_of_passing_tests=false
  local timing=false
  local trace=false
  local verbose=false
  local verbose_run=false

  while (($#)); do
    case "$1" in
      -h | --help | help) _help ;;
      --code-quote-style)
        options+=("$1" "$2")
        shift
        ;;
      -c | --count) options+=("$1") ;;
      -f | --filter)
        options+=("$1" "$2")
        shift
        ;;
      -F | --formatter)
        options+=("$1" "$2")
        shift
        ;;
      -d | --dry-run) dry=true ;;
      -j | --jobs)
        jobs=("$1" "$2")
        shift
        ;;
      --gather-test-outputs-in)
        gather_test_outputs_in=true
        gather_dir=("$(realpath "$2")")
        options+=("$1" "$2")
        shift
        ;;
      --man)
        man "${BATS_SHARE}/bats-core/man/bats.1"
        exit
        ;;
      --man7)
        man "${BATS_SHARE}/bats-core/man/bats.7"
        exit
        ;;
      --no-parallelize-across-files) no_parallelize_across_files=("$1") ;;
      --no-parallelize-within-files) no_parallelize_within_files=("$1") ;;
      --no-tempdir-cleanup)
        no_tempdir_cleanup=true
        options+=("$1")
        ;;
      --one) one=true ;;
      -p | --pretty) options+=("$1") ;;
      --report-formatter)
        options+=("$1" "$2")
        shift
        ;;
      -r | --recursive) : ;;
      -o | --output)
        output=true
        output_dir=("$(realpath "$2")")
        options+=("$1" "$2")
        shift
        ;;
      --print-output-on-failure) : ;;
      --show-output-of-passing-tests)
        show_output_of_passing_tests=true
        options+=("$1")
        ;;
      --tap) options+=("$1") ;;
      -T | --timing)
        timing=true
        options+=("$1")
        ;;
      -x | --trace)
        trace=true
        options+=("$1")
        ;;
      --verbose) verbose=true ;;
      --verbose-run)
        verbose_run=true
        options+=("$1")
        ;;
      -v | --version) options+=("$1") ;;
      bashpro)
        _bashpro
        exit
        ;;
      commands)
        printf '%s\n' -h --help --man --man7 -v --version bashpro "$1" functions help list | sort
        exit
        ;;
      functions)
        printf '%s\n' "${BATS_FUNCTIONS[@]}" | sort
        exit
        ;;
      list) list=true ;;
      -*) _help "$1" "invalid option" ;;
      *)
        test -e "$1" || _help "$1" "no such file, directory or invalid command"
        test -d "$1" || { _file "$1" && shift && continue; } || _die "${1}:" "invalid .bats extension"
        _directory "$1" || _die "${1}:" "no .bats tests found in directory"
        ;;
    esac
    shift
  done

  [ "${jobs-}" ] || jobs=(--jobs "${BATS_NUMBER_OF_PARALLEL_JOBS:-1}")
  [ ! "${no_parallelize_across_files-}" ] || [ "${jobs[1]}" -ne 1 ] || jobs=(--jobs 2)
  [ ! "${no_parallelize_within_files-}" ] || [ "${jobs[1]}" -ne 1 ] || jobs=(--jobs 2)

  ! $one || {
    jobs=(--jobs 1)
    no_parallelize_across_files=()
    no_parallelize_within_files=()
  }

  if $verbose; then
    $gather_test_outputs_in || {
      gather_test_outputs_in=true
      options+=("--gather-test-outputs-in" "${gather_dir[@]}")
    }
    $no_tempdir_cleanup || options+=("--no-tempdir-cleanup")
    $output || {
      output=true
      options+=("--output" "${output_dir[@]}")
    }
    $show_output_of_passing_tests || options+=("--show-output-of-passing-tests")
    $timing || options+=("--timing")
    $trace || options+=("--trace")
    $verbose_run || options+=("--verbose-run")
  fi

  if ! $dry; then
    ! $gather_test_outputs_in || ! test -d "${gather_dir[@]}" || rm -rf "${gather_dir[@]}"
    ! $output || {
      rm -rf "${output_dir[@]}"
      mkdir -p "${output_dir[@]}"
    }
  fi

  if [ ! "${BATS_TESTS-}" ] && ! _directory "$(pwd)"; then
    if [ "${BATS_TOP-}" ]; then
      for _bats_test_dir in __tests__ test tests; do
        directory="${BATS_TOP}/${_bats_test_dir}"
        ! test -d "${directory}" || _directory "${directory}" || true
      done
      [ "${BATS_TESTS-}" ] || _die "${BATS_TOP}/{__tests__,test,tests}: no .bats test found"
    else
      _die "${PWD}: not a git repository (or any of the parent directories)"
    fi
  fi

  local directories=()
  for _bats_test_dir in "${BATS_TESTS[@]}"; do
    [ -d "${_bats_test_dir}" ] || {
      directories+=("$(dirname "${_bats_test_dir}")")
      continue
    }
    directories+=("${_bats_test_dir}")
  done
  mapfile -t directories < <(printf '%s\n' "${directories[@]}" | sort -u)
  BATS_TEST_DIR="$(find "${directories[@]}" -mindepth 0 -maxdepth 0 -type d -print -quit)"

  local directory="${BATS_TESTS[0]}"
  for _bats_test_dir in "${BATS_TESTS[@]}"; do
    directory="$(comm -12 <(tr "/" "\n" <<<"${_bats_test_dir/\//}") \
      <(tr "/" "\n" <<<"${directory/\//}") | sed 's|^|/|g' | tr -d '\n')"
  done
  test -d "${directory}" || directory="$(dirname "${directory}")"

  local command=(
    "${BATS_EXECUTABLE}"
    "${jobs[@]}"
    "${no_parallelize_across_files[@]}"
    "${no_parallelize_within_files[@]}"
    "${print_output_on_failure[@]}"
    "${options[@]}"
    "${BATS_TESTS[@]}"
  )

  BATS_COMMAND="${command[*]}"
  BATS_GATHER="${gather_dir[*]}"
  BATS_OUTPUT="${output_dir[*]}"

  if $list; then
    printarr "${BATS_TESTS[@]}" | sed "s|$(pwd)/||"
  elif $dry; then
    echo BATS_GATHER="${BATS_GATHER}" BATS_OUTPUT="${BATS_OUTPUT}" BATS_TEST_DIR="${directory}" "${command[@]}"
  else
    BATS_TEST_DIR="${directory}" "${command[@]}"
  fi

  if $verbose; then
    echo >&2 BATS_GATHER: "${gather_dir[*]}"
    echo >&2 BATS_OUTPUT: "${output_dir[*]}"
  fi
}

_main "$@"
