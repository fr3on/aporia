# aporia/plugins/gh-context/gh-context.zsh
# Source Intelligence: GitHub CLI Identity

AP_C_GH=${AP_C_GH:-255}             # White (Matching GitHub Logo)
_AP_ICO_GH="󰊤"                     # GitHub Icon

_ap_gh_segment() {
  # [1] Detection: check for gh binary
  (( $+commands[gh] )) || return

  local gh_user=""
  local cache_file="/tmp/aporia_gh_user_$$"
  local config_file="$HOME/.config/gh/config.yml"
  
  # [2] Cache Check: try to avoid running 'gh' if we already know the user
  # We use a session-based temp file for speed
  if [[ -f $cache_file ]]; then
    gh_user=$(cat "$cache_file")
  else
    # Fast path: check if logged in via config file existence
    [[ -f $config_file ]] || return

    # Parse user from gh auth status -- show only the active account
    # This is still the "heavy" part, but it's now async
    gh_user=$(command gh auth status 2>&1 | grep "Logged in to github.com as" | awk '{print $NF}' | tr -d '()')
    
    if [[ -n $gh_user ]]; then
      echo -n "$gh_user" > "$cache_file"
    fi
  fi

  [[ -z $gh_user ]] && return

  echo "%F{$AP_C_GH}${_AP_ICO_GH} ${gh_user}%f"
}

# Register with Aporia's async engine
if (( $+functions[aporia_register_async] )); then
  aporia_register_async "gh_ctx" "_ap_gh_segment"
else
  # Fallback for older theme versions
  autoload -Uz add-zsh-hook
  _ap_gh_precmd() {
    local seg=$(_ap_gh_segment)
    [[ -n $seg ]] && RPROMPT="${seg} ${RPROMPT:-}"
  }
  add-zsh-hook -d precmd _ap_gh_precmd 2>/dev/null
  add-zsh-hook precmd _ap_gh_precmd
fi
