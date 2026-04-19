# ╔═══════════════════════════════════════════════════════════╗
# ║  aporia.plugin.zsh — Plugin Registry & Loader             ║
# ║  Sourced by the theme after aporia.zsh-theme is loaded    ║
# ╚═══════════════════════════════════════════════════════════╝

# ── Plugin directory ────────────────────────────────────────
AP_PLUGIN_DIR="${AP_PLUGIN_DIR:-$HOME/.aporia/plugins}"

# ── User plugin list (set in ~/.zshrc before sourcing theme) ─
# Example: AP_PLUGINS=(history-substring-search autopair docker-ctx)
if [[ ${(t)AP_PLUGINS} != *array* ]]; then
  AP_PLUGINS=(${AP_PLUGINS:-})
fi
# Remove any empty elements that might cause "Unknown plugin ''" errors
AP_PLUGINS=(${AP_PLUGINS:#})

# ── Plugins that must load LAST (order-sensitive) ───────────
typeset -ga _AP_DEFERRED_PLUGINS=(fast-syntax-highlighting fzf-tab zsh-syntax-highlighting)

# ── Registry: plugin_name → upstream git URL ────────────────
typeset -gA _AP_PLUGIN_REGISTRY=(
  history-substring-search  "https://github.com/zsh-users/zsh-history-substring-search"
  autopair                  "https://github.com/hlissner/zsh-autopair"
  you-should-use            "https://github.com/MichaelAquilina/zsh-you-should-use"
  fast-syntax-highlighting  "https://github.com/zdharma-continuum/fast-syntax-highlighting"
  fzf-tab                   "https://github.com/Aloxaf/fzf-tab"
  fzf-history               "https://github.com/joshskidmore/zsh-fzf-history-search"
  docker-ctx                ""   # first-party — ships inside this repo
  kube-ctx                  ""   # first-party
  aws-profile               ""   # first-party
  autoswitch-venv           "https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv"
  nix-shell                 ""   # first-party
  forgit                    "https://github.com/wfxr/forgit"
  sudo                      ""   # first-party (no upstream dep)
  zsh-autosuggestions       "https://github.com/zsh-users/zsh-autosuggestions"
  zsh-syntax-highlighting   "https://github.com/zsh-users/zsh-syntax-highlighting"
)

# ── Loader ───────────────────────────────────────────────────

_ap_plugin_source() {
  local name=$1
  local plugin_file="$AP_PLUGIN_DIR/$name/$name.zsh"

  # Fall back to first-party bundled plugin
  if [[ ! -f $plugin_file ]]; then
    local bundled="${${(%):-%x}:h}/plugins/$name/$name.zsh"
    [[ -f $bundled ]] && plugin_file=$bundled
  fi

  if [[ -f $plugin_file ]]; then
    source "$plugin_file"
    return 0
  fi

  # Plugin not found in any path — check registry to guide user
  if (( ${+_AP_PLUGIN_REGISTRY[$name]} )); then
    local url=${_AP_PLUGIN_REGISTRY[$name]}
    if [[ -n $url ]]; then
      # Third-party plugin (has upstream)
      print -P "%F{$AP_C_YELLOW}[aporia] Plugin '$name' not installed.%f"
      print -P "%F{$AP_C_GRAY}  Run: aporia-install-plugin $name%f"
    else
      # First-party plugin (no upstream, bundled)
      print -P "%F{$AP_C_YELLOW}[aporia] Plugin '$name' missing from installation.%f"
      print -P "%F{$AP_C_GRAY}  Try re-running the installer: zsh install.sh%f"
    fi
  else
    # Truly unknown
    print -P "%F{$AP_C_RED}[aporia] Unknown plugin '$name'. Check AP_PLUGINS.%f"
  fi
  return 1
}

_ap_load_plugins() {
  local name deferred=()

  for name in "${AP_PLUGINS[@]}"; do
    # Defer order-sensitive plugins
    if (( ${_AP_DEFERRED_PLUGINS[(Ie)$name]} )); then
      deferred+=("$name")
      continue
    fi
    _ap_plugin_source "$name"
  done

  # Always load deferred plugins at the end
  for name in "${deferred[@]}"; do
    _ap_plugin_source "$name"
  done
}

# ── Install helper (callable from terminal) ──────────────────

aporia-install-plugin() {
  local name=$1
  if [[ -z $name ]]; then
    print -P "%F{$AP_C_RED}Usage: aporia-install-plugin <plugin-name>%f"
    return 1
  fi

  if ! (( $+commands[git] )); then
    print -P "%F{$AP_C_RED}[aporia] Error: 'git' is required but not found in your PATH.%f"
    return 1
  fi

  local url=${_AP_PLUGIN_REGISTRY[$name]:-}
  if [[ -z $url ]]; then
    print -P "%F{$AP_C_RED}[aporia] No upstream URL for '$name'. Is it a first-party plugin?%f"
    return 1
  fi

  local dest="$AP_PLUGIN_DIR/$name"
  if [[ -d $dest ]]; then
    print -P "%F{$AP_C_YELLOW}[aporia] '$name' already installed. Updating...%f"
    git -C "$dest" pull --ff-only || return 1
  else
    print -P "%F{$AP_C_BLUE}[aporia] Installing '$name'...%f"
    git clone --depth=1 "$url" "$dest" || return 1
  fi

  # Rename entry file to match Aporia naming convention if needed
  local canonical="$dest/$name.zsh"
  if [[ ! -f $canonical ]]; then
    # Try common alternative names (N) qualifier avoids "no matches found" errors
    local alt
    for alt in "$dest"/*.plugin.zsh(N) "$dest"/*.zsh(N); do
      [[ -f $alt ]] && ln -sf "$alt" "$canonical" && break
    done
  fi

  if [[ -f $canonical ]]; then
    print -P "%F{$AP_C_GREEN}[aporia] '$name' installed. Reload your shell to activate.%f"
  else
    print -P "%F{$AP_C_RED}[aporia] Error: Could not find plugin entry file in '$dest'.%f"
    return 1
  fi
}

aporia-update-plugins() {
  if ! (( $+commands[git] )); then
    print -P "%F{$AP_C_RED}[aporia] Error: 'git' is required but not found in your PATH.%f"
    return 1
  fi

  local name
  for name in "${AP_PLUGINS[@]}"; do
    local dest="$AP_PLUGIN_DIR/$name"
    [[ -d "$dest/.git" ]] && {
      print -P "%F{$AP_C_BLUE}[aporia] Updating $name...%f"
      git -C "$dest" pull --ff-only --quiet || print -P "%F{$AP_C_RED}  Failed to update $name%f"
    }
  done
  print -P "%F{$AP_C_GREEN}[aporia] All plugins updated.%f"
}

aporia-list-plugins() {
  print -P "%F{$AP_C_BLUE}Available plugins:%f"
  local name url plugin_status
  for name url in "${(@kv)_AP_PLUGIN_REGISTRY}"; do
    if (( ${AP_PLUGINS[(Ie)$name]} )); then
      plugin_status="%F{$AP_C_GREEN}● active%f"
    elif [[ $name == "zsh-autosuggestions" || $name == "zsh-syntax-highlighting" ]] && [[ -d "$AP_PLUGIN_DIR/$name" ]]; then
      plugin_status="%F{$AP_C_GREEN}● active (essential)%f"
    elif [[ -d "$AP_PLUGIN_DIR/$name" ]]; then
      plugin_status="%F{$AP_C_YELLOW}○ installed, not active%f"
    else
      plugin_status="%F{$AP_C_GRAY}○ not installed%f"
    fi
    print -P "  %-30s $plugin_status" "$name"
  done

  print -P "\n%F{$AP_C_GRAY}Tip: To activate an installed plugin, use: aporia-activate-plugin <name>%f"
  print -P "%F{$AP_C_GRAY}To activate all installed plugins at once, use: aporia-activate-all%f"
}

aporia-activate-plugin() {
  local name=$1
  if [[ -z $name ]]; then
    print -P "%F{$AP_C_RED}Usage: aporia-activate-plugin <plugin-name>%f"
    return 1
  fi
  
  if [[ ! -d "$AP_PLUGIN_DIR/$name" ]]; then
    print -P "%F{$AP_C_RED}[aporia] '$name' is not installed. Run aporia-install-plugin first.%f"
    return 1
  fi

  if (( ${AP_PLUGINS[(Ie)$name]} )); then
    print -P "%F{$AP_C_YELLOW}[aporia] '$name' is already active.%f"
    return 0
  fi

  # Activate in current session
  AP_PLUGINS+=("$name")
  _ap_plugin_source "$name"

  # Persistent activation in ~/.zshrc
  local zrc="$HOME/.zshrc"
  local found=0
  if [[ -f $zrc ]]; then
    if grep -q "AP_PLUGINS=(" "$zrc"; then
      # Add to existing array
      if ! grep -q "$name" "$zrc"; then
         # Using a temp file for portability across sed versions
         sed "s/AP_PLUGINS=(\([^)]*\))/AP_PLUGINS=(\1 $name)/" "$zrc" > "${zrc}.tmp" && mv "${zrc}.tmp" "$zrc"
         found=1
      fi
    else
      # Create new array before theme source
      if grep -q "aporia.zsh-theme" "$zrc"; then
        sed "/aporia.zsh-theme/i export AP_PLUGINS=($name)" "$zrc" > "${zrc}.tmp" && mv "${zrc}.tmp" "$zrc"
        found=1
      else
        print "\nexport AP_PLUGINS=($name)" >> "$zrc"
        found=1
      fi
    fi
  fi
  
  if [[ $found -eq 1 ]]; then
    print -P "%F{$AP_C_GREEN}[aporia] '$name' activated and added to ~/.zshrc%f"
  else
    print -P "%F{$AP_C_GREEN}[aporia] '$name' activated for this session only (could not patch .zshrc automatically).%f"
  fi
}

aporia-activate-all() {
  local count=0
  local name
  for name in "${(@k)_AP_PLUGIN_REGISTRY}"; do
    if [[ -d "$AP_PLUGIN_DIR/$name" && ! "zsh-autosuggestions" == "$name" && ! "zsh-syntax-highlighting" == "$name" ]]; then
      if (( ! ${AP_PLUGINS[(Ie)$name]} )); then
        aporia-activate-plugin "$name"
        ((count++))
      fi
    fi
  done
  print -P "%F{$AP_C_GREEN}[aporia] $count new plugins activated.%f"
}

# Always load Essentials (autosuggestions and syntax highlighting)
_ap_load_essentials() {
  _ap_plugin_source "zsh-autosuggestions"
  _ap_plugin_source "zsh-syntax-highlighting"
  
  # Set subtle gray style matching Aporia palette
  [[ -n $functions[_zsh_autosuggest_start] ]] && \
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${AP_C_GRAY:-242}"
}

_ap_load_essentials
_ap_load_plugins
