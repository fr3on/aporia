#!/usr/bin/env zsh

# Prompt logic tests for aporia.zsh-theme
# Usage: zsh tests/test_prompt_logic.zsh

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export COLUMNS=120

SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)
export HOME="/tmp/aporia-prompt-test"
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

# Mock async for synchronous testing
_ap_async_request() {
  local key=$1 cmd=$2
  _AP_ASYNC_DATA[$key]=$(eval "$cmd")
}

echo "Running Prompt Logic Tests...\n"

# 1. SSH Context
SSH_CONNECTION="192.168.1.1 1234 192.168.1.2 22"
_ap_build_prompt
assert "[[ \"$PROMPT\" == *\"@\"* ]]" "Shows user@host in SSH session"
unset SSH_CONNECTION

# 2. Root User Safety Mode
export _AP_UID=0
_ap_build_prompt
# When root, _AP_ICO_PROMPT becomes _AP_ICO_OS
assert "[[ \"$PROMPT\" == *\"$_AP_ICO_OS\"* ]]" "Shows OS icon as prompt for root user"
unset _AP_UID # back to normal

# 3. Exit Code Coloring
false # set $? to 1
_ap_build_prompt
assert "[[ \"$PROMPT\" == *\"%F{$AP_C_RED}\"* ]]" "Prompt character turns RED on failure"

true # set $? to 0
_ap_build_prompt
assert "[[ \"$PROMPT\" == *\"%F{$AP_C_GREEN}\"* ]]" "Prompt character turns GREEN on success"

# 4. Segment Toggles
AP_SHOW_TIME=0
_ap_build_prompt
assert "[[ \"$RPROMPT\" != *\"%D{\"* ]]" "Hides clock when AP_SHOW_TIME=0"

AP_SHOW_TIME=1
_ap_build_prompt
assert "[[ \"$RPROMPT\" == *\"%D{\"* ]]" "Shows clock when AP_SHOW_TIME=1"

# 5. Adaptive Width (RPROMPT reduction)
COLUMNS=40
_ap_build_prompt
# At 40 cols, time (needs 80), langs (needs 100), exec_time (needs 60) should hide
assert "[[ -z \"$RPROMPT\" ]]" "Hides RPROMPT segments in narrow terminal (40 cols)"

# 6. Flat Design Check (No background colors on left)
# We check if Directory, Venv, and Git segments contain %K
_ap_build_prompt
# The OS branding might have a background if SSH is active, but we unset it
# So LEFT should have NO %K
assert "[[ \"$PROMPT\" != *\"%K{\"* ]]" "Left side (PROMPT) uses flat design (no background colors)"

echo "\n$_pass passed, $_fail failed"
if [[ $_fail -eq 0 ]]; then
  exit 0
else
  exit 1
fi
