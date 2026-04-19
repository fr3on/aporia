# aporia/plugins/sudo/sudo.zsh
# Double ESC → prepend sudo to current or last command

_ap_sudo_plugin() {
  if [[ -z $BUFFER ]]; then
    BUFFER="sudo $(fc -ln -1)"
    zle end-of-line
  elif [[ $BUFFER == sudo\ * ]]; then
    BUFFER="${BUFFER#sudo }"
  else
    BUFFER="sudo $BUFFER"
  fi
}

zle -N _ap_sudo_plugin
bindkey '\e\e' _ap_sudo_plugin
