#!/usr/bin/env zsh

# Utility function tests for aporia.zsh-theme
# Usage: zsh tests/test_utils.zsh

SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)
export HOME="/tmp/aporia-utils-test"
mkdir -p "$HOME"
cd "$HOME"

# Source the theme
source "$SOURCE_DIR/aporia.zsh-theme"

_pass=0; _fail=0
assert() {
  if eval "$1" &>/dev/null; then
    (( _pass++ )); echo "  ✓ $2"
  else
    (( _fail++ )); echo "  ✗ $2"
  fi
}

echo "Running Utility Function Tests...\n"

# 1. _ap_find_up recursion depth and HOME boundary
mkdir -p "$HOME/my-project/sub/dir"
touch "$HOME/my-project/package.json"

pushd "$HOME/my-project/sub/dir" > /dev/null
assert "_ap_find_up package.json" "_ap_find_up finds file in project root above current DIR"
popd > /dev/null

# 2. _ap_is_utf8 (basic check)
if [[ "$LANG" == *"UTF-8"* ]]; then
  assert "_ap_is_utf8" "Correctly detects UTF-8 locale"
fi

echo "\n$_pass passed, $_fail failed"
if [[ $_fail -eq 0 ]]; then
  exit 0
else
  exit 1
fi
