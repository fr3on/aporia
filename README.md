<div align="center">
  <h1>Aporia</h1>
  <p><b>Deep Blue · Context-Aware · High-Performance</b></p>
  <p>A professional Zsh theme designed for developers who demand a state-of-the-art terminal environment.</p>

  <a href="https://github.com/fr3on/aporia/releases/latest"><img src="https://img.shields.io/github/v/release/fr3on/aporia?style=flat-square&logo=github&color=blue" alt="Latest Release"></a>
  <img src="https://img.shields.io/badge/zsh-%3E%3D5.2-orange?style=flat-square&logo=zsh" alt="Zsh Version">
  <a href="https://github.com/fr3on/aporia/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/fr3on/aporia/ci.yml?style=flat-square&logo=github-actions" alt="CI Status"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/fr3on/aporia?style=flat-square&color=brightgreen" alt="License"></a>
  <img src="screenshots/preview.png" width="800" alt="Aporia Theme Preview">
</div>


## The Aporia Philosophy
Aporia isn't just a prompt; it's a **context-aware environment**. It adapts dynamically to your project, your privileges, and your operating system—staying minimal when you're busy and providing deep insights when you need them.

### Core Features
*   **Asynchronous Prompt Engine**: Native non-blocking background workers (`zle -F`) for instant terminal snappiness.
*   **Theme Presets**: Switch between `deep_blue`, `light`, `amber`, `crimson_void`, and `forest_matrix`.
*   **Adaptive Branding**: Official high-fidelity icons for macOS, Debian, Ubuntu, Arch, and more.
*   **Polyglot Awareness**: Real-time project detection for **Go, Rust, Python, Node, Ruby, PHP, Java, and C++**.
*   **Forensic Intelligence**: Dedicated modules for **VPN detection, Operational Target tracking, and Cloud Identity**.
*   **Aporia Essentials**: Built-in support for ghost-text **Autosuggestions** and live **Syntax Highlighting**.


## Compatibility

Aporia is designed for native performance across Unix-like systems. It is formally compatible with:

*   **macOS**: Native optimized support via Homebrew or standard install.
*   **Linux**: Full support for Debian, Ubuntu, Arch, Fedora, Alpine, and more.
*   **Windows**: Supported via **WSL2** (requires a Nerd Font installed on the Windows side).

**Requirements**:
- **Zsh**: Version 5.2 or newer.
- **Font**: A [Nerd Font](https://www.nerdfonts.com) (e.g., JetBrainsMono, Hack) for high-fidelity icons.


## Installation

### 1-Click Install (Universal)
The fastest way to get started on any system:
```bash
curl -fsSL https://raw.githubusercontent.com/fr3on/aporia/main/install.sh | zsh
```

### Homebrew (macOS)
The professional way to manage Aporia on your Mac:
```bash
brew tap fr3on/aporia https://github.com/fr3on/aporia
brew install aporia
```
*Note: Make sure to add `source $(brew --prefix)/share/aporia/aporia.zsh-theme` to your `.zshrc`.*

### Plugin Managers
| Manager | Configuration |
| :--- | :--- |
| **Oh My Zsh** | `git clone https://github.com/fr3on/aporia $ZSH_CUSTOM/themes/aporia`<br/>*Set `ZSH_THEME="aporia/aporia"` in `.zshrc`* |
| **Zinit** | `zinit ice pick"aporia.zsh-theme"; zinit light fr3on/aporia` |
| **Antigen** | `antigen theme fr3on/aporia` |
| **Zplug** | `zplug "fr3on/aporia", as:theme` |


## The Aporia CLI

Aporia includes a built-in management utility to control your environment:

*   **`aporia theme <name>`**: Instantly switch between color schemes (`amber`, `crimson_void`, etc.).
*   **`aporia info`**: Show the forensic dashboard with system health and plugin status.
*   **`aporia inspect`**: Dump raw contextual data for debugging segment logic.
*   **`aporia list`**: View all available and active forensic plugins.


## Plugin System

Aporia features a modular plugin system that keeps your prompt fast while giving you the tools you need. Plugins are opt-in and handled via the `AP_PLUGINS` array.

> [!TIP]
> **New to Aporia plugins?** Check out our **[Detailed Plugin Guide (with examples)](PLUGINS.md)** to see how each feature works!

### Available Plugins

| Plugin | Description | Type |
|---|---|---|
| `vpn-status` | Real-time detection of Tailscale, Mullvad, and WireGuard tunnels | **Forensic** |
| `target` | Sets an operational scope (IP/Host) to prevent command leakage | **Forensic** |
| `telemetry` | Dynamic CPU/RAM monitor (alerts only during high load) | **Forensic** |
| `azure-ctx` | Shows active Azure Subscription and Resource Group | **Cloud** |
| `gcp-ctx` | Shows active Google Cloud Project and Identity | **Cloud** |
| `gh-context` | Tracks GitHub CLI identity and repository context | **Cloud** |
| `docker-ctx` | Shows Docker context in prompt (no subprocess) | **Infra** |
| `kube-ctx` | Shows kubectl context:namespace (no kubectl) | **Infra** |
| `fast-syntax-highlighting` | Drop-in FSH replacement (faster, themeable) | **Essential** |
| `fzf-tab` | Replaces tab completion menu with fzf | **Utility** |

### Management Commands
*   **`aporia install <p>`**: Downloads a third-party plugin.
*   **`aporia activate <p>`**: Enables a plugin and saves it to your `~/.zshrc`.
*   **`aporia activate-all`**: Activates all installed plugins.
*   **`aporia update`**: Pulls the latest changes for all your installed plugins.


## Configuration
Override these variables in your `~/.zshrc` *before* the theme is sourced to customize your experience:

| Variable | Default | Description |
| :--- | :--- | :--- |
| `AP_THEME` | `deep_blue` | Color preset: `deep_blue`, `light`, `amber`, `crimson_void`, `forest_matrix` |
| `AP_USE_NERD_FONT` | `1` | Set to `0` for fallback Unicode characters |
| `AP_ASCII_FALLBACK` | `0` | Set to `1` to use ASCII separators instead of Nerd Fonts |
| `AP_SHOW_SSH` | `1` | Show SSH context (user@host) |
| `AP_SHOW_GIT` | `1` | Show Git status and upstream info |
| `AP_SHOW_LANGS` | `1` | Show language versions (only inside projects) |
| `AP_SHOW_EXEC_TIME` | `1` | Show command execution timing |
| `AP_EXEC_TIME_THRESHOLD` | `2` | Minimum duration (s) to show timing |
| `AP_SHOW_EXIT_CODE` | `1` | Show non-zero exit codes |
| `AP_SHOW_TIME` | `1` | Show the right-side clock |


## Troubleshooting

> [!IMPORTANT]
> **Icons appearing as squares?**
> 1. Ensure you are using a [Nerd Font](https://www.nerdfonts.com) (we recommend **JetBrainsMono**).
> 2. Check your locale: Run `locale` and ensure `LANG` includes `UTF-8`.
> 3. If you cannot use Nerd Fonts, set `AP_ASCII_FALLBACK=1` in your `.zshrc`.


## License
MIT © **Ahmed Mardi (fr3on)**
