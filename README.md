# aporia.zsh-theme

> Dark flame powerline prompt for zsh — no dependencies, cross-platform.

![preview](screenshots/preview.png)

## Features
- Flame/slant powerline separators (Nerd Font)
- Git branch, dirty indicator, ahead/behind upstream
- SSH context (user@host — SSH sessions only)
- Execution time (configurable threshold)
- Language versions: Python venv · Node · Rust (project-aware)
- Exit code indicator
- Title bar integration
- Clock
- ASCII fallback mode (no Nerd Font needed)
- macOS + Linux · zsh 5.3+
- **Aporia Essentials**: Built-in Autocomplete & Syntax Highlighting

## 🚀 Installation

### 1-Click Install (Universal)
```bash
curl -fsSL https://raw.githubusercontent.com/fr3on/aporia/main/install.sh | bash
```

### Homebrew (macOS)
```bash
brew tap fr3on/aporia
brew install aporia
```
*Add `source $(brew --prefix)/share/aporia/aporia.zsh-theme` to your `.zshrc`.*

### Plugin Managers
| Manager | Command |
| :--- | :--- |
| **Oh My Zsh** | `git clone https://github.com/fr3on/aporia $ZSH_CUSTOM/themes/aporia` |
| **Zinit** | `zinit ice pick"aporia.zsh-theme"; zinit light fr3on/aporia` |
| **Antigen** | `antigen theme fr3on/aporia` |
| **Zplug** | `zplug "fr3on/aporia", as:theme` |

### Manual
1. Download `aporia.zsh-theme` to your home folder.
2. Add `source ~/.aporia.zsh-theme` to your `.zshrc`.
3. Reload: `source ~/.zshrc`

## ⚙️ Configuration

You can override these variables in your `~/.zshrc` *before* sourcing the theme:

| Variable | Default | Description |
|---|---|---|
| `AP_ASCII_FALLBACK` | `0` | Set to `1` to use ASCII separators instead of Nerd Fonts |
| `AP_SHOW_SSH` | `1` | Show SSH context |
| `AP_SHOW_GIT` | `1` | Show Git status |
| `AP_SHOW_LANGS` | `1` | Show language versions |
| `AP_SHOW_EXEC_TIME` | `1` | Show command execution time |
| `AP_EXEC_TIME_THRESHOLD` | `2` | Minimum duration (s) to show exec time |
| `AP_DIR_DEPTH` | `3` | Number of directory segments to show |

## Nerd Font
Requires a [Nerd Font](https://www.nerdfonts.com) for flame/slant glyphs.
Recommended: **JetBrainsMono Nerd Font**

Set `AP_ASCII_FALLBACK=1` for terminals without Nerd Fonts.

## Troubleshooting Icons
If you see broken squares or strange characters instead of icons:
1. **Locale**: Ensure your shell uses a UTF-8 locale. Run `locale` and check that `LANG="en_US.UTF-8"`.
2. **Terminal Font**: Ensure you have selected a **Nerd Font** in your terminal's settings.
3. **Fallback**: If you cannot use Nerd Fonts, enable ASCII mode in `~/.zshrc`: `AP_ASCII_FALLBACK=1`.

## 🗑 Uninstall
```bash
bash ~/.aporia-uninstall.sh
```

## 📄 License
MIT © Ahmed (aporia)
