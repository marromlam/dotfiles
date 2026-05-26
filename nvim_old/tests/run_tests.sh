#!/usr/bin/env bash
# Run the full Neovim test suite using mini.test.
# Usage: bash tests/run_tests.sh [directory]
#
# When run from the repo root:
#   bash files/.config/nvim/tests/run_tests.sh
# Or from the nvim config root:
#   bash tests/run_tests.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_DIR="${1:-$SCRIPT_DIR}"

cd "$NVIM_ROOT"

echo "Running tests in: $TEST_DIR"
echo "Neovim config root: $NVIM_ROOT"

nvim --headless --noplugin -u "$SCRIPT_DIR/minimal_init.lua" \
  -c "lua require('mini.test').run({ execute = { reporter = require('mini.test').gen_reporter.stdout({ group_depth = 2 }) } })" \
  -c "qa!"
