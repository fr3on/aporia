# aporia/plugins/gcp-ctx/gcp-ctx.zsh
# Cloud Intelligence: Google Cloud Project Context

AP_C_GCP=${AP_C_GCP:-69}            # GCP Blue/Google Colors
_AP_ICO_GCP="󱇶"                     # Google Cloud Icon

_ap_gcp_segment() {
  # [1] Detection: check for gcloud binary and config
  (( $+commands[gcloud] )) || return
  [[ -d $HOME/.config/gcloud ]] || return

  # [2] Extraction: Get active project
  # Reading from active_config file is faster
  local config_dir="$HOME/.config/gcloud"
  local active_config_file="$config_dir/active_config"
  [[ -f $active_config_file ]] || return
  
  local active_config=$(< "$active_config_file")
  local project_file="$config_dir/configurations/config_$active_config"
  
  local project=""
  if [[ -f $project_file ]]; then
    project=$(grep "^project =" "$project_file" | cut -d'=' -f2 | tr -d ' ')
  fi

  [[ -z $project ]] && return

  echo "%F{$AP_C_GCP}${_AP_ICO_GCP} ${project}%f"
}

_ap_gcp_precmd() {
  local seg=$(_ap_gcp_segment)
  if [[ -n $seg ]]; then
    RPROMPT="${seg} ${RPROMPT:-}"
  fi
}

# Register the hook
autoload -Uz add-zsh-hook
add-zsh-hook precmd _ap_gcp_precmd
