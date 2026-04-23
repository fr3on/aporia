# aporia/plugins/gh-context/gh-context.zsh
# Source Intelligence: GitHub CLI Identity

AP_C_GH=${AP_C_GH:-255}             # White (Matching GitHub Logo)
_AP_ICO_GH="󰊤"                     # GitHub Icon

_ap_gh_segment() {
  # [1] Detection: check for gh binary
  (( $+commands[gh] )) || return

  # [2] Extraction: Get active user
  # We try to use a fast check if possible, or cache it
  local gh_user=""
  
  # Check if GH_USER is set manually (for performance)
  if [[ -n $GH_USER ]]; then
    gh_user=$GH_USER
  else
    # Fallback to gh auth status (can be slow, ideally we should async this but for now we keep it simple)
    # We only run this if we are in a git repo to avoid unnecessary calls?
    # Or just run it once and cache?
    # For now, let's look for the config file presence as a fast gate
    local gh_config="$HOME/.config/gh/config.yml"
    [[ -f $gh_config ]] || return

    # Parse user from gh auth status -- show only the active account
    gh_user=$(gh auth status 2>&1 | grep "Logged in to github.com as" | awk '{print $NF}' | tr -d '()')
  fi

  [[ -z $gh_user ]] && return

  echo "%F{$AP_C_GH}${_AP_ICO_GH} ${gh_user}%f"
}

_ap_gh_precmd() {
  local seg=$(_ap_gh_segment)
  if [[ -n $seg ]]; then
    RPROMPT="${seg} ${RPROMPT:-}"
  fi
}

# Register the hook
autoload -Uz add-zsh-hook
add-zsh-hook precmd _ap_gh_precmd
