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

## Install

### One-liner
```bash
curl -fsSL https://raw.githubusercontent.com/fr3on/aporia/main/install.sh | bash
```

### Manual
```bash
curl -fsSL https://raw.githubusercontent.com/fr3on/aporia/main/aporia.zsh-theme \
  -o ~/.aporia.zsh-theme
echo 'source ~/.aporia.zsh-theme' >> ~/.zshrc
source ~/.zshrc
```

### oh-my-zsh
1. Clone the repo:
   ```bash
   git clone https://github.com/fr3on/aporia \
     ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/aporia
   ```
2. Set `ZSH_THEME="fr3on/aporia"` in your `~/.zshrc`.

## Configuration

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
1. **Locale**: Ensure your shell uses a UTF-8 locale. Run `locale` and check that `LANG="en_US.UTF-8"`. If not, add `export LANG=en_US.UTF-8` to your `~/.zshrc`.
2. **Terminal Font**: Ensure you have selected a **Nerd Font** in your terminal's settings (e.g., iTerm2 > Profiles > Text > Font).
3. **Fallback**: If you cannot use Nerd Fonts, enable ASCII mode in `~/.zshrc`:
   ```zsh
   AP_ASCII_FALLBACK=1
   ```

## Uninstall
```bash
bash ~/.aporia-uninstall.sh
```

## License
MIT © Ahmed (aporia)
