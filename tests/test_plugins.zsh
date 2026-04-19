#!/usr/bin/env zsh

# Verification tests for Aporia Plugin System (v1.1.0)
# Usage: zsh tests/test_plugins.zsh

SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)
export HOME="/tmp/aporia-plugins-test"
mkdir -p "$HOME"
cd "$HOME"

# Mock current directory hook logic
_ap_plugin_source() {
  # We'll source the actual aporia.plugin.zsh but we need to mock some env
  source "$SOURCE_DIR/aporia.plugin.zsh"
}

# Source theme dependencies first (colors, etc)
source "$SOURCE_DIR/aporia.zsh-theme"

_pass=0; _fail=0
assert() {
  if eval "$1" &>/dev/null; then
    (( _pass++ )); echo "  ✓ $2"
  else
    (( _fail++ )); echo "  ✗ $2"
  fi
}

echo "Running Plugin System Verification Tests...\n"

# 1. Existence of helper functions
source "$SOURCE_DIR/aporia.plugin.zsh"
assert "(( $+functions[aporia-install-plugin] ))" "aporia-install-plugin is defined"
assert "(( $+functions[aporia-update-plugins] ))" "aporia-update-plugins is defined"
assert "(( $+functions[aporia-list-plugins] ))" "aporia-list-plugins is defined"

# 2. _ap_plugin_source returns 0 for bundled plugins (sudo, docker-ctx, etc)
# Note: we need to make sure the bundled path is correct
assert "_ap_plugin_source sudo" "_ap_plugin_source finds bundled sudo plugin"
assert "_ap_plugin_source docker-ctx" "_ap_plugin_source finds bundled docker-ctx plugin"

# 3. _ap_plugin_source returns 1 for unknown plugins
assert "! _ap_plugin_source unknown-plugin" "_ap_plugin_source returns 1 for unknown plugin"

# 4. Deferred Plugins logic
# Mock _ap_plugin_source to track call order
local -a call_order=()
_ap_plugin_source() {
  call_order+=("$1")
}

AP_PLUGINS=(fast-syntax-highlighting sudo fzf-tab aws-profile)
_ap_load_plugins

# Expected order: sudo, aws-profile, fast-syntax-highlighting, fzf-tab
assert "[[ \"${call_order[1]}\" == \"sudo\" ]]" "Non-deferred plugin 'sudo' loaded first"
assert "[[ \"${call_order[2]}\" == \"aws-profile\" ]]" "Non-deferred plugin 'aws-profile' loaded second"
assert "[[ \"${call_order[3]}\" == \"fast-syntax-highlighting\" ]]" "Deferred plugin 'fast-syntax-highlighting' loaded near end"
assert "[[ \"${call_order[4]}\" == \"fzf-tab\" ]]" "Deferred plugin 'fzf-tab' loaded last"

echo "\n$_pass passed, $_fail failed"
if [[ $_fail -eq 0 ]]; then
  exit 0
else
  exit 1
fi
