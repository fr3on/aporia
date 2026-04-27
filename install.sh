#!/usr/bin/env zsh
# shellcheck disable=SC2296,SC2128,SC2206
# aporia.zsh-theme — installer
# https://github.com/fr3on/aporia
set -eu

[[ -n $ZSH_VERSION ]] || { echo "Error: This script must be run with zsh."; exit 1; }

if [ "${SHELL##*/}" = "fish" ]; then
  echo "Error: Fish shell is not compatible with this installer."
  echo "Switch to Zsh first:  chsh -s \$(command -v zsh)"
  exit 1
fi

# ─── CONSTANTS ────────────────────────────────────────────────────────────────

APORIA_VERSION="1.1.4"
THEME_DEST="$HOME/.aporia.zsh-theme"
THEME_URL="https://raw.githubusercontent.com/fr3on/aporia/main/aporia.zsh-theme"
PLUGIN_SYS_DEST="$HOME/.aporia.plugin.zsh"
PLUGIN_SYS_URL="https://raw.githubusercontent.com/fr3on/aporia/main/aporia.plugin.zsh"
ZSHRC="$HOME/.zshrc"
PLUGIN_DIR="$HOME/.aporia/plugins"

INSTALLED_PLUGINS=()
WARNINGS=()

# ─── COLORS ───────────────────────────────────────────────────────────────────
# Use $'...' so escape chars are stored correctly, not as literal \033

R=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'

FG_WHITE=$'\033[38;5;255m'
FG_GREEN=$'\033[38;5;83m'
FG_YELLOW=$'\033[38;5;220m'
FG_RED=$'\033[38;5;203m'
FG_BLUE=$'\033[38;5;75m'
FG_CYAN=$'\033[38;5;87m'
FG_PURPLE=$'\033[38;5;141m'
FG_GRAY=$'\033[38;5;245m'

# ─── REGISTRY ────────────────────────────────────────────────────────────────
typeset -gA PLUGIN_REGISTRY=(
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
  ["proxmox"]=""
)

SELECTED_PLUGINS=()

# ─── OUTPUT ───────────────────────────────────────────────────────────────────

ok()      { printf "  ${FG_GREEN}✓${R}  %s\n" "$1"; }
warn()    { printf "  ${FG_YELLOW}!${R}  %s\n" "$1"; WARNINGS+=("$1"); }
fail()    { printf "\n  ${FG_RED}✗${R}  %s\n\n" "$1"; exit 1; }
info()    { printf "  ${FG_GRAY}·${R}  ${DIM}%s${R}\n" "$1"; }
section() { printf "\n  ${BOLD}${FG_BLUE}::${R} ${BOLD}${FG_WHITE}%s${R}\n\n" "$1"; }

# Spinner — animates while a command runs in the background
spinner() {
  local label="$1"; shift
  local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local idx=0

  "$@" >/dev/null 2>&1 &
  local pid=$!

  while kill -0 "$pid" 2>/dev/null; do
    printf "\r  ${FG_CYAN}${spin[$idx]}${R}  ${DIM}%s${R}" "$label"
    idx=$(( (idx + 1) % ${#spin[@]} ))
    sleep 0.08
  done
  wait "$pid"
  local rc=$?
  printf "\r"
  return $rc
}

# ─── HEADER ───────────────────────────────────────────────────────────────────

print_header() {
  clear 2>/dev/null || true
  printf "\n"
  printf "  ${FG_BLUE}${BOLD}aporia${R}  ${FG_GRAY}·  zsh theme  ·  v${APORIA_VERSION}${R}\n"
  printf "  ${FG_GRAY}github.com/fr3on/aporia${R}\n"
}

# ─── ARG PARSING ─────────────────────────────────────────────────────────────

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --plugin)
        if [ -n "${2:-}" ]; then
          local ADDR=("${(@s:,:)2}")
          for i in "${ADDR[@]}"; do SELECTED_PLUGINS+=("$i"); done
          shift 2
        else
          fail "--plugin requires an argument"
        fi
        ;;
      --help|-h)
        printf "\n  ${BOLD}Usage${R}  zsh install.sh [options]\n\n"
        printf "  ${FG_GRAY}--plugin <name,...>${R}  pre-select plugins\n"
        printf "  ${FG_GRAY}--help${R}               show this message\n\n"
        exit 0
        ;;
      *) shift ;;
    esac
  done
}

# ─── CHECKS ──────────────────────────────────────────────────────────────────

check_shell() {
  section "Environment"

  if ! command -v zsh >/dev/null 2>&1; then
    warn "zsh not found"
    info "macOS:  brew install zsh"
    info "Ubuntu: sudo apt install zsh"
    fail "zsh is required."
  fi

  local zsh_ver major minor
  zsh_ver=$(zsh --version | awk '{print $2}')
  major=$(echo "$zsh_ver" | cut -d. -f1)
  minor=$(echo "$zsh_ver" | cut -d. -f2)

  [ "$major" -gt 5 ] || { [ "$major" -eq 5 ] && [ "$minor" -ge 3 ]; } \
    || fail "Zsh 5.3+ required (found $zsh_ver)"
  [ "$major" -gt 5 ] || [ "$minor" -ge 8 ] \
    || warn "Zsh $zsh_ver — upgrade for better timing precision"

  ok "Zsh $zsh_ver"

  case "${LANG:-}" in
    *UTF-8*|*utf8*) ok "Locale ${LANG}" ;;
    *) warn "Non-UTF-8 locale — add: export LANG=en_US.UTF-8" ;;
  esac

  if command -v git >/dev/null 2>&1; then
    ok "Git $(git --version | awk '{print $3}')"
  else
    warn "Git not found — some features will be limited"
  fi

  if [ "${SHELL##*/}" != "zsh" ]; then
    warn "Default shell is ${SHELL##*/} — will offer to switch"
  fi
}

# ─── INSTALL CORE ────────────────────────────────────────────────────────────

install_core() {
  section "Installing"

  if [ -f "./aporia.zsh-theme" ]; then
    cp "./aporia.zsh-theme" "$THEME_DEST"
    ok "Theme  ${FG_GRAY}~/.aporia.zsh-theme${R}"
  elif command -v curl >/dev/null 2>&1; then
    spinner "Downloading theme" curl -fsSL "$THEME_URL" -o "$THEME_DEST" \
      && ok "Theme downloaded" \
      || fail "Failed to download theme. Check your connection."
  else
    fail "curl not found and no local copy available."
  fi

  if [ -f "./aporia.plugin.zsh" ]; then
    cp "./aporia.plugin.zsh" "$PLUGIN_SYS_DEST"
    ok "Plugin system  ${FG_GRAY}~/.aporia.plugin.zsh${R}"
  elif command -v curl >/dev/null 2>&1; then
    spinner "Downloading plugin system" curl -fsSL "$PLUGIN_SYS_URL" -o "$PLUGIN_SYS_DEST" \
      && ok "Plugin system downloaded" \
      || warn "Plugin system download failed"
  fi

  # Always copy bundled first-party plugins so they are available offline
  if [ -d "./plugins" ]; then
    mkdir -p "$PLUGIN_DIR"
    cp -r "./plugins/"* "$PLUGIN_DIR/" 2>/dev/null || true
    ok "Bundled plugins copied to ${FG_GRAY}~/.aporia/plugins/${R}"
  fi
}

# ─── PLUGINS ─────────────────────────────────────────────────────────────────

install_plugin() {
  local name=$1
  local url="${PLUGIN_REGISTRY[$name]-}"
  local dest="$PLUGIN_DIR/$name"

  if [ -d "$dest" ]; then
    info "$name  ${FG_GRAY}already installed${R}"
    return 0
  fi

  if [ -n "$url" ]; then
    if spinner "Installing $name" git clone --depth=1 "$url" "$dest"; then
      local canonical="$dest/$name.zsh"
      if [ ! -f "$canonical" ]; then
        for alt in "$dest"/*.plugin.zsh "$dest"/*.zsh; do
          [ -f "$alt" ] && ln -sf "$(basename "$alt")" "$canonical" && break
        done
      fi
      ok "$name"
      INSTALLED_PLUGINS+=("$name")
    else
      warn "$name failed to install"
    fi
  else
    if [ -d "./plugins/$name" ]; then
      cp -r "./plugins/$name" "$PLUGIN_DIR/"
      ok "$name  ${FG_GRAY}(bundled)${R}"
      INSTALLED_PLUGINS+=("$name")
    else
      warn "$name — unknown plugin, skipping"
    fi
  fi
}

setup_plugins() {
  section "Plugins"
  mkdir -p "$PLUGIN_DIR"

  if (( ! ${+AP_PLUGINS} )) || [[ ${(t)AP_PLUGINS} != *array* ]]; then
    AP_PLUGINS=(${=AP_PLUGINS:-})
  fi

  if [ -n "${AP_PLUGINS:-}" ]; then
    for p in "${AP_PLUGINS[@]}"; do
      [[ ! " ${SELECTED_PLUGINS[*]} " == *" $p "* ]] && SELECTED_PLUGINS+=("$p")
    done
    info "Existing plugins: ${AP_PLUGINS[*]}"
  fi

  if [ ${#SELECTED_PLUGINS[@]} -eq 0 ] && [ -t 0 ]; then
    printf "  ${FG_GRAY}Install essentials?${R}  ${DIM}zsh-autosuggestions + zsh-syntax-highlighting${R}\n"
    printf "  ${FG_WHITE}[Y/n]${R} "
    read -r opt
    case "$opt" in
      [nN]*) info "Skipping essentials" ;;
      *)
        SELECTED_PLUGINS+=("zsh-autosuggestions" "zsh-syntax-highlighting")
        ;;
    esac
    printf "\n"
  fi

  local total=${#SELECTED_PLUGINS[@]}
  local idx=0
  for name in "${SELECTED_PLUGINS[@]}"; do
    (( idx++ )) || true

    if [[ "$name" == "zsh-autosuggestions" || "$name" == "zsh-syntax-highlighting" ]]; then
      local repo="https://github.com/zsh-users/${name}"
      if [ ! -d "$PLUGIN_DIR/$name" ]; then
        spinner "Installing $name" git clone --depth=1 "$repo" "$PLUGIN_DIR/$name" \
          && ok "$name" && INSTALLED_PLUGINS+=("$name") \
          || warn "$name failed"
      else
        info "$name  ${FG_GRAY}already installed${R}"
      fi
      continue
    fi
    install_plugin "$name"
  done

  if [ $total -eq 0 ]; then
    info "No plugins selected"
  fi
}

# ─── PATCH .ZSHRC ────────────────────────────────────────────────────────────

patch_zshrc() {
  section "Config"
  local SOURCE_LINE="source $THEME_DEST"

  [ -f "$ZSHRC" ] || touch "$ZSHRC"

  # Merge plugin list
  if [ ${#SELECTED_PLUGINS[@]} -gt 0 ]; then
    local plugin_str=""
    for p in "${SELECTED_PLUGINS[@]}"; do
      [[ "$p" == "zsh-autosuggestions" || "$p" == "zsh-syntax-highlighting" ]] && continue
      plugin_str+="$p "
    done
    if [ -n "$plugin_str" ]; then
      if grep -q "AP_PLUGINS=" "$ZSHRC"; then
        perl -pi -e "s/AP_PLUGINS=\(([^)]*)\)/AP_PLUGINS=($plugin_str\$1)/" "$ZSHRC"
        ok "AP_PLUGINS updated"
      else
        printf '\n# Aporia: Active Plugins\nexport AP_PLUGINS=(%s)\n' "$plugin_str" >> "$ZSHRC"
        ok "AP_PLUGINS added"
      fi
    fi
  fi

  # Comment out conflicting ZSH_THEME
  if grep -qE "^ZSH_THEME=" "$ZSHRC" 2>/dev/null; then
    cp "$ZSHRC" "${ZSHRC}.aporia.bak"
    perl -pi -e 's/^ZSH_THEME=/# ZSH_THEME=/g' "$ZSHRC"
    warn "ZSH_THEME commented out  ${FG_GRAY}(backup: ~/.zshrc.aporia.bak)${R}"
  fi

  # Source line
  if grep -qF "$SOURCE_LINE" "$ZSHRC" 2>/dev/null; then
    info "Already sourced — no change"
  else
    if ! grep -q "HISTFILE=" "$ZSHRC"; then
      printf '\n# Aporia: History\nexport HISTFILE="$HOME/.zsh_history"\nexport HISTSIZE=10000\nexport SAVEHIST=10000\n' >> "$ZSHRC"
      ok "History defaults added"
    fi
    printf '\n# aporia.zsh-theme\n%s\n' "$SOURCE_LINE" >> "$ZSHRC"
    ok "Source line added to ~/.zshrc"
  fi
}

# ─── BASH BRIDGE ─────────────────────────────────────────────────────────────

patch_bashrc() {
  local BASHRC="$HOME/.bashrc"
  local MARK="# aporia-bash-bridge"
  [ -f "$BASHRC" ] || touch "$BASHRC"
  if ! grep -qF "$MARK" "$BASHRC" 2>/dev/null; then
    printf '\n%s\nif [[ $- == *i* ]] && command -v zsh >/dev/null 2>&1; then\n  exec zsh\nfi\n' "$MARK" >> "$BASHRC"
    ok "Bash → Zsh bridge added"
  fi
}

# ─── FONTS ───────────────────────────────────────────────────────────────────

configure_fonts() {
  section "Fonts"
  [ -t 0 ] || return 0

  printf "  ${FG_GRAY}Do you use a Nerd Font in your terminal?${R}\n"
  printf "  ${FG_GRAY}(JetBrainsMono, FiraCode, etc.)${R}\n\n"
  printf "  ${FG_WHITE}[Y/n]${R} "
  read -r opt
  printf "\n"
  case "$opt" in
    [nN]*)
      if grep -q "export AP_USE_NERD_FONT=" "$ZSHRC" 2>/dev/null; then
        perl -pi -e 's/export AP_USE_NERD_FONT=.*/export AP_USE_NERD_FONT=0/' "$ZSHRC"
      else
        printf '\n# Aporia: Compatibility Mode\nexport AP_USE_NERD_FONT=0\n' >> "$ZSHRC"
      fi
      ok "Compatibility mode  ${FG_GRAY}(standard Unicode)${R}"
      ;;
    *)
      if grep -q "export AP_USE_NERD_FONT=" "$ZSHRC" 2>/dev/null; then
        perl -pi -e 's/export AP_USE_NERD_FONT=.*/export AP_USE_NERD_FONT=1/' "$ZSHRC"
      fi
      ok "Rich mode  ${FG_GRAY}(Nerd Font icons)${R}"
      ;;
  esac
}

# ─── DEFAULT SHELL ────────────────────────────────────────────────────────────

switch_shell() {
  [ "$(basename "$SHELL")" = "zsh" ] && return 0

  section "Default Shell"
  printf "  ${FG_GRAY}Your default shell is ${FG_YELLOW}${SHELL##*/}${FG_GRAY}.${R}\n"
  printf "  Switch to Zsh? ${FG_WHITE}[Y/n]${R} "
  read -r opt
  printf "\n"
  case "$opt" in
    [nN]*) info "Keeping ${SHELL##*/}" ;;
    *)
      local zsh_path; zsh_path=$(command -v zsh)
      if chsh -s "$zsh_path" 2>/dev/null || chsh -s "$zsh_path" "$USER" 2>/dev/null; then
        ok "Default shell set to Zsh"
      else
        warn "Auto-switch failed — run:  chsh -s \$(which zsh)"
      fi
      ;;
  esac
}

# ─── UNINSTALLER ─────────────────────────────────────────────────────────────

install_uninstaller() {
  if [ -f "./uninstall.sh" ]; then
    cp "./uninstall.sh" "$HOME/.aporia-uninstall.sh"
    chmod +x "$HOME/.aporia-uninstall.sh"
  fi
}

# ─── SUMMARY ─────────────────────────────────────────────────────────────────

print_summary() {
  printf "\n"

  if [ ${#INSTALLED_PLUGINS[@]} -gt 0 ]; then
    printf "  ${FG_GRAY}Installed:  ${FG_WHITE}${INSTALLED_PLUGINS[*]}${R}\n\n"
  fi

  if [ ${#WARNINGS[@]} -gt 0 ]; then
    printf "  ${FG_YELLOW}Warnings:${R}\n"
    for w in "${WARNINGS[@]}"; do
      printf "  ${FG_YELLOW}!${R}  ${DIM}%s${R}\n" "$w"
    done
    printf "\n"
  fi

  printf "  ${FG_GREEN}${BOLD}Done.${R}  Aporia has been successfully installed.\n\n"
  printf "  ${FG_GRAY}Quick commands:  aporia help · aporia doctor · aporia benchmark${R}\n\n"

  printf "  ${FG_CYAN}Do you want to reload your shell now?${R} ${FG_WHITE}[Y/n]${R} "
  read -r opt
  printf "\n"
  case "$opt" in
    [nN]*) 
      printf "  ${FG_GRAY}Okay, please run:  source ~/.zshrc${R}\n\n"
      ;;
    *)
      printf "  ${FG_GREEN}Reloading shell...${R}\n\n"
      exec zsh -l
      ;;
  esac
}

# ─── MAIN ────────────────────────────────────────────────────────────────────

main() {
  print_header
  parse_args "$@"
  check_shell
  install_core
  setup_plugins
  patch_zshrc
  patch_bashrc
  configure_fonts
  switch_shell
  install_uninstaller
  print_summary
}

main "$@"