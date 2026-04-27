# aporia/plugins/vpn-status/vpn-status.zsh
# Network Intelligence: VPN & Tunnel Monitoring

AP_C_VPN=${AP_C_VPN:-39}           # Deep Blue/Cyan
_AP_ICO_VPN_ON="󰖂"                # Connected Icon
_AP_ICO_VPN_OFF="󰖀"               # Disconnected Icon
_AP_ICO_TAILSCALE="󰆟"             # Tailscale Icon

_ap_vpn_segment() {
  local vpn_type=""
  local vpn_name=""
  local vpn_active="off"

  # [1] Detection: Tailscale
  if (( $+commands[tailscale] )); then
    if tailscale status --peers=false >/dev/null 2>&1; then
      vpn_type="tailscale"
      vpn_active="on"
      vpn_name="Tailscale"
    fi
  fi

  # [2] Detection: Mullvad
  if [[ $vpn_active == "off" ]] && (( $+commands[mullvad] )); then
    local m_status=$(mullvad status 2>/dev/null)
    if [[ $m_status == *"Connected"* ]]; then
      vpn_type="mullvad"
      vpn_active="on"
      vpn_name="Mullvad"
    fi
  fi

  # [3] Detection: Generic Tunnels (tun/wg)
  if [[ $vpn_active == "off" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS: Check for utun interfaces commonly used by VPNs
      if ifconfig | grep -q "utun[0-9]"; then
        vpn_type="generic"
        vpn_active="on"
        vpn_name="VPN"
      fi
    else
      # Linux: Check for tun/wg/tap
      if ip link show | grep -qE "tun[0-9]|wg[0-9]|tap[0-9]"; then
        vpn_type="generic"
        vpn_active="on"
        vpn_name="VPN"
      fi
    fi
  fi

  # [4] Output
  if [[ $vpn_active == "on" ]]; then
    local icon=$_AP_ICO_VPN_ON
    [[ $vpn_type == "tailscale" ]] && icon=$_AP_ICO_TAILSCALE
    echo "%F{$AP_C_VPN}${icon} ${vpn_name}%f"
  fi
}

if (( $+functions[aporia_register_async] )); then
  aporia_register_async "vpn-status" "_ap_vpn_segment"
else
  _ap_vpn_precmd() {
    local seg=$(_ap_vpn_segment)
    if [[ -n $seg ]]; then
      # Insert before other segments in RPROMPT
      RPROMPT="${seg} ${RPROMPT:-}"
    fi
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _ap_vpn_precmd
fi
