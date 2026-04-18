#!/bin/sh
# aporia.zsh-theme — installer
# https://github.com/fr3on/aporia
set -eu

THEME_DEST="$HOME/.aporia.zsh-theme"
THEME_URL="https://raw.githubusercontent.com/fr3on/aporia/main/aporia.zsh-theme"
ZSHRC="$HOME/.zshrc"

# ─── OUTPUT ──────────────────────────────────────────────────────────────────

C_GREEN="\033[32m"; C_YELLOW="\033[33m"; C_RED="\033[31m"
C_BOLD="\033[1m";   C_DIM="\033[2m";     C_RESET="\033[0m"

ok()   { printf "${C_GREEN}  ✓${C_RESET}  %s\n" "$1"; }
warn() { printf "${C_YELLOW}  !${C_RESET}  %s\n" "$1"; }
fail() { printf "${C_RED}  ✘${C_RESET}  %s\n" "$1"; exit 1; }
hdr()  { printf "\n${C_BOLD}%s${C_RESET}\n" "$1"; }

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

# ─── SWITCH SHELL ────────────────────────────────────────────────────────────

switch_shell() {
  hdr "Setting default shell"
  if [ "$(basename "$SHELL")" = "zsh" ]; then
    ok "already using zsh"
    return
  fi

  printf "  Attempting to set zsh as default... "
  if command -v chsh >/dev/null 2>&1; then
    # Try non-interactively first, then suggest manual if it fails
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

# ─── INSTALL THEME ───────────────────────────────────────────────────────────

install_theme() {
  hdr "Installing theme"
  if [ -f "./aporia.zsh-theme" ]; then
    cp "./aporia.zsh-theme" "$THEME_DEST"
    ok "copied → $THEME_DEST"
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSL "$THEME_URL" -o "$THEME_DEST"
    ok "downloaded → $THEME_DEST"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$THEME_URL" -O "$THEME_DEST"
    ok "downloaded → $THEME_DEST"
  else
    fail "aporia.zsh-theme not found and no curl/wget available"
  fi
}

# ─── PATCH .ZSHRC ────────────────────────────────────────────────────────────

patch_zshrc() {
  hdr "Patching ~/.zshrc"
  SOURCE_LINE="source $THEME_DEST"

  [ -f "$ZSHRC" ] || touch "$ZSHRC"

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

# ─── PATCH .BASHRC (Fallback Bridge) ─────────────────────────────────────────

patch_bashrc() {
  hdr "Adding Bash fallback bridge"
  BASHRC="$HOME/.bashrc"
  
  # Ensure file exists
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

# ─── CONFIGURE FONTS ─────────────────────────────────────────────────────────

configure_fonts() {
  hdr "Font Configuration"
  # Default to Nerd Font if not interactive
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
      # Ensure it is set to 1 if we're re-installing
      if grep -q "export AP_USE_NERD_FONT=" "$ZSHRC" 2>/dev/null; then
        sed -i.tmp 's/export AP_USE_NERD_FONT=.*/export AP_USE_NERD_FONT=1/' "$ZSHRC" && rm -f "${ZSHRC}.tmp"
      fi
      ok "Rich mode enabled (Nerd Font)"
      ;;
  esac
}
# ─── SETUP PLUGINS (Essentials) ──────────────────────────────────────────────

setup_plugins() {
  hdr "Aporia Essentials"
  PLUGIN_DIR="$HOME/.aporia/plugins"
  mkdir -p "$PLUGIN_DIR"

  # Use a simple yes/no if interactive
  if [ -t 0 ]; then
    printf "  Install Aporia Essentials (Autocomplete & Highlighting)? [Y/n] "
    read -r opt
    case "$opt" in
      [nN]*) warn "skipping essentials"; return ;;
    esac
  fi

  for plugin in "zsh-users/zsh-autosuggestions" "zsh-users/zsh-syntax-highlighting"; do
    name=$(basename "$plugin")
    if [ ! -d "$PLUGIN_DIR/$name" ]; then
      if command -v git >/dev/null 2>&1; then
        git clone --depth 1 "https://github.com/$plugin" "$PLUGIN_DIR/$name" >/dev/null 2>&1
        ok "$name installed"
      else
        warn "git not found — skipping $name"
      fi
    else
      ok "$name already exists"
    fi
  done
}

# ─── MAIN ────────────────────────────────────────────────────────────────────

main() {
  printf "\n%baporia%b %bzsh theme · github.com/fr3on/aporia%b\n" "${C_BOLD}" "${C_RESET}" "${C_DIM}" "${C_RESET}"
  check_shell
  install_theme
  setup_plugins
  patch_zshrc
  patch_bashrc
  configure_fonts
  switch_shell
  install_uninstaller
  printf "\n%b%bdone.%b %breload: source ~/.zshrc or log in again%b\n\n" "${C_GREEN}" "${C_BOLD}" "${C_RESET}" "${C_DIM}" "${C_RESET}"
}

main "$@"