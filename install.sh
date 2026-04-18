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
  [ "${SHELL##*/}" = "zsh" ] || fail "zsh required (current: ${SHELL##*/}). Run: chsh -s \$(which zsh)"
  ok "shell: zsh"

  ZSH_VER=$(zsh --version | awk '{print $2}')
  MAJOR=$(echo "$ZSH_VER" | cut -d. -f1)
  MINOR=$(echo "$ZSH_VER" | cut -d. -f2)
  [ "$MAJOR" -gt 5 ] || { [ "$MAJOR" -eq 5 ] && [ "$MINOR" -ge 3 ]; } \
    || fail "zsh 5.3+ required (found $ZSH_VER)"
  [ "$MAJOR" -gt 5 ] || [ "$MINOR" -ge 8 ] \
    || warn "zsh $ZSH_VER: exec time less precise (no EPOCHSECONDS)"
  ok "version: $ZSH_VER"

  case "${LANG:-}" in
    *UTF-8*|*utf8*) ok "locale: ${LANG}" ;;
    *) warn "non-UTF-8 locale — add: export LANG=en_US.UTF-8" ;;
  esac
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

# ─── INSTALL UNINSTALLER ─────────────────────────────────────────────────────

install_uninstaller() {
  if [ -f "./uninstall.sh" ]; then
    cp "./uninstall.sh" "$HOME/.aporia-uninstall.sh"
    chmod +x "$HOME/.aporia-uninstall.sh"
    ok "uninstaller → ~/.aporia-uninstall.sh"
  fi
}

# ─── MAIN ────────────────────────────────────────────────────────────────────

main() {
  printf "\n${C_BOLD}aporia${C_RESET} ${C_DIM}zsh theme · github.com/fr3on/aporia${C_RESET}\n"
  check_shell
  install_theme
  patch_zshrc
  install_uninstaller
  printf "\n${C_GREEN}${C_BOLD}done.${C_RESET} ${C_DIM}reload: source ~/.zshrc${C_RESET}\n\n"
}

main "$@"