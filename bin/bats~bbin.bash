#!/usr/bin/env bash

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
