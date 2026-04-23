# ╔═══════════════════════════════════════════════════════════════════╗
# ║  aporia.plugin.zsh — Thin Plugin Wrapper                          ║
# ║  Sources the core theme and handles optional dependencies         ║
# ╚═══════════════════════════════════════════════════════════════════╝

# Core Theme Source
# We look for the theme file in the same directory as this plugin
_ap_theme_file="${${(%):-%x}:h}/aporia.zsh-theme"
if [[ -f $_ap_theme_file ]]; then
  source "$_ap_theme_file"
else
  # Fallback for alternative installation paths
  [[ -f "$HOME/.aporia.zsh-theme" ]] && source "$HOME/.aporia.zsh-theme"
fi

unset _ap_theme_file
