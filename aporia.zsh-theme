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

# Guard against double-sourcing (e.g. `source ~/.zshrc` after editing).
if [[ -n ${_APORIA_LOADED:-} ]]; then
  # Remove prior hooks so we can re-register cleanly below.
  # We use the -d flag to delete them before re-adding, ensuring
  # the theme's main hooks always run FIRST in the chain.
  autoload -Uz add-zsh-hook
  add-zsh-hook -d precmd  _ap_build_prompt      2>/dev/null
  add-zsh-hook -d preexec _ap_preexec            2>/dev/null
  add-zsh-hook -d precmd  _ap_set_title          2>/dev/null
  add-zsh-hook -d preexec _ap_set_title_preexec  2>/dev/null
  add-zsh-hook -d precmd  _ap_iterm2_prompt_start 2>/dev/null
  add-zsh-hook -d preexec _ap_iterm2_preexec      2>/dev/null
  add-zsh-hook -d precmd  _ap_history_setup      2>/dev/null
fi
typeset -g _APORIA_LOADED=1

# Ensure essential hooks and modules are available
autoload -Uz add-zsh-hook
autoload -Uz is-at-least
zmodload zsh/datetime 2>/dev/null
zmodload zsh/stat 2>/dev/null
zmodload zsh/parameter 2>/dev/null
zmodload zsh/system 2>/dev/null
zmodload zsh/mathfunc 2>/dev/null

# ── Prompt options ───────────────────────────────────────────────────────────
# PROMPT_SUBST  — enables $var and %F{} expansion inside PROMPT/RPROMPT.
#                 Without this, %F{color} sequences are printed as literal text
#                 and Zsh miscounts the prompt width → ↑/↓ arrows jump lines.
# PROMPT_PERCENT — enables %-escape sequences (%n, %~, %F, %f, %B, %b, etc.)
# PROMPT_CR      — ensures the prompt starts at column 0 (prevents drift).
setopt PROMPT_SUBST PROMPT_PERCENT PROMPT_CR

# Essential hooks (precmd must be early to stop timer, preexec must be late to start timer)
add-zsh-hook precmd  _ap_build_prompt
# Note: preexec registration is moved to the end of the file to capture only the command.

# Aporia Version
export APORIA_VERSION="1.1.4"
export ZSH_THEME_NAME="aporia"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  INTERNAL UTILS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if is-at-least 5.8 && [[ -n $EPOCHREALTIME ]]; then
  _ap_now() { echo $EPOCHREALTIME }
elif [[ -n $EPOCHSECONDS ]]; then
  _ap_now() { echo $EPOCHSECONDS }
else
  _ap_now() { date +%s }
fi
# Force float math for time variables
typeset -g _ap_cmd_start=${_ap_cmd_start:-0}
typeset -g _ap_last_exec_time=${_ap_last_exec_time:-""}

# Platform detection
_ap_is_macos() { [[ $(uname -s) == "Darwin" ]]; }
_ap_is_linux() { [[ $(uname -s) == "Linux"  ]]; }

# Distro Detection logic
_ap_get_os_icon() {
  if _ap_is_macos; then
    echo ""   # Apple
    return
  fi

  # Check if running inside WSL even if distro is unknown
  if [[ -n $WSL_DISTRO_NAME || -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
    echo "󰍲"   # Windows logo for WSL
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

      # ── Default Linux fallback ──────────────────────────────
      *)
        echo "󰌽"   # Generic Linux penguin
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
  local locale="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
  case "$locale" in
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
AP_EXEC_TIME_THRESHOLD=${AP_EXEC_TIME_THRESHOLD:-0}   # seconds (0 = show for all commands)
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
  _AP_ICO_STAGED="+"
  _AP_ICO_MODIFIED="!"
  _AP_ICO_UNTRACKED="?"
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
  _AP_ICO_STAGED="+"
  _AP_ICO_MODIFIED="!"
  _AP_ICO_UNTRACKED="?"
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
  _AP_ICO_STAGED="+"
  _AP_ICO_MODIFIED="!"
  _AP_ICO_UNTRACKED="?"
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
  # Tier 2 Unicode fallback — use standard characters on all platforms.
  if _ap_is_macos; then _AP_ICO_OS="⌘"; else _AP_ICO_OS="L"; fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  COLOR PALETTE  (256-color for max terminal compat)
#  Presets: deep_blue (default), light, amber
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

_ap_apply_theme() {
  case "${AP_THEME:-deep_blue}" in
    light)
      AP_C_BG0=255        # white
      AP_C_BG1=252        # light gray
      AP_C_BG2=248        # silver
      AP_C_BG3=244        # gray
      AP_C_WHITE=235    # dark text
      AP_C_BLUE=25       # navy
      AP_C_GREEN=28      # dark green
      AP_C_YELLOW=136   # muddy gold
      AP_C_RED=124         # dark red
      AP_C_ORANGE=130   # burnt orange
      AP_C_PURPLE=55    # indigo
      AP_C_CYAN=31        # teal
      AP_C_GRAY=240       # dim gray
      ;;
    amber)
      AP_C_BG0=234        # dark brown/gray
      AP_C_BG1=235        # slightly lighter
      AP_C_BG2=237        # brownish gray
      AP_C_BG3=239        # mid gray
      AP_C_WHITE=223    # soft cream
      AP_C_BLUE=109      # dusty blue
      AP_C_GREEN=108     # sage green
      AP_C_YELLOW=214   # amber/orange
      AP_C_RED=167         # terra cotta
      AP_C_ORANGE=173   # clay
      AP_C_PURPLE=139   # dusty purple
      AP_C_CYAN=108       # muted cyan
      AP_C_GRAY=243       # warm gray
      ;;
    crimson_void)
      AP_C_BG0=232        # deep black
      AP_C_BG1=233        # black
      AP_C_BG2=234        # dark red-tinted gray
      AP_C_BG3=235        # dark gray
      AP_C_WHITE=254     # white
      AP_C_BLUE=202       # sunset orange
      AP_C_GREEN=28       # deep forest green
      AP_C_YELLOW=214     # gold
      AP_C_RED=196        # blood red
      AP_C_ORANGE=208     # bright orange
      AP_C_PURPLE=125     # deep magenta
      AP_C_CYAN=161       # crimson cyan (muted pinkish red)
      AP_C_GRAY=239       # dim red-gray
      ;;
    forest_matrix)
      AP_C_BG0=16         # true black
      AP_C_BG1=232        # off-black
      AP_C_BG2=234        # dark gray
      AP_C_BG3=235        # mid gray
      AP_C_WHITE=121      # pale green text
      AP_C_BLUE=34        # forest green
      AP_C_GREEN=46       # matrix bright green
      AP_C_YELLOW=190     # lime
      AP_C_RED=124        # dark red (subtle)
      AP_C_ORANGE=28      # green-orange
      AP_C_PURPLE=22      # deep green
      AP_C_CYAN=48        # spring green
      AP_C_GRAY=240       # gray
      ;;
    *) # deep_blue (default)
      AP_C_BG0=232        # near-black
      AP_C_BG1=235        # dark gray
      AP_C_BG2=238        # mid gray
      AP_C_BG3=241        # light gray
      AP_C_WHITE=255     # bright white
      AP_C_BLUE=39        # electric blue
      AP_C_GREEN=82      # bright green
      AP_C_YELLOW=220   # gold
      AP_C_RED=196         # bright red
      AP_C_ORANGE=208   # orange
      AP_C_PURPLE=135   # purple
      AP_C_CYAN=51        # cyan
      AP_C_GRAY=242       # mid gray text
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
#  HISTORY & INTERACTION (Professional Defaults)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_ap_history_setup() {
  # Only set if not already configured to a useful value
  # Note: many default distros set SAVEHIST=0 or HISTSIZE=30, which breaks persistence.
  [[ -z $HISTFILE || $HISTFILE == "$HOME" ]] && export HISTFILE="$HOME/.zsh_history"
  [[ ${HISTSIZE:-0} -lt 1000 ]] && export HISTSIZE=10000
  [[ ${SAVEHIST:-0} -lt 1000 ]] && export SAVEHIST=10000

  # Sensible history options for a high-end environment
  setopt APPEND_HISTORY          # Append to history file instead of overwriting
  setopt SHARE_HISTORY           # Share history between sessions
  setopt INC_APPEND_HISTORY      # Write to history file immediately
  setopt HIST_IGNORE_DUPS        # Don't record dups
  setopt HIST_IGNORE_SPACE       # Don't record commands starting with space
  setopt HIST_REDUCE_BLANKS      # Remove extra blanks
  setopt HIST_VERIFY             # Don't execute immediately upon history expansion
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  LOCALE WARNING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if ! _ap_is_utf8 && [[ ${AP_HIDE_LOCALE_WARN:-0} -eq 0 ]]; then
  print -P "%F{$AP_C_YELLOW}[aporia] Warning: Non-UTF-8 locale detected. Falling back to ASCII mode.%f"
  print -P "%F{$AP_C_GRAY}        Set LANG=\"en_US.UTF-8\" in your .zshrc to enable icons.%f"
  AP_HIDE_LOCALE_WARN=1
fi



# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  GIT STATUS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_ap_segment_git() {
  command git rev-parse --is-inside-work-tree &>/dev/null || { echo "NONE"; return 1; }

  local branch dirty ahead=0 behind=0
  local staged=0 modified=0 untracked=0

  # Branch name or short SHA (detached HEAD)
  branch=$(command git symbolic-ref --short HEAD 2>/dev/null)
  [[ -z $branch ]] && branch=$(command git rev-parse --short HEAD 2>/dev/null)
  [[ -z $branch ]] && { echo "NONE"; return 1; }

  # Parse porcelain status for counts
  local git_status
  git_status=$(command git status --porcelain 2>/dev/null)
  if [[ -n $git_status ]]; then
    dirty=1
    staged=$(echo "$git_status" | grep -c "^[MADRC]")
    modified=$(echo "$git_status" | grep -c "^.[MD]")
    untracked=$(echo "$git_status" | grep -c "??")
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

  # Build label parts
  local -a git_parts=()
  git_parts+=("${_AP_ICO_GIT} $branch")
  
  if [[ -n $dirty ]]; then
    (( staged    > 0 )) && git_parts+=("${_AP_ICO_STAGED}$staged")
    (( modified  > 0 )) && git_parts+=("${_AP_ICO_MODIFIED}$modified")
    (( untracked > 0 )) && git_parts+=("${_AP_ICO_UNTRACKED}$untracked")
    
    # Fallback: if somehow dirty but no specific counts, show the indicator
    if [[ ${#git_parts} -eq 1 ]]; then
       git_parts+=("${_AP_ICO_DIRTY}")
    fi
  fi
  
  (( ahead  > 0 )) && git_parts+=("${_AP_ICO_AHEAD}$ahead")
  (( behind > 0 )) && git_parts+=("${_AP_ICO_BEHIND}$behind")
  (( stash  > 0 )) && git_parts+=("${_AP_ICO_STASH}$stash")

  # Join with single spaces
  local label="${(j: :)git_parts}"

  # Colour: green=clean, yellow=dirty, red=conflict zone
  local color=$AP_C_GREEN
  [[ -n $dirty   ]] && color=$AP_C_YELLOW
  (( behind > 0 )) && color=$AP_C_RED
  (( stash  > 0 && stash < 5 )) && [[ $color == $AP_C_GREEN ]] && color=$AP_C_YELLOW

  echo "$color $label"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  LANGUAGE VERSIONS  (project-aware, lazy)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Optimized _ap_lang_info: single pass up the directory tree
_ap_segment_lang() {
  local parts=()
  local dir=$PWD
  local -A found

  local nvm_ver=""
  # Walk up the tree once and collect project indicators
  while true; do
    # Node
    if [[ -z ${found[node]} ]]; then
      if [[ -f "$dir/package.json" ]]; then
        found[node]=1
      elif [[ -f "$dir/.nvmrc" ]]; then
        found[node]=1; nvm_ver=$(head -n 1 "$dir/.nvmrc" 2>/dev/null)
      elif [[ -f "$dir/.node-version" ]]; then
        found[node]=1; nvm_ver=$(head -n 1 "$dir/.node-version" 2>/dev/null)
      fi
    fi
    # Deno
    [[ -z ${found[deno]} ]] && [[ -f "$dir/deno.json" || -f "$dir/deno.jsonc" ]] && found[deno]=1
    # Rust
    [[ -z ${found[rust]} ]] && [[ -f "$dir/Cargo.toml" ]] && found[rust]=1
    # Go
    [[ -z ${found[go]} ]] && [[ -f "$dir/go.mod" || -f "$dir/go.sum" ]] && found[go]=1
    # Ruby
    [[ -z ${found[ruby]} ]] && [[ -f "$dir/Gemfile" || -f "$dir/.ruby-version" ]] && found[ruby]=1
    # PHP
    [[ -z ${found[php]} ]] && [[ -f "$dir/composer.json" || -f "$dir/index.php" ]] && found[php]=1
    # Java
    [[ -z ${found[java]} ]] && [[ -f "$dir/pom.xml" || -f "$dir/build.gradle" || -f "$dir/.java-version" ]] && found[java]=1
    # Python
    [[ -z ${found[python]} ]] && [[ -f "$dir/pyproject.toml" || -f "$dir/setup.py" || -f "$dir/requirements.txt" || -f "$dir/.python-version" ]] && found[python]=1
    # C++
    if [[ -z ${found[cpp]} ]]; then
      # Faster glob check for C++ files
      local cpp_files=("$dir"/(CMakeLists.txt|Makefile|meson.build|build.ninja|*.cpp|*.cxx|*.cc|*.c++)(N[1]))
      [[ ${#cpp_files[@]} -gt 0 ]] && found[cpp]=1
    fi

    [[ $dir == "/" || $dir == "$HOME" ]] && break
    dir=${dir:h}
  done

  # Run version commands only for found projects
  if [[ -n ${found[deno]} ]]; then
    local denov; denov=$(command deno --version 2>/dev/null | head -n 1 | awk '{print $2}') && [[ -n $denov ]] && parts+=("%F{$AP_C_WHITE}🦕 $denov%f")
  elif [[ -n ${found[node]} ]]; then
    local nv
    if [[ -n $nvm_ver ]]; then
      nv="${nvm_ver#v}"
    else
      nv=$(command node --version 2>/dev/null)
      nv="${nv#v}"
    fi
    [[ -n $nv ]] && parts+=("%F{$AP_C_GREEN}${_AP_ICO_NODE} $nv%f")
  fi
  if [[ -n ${found[rust]} ]]; then
    local rv; rv=$(command rustc --version 2>/dev/null | awk '{print $2}') && [[ -n $rv ]] && parts+=("%F{$AP_C_ORANGE}${_AP_ICO_RUST} $rv%f")
  fi
  if [[ -n ${found[go]} ]]; then
    local gv; gv=$(command go version 2>/dev/null | awk '{print $3}') && [[ -n $gv ]] && parts+=("%F{$AP_C_CYAN}${_AP_ICO_GO} ${gv#go}%f")
  fi
  if [[ -n ${found[ruby]} ]]; then
    local rbv; rbv=$(command ruby -e 'puts RUBY_VERSION' 2>/dev/null) && [[ -n $rbv ]] && parts+=("%F{$AP_C_RED}${_AP_ICO_RUBY} $rbv%f")
  fi
  if [[ -n ${found[php]} ]]; then
    local phpv; phpv=$(command php -v 2>/dev/null | head -n 1 | awk '{print $2}') && [[ -n $phpv ]] && parts+=("%F{$AP_C_PURPLE}${_AP_ICO_PHP} $phpv%f")
  fi
  if [[ -n ${found[java]} ]]; then
    local jv; jv=$(command java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}') && [[ -n $jv ]] && parts+=("%F{$AP_C_WHITE}${_AP_ICO_JAVA} $jv%f")
  fi
  if [[ -n ${found[python]} ]]; then
    local pyv; pyv=$(command python3 --version 2>/dev/null | awk '{print $2}') && [[ -n $pyv ]] && parts+=("%F{$AP_C_YELLOW}${_AP_ICO_PY} $pyv%f")
  fi
  if [[ -n ${found[cpp]} ]]; then
    local cppv; cppv=$(command c++ --version 2>/dev/null | head -n 1 | awk '{print $NF}') && [[ -n $cppv ]] && parts+=("%F{$AP_C_BLUE}${_AP_ICO_CPP} $cppv%f")
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

_ap_segment_venv() {
  local venv=""
  if [[ -n $VIRTUAL_ENV ]]; then
    venv=$(basename "$VIRTUAL_ENV")
  elif [[ -n $CONDA_DEFAULT_ENV && $CONDA_DEFAULT_ENV != "base" ]]; then
    venv=$CONDA_DEFAULT_ENV
  fi

  [[ -n $venv ]] && echo "$venv"
}

_ap_segment_docker() {
  # Requires docker binary or config
  [[ -f $HOME/.docker/config.json ]] || (( $+commands[docker] )) || return 1

  # Cache docker context for the session (refreshed only when needed)
  if [[ -z $_ap_docker_cache || $_ap_docker_cache_pwd != $PWD ]]; then
    local ctx="default"
    local cfg="$HOME/.docker/config.json"
    
    if [[ -f $cfg ]]; then
      # Fast path: read from config
      ctx=$(command awk -F'"' '/"currentContext"/{print $4; exit}' "$cfg" 2>/dev/null)
      [[ -z $ctx ]] && ctx="default"
    elif (( $+commands[docker] )); then
      # Fallback: subprocess
      ctx=$(command docker context show 2>/dev/null)
    fi

    if [[ -n $ctx && $ctx != "default" ]]; then
      _ap_docker_cache="$ctx"
    else
      _ap_docker_cache=""
    fi
    _ap_docker_cache_pwd=$PWD
    # Share with plugins to avoid duplication
    export _AP_DOCKER_CONTEXT=$_ap_docker_cache
  fi

  [[ -n $_ap_docker_cache ]] && echo "$_ap_docker_cache"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  EXECUTION TIME
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# (Variables are initialized at the top of the file to support re-sourcing)

_ap_preexec() {
  local LC_NUMERIC=C
  _ap_cmd_start=$(_ap_now)
}

_ap_calc_exec_time() {
  # If timer is 0, it means we already calculated time for the last command.
  (( _ap_cmd_start == 0 )) && return
  
  local LC_NUMERIC=C
  local now=$(_ap_now)
  typeset -F elapsed
  elapsed=$(( now - _ap_cmd_start ))
  _ap_cmd_start=0
  
  # Check threshold. If AP_EXEC_TIME_THRESHOLD is 0, we show it for everything.
  local threshold=${AP_EXEC_TIME_THRESHOLD:-0}
  if (( threshold > 0 )); then
    (( elapsed < threshold )) && { _ap_last_exec_time=""; return; }
  fi

  local out
  if   (( elapsed >= 3600 )); then
    out="$(( int(elapsed/3600) ))h $(( int(elapsed%3600/60) ))m $(( int(elapsed%60) ))s"
  elif (( elapsed >= 60 )); then
    out="$(( int(elapsed/60) ))m $(( int(elapsed%60) ))s"
  elif (( elapsed >= 1 )); then
    printf -v out "%.1fs" $elapsed
  else
    # For sub-second commands, show 2 decimal places
    printf -v out "%.2fs" $elapsed
  fi
  _ap_last_exec_time="${_AP_ICO_EXEC} $out"
}


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  MAIN PROMPT BUILDER  (runs every precmd)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_ap_build_prompt() {
  typeset -g _ap_last_exit=$?
  _ap_calc_exec_time
  
  # [1] Git Async Request (with index-mtime caching)
  if (( AP_SHOW_GIT )); then
    local git_root
    git_root=$(command git rev-parse --git-dir 2>/dev/null)
    if [[ -n $git_root ]]; then
      local mtime=""
      if [[ -f "$git_root/index" ]]; then
        # Use zsh/stat if available for speed
        if (( $+functions[zstat] )); then
          mtime=$(zstat +mtime "$git_root/index")
        elif command -v stat &>/dev/null; then
          mtime=$(stat -c %Y "$git_root/index" 2>/dev/null || stat -f %m "$git_root/index" 2>/dev/null)
        else
          mtime=$(date -r "$git_root/index" +%s 2>/dev/null)
        fi
      fi
      
      # Only request if directory changed OR git index changed
      if [[ ${_AP_ASYNC_PWDS[git]:-} != $PWD || ${_AP_GIT_MTIME:-} != $mtime ]]; then
        _ap_async_request "git" "_ap_segment_git"
        _AP_GIT_MTIME=$mtime
      fi
    else
       _AP_ASYNC_DATA[git]="NONE"
    fi
  fi

  # [2] Lang Async Request (directory-bound)
  if (( AP_SHOW_LANGS )); then
    if [[ ${_AP_ASYNC_PWDS[lang]:-} != $PWD ]]; then
      _ap_async_request "lang" "_ap_segment_lang"
    fi
  fi

  # [3] Registered Plugin Async Requests
  local p_key
  for p_key in "${(@k)_AP_ASYNC_PLUGINS}"; do
    local p_cmd=${_AP_ASYNC_PLUGINS[$p_key]}
    _ap_async_request "$p_key" "$p_cmd"
  done

  _ap_render_prompt
}

_ap_render_prompt() {
  # Pure renderer. Reads _ap_last_exit / _ap_last_exec_time from globals.
  # Safe to call from _ap_async_handler without clobbering state.
  local last_exit=$_ap_last_exit
  local LEFT="" RIGHT=""

  # [1] OS Branding (Always first)
  LEFT+="%F{$AP_C_GRAY}${_AP_ICO_OS} %f"

  # [2] SSH and User context
  if (( AP_SHOW_SSH )) && [[ -n $SSH_CONNECTION || -n $SSH_CLIENT ]]; then
    # Show SSH icon and user@host in orange/white
    LEFT+="%F{$AP_C_ORANGE}${_AP_ICO_SSH} %F{$AP_C_WHITE}%n@%m %f"
  fi

  # [3] Directory
  LEFT+="%F{$AP_C_BLUE}${_AP_ICO_DIR} %${AP_DIR_DEPTH}~ "

  # [4] Venv / Conda
  local venv=$(_ap_segment_venv)
  if [[ -n $venv ]]; then
    LEFT+="%F{$AP_C_GRAY}${_AP_SEP_L} %F{$AP_C_CYAN}${_AP_ICO_PY} $venv "
  fi

  # [5] Docker Context
  local dkr=$(_ap_segment_docker)
  if [[ -n $dkr ]]; then
    LEFT+="%F{$AP_C_GRAY}${_AP_SEP_L} %F{$AP_C_BLUE}${_AP_ICO_DOCKER} $dkr "
  fi

  # [6] Git segment
  if (( AP_SHOW_GIT )); then
    # Clear cache if directory changed
    if [[ ${_AP_ASYNC_PWDS[git]:-} != $PWD ]]; then
      unset "_AP_ASYNC_DATA[git]"
      _AP_ASYNC_PWDS[git]=$PWD
    fi

    local git_raw=${_AP_ASYNC_DATA[git]:-}
    if [[ -z $git_raw ]]; then
      git_raw="$AP_C_GRAY ${_AP_ICO_GIT} ..."
    fi

    if [[ $git_raw != "NONE" ]]; then
      local git_color=${git_raw%% *}
      local git_label=${git_raw#* }
      LEFT+="%F{$AP_C_GRAY}${_AP_SEP_L} %F{$git_color}$git_label "
    fi
  fi

  # [7] Prompt character — ❯ colored by exit status
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

  # [2] Execution time (hide if < 40 chars)
  if (( AP_SHOW_EXEC_TIME )) && [[ -n $_ap_last_exec_time ]] && (( ${COLUMNS:-80} > 40 )); then
    RIGHT+="%F{$AP_C_YELLOW}${_ap_last_exec_time}  %f"
  fi

  # [3] Language versions (async)
  if (( AP_SHOW_LANGS )) && (( width > 100 )); then
    if [[ ${_AP_ASYNC_PWDS[lang]:-} != $PWD ]]; then
      unset "_AP_ASYNC_DATA[lang]"
      _AP_ASYNC_PWDS[lang]=$PWD
    fi

    local lang_raw=${_AP_ASYNC_DATA[lang]:-}
    
    if [[ -n $lang_raw && $lang_raw != "NONE" ]]; then
      # Collapse multiple languages if needed (Show first + count)
      local -a langs=("${(s:%f :)lang_raw}")
      # Remove empty items
      langs=("${(@)langs:#}")
      
      if [[ ${#langs} -gt 1 ]]; then
        RIGHT+="${langs[1]}%f %F{$AP_C_GRAY}+$((${#langs}-1))%f  "
      else
        RIGHT+="$lang_raw  "
      fi
    fi
  fi

  # [4] Clock (hide if < 80 chars)
  if (( AP_SHOW_TIME )) && (( width > 80 )); then
    RIGHT+="%F{$AP_C_GRAY}${_AP_ICO_TIME} %D{%H:%M}%f%k%b"
  fi

  # [5] Plugin Async Segments (Right Side)
  local p_key
  for p_key in "${(@k)_AP_ASYNC_PLUGINS}"; do
    local p_val=${_AP_ASYNC_DATA[$p_key]:-}
    if [[ -n $p_val && $p_val != "NONE" ]]; then
      RIGHT=" $p_val $RIGHT"
    fi
  done

  PROMPT="$LEFT%f%k%b"
  [[ $TERM_PROGRAM == "iTerm.app" ]] && PROMPT+=$'%{\e]133;B\a%}'
  RPROMPT=$RIGHT

  # Clear RPROMPT if empty to avoid issues
  [[ -z $RPROMPT ]] && unset RPROMPT
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ASYNC WORKER ENGINE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
typeset -gA _AP_ASYNC_DATA
typeset -gA _AP_ASYNC_FDS       # fd → key (was _AP_ASYNC_PIDS, which was a misnomer)
typeset -gA _AP_ASYNC_PWDS      # key → $PWD at time of last request
typeset -gA _AP_ASYNC_PENDING   # key → 1 while a request is in-flight

# Clean up scalars/hashes from previous theme versions (safe no-op if absent).
unset _ap_async_git_pwd _ap_async_lang_pwd
unset _AP_ASYNC_PIDS 2>/dev/null || true

_ap_async_handler() {
  local fd=$1
  local data
  read -r data <&$fd
  
  local key=${_AP_ASYNC_FDS[$fd]}
  _AP_ASYNC_DATA[$key]=$data
  unset "_AP_ASYNC_FDS[$fd]"
  unset "_AP_ASYNC_PENDING[$key]"

  if zle; then
    zle -F $fd    # unregister
    exec {fd}<&-  # close
    _ap_render_prompt
    zle reset-prompt 2>/dev/null
  else
    exec {fd}<&-  # close
  fi
}

_ap_async_request() {
  local key=$1 cmd=$2
  # Idempotent: skip if a request for this key is already in-flight.
  [[ -n ${_AP_ASYNC_PENDING[$key]:-} ]] && return
  _AP_ASYNC_PENDING[$key]=1
  local fd
  exec {fd}< <(eval "$cmd")
  _AP_ASYNC_FDS[$fd]=$key
  zle -F $fd _ap_async_handler
}

# Plugin registration for async segments
typeset -gA _AP_ASYNC_PLUGINS
aporia_register_async() {
  local key=$1 cmd=$2
  _AP_ASYNC_PLUGINS[$key]=$cmd
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ZSH HOOKS & OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# Register hooks
autoload -Uz add-zsh-hook
add-zsh-hook precmd _ap_history_setup
# (preexec registration is handled at the very end of the file)

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
#  APORIA PLUGIN SYSTEM & CLI
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ── Plugin directory ────────────────────────────────────────
AP_PLUGIN_DIR="${AP_PLUGIN_DIR:-$HOME/.aporia/plugins}"

# ── User plugin list (set in ~/.zshrc before sourcing theme) ─
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
  cpanel                    ""   # first-party
  vpn-status                ""   # first-party
  target                    ""   # first-party
  azure-ctx                 ""   # first-party
  gcp-ctx                   ""   # first-party
  gh-context                ""   # first-party
  telemetry                 ""   # first-party
)

# ── Dependencies: plugin_name → required binary ─────────────
typeset -gA _AP_PLUGIN_DEPS=(
  fzf-tab      "fzf"
  fzf-history  "fzf"
  forgit       "fzf"
  kube-ctx     "kubectl"
  azure-ctx    "az"
  gcp-ctx      "gcloud"
  gh-context   "gh"
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
      print -P "%F{$AP_C_GRAY}  Run: aporia install $name%f"
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

aporia-install-plugin() {
  local name=$1
  if [[ -z $name ]]; then
    print -P "%F{$AP_C_RED}Usage: aporia install <plugin-name>%f"
    return 1
  fi

  if ! (( $+commands[git] )); then
    print -P "%F{$AP_C_RED}[aporia] Error: 'git' is required but not found in your PATH.%f"
    return 1
  fi

  local url=${_AP_PLUGIN_REGISTRY[$name]:-}
  if [[ -z $url ]]; then
    # First-party / Bundled plugin?
    local bundled_src="${${(%):-%x}:h}/plugins/$name"
    if [[ -d $bundled_src ]]; then
      print -P "%F{$AP_C_BLUE}[aporia] Copying bundled plugin '$name' to $AP_PLUGIN_DIR...%f"
      mkdir -p "$AP_PLUGIN_DIR"
      cp -r "$bundled_src" "$AP_PLUGIN_DIR/" || return 1
      print -P "%F{$AP_C_GREEN}[aporia] '$name' installed. Run 'aporia activate $name' to activate.%f"
      return 0
    elif (( $+commands[curl] )); then
      print -P "%F{$AP_C_BLUE}[aporia] Downloading bundled plugin '$name' from GitHub...%f"
      local p_base="https://raw.githubusercontent.com/fr3on/aporia/main/plugins/$name"
      mkdir -p "$AP_PLUGIN_DIR/$name"
      if curl -fsSL "$p_base/$name.zsh" -o "$AP_PLUGIN_DIR/$name/$name.zsh"; then
        print -P "%F{$AP_C_GREEN}[aporia] '$name' downloaded and installed. Run 'aporia activate $name' now.%f"
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

  print -P "\n%F{$AP_C_GRAY}Tip: To activate an installed plugin, use: aporia activate <name>%f"
  print -P "%F{$AP_C_GRAY}To activate all installed plugins at once, use: aporia activate-all%f"
}

aporia-activate-plugin() {
  local name=$1
  if [[ -z $name ]]; then
    print -P "%F{$AP_C_RED}Usage: aporia activate <plugin-name>%f"
    return 1
  fi
  
  local bundle_dir="${${(%):-%x}:h}/plugins/$name"
  if [[ ! -d "$AP_PLUGIN_DIR/$name" && ! -d "$bundle_dir" ]]; then
    if [[ -n ${_AP_PLUGIN_REGISTRY[$name]+x} ]]; then
      print -P "%F{$AP_C_RED}[aporia] '$name' is not installed in $AP_PLUGIN_DIR.%f"
      print -P "%F{$AP_C_GRAY}        Run: aporia install $name%f"
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
         perl -pi -e "s/AP_PLUGINS=\(([^)]*)\)/AP_PLUGINS=(\$1 $name)/" "$zrc"
         found=1
      fi
    else
      # Create new array before theme source
      if grep -q "aporia.zsh-theme" "$zrc"; then
        perl -pi -e "s/^(.*aporia.zsh-theme)/export AP_PLUGINS=($name)\n\$1/" "$zrc"
        found=1
      else
        print "\nexport AP_PLUGINS=($name)" >> "$zrc"
        found=1
      fi
    fi
  fi
  
  if [[ $found -eq 1 ]]; then
    export AP_PLUGINS=(${AP_PLUGINS[@]}) # Ensure exported in current session
    print -P "%F{$AP_C_GREEN}[aporia] '$name' activated and added to ~/.zshrc%f"
  else
    print -P "%F{$AP_C_GREEN}[aporia] '$name' activated for this session only (could not patch .zshrc automatically).%f"
  fi
}

aporia-activate-all() {
  local count=0
  local name bundle_dir
  for name in "${(@k)_AP_PLUGIN_REGISTRY}"; do
    bundle_dir="${${(%):-%x}:h}/plugins/$name"
    if [[ (-d "$AP_PLUGIN_DIR/$name" || -d "$bundle_dir") && "$name" != "zsh-autosuggestions" && "$name" != "zsh-syntax-highlighting" ]]; then
      if (( ! ${AP_PLUGINS[(Ie)$name]} )); then
        aporia-activate-plugin "$name"
        ((count++))
      fi
    fi
  done
  print -P "%F{$AP_C_GREEN}[aporia] $count new plugins activated.%f"
}

aporia-deactivate-plugin() {
  local name=$1
  if [[ -z $name ]]; then
    print -P "%F{$AP_C_RED}Usage: aporia deactivate <plugin-name>%f"
    return 1
  fi

  if [[ "$name" == "zsh-autosuggestions" || "$name" == "zsh-syntax-highlighting" ]]; then
    print -P "%F{$AP_C_YELLOW}[aporia] '$name' is an essential plugin and cannot be deactivated.%f"
    return 1
  fi

  if (( ! ${AP_PLUGINS[(Ie)$name]} )); then
    print -P "%F{$AP_C_YELLOW}[aporia] '$name' is not currently active.%f"
    return 0
  fi

  # Remove from current session array (doesn't unload loaded functions natively without restart)
  AP_PLUGINS=(${AP_PLUGINS:|name})
  export AP_PLUGINS

  # Persistent deactivation in ~/.zshrc
  local zrc="$HOME/.zshrc"
  local found=0
  if [[ -f $zrc ]]; then
    if grep -q "AP_PLUGINS=(" "$zrc"; then
      perl -pi -e "if (/AP_PLUGINS=\((.*)\)/) { my \$in = \$1; \$in =~ s/\b$name\b//g; \$in =~ s/\s+/ /g; \$in =~ s/^\s+|\s+$//g; s/AP_PLUGINS=\(.*\)/AP_PLUGINS=(\$in)/ }" "$zrc"
      found=1
    fi
  fi
  
  if [[ $found -eq 1 ]]; then
    print -P "%F{$AP_C_GREEN}[aporia] '$name' deactivated in ~/.zshrc. (Restart shell to fully unload)%f"
  else
    print -P "%F{$AP_C_YELLOW}[aporia] Could not find AP_PLUGINS in ~/.zshrc. Deactivated for this session only.%f"
  fi
}

_ap_load_essentials() {
  _ap_plugin_source "zsh-autosuggestions"
  _ap_plugin_source "zsh-syntax-highlighting"
  
  # Set subtle gray style matching Aporia palette
  [[ -n $functions[_zsh_autosuggest_start] ]] && \
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${AP_C_GRAY:-242}"
}

# ── Unified Aporia Command ───────────────────────────────────

_ap_print_flag() {
  local label=$1 value=$2
  local _ap_fstatus="%F{$AP_C_GREEN}on%f"
  [[ $value -eq 0 ]] && _ap_fstatus="%F{$AP_C_GRAY}off%f"
  print -P "   %F{$AP_C_WHITE}${(r:12:)label}:%f $_ap_fstatus"
}

_aporia_help() {
  print -P "\n %F{$AP_C_BLUE}Usage:%f aporia <command> [args]"
  print -P "\n %F{$AP_C_BLUE}Commands:%f"
  print -P "   %F{$AP_C_YELLOW}info%f          Show theme and system status (default)"
  print -P "   %F{$AP_C_YELLOW}list%f          List all available plugins and their status"
  print -P "   %F{$AP_C_YELLOW}theme <name>%f  Change the current color theme"
  print -P "   %F{$AP_C_YELLOW}install <p>%f   Download and install a plugin"
  print -P "   %F{$AP_C_YELLOW}activate <p>%f  Enable a plugin and add to .zshrc"
  print -P "   %F{$AP_C_YELLOW}deactivate <p>%f Disable a plugin and remove from .zshrc"
  print -P "   %F{$AP_C_YELLOW}activate-all%f  Activate all installed plugins"
  print -P "   %F{$AP_C_YELLOW}update%f        Update all installed plugins"
  print -P "   %F{$AP_C_YELLOW}inspect%f       Show raw segment data for debugging"
  print -P "   %F{$AP_C_YELLOW}doctor%f        Run system health checks"
  print -P "   %F{$AP_C_YELLOW}upgrade%f       Upgrade Aporia to the latest version"
  print -P "   %F{$AP_C_YELLOW}benchmark%f     Profile prompt rendering latency"
  print -P "   %F{$AP_C_YELLOW}help%f          Show this help message\n"
}

_aporia_dashboard() {
  print -P "\n %F{$AP_C_ORANGE}APORIA%f %F{$AP_C_GRAY}— %f%B%F{$AP_C_BLUE}v${APORIA_VERSION:-1.1.4}%f%b"
  print -P " %F{$AP_C_GRAY}──────────────────────────────────────────────────%f"

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
  print -P "   %F{$AP_C_GRAY}Run 'aporia theme' to see all options.%f"

  print -P "\n %F{$AP_C_BLUE}Configuration%f"
  _ap_print_flag "SSH Segment" ${AP_SHOW_SSH:-1}
  _ap_print_flag "Git Segment" ${AP_SHOW_GIT:-1}
  _ap_print_flag "Lang Stats"  ${AP_SHOW_LANGS:-1}
  _ap_print_flag "Exec Time"   ${AP_SHOW_EXEC_TIME:-1}
  _ap_print_flag "Exit Code"   ${AP_SHOW_EXIT_CODE:-1}
  _ap_print_flag "Clock"       ${AP_SHOW_TIME:-1}

  local active_count=0
  local name
  for name in "${(@k)_AP_PLUGIN_REGISTRY}"; do
    if (( ${AP_PLUGINS[(Ie)$name]} )); then
      ((active_count++))
    elif [[ $name == "zsh-autosuggestions" || $name == "zsh-syntax-highlighting" ]] && [[ -d "$AP_PLUGIN_DIR/$name" ]]; then
      ((active_count++))
    fi
  done

  local total_count=${#_AP_PLUGIN_REGISTRY[@]}
  print -P "\n %F{$AP_C_BLUE}Plugins%f"
  print -P "   %F{$AP_C_WHITE}${(r:12:):-Active}:%f  %F{$AP_C_GREEN}$active_count%f / $total_count"
  print -P "   %F{$AP_C_GRAY}Run 'aporia list' for more details.%f"

  print -P "\n %F{$AP_C_GRAY}Type 'aporia help' for a list of commands.%f\n"
}

_aporia_inspect_dump() {
  setopt local_options extended_glob
  
  local c_head=$AP_C_BLUE
  local c_sub=$AP_C_CYAN
  local c_lab=$AP_C_WHITE
  local c_val=$AP_C_CYAN
  local c_dim=$AP_C_GRAY

  print -P "\n %F{$AP_C_ORANGE}󰂚%f %B%F{$c_head}APORIA%f%b %F{$c_dim}— Context%f"
  print -P " %F{$c_dim}──────────────────────────────────────────────────────────────────%f"

  print -P " %F{$c_sub}󰉋 Project Status%f"
  print -P "  %F{$c_dim}│%f %F{$c_lab}Root:%f        %F{$c_val}$(git rev-parse --show-toplevel 2>/dev/null || echo $PWD)%f"
  print -P "  %F{$c_dim}│%f %F{$c_lab}Working Dir:%f %F{$c_val}$PWD%f"
  
  local version="unknown"
  if [[ -f Cargo.toml ]]; then
    version=$(grep -m1 "^version" Cargo.toml | cut -d'"' -f2 2>/dev/null)
  elif [[ -f package.json ]]; then
    version=$(grep -m1 "\"version\"" package.json | cut -d'"' -f4 2>/dev/null)
  fi
  [[ $version != "unknown" ]] && print -P "  %F{$c_dim}│%f %F{$c_lab}Version:%f     %F{$AP_C_YELLOW}v$version%f"

  local key val count=0
  for key val in "${(@kv)_AP_ASYNC_DATA}"; do
    ((count++))
    if [[ $key == "lang" ]]; then
      if [[ $val == "NONE" || -z $val ]]; then
        continue 
      fi
      print -P "  %F{$c_dim}├─%f %F{$c_lab}Languages:%f"
      local p
      for p in ${(s:%f :)val}; do
        [[ -z ${p// /} ]] && continue
        local clean_p=$(echo "$p" | sed -E 's/%[FfKkBbUu](\{[^}]*\})?//g')
        print -P "  %F{$c_dim}│%f   %F{$c_dim}•%f %F{$c_val}${clean_p#" "}%f"
      done
    elif [[ $key == "git" ]]; then
       local clean_val=$(echo "$val" | sed -E 's/%[FfKkBbUu](\{[^}]*\})?//g')
       clean_val=${clean_val##[0-9]# }
       print -P "  %F{$c_dim}├─%f %F{$c_lab}Prompt:%f    %F{$c_val}${clean_val#" "}%f"
    fi
  done
  
  if command git rev-parse --is-inside-work-tree &>/dev/null; then
    print -P "  %F{$c_dim}│%f"
    print -P "  %F{$c_dim}├─%f %F{$c_sub}󰊢 Git Engine%f"
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    local remote=$(git config --get branch.$branch.remote 2>/dev/null || echo "none")
    local upstream=$(git config --get branch.$branch.merge 2>/dev/null || echo "none")
    print -P "  %F{$c_dim}│%f  %F{$c_lab}Branch:%f   %F{$c_val}$branch%f"
    print -P "  %F{$c_dim}│%f  %F{$c_lab}Remote:%f   %F{$c_val}$remote%f"
    print -P "  %F{$c_dim}│%f  %F{$c_lab}Upstream:%f %F{$c_val}${upstream#refs/heads/}%f"
    print -P "  %F{$c_dim}│%f  %F{$c_lab}Stashed:%f  %F{$c_val}$(git stash list 2>/dev/null | wc -l | tr -d ' ') layers%f"
  fi

  print -P "\n %F{$c_sub}󰟀 Infrastructure Context%f"
  
  local dkr=$(_ap_segment_docker 2>/dev/null || echo "None")
  local venv=$(_ap_segment_venv 2>/dev/null || echo "None")
  local kube=$(command kubectl config current-context 2>/dev/null || echo "None")
  
  local cpanel="None"
  if [[ -d /usr/local/cpanel ]]; then
    cpanel=$(/usr/local/cpanel/cpanel -V 2>/dev/null || echo "Active")
  elif [[ -d $HOME/.cpanel ]]; then
    cpanel="User-level"
  fi
  
  local local_ip="unknown"
  if (( $+commands[ip] )); then
    local_ip=$(ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n 1)
  elif (( $+commands[ifconfig] )); then
    local_ip=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n 1)
  fi
  
  print -P "  %F{$c_dim}│%f %F{$c_lab}Container:%f  %F{$c_val}${dkr:-default}%f"
  print -P "  %F{$c_dim}│%f %F{$c_lab}VirtualEnv:%f %F{$c_val}${venv:-None}%f"
  print -P "  %F{$c_dim}│%f %F{$c_lab}Kubernetes:%f %F{$c_val}$kube%f"
  print -P "  %F{$c_dim}│%f %F{$c_lab}cPanel:%f     %F{$c_val}$cpanel%f"
  print -P "  %F{$c_dim}│%f %F{$c_lab}Local IP:%f   %F{$c_val}${local_ip:-unknown}%f"

  print -P "\n %F{$c_sub}󰄨 System Telemetry%f"
  
  if (( $+functions[_ap_telemetry_segment] )); then
    local t_data=$(_ap_telemetry_segment raw 2>/dev/null)
    [[ -n $t_data ]] && print -P "  %F{$c_dim}│%f %F{$c_lab}Live Stats:%f  $t_data"
  fi

  print -P "  %F{$c_dim}│%f %F{$c_lab}Exit Code:%f   %F{${_ap_last_exit:-0}}${_ap_last_exit:-0}%f"
  print -P "  %F{$c_dim}│%f %F{$c_lab}Last Exec:%f   %F{$c_val}${_ap_last_exec_time:-< ${AP_EXEC_TIME_THRESHOLD:-2}s}%f"
  
  local os_info="$(uname -s) $(uname -m)"
  if [[ -f /etc/os-release ]]; then
    os_info=$(grep "^PRETTY_NAME=" /etc/os-release | cut -d= -f2 | tr -d '"')
  fi
  print -P "  %F{$c_dim}│%f %F{$c_lab}OS/Distro:%f   %F{$c_dim}$os_info%f"
  print -P "  %F{$c_dim}│%f %F{$c_lab}Session PID:%f %F{$c_dim}$$%f"

  print -P "\n %F{$c_sub}󰋚 History%f"
  local h_file="${HISTFILE:-None}"
  local h_size="${HISTSIZE:-0}"
  local h_save="${SAVEHIST:-0}"
  local h_count=$(fc -l -1 2>/dev/null | awk '{print $1}' || echo "0")
  [[ $h_count == "0" ]] && h_count=$(wc -l < "$h_file" 2>/dev/null | awk '{print $1}')
  
  print -P "  %F{$c_dim}│%f %F{$c_lab}File:%f        %F{$c_val}$h_file%f"
  print -P "  %F{$c_dim}│%f %F{$c_lab}Size/Save:%f   %F{$c_val}$h_size / $h_save%f"
  print -P "  %F{$c_dim}│%f %F{$c_lab}Commands:%f    %F{$c_val}${h_count:-0} entries%f"
}

_aporia_doctor() {
  print -P "\n %F{$AP_C_BLUE}Aporia Doctor%f"
  
  local pass="%F{$AP_C_GREEN}✓%f"
  local fail="%F{$AP_C_RED}✗%f"
  local warn="%F{$AP_C_YELLOW}!%f"
  
  # Zsh version
  local zsh_v_major=$(echo $ZSH_VERSION | cut -d. -f1)
  local zsh_v_minor=$(echo $ZSH_VERSION | cut -d. -f2)
  if [[ $zsh_v_major -gt 5 ]] || [[ $zsh_v_major -eq 5 && $zsh_v_minor -ge 8 ]]; then
    print -P "   $pass Zsh version ($ZSH_VERSION)"
  else
    print -P "   $warn Zsh version ($ZSH_VERSION) - 5.8+ recommended"
  fi
  
  # Locale
  if _ap_is_utf8; then
    print -P "   $pass UTF-8 Locale"
  else
    print -P "   $fail Non-UTF-8 Locale detected. Please export LANG=en_US.UTF-8"
  fi
  
  # Git
  if (( $+commands[git] )); then
    print -P "   $pass Git installed"
  else
    print -P "   $fail Git not found in PATH"
  fi
  
  # Fonts
  if [[ ${AP_USE_NERD_FONT:-1} -eq 1 ]]; then
    print -P "   $pass Nerd Font Mode (ensure your terminal font is set correctly)"
  else
    print -P "   $warn Compatibility Mode (Nerd Fonts disabled)"
  fi
  
  print -P ""
}

_aporia_upgrade() {
  print -P "\n %F{$AP_C_BLUE}Upgrading Aporia...%f"
  if command -v brew >/dev/null && brew list aporia >/dev/null 2>&1; then
    print -P "   %F{$AP_C_GRAY}Homebrew installation detected.%f"
    brew upgrade aporia
  else
    local theme_dir=${${(%):-%x}:h}
    if [[ -d "$theme_dir/.git" ]]; then
      print -P "   %F{$AP_C_GRAY}Git installation detected.%f"
      git -C "$theme_dir" pull origin main
    else
      print -P "   %F{$AP_C_GRAY}Manual installation detected. Fetching latest from GitHub...%f"
      curl -fsSL https://raw.githubusercontent.com/fr3on/aporia/main/aporia.zsh-theme -o "$HOME/.aporia.zsh-theme"
      curl -fsSL https://raw.githubusercontent.com/fr3on/aporia/main/aporia.plugin.zsh -o "$HOME/.aporia.plugin.zsh"
      print -P "   %F{$AP_C_GREEN}✓ Successfully downloaded latest version to $HOME%f"
    fi
  fi
}

_aporia_benchmark() {
  print -P "\n %F{$AP_C_BLUE}Aporia Benchmark%f"
  typeset -F start end elapsed
  
  start=$(_ap_now)
  local git_res=$(_ap_segment_git)
  end=$(_ap_now)
  elapsed=$(( (end - start) * 1000 ))
  printf -v elapsed_fmt "%.0f ms" $elapsed
  print -P "   %F{$AP_C_GRAY}Git Segment:%f  $elapsed_fmt"
  
  start=$(_ap_now)
  local lang_res=$(_ap_segment_lang)
  end=$(_ap_now)
  elapsed=$(( (end - start) * 1000 ))
  printf -v elapsed_fmt "%.0f ms" $elapsed
  print -P "   %F{$AP_C_GRAY}Lang Segment:%f $elapsed_fmt"
  
  start=$(_ap_now)
  _ap_render_prompt >/dev/null
  end=$(_ap_now)
  elapsed=$(( (end - start) * 1000 ))
  printf -v elapsed_fmt "%.0f ms" $elapsed
  print -P "   %F{$AP_C_GRAY}Render Logic:%f $elapsed_fmt"
  print -P ""
}

aporia() {
  local cmd=$1
  case "$cmd" in
    list) aporia-list-plugins ;;
    install) shift; aporia-install-plugin "$@" ;;
    update) aporia-update-plugins ;;
    doctor) _aporia_doctor ;;
    upgrade) _aporia_upgrade ;;
    benchmark) _aporia_benchmark ;;
    theme)
      shift
      local new_theme=$1
      if [[ -z $new_theme ]]; then
        print -P "\n %F{$AP_C_BLUE}Available Themes:%f"
        print -P "   %F{$AP_C_CYAN}deep_blue%f     (Default)"
        print -P "   %F{$AP_C_CYAN}amber%f         Warm"
        print -P "   %F{$AP_C_CYAN}light%f         High visibility"
        print -P "   %F{$AP_C_CYAN}crimson_void%f  Hacker aesthetic"
        print -P "   %F{$AP_C_CYAN}forest_matrix%f Matrix green"
        print -P "\n %F{$AP_C_GRAY}Usage: aporia theme <name>%f\n"
        return 0
      fi
      
      case "$new_theme" in
        deep_blue|amber|light|crimson_void|forest_matrix)
          export AP_THEME="$new_theme"
          local zrc="$HOME/.zshrc"
          if [[ -f $zrc ]]; then
            if grep -q "export AP_THEME=" "$zrc"; then
              perl -pi -e "s/^export AP_THEME=.*/export AP_THEME=$new_theme/" "$zrc"
            else
              if grep -q "aporia.zsh-theme" "$zrc"; then
                perl -pi -e "s/^(.*aporia.zsh-theme)/export AP_THEME=$new_theme\n\$1/" "$zrc"
              else
                print "\nexport AP_THEME=$new_theme" >> "$zrc"
              fi
            fi
          fi
          
          if (( $+functions[_ap_apply_theme] )); then
            unset AP_C_BG0 AP_C_BG1 AP_C_BG2 AP_C_BG3 AP_C_WHITE AP_C_BLUE AP_C_GREEN AP_C_YELLOW AP_C_RED AP_C_ORANGE AP_C_PURPLE AP_C_CYAN AP_C_GRAY
            _ap_apply_theme
            if (( $+functions[_ap_render_prompt] )); then
               _ap_render_prompt
               zle && zle reset-prompt
            fi
            print -P "%F{$AP_C_GREEN}[aporia] Theme switched to '$new_theme'.%f"
          fi
          ;;
        *) print -P "%F{$AP_C_RED}[aporia] Invalid theme: $new_theme%f"; return 1 ;;
      esac
      ;;
    activate) shift; aporia-activate-plugin "$@" ;;
    deactivate) shift; aporia-deactivate-plugin "$@" ;;
    activate-all) aporia-activate-all ;;
    inspect|debug|env|data) _aporia_inspect_dump ;;
    info|status|"") _aporia_dashboard ;;
    help|--help|-h) _aporia_help ;;
    *) print -P "%F{$AP_C_RED}[aporia] Unknown command: $cmd%f"; _aporia_help; return 1 ;;
  esac
}

# ── Initialization ──────────────────────────────────────────

_ap_load_essentials
_ap_load_plugins

add-zsh-hook preexec _ap_preexec
