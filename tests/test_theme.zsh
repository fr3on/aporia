#!/usr/bin/env zsh

# Unit tests for Aporia Theme Presets
# Usage: zsh tests/test_theme.zsh

SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)
source "$SOURCE_DIR/aporia.zsh-theme"

_pass=0; _fail=0
assert() {
  if eval "$1" &>/dev/null; then
    (( _pass++ )); echo "  ✓ $2"
  else
    (( _fail++ )); echo "  ✗ $2"
  fi
}

echo "Running Theme Preset Tests...\n"

# Helper to reset colors
_reset_colors() {
  unset AP_C_BG0 AP_C_BG1 AP_C_BG2 AP_C_BG3 AP_C_WHITE AP_C_BLUE AP_C_GREEN AP_C_YELLOW AP_C_RED AP_C_ORANGE AP_C_PURPLE AP_C_CYAN AP_C_GRAY
}

# 1. Default Theme (deep_blue)
unset AP_THEME
_reset_colors
_ap_apply_theme
assert "[[ $AP_C_BLUE -eq 39 ]]" "Default theme uses electric blue (39)"
assert "[[ $AP_C_BG0 -eq 232 ]]" "Default theme uses near-black background (232)"

# 2. Light Theme
export AP_THEME="light"
_reset_colors
_ap_apply_theme
assert "[[ $AP_C_BLUE -eq 25 ]]" "Light theme uses navy blue (25)"
assert "[[ $AP_C_BG0 -eq 255 ]]" "Light theme uses white background (255)"

# 3. Amber Theme
export AP_THEME="amber"
_reset_colors
_ap_apply_theme
assert "[[ $AP_C_BLUE -eq 109 ]]" "Amber theme uses dusty blue (109)"
assert "[[ $AP_C_YELLOW -eq 214 ]]" "Amber theme uses amber yellow (214)"

echo "\n$_pass passed, $_fail failed"
[[ $_fail -eq 0 ]] && exit 0 || exit 1
