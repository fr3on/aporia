# aporia/plugins/nix-shell/nix-shell.zsh

AP_C_NIX=${AP_C_NIX:-105}   # nix purple

_ap_nix_segment() {
  local label=""

  if [[ -n $IN_NIX_SHELL ]]; then
    label="nix-shell"
    [[ -n $name ]] && label="$name"   # $name is set by nix-shell to pkg name
  elif [[ -n $DEVENV_ROOT ]]; then
    label="devenv"
  else
    return
  fi

  echo "%F{$AP_C_NIX}󱄅 $label%f"
}

_ap_nix_precmd() {
  local seg=$(_ap_nix_segment)
  [[ -n $seg ]] && RPROMPT="${RPROMPT:-} $seg"
}

add-zsh-hook precmd _ap_nix_precmd
