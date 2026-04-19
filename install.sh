#!/bin/bash
# aporia.zsh-theme — installer
# https://github.com/fr3on/aporia
set -eu

THEME_DEST="$HOME/.aporia.zsh-theme"
THEME_URL="https://raw.githubusercontent.com/fr3on/aporia/main/aporia.zsh-theme"
PLUGIN_SYS_DEST="$HOME/.aporia.plugin.zsh"
PLUGIN_SYS_URL="https://raw.githubusercontent.com/fr3on/aporia/main/aporia.plugin.zsh"
ZSHRC="$HOME/.zshrc"
PLUGIN_DIR="$HOME/.aporia/plugins"

# ─── REGISTRY ────────────────────────────────────────────────────────────────
declare -A PLUGIN_REGISTRY=(
  ["history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search"
  ["autopair"]="https://github.com/hlissner/zsh-autopair"
  ["you-should-use"]="https://github.com/MichaelAquilina/zsh-you-should-use"
  ["fast-syntax-highlighting"]="https://github.com/zdharma-continuum/fast-syntax-highlighting"
  ["fzf-tab"]="https://github.com/Aloxaf/fzf-tab"
  ["fzf-history"]="https://github.com/joshskidmore/zsh-fzf-history-search"
  ["docker-ctx"]=""
  ["kube-ctx"]=""
  ["aws-profile"]=""
  ["autoswitch-venv"]="https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv"
  ["nix-shell"]=""
  ["forgit"]="https://github.com/wfxr/forgit"
  ["sudo"]=""
)

SELECTED_PLUGINS=()

# ─── OUTPUT ──────────────────────────────────────────────────────────────────

C_GREEN="\033[32m"; C_YELLOW="\033[33m"; C_RED="\033[31m"; C_BLUE="\033[34m"
C_BOLD="\033[1m";   C_DIM="\033[2m";     C_RESET="\033[0m"

ok()   { printf "${C_GREEN}  ✓${C_RESET}  %s\n" "$1"; }
warn() { printf "${C_YELLOW}  !${C_RESET}  %s\n" "$1"; }
fail() { printf "${C_RED}  ✘${C_RESET}  %s\n" "$1"; exit 1; }
hdr()  { printf "\n${C_BOLD}%s${C_RESET}\n" "$1"; }

# ─── ARG PARSING ─────────────────────────────────────────────────────────────

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --plugin)
        if [ -n "${2:-}" ]; then
          # Split by comma if provided
          IFS=',' read -ra ADDR <<< "$2"
          for i in "${ADDR[@]}"; do
            SELECTED_PLUGINS+=("$i")
          done
          shift 2
        else
          fail "--plugin requires an argument"
        fi
        ;;
      *) shift ;;
    esac
  done
}

# ─── CHECKS ──────────────────────────────────────────────────────────────────

check_shell() {
  hdr "Checking environment"
  
  if ! command -v zsh >/dev/null 2>&1; then
    warn "zsh not found"
    printf "  To install zsh:\n"
    printf "    macOS:  brew install zsh\n"
    printf "    Ubuntu: sudo apt update && sudo apt install zsh\n"
    printf "    CentOS: sudo yum install zsh\n\n"
    fail "zsh is required to use this theme."
  fi
  ok "zsh is installed"

  ZSH_VER=$(zsh --version | awk '{print $2}')
  MAJOR=$(echo "$ZSH_VER" | cut -d. -f1)
  MINOR=$(echo "$ZSH_VER" | cut -d. -f2)
  [ "$MAJOR" -gt 5 ] || { [ "$MAJOR" -eq 5 ] && [ "$MINOR" -ge 3 ]; } \
    || fail "zsh 5.3+ required (found $ZSH_VER)"
  [ "$MAJOR" -gt 5 ] || [ "$MINOR" -ge 8 ] \
    || warn "zsh $ZSH_VER: exec time less precise (no EPOCHSECONDS)"
  ok "zsh version: $ZSH_VER"

  case "${LANG:-}" in
    *UTF-8*|*utf8*) ok "locale: ${LANG}" ;;
    *) warn "non-UTF-8 locale — suggest: export LANG=en_US.UTF-8" ;;
  esac

  if [ "${SHELL##*/}" != "zsh" ]; then
    warn "Currently using ${SHELL##*/}. Aporia requires zsh."
  fi
}

# ─── INSTALL THEME & PLUGIN SYSTEM ───────────────────────────────────────────

install_core() {
  hdr "Installing core files"
  
  # 1. Theme
  if [ -f "./aporia.zsh-theme" ]; then
    cp "./aporia.zsh-theme" "$THEME_DEST"
    ok "theme: copied → $THEME_DEST"
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSL "$THEME_URL" -o "$THEME_DEST"
    ok "theme: downloaded → $THEME_DEST"
  fi

  # 2. Plugin System
  if [ -f "./aporia.plugin.zsh" ]; then
    cp "./aporia.plugin.zsh" "$PLUGIN_SYS_DEST"
    ok "plugins: copied → $PLUGIN_SYS_DEST"
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSL "$PLUGIN_SYS_URL" -o "$PLUGIN_SYS_DEST"
    ok "plugins: downloaded → $PLUGIN_SYS_DEST"
  fi
}

# ─── PLUGIN SETUP ────────────────────────────────────────────────────────────

install_plugin() {
  local name=$1
  local url="${PLUGIN_REGISTRY[$name]-}"
  local dest="$PLUGIN_DIR/$name"

  if [ -d "$dest" ]; then
    printf "${C_YELLOW}  ⟳${C_RESET}  %-30s already present\n" "$name"
    return 0
  fi

  if [ -n "$url" ]; then
    printf "${C_BLUE}  ↓${C_RESET}  %-30s installing... " "$name"
    if git clone --depth=1 "$url" "$dest" >/dev/null 2>&1; then
      # Create canonical symlink if needed
      local canonical="$dest/$name.zsh"
      if [ ! -f "$canonical" ]; then
        for alt in "$dest"/*.plugin.zsh "$dest"/*.zsh; do
          if [ -f "$alt" ]; then
            ln -sf "$(basename "$alt")" "$canonical"
            break
          fi
        done
      fi
      printf "${C_GREEN}installed ✓${C_RESET}\n"
    else
      printf "${C_RED}failed ✗${C_RESET}\n"
      return 1
    fi
  else
    # First-party bundled plugin
    if [ -d "./plugins/$name" ]; then
      printf "${C_BLUE}  →${C_RESET}  %-30s copying bundled... " "$name"
      cp -r "./plugins/$name" "$PLUGIN_DIR/"
      printf "${C_GREEN}done ✓${C_RESET}\n"
    else
      printf "${C_RED}  ✗${C_RESET}  %-30s unknown plugin\n" "$name"
      return 1
    fi
  fi
}

setup_plugins() {
  hdr "Plugin System"
  mkdir -p "$PLUGIN_DIR"

  # 1. Essentials & Environment detection
  if [ -n "${AP_PLUGINS:-}" ]; then
     # Add existing env plugins to selection if not already there
     for p in "${AP_PLUGINS[@]}"; do
       if [[ ! " ${SELECTED_PLUGINS[*]} " =~ " ${p} " ]]; then
         SELECTED_PLUGINS+=("$p")
       fi
     done
     ok "detected existing plugins: ${AP_PLUGINS[*]}"
  fi

  if [ ${#SELECTED_PLUGINS[@]} -eq 0 ] && [ -t 0 ]; then
    printf "  Install Aporia Essentials (Autocomplete & Highlighting)? [Y/n] "
    read -r opt
    case "$opt" in
      [nN]*) warn "skipping essentials" ;;
      *)
        SELECTED_PLUGINS+=("zsh-autosuggestions")
        SELECTED_PLUGINS+=("zsh-syntax-highlighting")
        ;;
    esac
  fi

  # 2. Process selected plugins
  for name in "${SELECTED_PLUGINS[@]}"; do
    if [[ "$name" == "zsh-autosuggestions" ]]; then
      [ -d "$PLUGIN_DIR/$name" ] || git clone --depth=1 "https://github.com/zsh-users/zsh-autosuggestions" "$PLUGIN_DIR/$name" >/dev/null 2>&1 && ok "$name installed"
      continue
    fi
    if [[ "$name" == "zsh-syntax-highlighting" ]]; then
      [ -d "$PLUGIN_DIR/$name" ] || git clone --depth=1 "https://github.com/zsh-users/zsh-syntax-highlighting" "$PLUGIN_DIR/$name" >/dev/null 2>&1 && ok "$name installed"
      continue
    fi
    install_plugin "$name"
  done
}

# ─── PATCH .ZSHRC ────────────────────────────────────────────────────────────

patch_zshrc() {
  hdr "Patching ~/.zshrc"
  SOURCE_LINE="source $THEME_DEST"

  [ -f "$ZSHRC" ] || touch "$ZSHRC"

  # Merge plugins into AP_PLUGINS array in .zshrc
  if [ ${#SELECTED_PLUGINS[@]} -gt 0 ]; then
    local plugin_str=""
    for p in "${SELECTED_PLUGINS[@]}"; do
      # Skip legacy essentials as they are loaded via _ap_load_essentials
      [[ "$p" == "zsh-autosuggestions" || "$p" == "zsh-syntax-highlighting" ]] && continue
      plugin_str+="$p "
    done

    if [ -n "$plugin_str" ]; then
      if grep -q "AP_PLUGINS=" "$ZSHRC"; then
        # This is basic and might need a smarter merge, but following instructions
        sed -i.tmp "s/AP_PLUGINS=(.*/AP_PLUGINS=($plugin_str\${AP_PLUGINS[@]})/" "$ZSHRC" && rm -f "${ZSHRC}.tmp"
        ok "updated AP_PLUGINS in .zshrc"
      else
        printf '\n# Aporia: Active Plugins\nexport AP_PLUGINS=(%s)\n' "$plugin_str" >> "$ZSHRC"
        ok "added AP_PLUGINS to .zshrc"
      fi
    fi
  fi

  if grep -qE "^ZSH_THEME=" "$ZSHRC" 2>/dev/null; then
    cp "$ZSHRC" "${ZSHRC}.aporia.bak"
    sed -i.tmp 's/^ZSH_THEME=/# ZSH_THEME=/g' "$ZSHRC" && rm -f "${ZSHRC}.tmp"
    warn "ZSH_THEME commented out (backup: ~/.zshrc.aporia.bak)"
  fi

  if grep -qF "$SOURCE_LINE" "$ZSHRC" 2>/dev/null; then
    ok "already sourced — no changes"
  else
    printf '\n# aporia.zsh-theme\n%s\n' "$SOURCE_LINE" >> "$ZSHRC"
    ok "source line added"
  fi
}

# ─── REMAINING STEPS ─────────────────────────────────────────────────────────

patch_bashrc() {
  hdr "Adding Bash fallback bridge"
  local BASHRC="$HOME/.bashrc"
  [ -f "$BASHRC" ] || touch "$BASHRC"
  BRIDGE_MARK="# aporia-bash-bridge"
  if grep -qF "$BRIDGE_MARK" "$BASHRC" 2>/dev/null; then
    ok "bridge already exists"
  else
    printf '\n%s\nif [[ $- == *i* ]] && command -v zsh >/dev/null 2>&1; then\n  exec zsh\nfi\n' "$BRIDGE_MARK" >> "$BASHRC"
    ok "auto-switch added to ~/.bashrc"
  fi
}

install_uninstaller() {
  if [ -f "./uninstall.sh" ]; then
    cp "./uninstall.sh" "$HOME/.aporia-uninstall.sh"
    chmod +x "$HOME/.aporia-uninstall.sh"
    ok "uninstaller → ~/.aporia-uninstall.sh"
  fi
}

configure_fonts() {
  hdr "Font Configuration"
  [ -t 0 ] || return 0
  printf "  Do you use a Nerd Font (e.g. JetBrainsMono, FiraCode)? [Y/n] "
  read -r opt
  case "$opt" in
    [nN]*)
      if grep -q "export AP_USE_NERD_FONT=" "$ZSHRC" 2>/dev/null; then
        sed -i.tmp 's/export AP_USE_NERD_FONT=.*/export AP_USE_NERD_FONT=0/' "$ZSHRC" && rm -f "${ZSHRC}.tmp"
      else
        printf '\n# Aporia: Compatibility Mode (Standard Unicode)\nexport AP_USE_NERD_FONT=0\n' >> "$ZSHRC"
      fi
      ok "Compatibility mode enabled"
      ;;
    *)
      if grep -q "export AP_USE_NERD_FONT=" "$ZSHRC" 2>/dev/null; then
        sed -i.tmp 's/export AP_USE_NERD_FONT=.*/export AP_USE_NERD_FONT=1/' "$ZSHRC" && rm -f "${ZSHRC}.tmp"
      fi
      ok "Rich mode enabled (Nerd Font)"
      ;;
  esac
}

switch_shell() {
  hdr "Setting default shell"
  if [ "$(basename "$SHELL")" = "zsh" ]; then
    ok "already using zsh"
    return
  fi
  printf "  Attempting to set zsh as default... "
  if command -v chsh >/dev/null 2>&1; then
    if chsh -s "$(command -v zsh)" "$USER" >/dev/null 2>&1 || chsh -s "$(command -v zsh)" >/dev/null 2>&1; then
      ok "done"
    else
      warn "failed (requires manual intervention)"
      printf "  Please run: %bchsh -s \$(which zsh)%b\n" "${C_BOLD}" "${C_RESET}"
    fi
  else
    warn "chsh not found"
  fi
}

# ─── MAIN ────────────────────────────────────────────────────────────────────

main() {
  printf "\n%baporia%b %bzsh theme · github.com/fr3on/aporia%b\n" "${C_BOLD}" "${C_RESET}" "${C_DIM}" "${C_RESET}"
  parse_args "$@"
  check_shell
  install_core
  setup_plugins
  patch_zshrc
  patch_bashrc
  configure_fonts
  switch_shell
  install_uninstaller
  printf "\n%b%bdone.%b %breload: source ~/.zshrc or log in again%b\n\n" "${C_GREEN}" "${C_BOLD}" "${C_RESET}" "${C_DIM}" "${C_RESET}"
}

main "$@"