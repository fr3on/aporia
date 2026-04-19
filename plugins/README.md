# Aporia Plugin Authoring Guide

Aporia supports a simple, zero-magic plugin system. Plugins are sourced by the theme and can hook into Zsh's standard hook system (`add-zsh-hook`) or interact with Aporia's internal state.

## Directory Structure

Each plugin must reside in its own folder under `~/.aporia/plugins/`:
```
~/.aporia/plugins/<name>/
└── <name>.zsh
```
Aporia will specifically look for a file named `<name>.zsh` inside the directory.

## Plugin Conventions

- **Prefixing**: All internal functions should be prefixed with `_ap_<plugin-name>_` to avoid namespace collisions.
- **Styling**: Use the `$AP_C_*` color variables defined in the theme to ensure your plugin respects the user's color scheme.
- **Hooks**: Use `add-zsh-hook` (from Zsh's standard library) to hook into `precmd` (before prompt render) or `preexec` (before command execution).
- **Subprocesses**: Avoid calling heavy external commands (like `docker`, `kubectl`, `aws`) on every prompt. Instead, read configuration files or environment variables directly when possible.

## Example Plugin

```zsh
# plugins/my-plugin/my-plugin.zsh

AP_C_MY_PLUGIN=${AP_C_MY_PLUGIN:-82}

_ap_my_plugin_segment() {
  echo "%F{$AP_C_MY_PLUGIN} my-info %f"
}

_ap_my_plugin_precmd() {
  local seg=$(_ap_my_plugin_segment)
  [[ -n $seg ]] && RPROMPT="$seg $RPROMPT"
}

add-zsh-hook precmd _ap_my_plugin_precmd
```

## First-Party vs Third-Party

- **First-Party**: Bundled with the Aporia repository under `plugins/`. No `git clone` required.
- **Third-Party**: Registered in `_AP_PLUGIN_REGISTRY` in `aporia.plugin.zsh` with a Git URL. Users can install them using `aporia-install-plugin <name>`.
