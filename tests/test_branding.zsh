#!/usr/bin/env zsh

# Branding tests for aporia.zsh-theme
# Usage: zsh tests/test_branding.zsh

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

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

# Mock uname for macOS test
uname() {
  if [[ "$1" == "-s" && "$_mock_uname_s" != "" ]]; then
    echo "$_mock_uname_s"
  else
    command uname "$@"
  fi
}

echo "Running OS Branding Tests...\n"

MOCK_OS_RELEASE="/tmp/aporia-os-release"
export _AP_OS_RELEASE="$MOCK_OS_RELEASE"
touch "$MOCK_OS_RELEASE"

# 1. macOS
_mock_uname_s="Darwin"
# Remove mock file so it falls through to uname check
rm -f "$MOCK_OS_RELEASE"
assert "[[ $(_ap_get_os_icon) == \"\" ]]" "Detects macOS Apple icon"

# 2. Linux Distros
_mock_uname_s="Linux"
touch "$MOCK_OS_RELEASE"

set_distro() { echo "ID=$1" > "$MOCK_OS_RELEASE"; }

set_distro "ubuntu"
assert "[[ $(_ap_get_os_icon) == \"󰕈\" ]]" "Detects Ubuntu icon"

set_distro "arch"
assert "[[ $(_ap_get_os_icon) == \"󰣇\" ]]" "Detects Arch icon"

set_distro "fedora"
assert "[[ $(_ap_get_os_icon) == \"󰣛\" ]]" "Detects Fedora icon"

set_distro "nixos"
assert "[[ $(_ap_get_os_icon) == \"󱄅\" ]]" "Detects NixOS icon"

set_distro "debian"
assert "[[ $(_ap_get_os_icon) == \"󰣚\" ]]" "Detects Debian icon"

set_distro "gentoo"
assert "[[ $(_ap_get_os_icon) == \"󰣨\" ]]" "Detects Gentoo icon"

# 3. Generic/Unknown
set_distro "unknown_linux"
assert "[[ $(_ap_get_os_icon) == \"󰌽\" ]]" "Detects generic Linux penguin for unknown distro"

echo "\n$_pass passed, $_fail failed"
if [[ $_fail -eq 0 ]]; then
  exit 0
else
  exit 1
fi
