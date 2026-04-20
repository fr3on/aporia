#!/usr/bin/env zsh

# Unit tests for Aporia Docker context segment
# Usage: zsh tests/test_docker.zsh

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)
export HOME="/tmp/aporia-docker-test"
mkdir -p "$HOME/bin"
export PATH="$HOME/bin:$PATH"

# Create a mock docker script that handles 'context show'
cat <<EOF > "$HOME/bin/docker"
#!/usr/bin/env zsh
if [[ \$1 == "context" && \$2 == "show" ]]; then
  echo "\$MOCK_DOCKER_CONTEXT"
else
  # Fallback to real docker if needed, but not for these tests
  exit 0
fi
EOF
chmod +x "$HOME/bin/docker"

# Source theme
source "$SOURCE_DIR/aporia.zsh-theme"

_pass=0; _fail=0
assert() {
  if eval "$1" &>/dev/null; then
    (( _pass++ )); echo "  ✓ $2"
  else
    (( _fail++ )); echo "  ✗ $2"
  fi
}

echo "Running Docker Context Tests...\n"

# 1. Default context (should be hidden)
export MOCK_DOCKER_CONTEXT="default"
unset _ap_docker_cache _ap_docker_cache_pwd
assert "[[ -z \"$(_ap_docker_info)\" ]]" "Ignores 'default' docker context"

# 2. Custom context
export MOCK_DOCKER_CONTEXT="remote-prod"
unset _ap_docker_cache _ap_docker_cache_pwd
assert "[[ \"$(_ap_docker_info)\" == \"remote-prod\" ]]" "Detects custom docker context (remote-prod)"

echo "\n$_pass passed, $_fail failed"
[[ $_fail -eq 0 ]] && exit 0 || exit 1
