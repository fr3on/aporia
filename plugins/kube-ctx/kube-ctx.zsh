# aporia/plugins/kube-ctx/kube-ctx.zsh

AP_C_KUBE=${AP_C_KUBE:-141}   # purple #af87ff

_ap_kube_ctx_segment() {
  # Only show when kube tools are present
  command -v kubectl &>/dev/null || return

  local kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
  [[ -f $kubeconfig ]] || return

  # Parse current-context and its namespace from kubeconfig with awk
  # Avoids kubectl subprocess entirely
  local ctx ns
  ctx=$(command awk '/^current-context:/{print $2; exit}' "$kubeconfig")
  [[ -z $ctx ]] && return

  ns=$(command awk "
    /^contexts:/{in_ctx=1}
    in_ctx && /name: $ctx$/{found=1}
    found && /namespace:/{print \$2; exit}
  " "$kubeconfig")
  [[ -z $ns ]] && ns="default"

  echo "%F{$AP_C_KUBE}󱃾 ${ctx}:${ns}%f"
}

_ap_kube_ctx_precmd() {
  local seg=$(_ap_kube_ctx_segment)
  [[ -n $seg ]] && RPROMPT="${RPROMPT:-} $seg"
}

add-zsh-hook precmd _ap_kube_ctx_precmd
