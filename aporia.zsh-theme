# ╔═══════════════════════════════════════════════════════════════════╗
# ║  aporia.zsh-theme — Dark Flame Edition                            ║
# ║  Author : Ahmed (aporia) · github.com/fr3on                       ║
# ║  Cross-platform: macOS + Linux · Requires Nerd Font               ║
# ║                                                                   ║
# ║  Install:                                                         ║
# ║    source ~/.aporia.zsh-theme   (add to ~/.zshrc)                 ║
# ╚═══════════════════════════════════════════════════════════════════╝

# Guard: Ensure we are running in Zsh
if [[ -z $ZSH_VERSION ]]; then
  echo "[aporia] Error: This theme requires Zsh. Run 'zsh' to switch shells." >&2
  return 1 2>/dev/null || exit 1
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  INTERNAL UTILS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Platform detection
_ap_is_macos() { [[ $(uname -s) == "Darwin" ]]; }
_ap_is_linux() { [[ $(uname -s) == "Linux"  ]]; }

# Distro Detection logic
_ap_get_os_icon() {
  if _ap_is_macos; then
    echo "" # Apple Logo
    return
  fi

  if [[ -f /etc/os-release ]]; then
    local id=$(grep -E "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
    case "$id" in
      debian)  echo "󰣚" ;;
      ubuntu)  echo "󰕈" ;;
      arch)    echo "󰣇" ;;
      fedora)  echo "󰣛" ;;
      centos)  echo "󰣙" ;;
      alpine)  echo "󰣗" ;;
      kali)    echo "󰣘" ;;
      raspbian) echo "󰐕" ;;
      manjaro)  echo "󱘊" ;;
      *)        echo "󰌽" ;; # Generic Linux
    esac
  else
    echo "󰌽"
  fi
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

# [3] OS-Specific Branding
_AP_ICO_OS=$(_ap_get_os_icon)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  NERD FONT GLYPHS
#  Fallback to ASCII if AP_ASCII_FALLBACK=1 or locale is not UTF-8
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [[ ${AP_ASCII_FALLBACK:-0} -eq 1 ]] || ! _ap_is_utf8; then
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
  _AP_ICO_DIRTY="*"
  _AP_ICO_AHEAD="^"
  _AP_ICO_BEHIND="v"
  _AP_ICO_PROMPT=">"
else
  _AP_SEP_L="❯"        # Minimalist Slant
  _AP_SEP_R="❮"        # Minimalist Slant
  _AP_ICO_GIT="⎇"      # Universal Git
  _AP_ICO_SSH="⇄"      # Universal SSH
  _AP_ICO_DIR="›"      # Directory arrow
  _AP_ICO_OK="✓"       # Success
  _AP_ICO_ERR="✘"      # Error
  _AP_ICO_TIME="◷"     # Clock
  _AP_ICO_EXEC="󱎫"     # Stopwatch (Nerd Font)
  _AP_ICO_PY=""      # Python
  _AP_ICO_NODE=""    # Node
  _AP_ICO_RUST=""    # Rust
  _AP_ICO_GO="󰟓"      # Go
  _AP_ICO_RUBY=""    # Ruby
  _AP_ICO_PHP="󰌟"      # PHP
  _AP_ICO_JAVA=""    # Java
  _AP_ICO_CPP=""     # C++
  _AP_ICO_DIRTY="󰝥"   # Dirty (dot)
  _AP_ICO_AHEAD="↑"    # Ahead
  _AP_ICO_BEHIND="↓"   # Behind
  _AP_ICO_PROMPT="❯"   # Prompt char
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  COLOR PALETTE  (256-color for max terminal compat)
#  Override any of these before sourcing the theme.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AP_C_BG0=${AP_C_BG0:-232}        # near-black  #080808
AP_C_BG1=${AP_C_BG1:-235}        # dark gray   #262626
AP_C_BG2=${AP_C_BG2:-238}        # mid gray    #444444
AP_C_BG3=${AP_C_BG3:-241}        # light gray  #626262
AP_C_WHITE=${AP_C_WHITE:-255}     # bright white
AP_C_BLUE=${AP_C_BLUE:-39}        # electric blue   #00afff
AP_C_GREEN=${AP_C_GREEN:-82}      # bright green    #5fd700
AP_C_YELLOW=${AP_C_YELLOW:-220}   # gold            #ffd700
AP_C_RED=${AP_C_RED:-196}         # bright red      #ff0000
AP_C_ORANGE=${AP_C_ORANGE:-208}   # orange          #ff8700
AP_C_PURPLE=${AP_C_PURPLE:-135}   # purple          #af5fff
AP_C_CYAN=${AP_C_CYAN:-51}        # cyan            #00ffff
AP_C_GRAY=${AP_C_GRAY:-242}       # mid gray text   #6c6c6c

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ADAPTIVE CONTEXT (Root / Locale)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# [1] Root User Adaptivity (Safety Mode)
if [[ $UID -eq 0 ]]; then
  _AP_ICO_PROMPT="${_AP_ICO_OS}"  # use OS branding as prompt for root
fi

# [2] Auto-Locale Fix
if ! _ap_is_utf8; then
  export LANG="en_US.UTF-8"
  export LC_ALL="en_US.UTF-8"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  LOCALE WARNING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if ! _ap_is_utf8 && [[ ${AP_HIDE_LOCALE_WARN:-0} -eq 0 ]]; then
  print -P "%F{$AP_C_YELLOW}[aporia] Warning: Non-UTF-8 locale detected. Falling back to ASCII mode.%f"
  print -P "%F{$AP_C_GRAY}        Set LANG=\"en_US.UTF-8\" in your .zshrc to enable icons.%f"
  AP_HIDE_LOCALE_WARN=1
fi

# Guard EPOCHSECONDS — fall back to $SECONDS if zsh < 5.8
if (( ${ZSH_VERSION//./} >= 580 )) && [[ -n $EPOCHSECONDS ]]; then
  _ap_now() { echo $EPOCHSECONDS }
else
  _ap_now() { echo $SECONDS }
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
  command git rev-parse --is-inside-work-tree &>/dev/null || return 1

  local branch dirty ahead=0 behind=0

  # Branch name or short SHA (detached HEAD)
  branch=$(command git symbolic-ref --short HEAD 2>/dev/null)
  [[ -z $branch ]] && branch=$(command git rev-parse --short HEAD 2>/dev/null)
  [[ -z $branch ]] && return 1

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

  # Build label
  local label="${_AP_ICO_GIT} $branch"
  [[ -n $dirty   ]] && label+=" ${_AP_ICO_DIRTY}"
  (( ahead  > 0 )) && label+=" ${_AP_ICO_AHEAD}$ahead"
  (( behind > 0 )) && label+=" ${_AP_ICO_BEHIND}$behind"

  # Colour: green=clean, yellow=dirty, red=conflict zone
  local color=$AP_C_GREEN
  [[ -n $dirty   ]] && color=$AP_C_YELLOW
  (( behind > 0 )) && color=$AP_C_RED

  echo "$color $label"    # "COLOR label"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  LANGUAGE VERSIONS  (project-aware, lazy)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_ap_lang_info() {
  local parts=()

  # Python — active venv
  if [[ -n $VIRTUAL_ENV ]]; then
    local venv_name=$(basename "$VIRTUAL_ENV")
    parts+=("%F{$AP_C_CYAN}${_AP_ICO_PY} $venv_name%f")
  elif [[ -n $CONDA_DEFAULT_ENV && $CONDA_DEFAULT_ENV != "base" ]]; then
    parts+=("%F{$AP_C_CYAN}${_AP_ICO_PY} $CONDA_DEFAULT_ENV%f")
  fi

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
  if _ap_find_up "CMakeLists.txt" "Makefile" ".cpp" ".cc"; then
    local cppv
    cppv=$(command c++ --version 2>/dev/null | head -n 1 | awk '{print $NF}') && \
      [[ -n $cppv ]] && parts+=("%F{$AP_C_BLUE}${_AP_ICO_CPP} $cppv%f")
  fi

  (( ${#parts[@]} > 0 )) && echo "${(j:  :)parts}"
}

# Walk up directory tree looking for any of the given filenames
_ap_find_up() {
  local dir=$PWD
  while [[ $dir != "/" && $dir != "$HOME" ]]; do
    for f in "$@"; do
      [[ -e "$dir/$f" ]] && return 0
    done
    dir=${dir:h}
  done
  # Check one last time at the boundary
  for f in "$@"; do
    [[ -e "$dir/$f" ]] && return 0
  done
  return 1
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
  _ap_calc_exec_time          # calc before anything resets EPOCHSECONDS

  local LEFT="" RIGHT=""
  local prev_bg=$AP_C_BG0     # tracks last bg for separator chaining

  # ── LEFT SIDE ───────────────────────────────────────────────────

  # [1] SSH context — only when connected over SSH
  if (( AP_SHOW_SSH )) && [[ -n $SSH_CONNECTION || -n $SSH_CLIENT ]]; then
    LEFT+="%K{$AP_C_PURPLE}%F{$AP_C_WHITE} ${_AP_ICO_OS} %n@%m "
    LEFT+="%F{$AP_C_PURPLE}%K{$AP_C_BG2}${_AP_SEP_L}"
    prev_bg=$AP_C_BG2
  else
    # Show OS branding icon locally too
    LEFT+="%F{$AP_C_GRAY}${_AP_ICO_OS} %f"
  fi

  # [2] Directory
  LEFT+="%K{$AP_C_BG2}%F{$AP_C_BLUE} ${_AP_ICO_DIR} %${AP_DIR_DEPTH}~ "

  # [3] Git segment (only in git repos)
  if (( AP_SHOW_GIT )); then
    local git_raw=$(_ap_git_info)
    if [[ -n $git_raw ]]; then
      local git_color=${git_raw%% *}
      local git_label=${git_raw#* }
      LEFT+="%F{$AP_C_BG2}%K{$AP_C_BG1}${_AP_SEP_L}"
      LEFT+="%K{$AP_C_BG1}%F{$git_color} $git_label "
      LEFT+="%F{$AP_C_BG1}%K{$AP_C_BG0}${_AP_SEP_L}%k%f"
    else
      LEFT+="%F{$AP_C_BG2}%K{$AP_C_BG0}${_AP_SEP_L}%k%f"
    fi
  else
    LEFT+="%F{$AP_C_BG2}%K{$AP_C_BG0}${_AP_SEP_L}%k%f"
  fi

  # [4] Prompt character — ❯ colored by exit status
  if (( last_exit == 0 )); then
    LEFT+=" %B%F{$AP_C_GREEN}${_AP_ICO_PROMPT}%f%b "
  else
    LEFT+=" %B%F{$AP_C_RED}${_AP_ICO_PROMPT}%f%b "
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

  # [3] Language versions (hide if < 100 chars)
  if (( AP_SHOW_LANGS )) && (( width > 100 )); then
    local langs=$(_ap_lang_info)
    [[ -n $langs ]] && RIGHT+="$langs  "
  fi

  # [4] Clock (hide if < 80 chars)
  if (( AP_SHOW_TIME )) && (( width > 80 )); then
    RIGHT+="%F{$AP_C_GRAY}${_AP_ICO_TIME} %D{%H:%M}%f%k%b"
  fi

  PROMPT="$LEFT%f%k%b"
  RPROMPT=$RIGHT

  # Clear RPROMPT if empty to avoid issues
  [[ -z $RPROMPT ]] && unset RPROMPT
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
add-zsh-hook precmd _ap_set_title
add-zsh-hook preexec _ap_set_title

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  OPTIONAL: iTerm2 shell integration marks
#  (enables jump-to-prompt, cmd output selection)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
  # Mark prompt start
  add-zsh-hook precmd  _ap_iterm2_prompt_start
  add-zsh-hook preexec _ap_iterm2_preexec

  _ap_iterm2_prompt_start() { print -Pn "\e]133;A\a"; }
  _ap_iterm2_preexec()      { print -Pn "\e]133;C\a"; }
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  APORIA ESSENTIALS (Plugins)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_ap_load_essentials() {
  local pdir="$HOME/.aporia/plugins"
  
  # 1. Autosuggestions
  if [[ -f "$pdir/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$pdir/zsh-autosuggestions/zsh-autosuggestions.zsh"
    # subtle gray suggestions matching our theme
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=242"
  fi

  # 2. Syntax Highlighting (Must be loaded last)
  if [[ -f "$pdir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$pdir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  fi
}

# Run essentials loader
_ap_load_essentials
