#!/usr/bin/env zsh

# Bundled plugin functional tests for aporia.zsh-theme
# Usage: zsh tests/test_bundled_plugins.zsh

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)
export HOME="/tmp/aporia-bundled-plugins-test"
rm -rf "$HOME"
mkdir -p "$HOME"
cd "$HOME"

# Source the theme and plugin loader
source "$SOURCE_DIR/aporia.zsh-theme"
source "$SOURCE_DIR/aporia.plugin.zsh"

_pass=0; _fail=0
assert() {
  local cmd=$1
  local msg=$2
  local out
  out=$(eval "$cmd" 2>&1)
  if [[ $? -eq 0 ]]; then
    (( _pass++ )); echo "  ✓ $msg"
  else
    (( _fail++ )); echo "  ✗ $msg"
    echo "    Command: $cmd"
    echo "    Output: $out"
  fi
}

echo "Running Bundled Plugin Functional Tests...\n"

# 1. Sudo Plugin
_ap_plugin_source sudo
BUFFER="apt update"
_ap_sudo_plugin
assert '[[ "$BUFFER" == "sudo apt update" ]]' "Sudo plugin prepends 'sudo' to current buffer"
_ap_sudo_plugin
assert '[[ "$BUFFER" == "apt update" ]]' "Sudo plugin toggles 'sudo' off"

# 2. Docker Context
_ap_plugin_source docker-ctx
mkdir -p "$HOME/.docker"
echo '{"currentContext":"test-context"}' > "$HOME/.docker/config.json"
# Triggers docker-ctx: find a Dockerfile
touch "$HOME/Dockerfile"
assert '[[ $(_ap_docker_ctx_segment) == *"test-context"* ]]' "Docker-ctx plugin identifies context from config"

# 3. AWS Profile
_ap_plugin_source aws-profile
export AWS_PROFILE="prod-account"
export AWS_DEFAULT_REGION="us-east-1"
assert '[[ $(_ap_aws_segment) == *"prod-account"* && $(_ap_aws_segment) == *"us-east-1"* ]]' "AWS-profile plugin shows profile and region"
assert '[[ $(_ap_aws_segment) == *"%F{$AP_C_AWS_DANGER}"* ]]' "AWS-profile plugin uses danger color for 'prod' profiles"
unset AWS_PROFILE AWS_DEFAULT_REGION

# 4. Kube Context
_ap_plugin_source kube-ctx
# Mock kubectl to enable the segment
kubectl() { : }
mkdir -p "$HOME/.kube"
cat > "$HOME/.kube/config" <<EOF
current-context: dev-cluster
contexts:
- name: dev-cluster
  context:
    namespace: my-namespace
EOF
assert '[[ $(_ap_kube_ctx_segment) == *"dev-cluster:my-namespace"* ]]' "Kube-ctx plugin extracts context and namespace"

# 5. Nix Shell
_ap_plugin_source nix-shell
export IN_NIX_SHELL="pure"
export name="my-nix-pkg"
assert '[[ $(_ap_nix_segment) == *"my-nix-pkg"* ]]' "Nix-shell plugin identifies shell name from env"
unset IN_NIX_SHELL name

echo "\n$_pass passed, $_fail failed"
if [[ $_fail -eq 0 ]]; then
  exit 0
else
  exit 1
fi
