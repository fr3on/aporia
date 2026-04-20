#!/usr/bin/env zsh

# Language detection tests for aporia.zsh-theme
# Usage: zsh tests/test_languages.zsh

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Mock binary setup - DO THIS FIRST before sourcing theme
MOCK_BIN_DIR="/tmp/aporia-mock-bin"
rm -rf "$MOCK_BIN_DIR"
mkdir -p "$MOCK_BIN_DIR"
export PATH="$MOCK_BIN_DIR:$PATH"

create_mock() {
  local cmd=$1
  local output=$2
  echo "#!/bin/sh" > "$MOCK_BIN_DIR/$cmd"
  echo "echo \"$output\"" >> "$MOCK_BIN_DIR/$cmd"
  chmod +x "$MOCK_BIN_DIR/$cmd"
}

create_mock "node" "v20.10.0"
create_mock "rustc" "rustc 1.75.0"
create_mock "go" "go version go1.21.5"
create_mock "ruby" "3.3.0"
create_mock "php" "PHP 8.3.1"
create_mock "c++" "Apple clang version 15.0.0"

# Java prints to stderr
echo "#!/bin/sh" > "$MOCK_BIN_DIR/java"
echo 'echo "openjdk version \"21.0.1\"" >&2' >> "$MOCK_BIN_DIR/java"
chmod +x "$MOCK_BIN_DIR/java"

SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)
export HOME="/tmp/aporia-lang-test"
rm -rf "$HOME"
mkdir -p "$HOME"
cd "$HOME"

# Source the theme
source "$SOURCE_DIR/aporia.zsh-theme"

_pass=0; _fail=0
assert() {
  local result=$(eval "$1" 2>&1)
  local exit_code=$?
  if [[ $exit_code -eq 0 ]]; then
    (( _pass++ )); echo "  ✓ $2"
  else
    (( _fail++ )); echo "  ✗ $2 (Result: $result)"
  fi
}

echo "Running Language Detection Tests...\n"

# 1. Node.js
mkdir -p "$HOME/node-app"
cd "$HOME/node-app"
touch package.json
_ap_lang_cache_pwd="" # Clear cache for safety
_ap_lang_info
assert "[[ \"\$_ap_lang_cache_val\" == *\"v20.10.0\"* ]]" "Detects Node.js version"

# 2. Rust
mkdir -p "$HOME/rust-app"
cd "$HOME/rust-app"
touch Cargo.toml
_ap_lang_cache_pwd=""
_ap_lang_info
assert "[[ \"\$_ap_lang_cache_val\" == *\"1.75.0\"* ]]" "Detects Rust version"

# 3. Go
mkdir -p "$HOME/go-app"
cd "$HOME/go-app"
touch go.mod
_ap_lang_cache_pwd=""
_ap_lang_info
assert "[[ \"\$_ap_lang_cache_val\" == *\"1.21.5\"* ]]" "Detects Go version"

# 4. Ruby
mkdir -p "$HOME/ruby-app"
cd "$HOME/ruby-app"
touch Gemfile
_ap_lang_cache_pwd=""
_ap_lang_info
assert "[[ \"\$_ap_lang_cache_val\" == *\"3.3.0\"* ]]" "Detects Ruby version"

# 5. PHP
mkdir -p "$HOME/php-app"
cd "$HOME/php-app"
touch composer.json
_ap_lang_cache_pwd=""
_ap_lang_info
assert "[[ \"\$_ap_lang_cache_val\" == *\"8.3.1\"* ]]" "Detects PHP version"

# 6. Java
mkdir -p "$HOME/java-app"
cd "$HOME/java-app"
touch pom.xml
_ap_lang_cache_pwd=""
_ap_lang_info
assert "[[ \"\$_ap_lang_cache_val\" == *\"21.0.1\"* ]]" "Detects Java version"

# 7. C++ (CMake + files)
mkdir -p "$HOME/cpp-app"
cd "$HOME/cpp-app"
touch CMakeLists.txt
_ap_lang_cache_pwd=""
_ap_lang_info
assert "[[ \"\$_ap_lang_cache_val\" == *\"15.0.0\"* ]]" "Detects C++ via CMakeLists.txt"
rm CMakeLists.txt
touch main.cpp
_ap_lang_cache_pwd=""
_ap_lang_info
assert "[[ \"\$_ap_lang_cache_val\" == *\"15.0.0\"* ]]" "Detects C++ via .cpp file glob"

# 8. Python Venv
VIRTUAL_ENV="/home/user/my-venv"
_ap_lang_cache_pwd=""
_ap_lang_info
assert "[[ \"\$_ap_lang_cache_val\" == *\"my-venv\"* ]]" "Detects Python Venv from VIRTUAL_ENV"
unset VIRTUAL_ENV

# 9. Language Cache Verification
mkdir -p "$HOME/cache-test"
cd "$HOME/cache-test"
touch package.json
_ap_lang_info > /dev/null
assert "[[ \"\$_ap_lang_cache_pwd\" == \"_${PWD}\" ]]" "Cache PWD is set correctly"
_ap_lang_info
local first_call=$_ap_lang_cache_val
_ap_lang_info
local second_call=$_ap_lang_cache_val
assert "[[ \"\$first_call\" == \"\$second_call\" ]]" "Returns cached value in same directory"
cd "$HOME"
_ap_lang_info
local third_call=$_ap_lang_cache_val
assert "[[ \"\$third_call\" != \"\$first_call\" ]]" "Cache updates on directory change"

echo "\n$_pass passed, $_fail failed"
if [[ $_fail -eq 0 ]]; then
  exit 0
else
  exit 1
fi
