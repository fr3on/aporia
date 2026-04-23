# aporia/plugins/docker-ctx/docker-ctx.zsh

AP_C_DOCKER=${AP_C_DOCKER:-75}   # docker blue #5fafff

_ap_docker_ctx_segment() {
  # If theme already showed it on the left, skip right-side segment
  [[ -n ${_AP_DOCKER_CONTEXT:-} ]] && return

  # Only show when inside a Docker project
  _ap_find_up "docker-compose.yml" "docker-compose.yaml" "Dockerfile" || return

  # Read current context from config file — no subprocess
  local cfg="$HOME/.docker/config.json"
  local ctx="default"
  if [[ -f $cfg ]]; then
    ctx=$(command awk -F'"' '/"currentContext"/{print $4; exit}' "$cfg")
    [[ -z $ctx ]] && ctx="default"
  fi

  echo "%F{$AP_C_DOCKER} $ctx%f"
}

# Hook into RPROMPT via precmd
_ap_docker_ctx_precmd() {
  local seg=$(_ap_docker_ctx_segment)
  [[ -n $seg ]] && RPROMPT="$seg ${RPROMPT:-}"
}

add-zsh-hook precmd _ap_docker_ctx_precmd
