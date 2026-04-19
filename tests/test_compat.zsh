#!/usr/bin/env zsh

# Compatibility tests for aporia.zsh-theme
# Usage: zsh tests/test_compat.zsh

_pass=0; _fail=0
assert() {
  if eval "$1" &>/dev/null; then
    (( _pass++ )); echo "  ✓ $2"
  else
    (( _fail++ )); echo "  ✗ $2"
  fi
}

echo "Running Compatibility Tests...\n"

SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)
source "$SOURCE_DIR/aporia.zsh-theme"

# 1. zsh version
ZSH_VERSION_INSTALLED=$(zsh --version | awk '{print $2}')
assert "[[ -n $ZSH_VERSION_INSTALLED ]]" "Zsh is installed ($ZSH_VERSION_INSTALLED)"
assert "is-at-least 5.8" "Zsh version is 5.8+"

# 2. add-zsh-hook
autoload -Uz add-zsh-hook
assert "(( $+functions[add-zsh-hook] ))" "add-zsh-hook is available"

# 3. zsh/datetime
assert "zmodload zsh/datetime" "zsh/datetime module loads"
assert "[[ $(_ap_now) -gt 1700000000 ]]" "_ap_now returns a valid epoch"

# 4. PATH dependencies
assert "command -v git" "git is in PATH"
assert "command -v uname" "uname is in PATH"

# 5. OS Detection
OS=$(uname -s)
echo "  Platform: $OS"

echo "\n$_pass passed, $_fail failed"
if [[ $_fail -eq 0 ]]; then
  exit 0
else
  exit 1
fi
