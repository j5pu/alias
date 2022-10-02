#!/usr/bin/env bash

. "$(dirname "${BASH_SOURCE[0]}")/utils.bash"

# <html><h2>Bats Description Array</h2>
# <p><strong><code>$BATS_ARRAY</code></strong> created by bats::array() with $BATS_TEST_DESCRIPTION.</p>
# </html>
export BATS_ARRAY=()

# Docker Context for Container Tests (default: macOS or default for Linux)
#
export BATS_DOCKER_CONTEXT

# <html><h2>Array with Bats Libs Functions and Helper Functions Provided by bats/bats.sh</h2>
# <p><strong><code>$BATS_FUNCTIONS</code></strong> created by bats::array() with $BATS_TEST_DESCRIPTION.</p>
# </html>
export BATS_FUNCTIONS

# Bats Libs Repositories
#
export BATS_LIBS="bats-assert bats-file bats-support"

# Run only local tests when set to 1, otherwise run container tests (Default: 0 when isaction is true).
#
: "${BATS_LOCAL=0}"; export BATS_LOCAL

# <html><h2>Saved $INFOPATH on First Suite Test Start after bats::env</h2>
# <p><strong><code>$BATS_INFOPATH</code></strong></p>
# </html>
export BATS_SAVED_INFOPATH

# <html><h2>Saved $MANPATH on First Suite Test Start after bats::env</h2>
# <p><strong><code>$BATS_MANPATH</code></strong></p>
# </html>
export BATS_SAVED_MANPATH

# <html><h2>Saved $PATH on First Suite Test Start after bats::env</h2>
# <p><strong><code>$BATS_SAVED_PATH</code></strong>bats-core adds bats-core libexec</p>
# </html>
export BATS_SAVED_PATH

# Verbose show Docker Command.
#
: "${BATS_SHOW_DOCKER_COMMAND=0}"; export BATS_SHOW_DOCKER_COMMAND

# <html><h2>Start $INFOPATH on First Suite Test Start</h2>
# <p><strong><code>$BATS_INFOPATH</code></strong></p>
# </html>
export BATS_START_INFOPATH="${INFOPATH}"

# <html><h2>Start $MANPATH on First Suite Test Start</h2>
# <p><strong><code>$BATS_MANPATH</code></strong></p>
# </html>
export BATS_START_MANPATH="${MANPATH}"

# <html><h2>Start $PATH on First Suite Test Start</h2>
# <p><strong><code>$BATS_START_PATH</code></strong></p>
# </html>
export BATS_START_PATH="${PATH}"

# Output directory to write gathered tests results
#
export BATS_OUTPUT="${HOME}/.local/log/bats"; mkdir -p "${BATS_OUTPUT}"

# Bats Core and Bats Libs Repositories
#
export BATS_REPOS="bats-core ${BATS_LIBS}"

# <html><h2>Bats Remote and Local Repository Array</h2>
# <p><strong><code>$BATS_REMOTE</code></strong> created by bats::remote(), [0] repo, [1] remote.</p>
# </html>
export BATS_REMOTE=()

# Installation Directory for bats-core and bats libs
#
export BATS_SHARE="${HOME}/.local/share"; mkdir -p "${BATS_SHARE}"

# <html><h2>Git Top Path</h2>
# <p><strong><code>$BATS_TOP</code></strong> contains the git top directory using $PWD.</p>
# </html>
BATS_TOP="$(git rev-parse --show-toplevel 2>/dev/null || true)"; export BATS_TOP

# Bats Core executable path
#
export BATS_EXECUTABLE="${BATS_SHARE}/bats-core/bin/bats"

# <html><h2>Git Top Basename</h2>
# <p><strong><code>$BATS_TOP_NAME</code></strong> basename of git top directory when sourced from a git dir.</p>
# </html>
export BATS_BASENAME="${BATS_TOP##*/}"

export INFOPATH

export MANPATH
