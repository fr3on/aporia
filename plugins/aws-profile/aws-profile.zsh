# aporia/plugins/aws-profile/aws-profile.zsh

AP_C_AWS=${AP_C_AWS:-214}        # amber
AP_C_AWS_DANGER=${AP_C_AWS_DANGER:-196}   # red (prod context)

_ap_aws_segment() {
  local profile="${AWS_PROFILE:-${AWS_DEFAULT_PROFILE:-}}"
  local region="${AWS_DEFAULT_REGION:-${AWS_REGION:-}}"

  [[ -z $profile && -z $region ]] && return

  local color=$AP_C_AWS
  [[ $profile == prod* || $profile == production* ]] && color=$AP_C_AWS_DANGER

  local label=""
  [[ -n $profile ]] && label+="$profile"
  [[ -n $region  ]] && label+=" ${region}"

  echo "%F{$color} $label%f"
}

if (( $+functions[aporia_register_async] )); then
  aporia_register_async "aws-profile" "_ap_aws_segment"
else
  _ap_aws_precmd() {
    local seg=$(_ap_aws_segment)
    [[ -n $seg ]] && RPROMPT="${RPROMPT:-} $seg"
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _ap_aws_precmd
fi
