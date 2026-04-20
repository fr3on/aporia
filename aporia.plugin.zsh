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
  proxmox                   ""   # first-party
)

# ── Dependencies: plugin_name → required binary ─────────────
typeset -gA _AP_PLUGIN_DEPS=(
  fzf-tab      "fzf"
  fzf-history  "fzf"
  forgit       "fzf"
  kube-ctx     "kubectl"
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
    # Check dependencies before sourcing
    local dep=${_AP_PLUGIN_DEPS[$name]:-}
    if [[ -n $dep ]] && ! (( $+commands[$dep] )); then
      # Special case: some plugins (like kube-ctx) handle missing deps gracefully inside segments
      # We only warn for "active" plugins that users explicitly requested
      if [[ $name != "kube-ctx" && $name != "nix-shell" ]]; then
         print -P "%F{$AP_C_YELLOW}[aporia] Warning: Plugin '$name' requires '$dep' which is not in your PATH.%f"
      fi
    fi

    source "$plugin_file"
    
    # Plugin-specific post-load logic
    if [[ $name == "fzf-history" ]]; then
      alias fzf-history='fzf_history_search'
    fi
    
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

  # Automatic keybindings for common widgets
  if [[ -n $widgets[history-substring-search-up] ]]; then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    [[ -n ${terminfo[kcuu1]} ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
    [[ -n ${terminfo[kcud1]} ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down
  fi
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
    # First-party / Bundled plugin?
    local bundled_src="./plugins/$name"
    if [[ -d $bundled_src ]]; then
      print -P "%F{$AP_C_BLUE}[aporia] Copying bundled plugin '$name' to $AP_PLUGIN_DIR...%f"
      mkdir -p "$AP_PLUGIN_DIR"
      cp -r "$bundled_src" "$AP_PLUGIN_DIR/" || return 1
      print -P "%F{$AP_C_GREEN}[aporia] '$name' installed. Run 'aporia-activate-plugin $name' to activate.%f"
      return 0
    elif (( $+commands[curl] )); then
      print -P "%F{$AP_C_BLUE}[aporia] Downloading bundled plugin '$name' from GitHub...%f"
      local p_base="https://raw.githubusercontent.com/fr3on/aporia/main/plugins/$name"
      mkdir -p "$AP_PLUGIN_DIR/$name"
      if curl -fsSL "$p_base/$name.zsh" -o "$AP_PLUGIN_DIR/$name/$name.zsh"; then
        print -P "%F{$AP_C_GREEN}[aporia] '$name' downloaded and installed. Run 'aporia-activate-plugin $name' now.%f"
        return 0
      else
        rm -rf "$AP_PLUGIN_DIR/$name"
        print -P "%F{$AP_C_RED}[aporia] Failed to download '$name'. Check your internet connection.%f"
        return 1
      fi
    fi
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
    elif [[ -d "$AP_PLUGIN_DIR/$name" ]] || [[ -d "${${(%):-%x}:h}/plugins/$name" ]]; then
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
  
  local bundle_dir="${${(%):-%x}:h}/plugins/$name"
  if [[ ! -d "$AP_PLUGIN_DIR/$name" && ! -d "$bundle_dir" ]]; then
    if [[ -n ${_AP_PLUGIN_REGISTRY[$name]+x} ]]; then
      print -P "%F{$AP_C_RED}[aporia] '$name' is not installed in $AP_PLUGIN_DIR.%f"
      print -P "%F{$AP_C_GRAY}        Run: aporia-install-plugin $name%f"
    else
      print -P "%F{$AP_C_RED}[aporia] Unknown plugin '$name'.%f"
    fi
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

# ── Unified Aporia Command ───────────────────────────────────

# Internal: Print feature flag status
_ap_print_flag() {
  local label=$1 value=$2
  local _ap_fstatus="%F{$AP_C_GREEN}on%f"
  [[ $value -eq 0 ]] && _ap_fstatus="%F{$AP_C_GRAY}off%f"
  # Using print -P with padding
  print -P "   %F{$AP_C_WHITE}${(r:12:)label}:%f $_ap_fstatus"
}

_aporia_help() {
  print -P "\n %F{$AP_C_BLUE}Usage:%f aporia <command> [args]"
  print -P "\n %F{$AP_C_BLUE}Commands:%f"
  print -P "   %F{$AP_C_YELLOW}info%f          Show theme and system status (default)"
  print -P "   %F{$AP_C_YELLOW}list%f          List all available plugins and their status"
  print -P "   %F{$AP_C_YELLOW}install <p>%f   Download and install a plugin"
  print -P "   %F{$AP_C_YELLOW}activate <p>%f  Enable a plugin and add to .zshrc"
  print -P "   %F{$AP_C_YELLOW}activate-all%f  Activate all installed plugins"
  print -P "   %F{$AP_C_YELLOW}update%f        Update all installed plugins"
  print -P "   %F{$AP_C_YELLOW}help%f          Show this help message\n"
}

_aporia_dashboard() {
  # Header
  print -P "\n %F{$AP_C_ORANGE}APORIA%f %F{$AP_C_GRAY}— The Dark Flame Edition %f%B%F{$AP_C_BLUE}v${APORIA_VERSION:-1.0.0}%f%b"
  print -P " %F{$AP_C_GRAY}──────────────────────────────────────────────────%f"

  # System Status
  print -P " %F{$AP_C_BLUE}System Info%f"
  print -P "   %F{$AP_C_WHITE}${(r:12:):-OS}:%f  ${_AP_ICO_OS:-?} $(_ap_get_os_name)"
  print -P "   %F{$AP_C_WHITE}${(r:12:):-Shell}:%f  Zsh $ZSH_VERSION"
  
  local icon_mode="Standard Unicode"
  [[ ${AP_USE_NERD_FONT:-1} -eq 1 ]] && icon_mode="Nerd Font (Rich)"
  [[ ${AP_ASCII_FALLBACK:-0} -eq 1 ]] && icon_mode="ASCII Fallback"
  print -P "   %F{$AP_C_WHITE}${(r:12:):-Icons}:%f  $icon_mode"
  
  local locale_status="%F{$AP_C_GREEN}UTF-8%f"
  _ap_is_utf8 || locale_status="%F{$AP_C_RED}Standard%f"
  print -P "   %F{$AP_C_WHITE}${(r:12:):-Locale}:%f  $locale_status"

  local theme_name=${AP_THEME:-deep_blue}
  print -P "   %F{$AP_C_WHITE}${(r:12:):-Theme}:%f  %F{$AP_C_CYAN}$theme_name%f"

  # Theme Config
  print -P "\n %F{$AP_C_BLUE}Configuration%f"
  _ap_print_flag "SSH Segment" ${AP_SHOW_SSH:-1}
  _ap_print_flag "Git Segment" ${AP_SHOW_GIT:-1}
  _ap_print_flag "Lang Stats"  ${AP_SHOW_LANGS:-1}
  _ap_print_flag "Exec Time"   ${AP_SHOW_EXEC_TIME:-1}
  _ap_print_flag "Exit Code"   ${AP_SHOW_EXIT_CODE:-1}
  _ap_print_flag "Clock"       ${AP_SHOW_TIME:-1}

  # Plugins
  local active_count=${#AP_PLUGINS[@]}
  local total_count=${#_AP_PLUGIN_REGISTRY[@]}
  print -P "\n %F{$AP_C_BLUE}Plugins%f"
  print -P "   %F{$AP_C_WHITE}${(r:12:):-Active}:%f  %F{$AP_C_GREEN}$active_count%f / $total_count"
  print -P "   %F{$AP_C_GRAY}Run 'aporia list' for more details.%f"

  # Footer / Help
  print -P "\n %F{$AP_C_GRAY}Type 'aporia help' for a list of commands.%f\n"
}

aporia() {
  local cmd=$1
  case "$cmd" in
    list)
      aporia-list-plugins
      ;;
    install)
      shift
      aporia-install-plugin "$@"
      ;;
    update)
      aporia-update-plugins
      ;;
    activate)
      shift
      aporia-activate-plugin "$@"
      ;;
    activate-all)
      aporia-activate-all
      ;;
    info|status|"")
      _aporia_dashboard
      ;;
    help|--help|-h)
      _aporia_help
      ;;
    *)
      print -P "%F{$AP_C_RED}[aporia] Unknown command: $cmd%f"
      _aporia_help
      return 1
      ;;
  esac
}
