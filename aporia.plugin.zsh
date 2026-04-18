# Aporia Zsh Theme Plugin Loader
# Standard entry point for Zsh plugin managers

# Compute the plugin directory
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
APORIA_DIR="${0:h}"

# Source the main theme
if [[ -f "$APORIA_DIR/aporia.zsh-theme" ]]; then
  source "$APORIA_DIR/aporia.zsh-theme"
else
  # Fallback for installed locations
  source "$APORIA_DIR/aporia.zsh" 2>/dev/null
fi
