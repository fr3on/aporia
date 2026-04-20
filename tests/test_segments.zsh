#!/usr/bin/env zsh

# Unit tests for aporia.zsh-theme segments
# Usage: zsh tests/test_segments.zsh

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)
export HOME="/tmp/aporia-test-home-3"
mkdir -p "$HOME"
cd "$HOME"

source "$SOURCE_DIR/aporia.zsh-theme"

# Unregister hooks
add-zsh-hook -d precmd _ap_build_prompt
add-zsh-hook -d preexec _ap_preexec

_pass=0; _fail=0
assert() {
  local res
  res=$(eval "$1" 2>&1)
  if [[ $? -eq 0 ]]; then
    (( _pass++ )); echo "  ✓ $2"
  else
    (( _fail++ )); echo "  ✗ $2 (Result: $res)"
  fi
}

echo "Running Segment Tests...\n"

# 1. _ap_find_up
mkdir -p "$HOME/proj/sub"
touch "$HOME/proj/Cargo.toml"
(cd "$HOME/proj/sub" && assert "_ap_find_up Cargo.toml" "Finds Cargo.toml in parent directory")
assert "! _ap_find_up nonexistent.file" "Returns 1 for non-existent file"

# 2. _ap_calc_exec_time
AP_EXEC_TIME_THRESHOLD=2
_ap_now() { echo "$current_time" }
current_time=1000
_ap_cmd_start=995
_ap_calc_exec_time
assert "[[ -n \"$_ap_last_exec_time\" ]]" "Calculates time for > threshold"
_ap_cmd_start=999
_ap_calc_exec_time
assert "[[ -z \"$_ap_last_exec_time\" ]]" "Returns empty for < threshold"

# 3. _ap_git_info (with stashes)
mkdir -p "$HOME/git-repo"
cd "$HOME/git-repo"
command git init -q
command git config user.email "test@example.com"
command git config user.name "Test User"

# In a fresh repo, it should show the branch name (e.g. main/master)
local git_init_out=$(_ap_git_info)
assert "[[ \"$git_init_out\" != \"NONE\" ]]" "Git info identifies repo even without commits"

# After first commit
touch initial-file && command git add initial-file && command git commit -m "initial" -q
local git_commit_out=$(_ap_git_info)
assert "[[ \"$git_commit_out\" == *\"main\"* || \"$git_commit_out\" == *\"master\"* ]]" "Git info shows branch name after commit"

# Stash detection
echo "stash-me" > stash-file
command git add stash-file
command git stash push -m "test stash" &>/dev/null
local git_stash_out=$(_ap_git_info)
assert "[[ \"$git_stash_out\" == *\"${_AP_ICO_STASH}1\"* ]]" "Git info shows stash count (1)"

# 4. _ap_venv_info
VIRTUAL_ENV="/home/user/venv/my-env"
assert "[[ \"$(_ap_venv_info)\" == \"my-env\" ]]" "Detects VIRTUAL_ENV name"
unset VIRTUAL_ENV
CONDA_DEFAULT_ENV="conda-env"
assert "[[ \"$(_ap_venv_info)\" == \"conda-env\" ]]" "Detects CONDA_DEFAULT_ENV name"
unset CONDA_DEFAULT_ENV

echo "\n$_pass passed, $_fail failed"
[[ $_fail -eq 0 ]] && exit 0 || exit 1
