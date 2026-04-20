# ╔═══════════════════════════════════════════════════════════════════╗
# ║  aporia.zsh-theme — Dark Flame Edition                            ║
# ║  Author : Ahmed Mardi · github.com/fr3on                          ║
# ║  Cross-platform: macOS + Linux · Requires Nerd Font               ║
# ║                                                                   ║
# ║  Install:                                                         ║
# ║    source ~/.aporia.zsh-theme   (add to ~/.zshrc)                 ║
# ╚═══════════════════════════════════════════════════════════════════╝

# Guard: Ensure we are running in Zsh
if [[ -z $ZSH_VERSION ]]; then
  _sh="unknown"
  [[ -n $BASH_VERSION ]] && _sh="Bash"
  printf "\033[1;31m[aporia] Error: This theme requires Zsh but you are in $_sh.\033[0m\n" >&2
  
  # Auto-switch for interactive shells if zsh is available
  if [[ $- == *i* ]] && command -v zsh >/dev/null; then
    printf "         \033[1;33mSwitching to Zsh...\033[0m\n" >&2
    exec zsh
  fi

  printf "         Run \033[1;32mzsh\033[0m to switch shells.\n" >&2
  return 1 2>/dev/null || exit 1
fi

# Aporia Version
export APORIA_VERSION="1.1.0"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  INTERNAL UTILS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Load modules
zmodload zsh/datetime 2>/dev/null
zmodload zsh/parameter 2>/dev/null
zmodload zsh/system 2>/dev/null

autoload -Uz is-at-least

if is-at-least 5.8 && [[ -n $EPOCHSECONDS ]]; then
  _ap_now() { echo $EPOCHSECONDS }
else
  _ap_now() { date +%s }
fi

# Platform detection
_ap_is_macos() { [[ $(uname -s) == "Darwin" ]]; }
_ap_is_linux() { [[ $(uname -s) == "Linux"  ]]; }

# Distro Detection logic
_ap_get_os_icon() {
  if _ap_is_macos; then
    echo ""   # Apple
    return
  fi

  _AP_OS_RELEASE=${_AP_OS_RELEASE:-/etc/os-release}
  if [[ -f $_AP_OS_RELEASE ]]; then
    local id=$(grep -E "^ID=" "$_AP_OS_RELEASE" | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
    case "$id" in
      # ── Debian family ───────────────────────────────────────
      debian)        echo "󰣚" ;;
      ubuntu)        echo "󰕈" ;;
      linuxmint)     echo "󰣭" ;;
      pop)           echo "󰣛" ;;   # Pop!_OS
      elementary)    echo "󰣫" ;;
      zorin)         echo "󰣼" ;;
      kali)          echo "󰣘" ;;
      parrot)        echo "󰓅" ;;
      mx)            echo "󰵆" ;;   # MX Linux
      deepin)        echo "󰣰" ;;
      raspbian)      echo "󰐕" ;;

      # ── Red Hat family ──────────────────────────────────────
      fedora)        echo "󰣛" ;;
      rhel)          echo "󰮤" ;;   # Red Hat Enterprise
      centos)        echo "󰣙" ;;
      rocky)         echo "󰺆" ;;
      alma|almalinux) echo "󰮤" ;;
      ol|oraclelinux) echo "󰮤" ;;
      scientific)    echo "󰮤" ;;

      # ── Arch family ─────────────────────────────────────────
      arch)          echo "󰣇" ;;
      manjaro)       echo "󱘊" ;;
      endeavouros)   echo "󰣙" ;;
      garuda)        echo "󰛓" ;;
      artix)         echo "󰣇" ;;
      blackarch)     echo "󰣇" ;;
      parabola)      echo "󰣇" ;;
      hyperbola)     echo "󰣇" ;;

      # ── SUSE family ─────────────────────────────────────────
      opensuse*|opensuse-leap|opensuse-tumbleweed) echo "󰗊" ;;
      sles)          echo "󰗊" ;;

      # ── Gentoo family ───────────────────────────────────────
      gentoo)        echo "󰣨" ;;
      funtoo)        echo "󰣨" ;;
      calculate)     echo "󰣨" ;;

      # ── Slackware family ────────────────────────────────────
      slackware)     echo "󰓽" ;;

      # ── Alpine & minimal ────────────────────────────────────
      alpine)        echo "󰣗" ;;
      void)          echo "󰣵" ;;
      musl)          echo "󰌽" ;;
      buildroot)     echo "󰌽" ;;

      # ── Nix ─────────────────────────────────────────────────
      nixos)         echo "󱄅" ;;

      # ── Immutable / atomic ──────────────────────────────────
      silverblue|kinoite|sericea) echo "󰣛" ;;   # Fedora spins
      vanillaos)     echo "󰮯" ;;
      blendos)       echo "󰌽" ;;

      # ── BSD (appears in /etc/os-release on some BSDs) ───────
      freebsd)       echo "󰻀" ;;
      openbsd)       echo "󰻀" ;;
      netbsd)        echo "󰻀" ;;
      dragonfly)     echo "󰻀" ;;
      ghostbsd)      echo "󰻀" ;;

      # ── Mobile / embedded ───────────────────────────────────
      android)       echo "󰀲" ;;
      postmarketos)  echo "󰠓" ;;
      sailfishos)    echo "󰓅" ;;
      tizen)         echo "󰌽" ;;

      # ── Other notable ───────────────────────────────────────
      solus)         echo "󰣼" ;;
      mageia)        echo "󰣼" ;;
      pclinuxos)     echo "󰣼" ;;
      rosa)          echo "󰣼" ;;
      clearlinux*)   echo "󰣼" ;;   # Intel Clear Linux
      chromeos)      echo "󰊯" ;;
      steamos)       echo "󰓓" ;;   # Steam Deck
      tails)         echo "󰒄" ;;
      whonix)        echo "󰒄" ;;
      qubes)         echo "󰒄" ;;

      # ── WSL detection ───────────────────────────────────────
      *)
        # Check if running inside WSL even if distro is unknown
        if [[ -n $WSL_DISTRO_NAME || -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
          echo "󰍲"   # Windows logo for WSL
        else
          echo "󰌽"   # Generic Linux penguin
        fi
        ;;
    esac
  else
    # No /etc/os-release — check uname for BSDs
    local kernel=$(uname -s)
    case "$kernel" in
      FreeBSD|OpenBSD|NetBSD|DragonFly) echo "󰻀" ;;
      SunOS)  echo "󰖣" ;;
      AIX)    echo "󰌽" ;;
      *)      echo "󰌽" ;;
    esac
  fi
}

# Get detailed OS/Distro name
_ap_get_os_name() {
  if _ap_is_macos; then
    local ver=$(sw_vers -productVersion)
    echo "macOS $ver"
    return
  fi

  if [[ -f /etc/os-release ]]; then
    local name=$(grep -E "^PRETTY_NAME=" /etc/os-release | cut -d= -f2 | tr -d '"')
    [[ -z $name ]] && name=$(grep -E "^NAME=" /etc/os-release | cut -d= -f2 | tr -d '"')
    [[ -n $name ]] && echo "$name" && return
  fi

  uname -s
}

# Check if current locale supports UTF-8
_ap_is_utf8() {
  case "${LANG:-}${LC_ALL:-}${LC_CTYPE:-}" in
    *UTF-8*|*utf8*) return 0 ;;
    *) return 1 ;;
  esac
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  FEATURE FLAGS — toggle segments on/off
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AP_SHOW_SSH=${AP_SHOW_SSH:-1}         # user@host (SSH sessions only)
AP_SHOW_GIT=${AP_SHOW_GIT:-1}         # git branch + dirty/ahead/behind
AP_SHOW_LANGS=${AP_SHOW_LANGS:-1}     # python / node / rust versions
AP_SHOW_EXEC_TIME=${AP_SHOW_EXEC_TIME:-1}   # execution time (> threshold)
AP_EXEC_TIME_THRESHOLD=${AP_EXEC_TIME_THRESHOLD:-2}   # seconds
AP_SHOW_EXIT_CODE=${AP_SHOW_EXIT_CODE:-1}   # non-zero exit codes
AP_SHOW_TIME=${AP_SHOW_TIME:-1}       # clock on right
AP_DIR_DEPTH=${AP_DIR_DEPTH:-3}       # how many path segments to show

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  GLYPHS & ICONOGRAPHY
#  Tiered support: Nerd Font > Standard Unicode > ASCII
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AP_USE_NERD_FONT=${AP_USE_NERD_FONT:-1}   # Toggle rich Nerd Font icons
AP_ASCII_FALLBACK=${AP_ASCII_FALLBACK:-0} # Force text-only mode

if [[ $AP_ASCII_FALLBACK -eq 1 ]] || ! _ap_is_utf8; then
  # Tier 3: ASCII Fallback
  _AP_SEP_L=">"
  _AP_SEP_R="<"
  _AP_ICO_GIT="git"
  _AP_ICO_SSH="ssh"
  _AP_ICO_DIR="/"
  _AP_ICO_OK="ok"
  _AP_ICO_ERR="!!"
  _AP_ICO_TIME="at"
  _AP_ICO_EXEC="+"
  _AP_ICO_PY="py"
  _AP_ICO_NODE="js"
  _AP_ICO_RUST="rs"
  _AP_ICO_GO="go"
  _AP_ICO_DIRTY="*"
  _AP_ICO_AHEAD="^"
  _AP_ICO_BEHIND="v"
  _AP_ICO_STASH="$"
  _AP_ICO_DOCKER="dkr"
  _AP_ICO_PROMPT=">"
elif [[ $AP_USE_NERD_FONT -eq 0 ]]; then
  # Tier 2: Standard Unicode (Compatibility Mode)
  _AP_SEP_L="❯"
  _AP_SEP_R="❮"
  _AP_ICO_GIT="±"
  _AP_ICO_SSH="⇄"
  _AP_ICO_DIR="»"
  _AP_ICO_OK="✓"
  _AP_ICO_ERR="✘"
  _AP_ICO_TIME="at"
  _AP_ICO_EXEC="+"
  _AP_ICO_PY="py"
  _AP_ICO_NODE="js"
  _AP_ICO_RUST="rs"
  _AP_ICO_GO="go"
  _AP_ICO_PHP="php"
  _AP_ICO_RUBY="rb"
  _AP_ICO_JAVA="java"
  _AP_ICO_CPP="c++"
  _AP_ICO_DIRTY="*"
  _AP_ICO_AHEAD="↑"
  _AP_ICO_BEHIND="↓"
  _AP_ICO_STASH="⚑"
  _AP_ICO_DOCKER="dkr"
  _AP_ICO_PROMPT="❯"
else
  # Tier 1: Nerd Font (Rich Mode)
  _AP_SEP_L="❯"
  _AP_SEP_R="❮"
  _AP_ICO_GIT="⎇"
  _AP_ICO_SSH="⇄"
  _AP_ICO_DIR="›"
  _AP_ICO_OK="✓"
  _AP_ICO_ERR="✘"
  _AP_ICO_TIME="◷"
  _AP_ICO_EXEC="󱎫"
  _AP_ICO_PY=""
  _AP_ICO_NODE=""
  _AP_ICO_RUST=""
  _AP_ICO_GO="󰟓"
  _AP_ICO_RUBY=""
  _AP_ICO_PHP="󰌟"
  _AP_ICO_JAVA=""
  _AP_ICO_CPP=""
  _AP_ICO_DIRTY="󰝥"
  _AP_ICO_AHEAD="↑"
  _AP_ICO_BEHIND="↓"
  _AP_ICO_STASH="󰟫"
  _AP_ICO_DOCKER="󰡨"
  _AP_ICO_PROMPT="❯"
fi

# [3] OS-Specific Branding
_AP_ICO_OS=$(_ap_get_os_icon)

# Override OS icon in compatibility modes
if [[ $AP_ASCII_FALLBACK -eq 1 ]] || ! _ap_is_utf8; then
  _AP_ICO_OS="L"
elif [[ $AP_USE_NERD_FONT -eq 0 ]]; then
  if _ap_is_macos; then _AP_ICO_OS=""; else _AP_ICO_OS="L"; fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  COLOR PALETTE  (256-color for max terminal compat)
#  Presets: deep_blue (default), light, amber
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

_ap_apply_theme() {
  case "${AP_THEME:-deep_blue}" in
    light)
      AP_C_BG0=${AP_C_BG0:-255}        # white
      AP_C_BG1=${AP_C_BG1:-252}        # light gray
      AP_C_BG2=${AP_C_BG2:-248}        # silver
      AP_C_BG3=${AP_C_BG3:-244}        # gray
      AP_C_WHITE=${AP_C_WHITE:-235}    # dark text
      AP_C_BLUE=${AP_C_BLUE:-25}       # navy
      AP_C_GREEN=${AP_C_GREEN:-28}      # dark green
      AP_C_YELLOW=${AP_C_YELLOW:-136}   # muddy gold
      AP_C_RED=${AP_C_RED:-124}         # dark red
      AP_C_ORANGE=${AP_C_ORANGE:-130}   # burnt orange
      AP_C_PURPLE=${AP_C_PURPLE:-55}    # indigo
      AP_C_CYAN=${AP_C_CYAN:-31}        # teal
      AP_C_GRAY=${AP_C_GRAY:-240}       # dim gray
      ;;
    amber)
      AP_C_BG0=${AP_C_BG0:-234}        # dark brown/gray
      AP_C_BG1=${AP_C_BG1:-235}        # slightly lighter
      AP_C_BG2=${AP_C_BG2:-237}        # brownish gray
      AP_C_BG3=${AP_C_BG3:-239}        # mid gray
      AP_C_WHITE=${AP_C_WHITE:-223}    # soft cream
      AP_C_BLUE=${AP_C_BLUE:-109}      # dusty blue
      AP_C_GREEN=${AP_C_GREEN:-108}     # sage green
      AP_C_YELLOW=${AP_C_YELLOW:-214}   # amber/orange
      AP_C_RED=${AP_C_RED:-167}         # terra cotta
      AP_C_ORANGE=${AP_C_ORANGE:-173}   # clay
      AP_C_PURPLE=${AP_C_PURPLE:-139}   # dusty purple
      AP_C_CYAN=${AP_C_CYAN:-108}       # muted cyan
      AP_C_GRAY=${AP_C_GRAY:-243}       # warm gray
      ;;
    *) # deep_blue (default)
      AP_C_BG0=${AP_C_BG0:-232}        # near-black
      AP_C_BG1=${AP_C_BG1:-235}        # dark gray
      AP_C_BG2=${AP_C_BG2:-238}        # mid gray
      AP_C_BG3=${AP_C_BG3:-241}        # light gray
      AP_C_WHITE=${AP_C_WHITE:-255}     # bright white
      AP_C_BLUE=${AP_C_BLUE:-39}        # electric blue
      AP_C_GREEN=${AP_C_GREEN:-82}      # bright green
      AP_C_YELLOW=${AP_C_YELLOW:-220}   # gold
      AP_C_RED=${AP_C_RED:-196}         # bright red
      AP_C_ORANGE=${AP_C_ORANGE:-208}   # orange
      AP_C_PURPLE=${AP_C_PURPLE:-135}   # purple
      AP_C_CYAN=${AP_C_CYAN:-51}        # cyan
      AP_C_GRAY=${AP_C_GRAY:-242}       # mid gray text
      ;;
  esac
}
_ap_apply_theme

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ADAPTIVE CONTEXT (Root / Locale)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# [1] Root User Adaptivity is evaluated per-prompt below

# [2] Auto-Locale Fix
if ! _ap_is_utf8; then
  export LANG="en_US.UTF-8"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  LOCALE WARNING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if ! _ap_is_utf8 && [[ ${AP_HIDE_LOCALE_WARN:-0} -eq 0 ]]; then
  print -P "%F{$AP_C_YELLOW}[aporia] Warning: Non-UTF-8 locale detected. Falling back to ASCII mode.%f"
  print -P "%F{$AP_C_GRAY}        Set LANG=\"en_US.UTF-8\" in your .zshrc to enable icons.%f"
  AP_HIDE_LOCALE_WARN=1
fi


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  SEGMENT HELPERS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# _ap_lseg <fg> <bg> <text> [next_bg]
# Renders a left-side powerline segment with flame separator
_ap_lseg() {
  local fg=$1 bg=$2 text=$3 next_bg=${4:-$AP_C_BG0}
  echo -n "%K{$bg}%F{$fg} $text %F{$bg}%K{$next_bg}${_AP_SEP_L}"
}

# _ap_rseg <sep_bg> <fg> <bg> <text>
# Renders a right-side powerline segment
_ap_rseg() {
  local sep_bg=$1 fg=$2 bg=$3 text=$4
  echo -n "%F{$bg}%K{$sep_bg}${_AP_SEP_R}%K{$bg}%F{$fg} $text "
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  GIT STATUS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_ap_git_info() {
  command git rev-parse --is-inside-work-tree &>/dev/null || { echo "NONE"; return 1; }

  local branch dirty ahead=0 behind=0

  # Branch name or short SHA (detached HEAD)
  branch=$(command git symbolic-ref --short HEAD 2>/dev/null)
  [[ -z $branch ]] && branch=$(command git rev-parse --short HEAD 2>/dev/null)
  [[ -z $branch ]] && { echo "NONE"; return 1; }

  # Dirty check (unstaged + staged + untracked)
  if ! command git diff --quiet 2>/dev/null || \
     ! command git diff --cached --quiet 2>/dev/null || \
     [[ -n $(command git ls-files --others --exclude-standard 2>/dev/null | head -1) ]]; then
    dirty=1
  fi

  # Ahead / behind upstream
  local ab
  ab=$(command git rev-list --count --left-right "@{upstream}...HEAD" 2>/dev/null)
  if [[ -n $ab ]]; then
    behind=${ab%%$'\t'*}
    ahead=${ab##*$'\t'}
  fi

  # Stash count
  local stash=0
  stash=$(command git stash list 2>/dev/null | wc -l | tr -d ' ')

  # Build label
  local label="${_AP_ICO_GIT} $branch"
  [[ -n $dirty   ]] && label+=" ${_AP_ICO_DIRTY}"
  (( ahead  > 0 )) && label+=" ${_AP_ICO_AHEAD}$ahead"
  (( behind > 0 )) && label+=" ${_AP_ICO_BEHIND}$behind"
  (( stash  > 0 )) && label+=" ${_AP_ICO_STASH}$stash"

  # Colour: green=clean, yellow=dirty, red=conflict zone
  local color=$AP_C_GREEN
  [[ -n $dirty   ]] && color=$AP_C_YELLOW
  (( behind > 0 )) && color=$AP_C_RED
  (( stash  > 0 && stash < 5 )) && [[ $color == $AP_C_GREEN ]] && color=$AP_C_YELLOW

  echo "$color $label"    # "COLOR label"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  LANGUAGE VERSIONS  (project-aware, lazy)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_ap_lang_info() {
  # Language versions only (venv handled separately)
  local parts=()

  # Node — only inside a node project
  if _ap_find_up "package.json" ".node-version" ".nvmrc"; then
    local nv
    nv=$(command node --version 2>/dev/null) && \
      parts+=("%F{$AP_C_GREEN}${_AP_ICO_NODE} $nv%f")
  fi

  # Rust — only inside a cargo project
  if _ap_find_up "Cargo.toml"; then
    local rv
    rv=$(command rustc --version 2>/dev/null | awk '{print $2}') && \
      [[ -n $rv ]] && parts+=("%F{$AP_C_ORANGE}${_AP_ICO_RUST} $rv%f")
  fi

  # Go — only inside a go project
  if _ap_find_up "go.mod" "go.sum"; then
    local gv
    gv=$(command go version 2>/dev/null | awk '{print $3}') && \
      [[ -n $gv ]] && parts+=("%F{$AP_C_CYAN}${_AP_ICO_GO} ${gv#go}%f")
  fi

  # Ruby — only inside a ruby project
  if _ap_find_up "Gemfile" ".ruby-version"; then
    local rbv
    rbv=$(command ruby -e 'puts RUBY_VERSION' 2>/dev/null) && \
      [[ -n $rbv ]] && parts+=("%F{$AP_C_RED}${_AP_ICO_RUBY} $rbv%f")
  fi

  # PHP — only inside a php project
  if _ap_find_up "composer.json" "index.php"; then
    local phpv
    phpv=$(command php -v 2>/dev/null | head -n 1 | awk '{print $2}') && \
      [[ -n $phpv ]] && parts+=("%F{$AP_C_PURPLE}${_AP_ICO_PHP} $phpv%f")
  fi

  # Java — only inside a java project
  if _ap_find_up "pom.xml" "build.gradle" ".java-version"; then
    local jv
    jv=$(command java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}') && \
      [[ -n $jv ]] && parts+=("%F{$AP_C_WHITE}${_AP_ICO_JAVA} $jv%f")
  fi

  # C++ — only inside a C++ project
  if _ap_find_up "CMakeLists.txt" "Makefile" "meson.build" "build.ninja" "*.cpp" "*.cxx" "*.cc" "*.c++"; then
    local cppv
    cppv=$(command c++ --version 2>/dev/null | head -n 1 | awk '{print $NF}') &&
      [[ -n $cppv ]] && parts+=("%F{$AP_C_BLUE}${_AP_ICO_CPP} $cppv%f")
  fi

  local out="${(j: :)parts}"
  [[ -z $out ]] && echo "NONE" || echo "$out"
}

# Walk up directory tree looking for any of the given filenames or globs
# Optimized to check for direct matches before attempting globs
_ap_find_up() {
  local dir=$PWD
  local f
  while true; do
    for f in "$@"; do
      if [[ -e "$dir/$f" ]]; then
        return 0
      fi
      # If f contains glob characters, try globbing
      if [[ $f == *[*?]* ]]; then
        local matches=("$dir"/$~f(N[1]))
        [[ ${#matches[@]} -gt 0 ]] && return 0
      fi
    done
    [[ $dir == "/" || $dir == "$HOME" ]] && break
    dir=${dir:h}
  done
  return 1
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  VIRTUAL ENV & DOCKER CONTEXT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

_ap_venv_info() {
  local venv=""
  if [[ -n $VIRTUAL_ENV ]]; then
    venv=$(basename "$VIRTUAL_ENV")
  elif [[ -n $CONDA_DEFAULT_ENV && $CONDA_DEFAULT_ENV != "base" ]]; then
    venv=$CONDA_DEFAULT_ENV
  fi

  [[ -n $venv ]] && echo "$venv"
}

_ap_docker_info() {
  # Requires docker binary
  (( $+commands[docker] )) || return 1

  # Cache docker context for the session (refreshed only when needed)
  if [[ -z $_ap_docker_cache || $_ap_docker_cache_pwd != $PWD ]]; then
    local ctx
    ctx=$(command docker context show 2>/dev/null)
    if [[ -n $ctx && $ctx != "default" ]]; then
      _ap_docker_cache="$ctx"
    else
      _ap_docker_cache=""
    fi
    _ap_docker_cache_pwd=$PWD
  fi

  [[ -n $_ap_docker_cache ]] && echo "$_ap_docker_cache"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  EXECUTION TIME
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
typeset -g _ap_cmd_start=0
typeset -g _ap_last_exec_time=""

_ap_preexec() {
  _ap_cmd_start=$(_ap_now)
}

_ap_calc_exec_time() {
  _ap_last_exec_time=""
  [[ $_ap_cmd_start -eq 0 ]] && return
  local elapsed=$(( $(_ap_now) - _ap_cmd_start ))
  _ap_cmd_start=0
  (( elapsed < AP_EXEC_TIME_THRESHOLD )) && return

  local out
  if   (( elapsed >= 3600 )); then
    out="$(( elapsed/3600 ))h $(( elapsed%3600/60 ))m $(( elapsed%60 ))s"
  elif (( elapsed >= 60 )); then
    out="$(( elapsed/60 ))m $(( elapsed%60 ))s"
  else
    out="${elapsed}s"
  fi
  _ap_last_exec_time="${_AP_ICO_EXEC} $out"
}


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  MAIN PROMPT BUILDER  (runs every precmd)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_ap_build_prompt() {
  local last_exit=$?          # capture IMMEDIATELY — first line
  typeset -g _ap_last_exit=$last_exit  # share with iTerm2 hook
  _ap_calc_exec_time          # calc before anything resets EPOCHSECONDS

  local LEFT="" RIGHT=""
  local prev_bg=$AP_C_BG0     # tracks last bg for separator chaining

  # ── LEFT SIDE ───────────────────────────────────────────────────

  # [1] SSH and User context
  if (( AP_SHOW_SSH )) && [[ -n $SSH_CONNECTION || -n $SSH_CLIENT ]]; then
    # Show SSH icon and user@host in orange/white
    LEFT+="%F{$AP_C_ORANGE}${_AP_ICO_SSH} %F{$AP_C_WHITE}%n@%m %f"
  fi

  # Always show OS branding icon for normal users
  # For root (UID 0), this is redundant as the prompt character itself becomes the OS icon
  if [[ $UID -ne 0 && $EUID -ne 0 ]]; then
    LEFT+="%F{$AP_C_GRAY}${_AP_ICO_OS} %f"
  fi

  # [2] Directory
  LEFT+="%F{$AP_C_BLUE}${_AP_ICO_DIR} %${AP_DIR_DEPTH}~ "

  # [3] Venv / Conda
  local venv=$(_ap_venv_info)
  if [[ -n $venv ]]; then
    LEFT+="%F{$AP_C_GRAY}${_AP_SEP_L} %F{$AP_C_CYAN}${_AP_ICO_PY} $venv "
  fi

  # [4] Docker Context
  local dkr=$(_ap_docker_info)
  if [[ -n $dkr ]]; then
    LEFT+="%F{$AP_C_GRAY}${_AP_SEP_L} %F{$AP_C_BLUE}${_AP_ICO_DOCKER} $dkr "
  fi

  # [5] Git segment
  if (( AP_SHOW_GIT )); then
    local git_raw=${_AP_ASYNC_DATA[git]:-}
    if [[ -z $git_raw ]]; then
       _ap_async_request "git" "_ap_git_info"
       git_raw="$AP_C_GRAY ${_AP_ICO_GIT} ..."
    elif [[ ${_AP_ASYNC_PWDS[git]:-} != $PWD ]]; then
       _ap_async_request "git" "_ap_git_info"
       _AP_ASYNC_PWDS[git]=$PWD
    fi

    if [[ $git_raw != "NONE" ]]; then
      local git_color=${git_raw%% *}
      local git_label=${git_raw#* }
      LEFT+="%F{$AP_C_GRAY}${_AP_SEP_L} %F{$git_color}$git_label "
    fi
  fi

  # [4] Prompt character — ❯ colored by exit status
  local prompt_icon="${_AP_ICO_PROMPT}"
  [[ $UID -eq 0 || $EUID -eq 0 ]] && prompt_icon="${_AP_ICO_OS}"

  if (( last_exit == 0 )); then
    LEFT+=" %B%F{$AP_C_GREEN}${prompt_icon}%f%b "
  else
    LEFT+=" %B%F{$AP_C_RED}${prompt_icon}%f%b "
  fi

  # ── RIGHT SIDE ──────────────────────────────────────────────────
  local width=$COLUMNS
  [[ -z $width || $width -eq 0 ]] && width=80  # fallback

  # [1] Exit code (non-zero only)
  if (( AP_SHOW_EXIT_CODE && last_exit != 0 )); then
    RIGHT+="%F{$AP_C_RED}${_AP_ICO_ERR} $last_exit  %f"
  fi

  # [2] Execution time (hide if < 60 chars)
  if (( AP_SHOW_EXEC_TIME )) && [[ -n $_ap_last_exec_time ]] && (( width > 60 )); then
    RIGHT+="%F{$AP_C_YELLOW}${_ap_last_exec_time}  %f"
  fi

  # [3] Language versions (async)
  if (( AP_SHOW_LANGS )) && (( width > 100 )); then
    local lang_raw=${_AP_ASYNC_DATA[lang]:-}
    if [[ -z $lang_raw || ${_AP_ASYNC_PWDS[lang]:-} != $PWD ]]; then
       _ap_async_request "lang" "_ap_lang_info"
       _AP_ASYNC_PWDS[lang]=$PWD
    fi
    [[ -n $lang_raw && $lang_raw != "NONE" ]] && RIGHT+="$lang_raw  "
  fi

  # [4] Clock (hide if < 80 chars)
  if (( AP_SHOW_TIME )) && (( width > 80 )); then
    RIGHT+="%F{$AP_C_GRAY}${_AP_ICO_TIME} %D{%H:%M}%f%k%b"
  fi

  PROMPT="$LEFT%f%k%b"
  [[ $TERM_PROGRAM == "iTerm.app" ]] && PROMPT+="%{\e]133;B\a%}"
  RPROMPT=$RIGHT

  # Clear RPROMPT if empty to avoid issues
  [[ -z $RPROMPT ]] && unset RPROMPT
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ASYNC WORKER ENGINE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
typeset -gA _AP_ASYNC_DATA
typeset -gA _AP_ASYNC_PIDS
typeset -gA _AP_ASYNC_PWDS

# Cleanup old scalar variables from previous versions to fix AUTO_NAME_DIRS leaks
unset _ap_async_git_pwd _ap_async_lang_pwd

_ap_async_handler() {
  local fd=$1
  local data
  read -r data <&$fd
  exec {fd}<&-  # close
  zle -F $fd    # unregister

  local key=${_AP_ASYNC_PIDS[$fd]}
  _AP_ASYNC_DATA[$key]=$data
  unset "_AP_ASYNC_PIDS[$fd]"

  # Redraw prompt
  zle reset-prompt
}

_ap_async_request() {
  local key=$1 cmd=$2
  local fd
  exec {fd}< <(eval "$cmd")
  _AP_ASYNC_PIDS[$fd]=$key
  zle -F $fd _ap_async_handler
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ZSH HOOKS & OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# PROMPT_SUBST lets us use $(...) and %n etc. inside PROMPT strings
setopt PROMPT_SUBST

# Register hooks
autoload -Uz add-zsh-hook
add-zsh-hook precmd _ap_build_prompt
add-zsh-hook preexec _ap_preexec

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  TITLE BAR  (iTerm2, GNOME Terminal, kitty, etc.)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_ap_set_title() {
  local title="${${(%):-"%~"}//[^[:print:]]/}"   # current dir, printable
  # xterm-compatible title escape (works on macOS Terminal, iTerm2, kitty, GNOME)
  print -Pn "\e]0;${title}\a"
}
_ap_set_title_preexec() {
  local cmd="${1//[^[:print:]]/}"
  print -Pn "\e]0;${cmd}\a"
}
add-zsh-hook precmd _ap_set_title
add-zsh-hook preexec _ap_set_title_preexec

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  OPTIONAL: iTerm2 shell integration marks
#  (enables jump-to-prompt, cmd output selection)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
  _ap_iterm2_prompt_start() { print -Pn "\e]133;D;${_ap_last_exit:-0}\a\e]133;A\a"; }
  _ap_iterm2_preexec()      { print -Pn "\e]133;C\a"; }

  add-zsh-hook precmd  _ap_iterm2_prompt_start
  add-zsh-hook preexec _ap_iterm2_preexec
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  APORIA PLUGIN SYSTEM
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_ap_load_plugins_system() {
  # Look for aporia.plugin.zsh in:
  # 1. Same directory as this theme file (developers/repo)
  # 2. $HOME (installed via installer)
  local theme_dir=${${(%):-%x}:h}
  local plugin_file=""

  if [[ -f "$theme_dir/aporia.plugin.zsh" ]]; then
    plugin_file="$theme_dir/aporia.plugin.zsh"
  elif [[ -f "$HOME/.aporia.plugin.zsh" ]]; then
    plugin_file="$HOME/.aporia.plugin.zsh"
  fi

  if [[ -n $plugin_file ]]; then
    source "$plugin_file"
  else
    # Fallback to absolute barebones if plugin file is missing
    local pdir="$HOME/.aporia/plugins"
    [[ -f "$pdir/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
      source "$pdir/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [[ -f "$pdir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
      source "$pdir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  fi
}

_ap_load_plugins_system
