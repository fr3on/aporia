# aporia/plugins/cpanel/cpanel.zsh
# Contextual Intelligence for cPanel Environments

AP_C_CPANEL=${AP_C_CPANEL:-208}   # cPanel Orange (Standard)
_AP_ICO_CPANEL="󰨿"               # Server/Panel Icon

_ap_cpanel_segment() {
  # [1] Detection: Check for cPanel markers
  # We look for the .cpanel directory or the /usr/local/cpanel binary path
  [[ -d $HOME/.cpanel || -d /usr/local/cpanel ]] || return

  # [2] Extraction: Identify the cPanel context
  local cp_user=$USER
  local cp_domain=""
  
  # Check for common cPanel metadata files in the user's home
  # This file often contains the primary domain name
  local domain_file="$HOME/.cpanel/datastore/_main_domain"
  if [[ -f $domain_file ]]; then
    cp_domain=$(< "$domain_file" 2>/dev/null)
  fi
  
  # Fallback: check if we can get it from the home directory structure (common on shared hosts)
  if [[ -z $cp_domain && $PWD =~ "/home/([^/]+)/public_html" ]]; then
     # If we are in public_html, we might be able to infer things, but keep it safe
     cp_domain="webroot"
  fi

  # [3] Output: Format the segment
  local out="%F{$AP_C_CPANEL}${_AP_ICO_CPANEL} ${cp_user}"
  [[ -n $cp_domain && $cp_domain != "unknown" ]] && out+="@${cp_domain}"
  
  echo "${out}%f"
}

_ap_cpanel_precmd() {
  # Avoid clutter: only show if we are actually in a cPanel-managed path 
  # or if the user is a standard cPanel user (UID >= 1000 and has .cpanel)
  [[ -d $HOME/.cpanel ]] || return
  
  local seg=$(_ap_cpanel_segment)
  if [[ -n $seg ]]; then
    # Insert at the beginning of RPROMPT to prioritize environment context
    RPROMPT="${seg} ${RPROMPT:-}"
  fi
}

# Register the hook
autoload -Uz add-zsh-hook
add-zsh-hook precmd _ap_cpanel_precmd
