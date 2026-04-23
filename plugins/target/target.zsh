# aporia/plugins/target/target.zsh
# Operational Security: Target Focus Tracking

AP_C_TARGET=${AP_C_TARGET:-161}    # Deep Crimson/Red (High visibility)
_AP_ICO_TARGET="󰓾"                 # Target/Bullseye Icon

# [1] Controller: Management command
aporia-target() {
  local val=$1
  if [[ -z $val ]]; then
    if [[ -n $APORIA_TARGET ]]; then
      print -P "%F{$AP_C_TARGET}${_AP_ICO_TARGET} Current Target:%f %B$APORIA_TARGET%b"
      print -P "%F{$AP_C_GRAY}Use 'aporia-target --clear' to reset.%f"
    else
      print -P "%F{$AP_C_GRAY}No target set. Usage: aporia-target <ip/domain>%f"
    fi
    return 0
  fi

  if [[ $val == "--clear" || $val == "-c" ]]; then
    unset APORIA_TARGET
    print -P "%F{$AP_C_GREEN}Target cleared.%f"
    return 0
  fi

  export APORIA_TARGET="$val"
  print -P "%F{$AP_C_GREEN}Target set to:%f %B$val%b"
}

# [2] Segment: Prompt rendering
_ap_target_segment() {
  [[ -z $APORIA_TARGET ]] && return

  echo "%F{$AP_C_TARGET}${_AP_ICO_TARGET} ${APORIA_TARGET}%f"
}

_ap_target_precmd() {
  local seg=$(_ap_target_segment)
  if [[ -n $seg ]]; then
    # Prioritize target in RPROMPT (right-most or second right-most)
    RPROMPT="${seg} ${RPROMPT:-}"
  fi
}

# Register the hook
autoload -Uz add-zsh-hook
add-zsh-hook precmd _ap_target_precmd

# Add completions for the command
_aporia_target_completions() {
  local -a opts
  opts=("--clear" "-c")
  _describe 'command' opts
}

compdef _aporia_target_completions aporia-target
