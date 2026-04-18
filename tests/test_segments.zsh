#!/usr/bin/env zsh

# Unit tests for aporia.zsh-theme segments
# Usage: zsh tests/test_segments.zsh

# Ensure UTF-8 locale for characters
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Path setup
SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)

# Mock setup
export HOME="/tmp/aporia-test-home"
mkdir -p "$HOME"
cd "$HOME"

# Source the theme
source "$SOURCE_DIR/aporia.zsh-theme"

# Unregister hooks to prevent interference during tests
add-zsh-hook -d precmd _ap_build_prompt
add-zsh-hook -d preexec _ap_preexec
add-zsh-hook -d precmd _ap_set_title
add-zsh-hook -d preexec _ap_set_title

_pass=0; _fail=0
assert() {
  if eval "$1" &>/dev/null; then
    (( _pass++ )); echo "  ✓ $2"
  else
    (( _fail++ )); echo "  ✗ $2"
  fi
}

echo "Running Segment Tests...\n"
zmodload zsh/datetime 2>/dev/null || true

# 1. _ap_find_up
mkdir -p "$HOME/proj/sub"
touch "$HOME/proj/Cargo.toml"
(cd "$HOME/proj/sub" && assert "_ap_find_up Cargo.toml" "Finds Cargo.toml in parent directory")
(cd "$HOME" && assert "! _ap_find_up Cargo.toml" "Does not find Cargo.toml in HOME root if it's outside")
assert "! _ap_find_up nonexistent.file" "Returns 1 for non-existent file"

# 2. _ap_calc_exec_time
AP_EXEC_TIME_THRESHOLD=2

# Mock time for predictability
_ap_now() { echo "$current_time" }
current_time=1000

_ap_cmd_start=995 # 5 seconds elapsed
_ap_calc_exec_time
assert "[[ -n \"$_ap_last_exec_time\" ]]" "Calculates time for > threshold"
assert "[[ \"$_ap_last_exec_time\" == *\"5s\"* ]]" "Formats seconds accurately"

_ap_cmd_start=999 # 1 second elapsed
_ap_calc_exec_time
assert "[[ -z \"$_ap_last_exec_time\" ]]" "Returns empty for < threshold"

# 3. Formatting time
current_time=5000
_ap_cmd_start=$(( 5000 - 3661 ))
_ap_calc_exec_time
assert "[[ \"$_ap_last_exec_time\" == *\"1h 1m 1s\"* ]]" "Formats hours/minutes/seconds correctly"

# 4. _ap_git_info (Mocking git commands is hard without a real repo)
mkdir -p "$HOME/git-repo"
cd "$HOME/git-repo"
command git init -q
assert "[[ -n \"$(_ap_git_info)\" ]]" "Git info returns data in a repo"
command git checkout -b test-branch &>/dev/null
assert "[[ \"$(_ap_git_info)\" == *\"test-branch\"* ]]" "Git info shows branch name"

# Dirty state test
touch dirty-file
assert "[[ \"$(_ap_git_info)\" == *\"${_AP_ICO_DIRTY}\"* ]]" "Git info marks dirty state with untracked file"
command git add dirty-file
assert "[[ \"$(_ap_git_info)\" == *\"${_AP_ICO_DIRTY}\"* ]]" "Git info marks dirty state with staged file"

# 5. ASCII Fallback
AP_ASCII_FALLBACK=1
# We need to re-source or re-evaluate the glyph logic
source "$SOURCE_DIR/aporia.zsh-theme"
assert "[[ \"$_AP_SEP_L\" == \">\" ]]" "Sets ASCII separators when AP_ASCII_FALLBACK=1"

echo "\n$_pass passed, $_fail failed"
if [[ $_fail -eq 0 ]]; then
  exit 0
else
  exit 1
fi
