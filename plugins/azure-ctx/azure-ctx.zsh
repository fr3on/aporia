# aporia/plugins/azure-ctx/azure-ctx.zsh
# Cloud Intelligence: Azure Subscription Context

AP_C_AZURE=${AP_C_AZURE:-33}         # Azure Blue
_AP_ICO_AZURE="󰠅"                    # Azure Icon

_ap_azure_segment() {
  # [1] Detection: check for az binary and config
  (( $+commands[az] )) || return
  [[ -d $HOME/.azure ]] || return

  # [2] Extraction: Get active subscription
  # Parsing the local config file (~/.azure/azureProfile.json) is much faster than running 'az account show'
  local profile_file="$HOME/.azure/azureProfile.json"
  [[ -f $profile_file ]] || return

  local sub_name=""
  # Simple grep/sed parsing to avoid 'jq' dependency
  sub_name=$(grep -A 5 '"isDefault": true' "$profile_file" | grep '"name":' | head -n 1 | cut -d'"' -f4)

  [[ -z $sub_name ]] && return

  echo "%F{$AP_C_AZURE}${_AP_ICO_AZURE} ${sub_name}%f"
}

_ap_azure_precmd() {
  local seg=$(_ap_azure_segment)
  if [[ -n $seg ]]; then
    RPROMPT="${seg} ${RPROMPT:-}"
  fi
}

# Register the hook
autoload -Uz add-zsh-hook
add-zsh-hook precmd _ap_azure_precmd
