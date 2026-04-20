#!/usr/bin/env zsh
# shellcheck disable=all
# aporia.zsh-theme — uninstaller
# https://github.com/fr3on/aporia
set -eu

THEME_DEST="$HOME/.aporia.zsh-theme"
ZSHRC="$HOME/.zshrc"

C_GREEN="\033[32m"; C_YELLOW="\033[33m"
C_BOLD="\033[1m";   C_DIM="\033[2m"; C_RESET="\033[0m"

ok()   { printf "%b  ✓%b  %s\n" "${C_GREEN}" "${C_RESET}" "$1"; }
warn() { printf "%b  !%b  %s\n" "${C_YELLOW}" "${C_RESET}" "$1"; }
hdr()  { printf "\n%b%s%b\n" "${C_BOLD}" "$1" "${C_RESET}"; }

remove_theme() {
  hdr "Removing theme"
  if [ -f "$THEME_DEST" ]; then
    rm -f "$THEME_DEST"
    ok "removed $THEME_DEST"
  else
    warn "$HOME/.aporia.zsh-theme not found — skipping"
  fi
}

restore_zshrc() {
  hdr "Restoring ~/.zshrc"
  [ -f "$ZSHRC" ] || { warn "$HOME/.zshrc not found — skipping"; return; }

  tmp=$(mktemp)
  grep -Ev "^# aporia\.zsh-theme$|^source ['\"]?$HOME/\.aporia\.zsh-theme['\"]?$" \
    "$ZSHRC" > "$tmp" 2>/dev/null || true

  # Restore any ZSH_THEME we commented out
  if grep -q "^# ZSH_THEME=" "$tmp" 2>/dev/null; then
    sed -i.bak 's/^# ZSH_THEME=/ZSH_THEME=/g' "$tmp" && rm -f "${tmp}.bak"
    ok "ZSH_THEME restored"
  fi

  mv "$tmp" "$ZSHRC"
  ok "$HOME/.zshrc cleaned"
}

restore_bashrc() {
  hdr "Restoring ~/.bashrc"
  BASHRC="$HOME/.bashrc"
  [ -f "$BASHRC" ] || return 0

  BRIDGE_MARK="# aporia-bash-bridge"
  if grep -qF "$BRIDGE_MARK" "$BASHRC" 2>/dev/null; then
    # Safely remove the 4-line bridge block
    tmp=$(mktemp)
    sed "/$BRIDGE_MARK/,+3d" "$BASHRC" > "$tmp"
    mv "$tmp" "$BASHRC"
    ok "Bash bridge removed"
  fi
}

remove_leftovers() {
  hdr "Cleaning up"
  for f in "$HOME/.aporia-uninstall.sh" "${ZSHRC}.aporia.bak"; do
    if [ -f "$f" ]; then
      rm -f "$f"
      ok "removed $f"
    fi
  done
}

main() {
  printf "\n%baporia%b %buninstaller%b\n" "${C_BOLD}" "${C_RESET}" "${C_DIM}" "${C_RESET}"
  remove_theme
  restore_zshrc
  restore_bashrc
  remove_leftovers
  printf "\n%b%bdone.%b %breload: exec zsh%b\n" "${C_GREEN}" "${C_BOLD}" "${C_RESET}" "${C_DIM}" "${C_RESET}"
}

main "$@"