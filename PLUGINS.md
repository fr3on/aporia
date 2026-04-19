# 🌀 Aporia Plugin Guide

This guide provides a comprehensive overview of every plugin supported by the Aporia Zsh theme, complete with actionable examples and "Try This" scenarios.

## Activation Quick-Start
To enable any plugin mentioned below, simply run:
```zsh
aporia-activate-plugin <plugin-name>
```

---

## The Essentials
*These are recommended for every installation to provide the core Aporia experience.*

### `zsh-autosuggestions`
**What it does:** Suggests commands as you type based on your history (Ghost Text).
- **Example:** Type `gi` and you might see `t status` in gray.
- **Try This:** 
  1. Type the first few letters of a command you use often.
  2. Press **`→` (Right Arrow)** or **`End`** to accept the suggestion.

### `fast-syntax-highlighting`
**What it does:** Provides high-speed, theme-aware coloring for your commands.
- **Example:** Valid commands are **Green**, invalid commands are **Red**.
- **Try This:** 
  1. Type `ls` (Green).
  2. Type `lsssss` (Red).

---

## Search & History

### `history-substring-search`
**What it does:** Search history for commands containing a specific substring using arrow keys.
- **Try This:** 
  1. Type `ssh`.
  2. Press **`Up Arrow`**. It will find every previous command that has `ssh` anywhere in it, not just at the start.

### `fzf-history`
**What it does:** Full interactive fuzzy search of your entire command history.
- **Keybinding:** `Ctrl` + `R`
- **Command:** `fzf-history`
- **Try This:** 
  1. Press **`Ctrl + R`**.
  2. Type a part of a command (e.g., `brew` or `docker`).
  3. Use arrows to select and `Enter` to pick it.

---

## Productivity Tools

### `sudo`
**What it does:** Quickly prepend `sudo` to your current or previous command.
- **Keybinding:** Press **`ESC`** twice.
- **Try This:** 
  1. Type `apt update` (or any command that needs root).
  2. Realize you forgot sudo? Press **`ESC` `ESC`**. It will turn into `sudo apt update` automatically.

### `autopair`
**What it does:** Automatically closes brackets, quotes, and parentheticals.
- **Try This:** 
  1. Type `(`. It will automatically become `()`.
  2. Type `"`. It will automatically become `""`.

### `you-should-use`
**What it does:** Reminds you to use your aliases when you type a full command.
- **Try This:** 
  1. Create an alias: `alias gs='git status'`.
  2. Type the full `git status`.
  3. Aporia will helpfully suggest: `Found existing alias: gs. You should use it!`

---

## Cloud & Context (Right Prompt)
*These plugins automatically appear in your **Right Prompt (RPROMPT)** when relevant.*

### `docker-ctx`
**What it does:** Shows your current Docker context.
- **Example:** `󰡨  default`
- **Try This:** Switch your context: `docker context use desktop-linux`. You'll see the prompt update instantly.

### `kube-ctx`
**What it does:** Shows your current Kubernetes context and namespace.
- **Example:** `  my-cluster:default`
- **Try This:** Switch namespace: `kubectl config set-context --current --namespace=prod`. The context indicator will update.

### `aws-profile`
**What it does:** Shows your active AWS profile and region.
- **Safe Mode:** Turns **Red** if your profile starts with `prod` or `production`.
- **Try This:** `export AWS_PROFILE=prod-deploy`. Watch the prompt turn red as a safety warning.

### `proxmox`
**What it does:** Identifies if you are on a Proxmox Host node or inside a Proxmox Guest VM.
- **Example:** `󱘊 PVE Host`
- **Try This:** Run `aporia-activate-plugin proxmox` while on your Proxmox system to see the branding update.

---

## Environment Managers

### `autoswitch-venv`
**What it does:** Automatically activates Python virtual environments (`.venv`, `venv`, `env`).
- **Try This:** 
  1. `cd` into a Python project with a virtualenv.
  2. Aporia will automatically source it and show the indicator in your prompt.

### `nix-shell`
**What it does:** Shows when you are inside a Nix shell or `devenv` environment.
- **Example:** `  nix-shell`

---

## Advanced Interaction

### `fzf-tab`
**What it does:** Replaces the standard Zsh completion menu with a powerful `fzf` browser.
- **Try This:** 
  1. Type `cd` and press **`TAB`**.
  2. Instead of a list, you get a fuzzy-searchable `fzf` window for your directories.

### `forgit`
**What it does:** Interactive `fzf`-powered Git workflows.
- **Try This:**
  - `gl`: Interactive git log.
  - `gd`: Interactive git diff.
  - `ga`: Interactive git add.

---

> [!TIP]
> Use **`aporia-list-plugins`** at any time to see which of these are currently active in your shell!
