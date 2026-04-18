#!/bin/sh
# aporia.zsh-theme — uninstaller
# https://github.com/fr3on/aporia
set -eu

THEME_DEST="$HOME/.aporia.zsh-theme"
ZSHRC="$HOME/.zshrc"

C_GREEN="\033[32m"; C_YELLOW="\033[33m"
C_BOLD="\033[1m";   C_DIM="\033[2m"; C_RESET="\033[0m"

ok()   { printf "${C_GREEN}  ✓${C_RESET}  %s\n" "$1"; }
warn() { printf "${C_YELLOW}  !${C_RESET}  %s\n" "$1"; }
hdr()  { printf "\n${C_BOLD}%s${C_RESET}\n" "$1"; }

remove_theme() {
  hdr "Removing theme"
  if [ -f "$THEME_DEST" ]; then
    rm -f "$THEME_DEST"
    ok "removed $THEME_DEST"
  else
    warn "~/.aporia.zsh-theme not found — skipping"
  fi
}

restore_zshrc() {
  hdr "Restoring ~/.zshrc"
  [ -f "$ZSHRC" ] || { warn "~/.zshrc not found — skipping"; return; }

  tmp=$(mktemp)
  grep -Ev "^# aporia\.zsh-theme$|^source ['\"]?$HOME/\.aporia\.zsh-theme['\"]?$" \
    "$ZSHRC" > "$tmp" 2>/dev/null || true

  # Restore any ZSH_THEME we commented out
  if grep -q "^# ZSH_THEME=" "$tmp" 2>/dev/null; then
    sed -i.bak 's/^# ZSH_THEME=/ZSH_THEME=/g' "$tmp" && rm -f "${tmp}.bak"
    ok "ZSH_THEME restored"
  fi

  mv "$tmp" "$ZSHRC"
  ok "~/.zshrc cleaned"
}

remove_leftovers() {
  hdr "Cleaning up"
  for f in "$HOME/.aporia-uninstall.sh" "${ZSHRC}.aporia.bak"; do
    [ -f "$f" ] && rm -f "$f" && ok "removed $f" || true
  done
}

main() {
  printf "\n${C_BOLD}aporia${C_RESET} ${C_DIM}uninstaller${C_RESET}\n"
  remove_theme
  restore_zshrc
  remove_leftovers
  printf "\n${C_GREEN}${C_BOLD}done.${C_RESET} ${C_DIM}reload: exec zsh${C_RESET}\n\n"
}

main "$@"