<div align="center">
  <h1>🌀 Aporia</h1>
  <p><b>Deep Blue · Context-Aware · High-Performance</b></p>
  <p>A professional Zsh theme designed for developers who demand a state-of-the-art terminal environment.</p>

  <a href="https://github.com/fr3on/aporia/releases/tag/1.0.0"><img src="https://img.shields.io/badge/version-1.0.0-blue.svg" alt="1.0.0"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="MIT License"></a>
  <img src="screenshots/preview.png" width="800" alt="Aporia Theme Preview">
</div>

---

## The Aporia Philosophy
Aporia isn't just a prompt; it's a **context-aware environment**. It adapts dynamically to your project, your privileges, and your operating system—staying minimal when you're busy and providing deep insights when you need them.

### Core Features
*   **Adaptive Branding**: Official high-fidelity icons for macOS, Debian, Ubuntu, Arch, and more.
*   **Polyglot Awareness**: Real-time version detection for **Go, Rust, Python, Node, Ruby, PHP, Java, and C++**.
*   **Root Safety**: Subtle OS-native alerts when running with high privileges.
*   **Deep Blue UI**: A curated Slate & Electric Blue palette designed for focus and aesthetics.
*   **Zero Dependencies**: Optimized for speed with native Zsh hooks (no slow external calls).
*   **Aporia Essentials**: Built-in support for ghost-text **Autosuggestions** and live **Syntax Highlighting**.

---

## Installation

### 1-Click Install (Universal)
The fastest way to get started on any system:
```bash
curl -fsSL https://raw.githubusercontent.com/fr3on/aporia/main/install.sh | bash
```

### Homebrew (macOS)
The professional way to manage Aporia on your Mac:
```bash
brew tap fr3on/aporia
brew install aporia
```
*Note: Make sure to add `source $(brew --prefix)/share/aporia/aporia.zsh-theme` to your `.zshrc`.*

### Plugin Managers
| Manager | Configuration |
| :--- | :--- |
| **Oh My Zsh** | `git clone https://github.com/fr3on/aporia $ZSH_CUSTOM/themes/aporia` |
| **Zinit** | `zinit ice pick"aporia.zsh-theme"; zinit light fr3on/aporia` |
| **Antigen** | `antigen theme fr3on/aporia` |
| **Zplug** | `zplug "fr3on/aporia", as:theme` |

---

## Aporia Essentials
To enable the full "Terminal OS" experience, we recommend installing the **Essentials Bundle** during setup. This activates:
*   **zsh-autosuggestions**: Predictions based on your history.
*   **zsh-syntax-highlighting**: Commands turn Green/Red as you type.

> [!TIP]
> Run the `install.sh` and select **"Y"** when prompted for Essentials to have these pre-configured for you.

---

## Configuration
Override these variables in your `~/.zshrc` *before* the theme is sourced to customize your experience:

| Variable | Default | Description |
| :--- | :--- | :--- |
| `AP_ASCII_FALLBACK` | `0` | Set to `1` to use ASCII separators instead of Nerd Fonts |
| `AP_SHOW_SSH` | `1` | Show SSH context (user@host) |
| `AP_SHOW_GIT` | `1` | Show Git status and upstream info |
| `AP_SHOW_LANGS` | `1` | Show language versions (only inside projects) |
| `AP_SHOW_EXEC_TIME` | `1` | Show command execution timing |
| `AP_EXEC_TIME_THRESHOLD` | `2` | Minimum duration (s) to show timing |
| `AP_DIR_DEPTH` | `3` | Number of directory segments to show |

---

## Troubleshooting

> [!IMPORTANT]
> **Icons appearing as squares?**
> 1. Ensure you are using a [Nerd Font](https://www.nerdfonts.com) (we recommend **JetBrainsMono**).
> 2. Check your locale: Run `locale` and ensure `LANG` includes `UTF-8`.
> 3. If you cannot use Nerd Fonts, set `AP_ASCII_FALLBACK=1` in your `.zshrc`.

---

## License
MIT © **Ahmed Mardi (fr3on)**
