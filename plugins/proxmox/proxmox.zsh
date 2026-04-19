# aporia/plugins/proxmox/proxmox.zsh

AP_C_PROXMOX=${AP_C_PROXMOX:-208}   # Proxmox Orange/Coral

_ap_proxmox_segment() {
  local label=""
  
  # 1. Host Detection (Are we running on a Proxmox hardware node?)
  if [[ -d /etc/pve ]]; then
    label="PVE Host"
  elif (( $+commands[pveversion] )); then
    label="PVE Node"
  # 2. Guest Detection (Are we inside a Proxmox-managed VM?)
  elif [[ -f /sys/class/dmi/id/product_name ]]; then
    if grep -q "Proxmox" /sys/class/dmi/id/product_name 2>/dev/null; then
      label="PVE Guest"
    fi
  fi

  [[ -z $label ]] && return

  # Use the Manjaro-like stylized P icon (󱘊) or a generic server icon (󰒄)
  # Aporia preference: 󱘊 for PVE matches the branding silhouette
  echo "%F{$AP_C_PROXMOX}󱘊 $label%f"
}

_ap_proxmox_precmd() {
  local seg=$(_ap_proxmox_segment)
  [[ -n $seg ]] && RPROMPT="$seg ${RPROMPT:-}"
}

# Ensure hooks are available
autoload -Uz add-zsh-hook
add-zsh-hook precmd _ap_proxmox_precmd
