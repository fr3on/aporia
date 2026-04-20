# 📑 Changelog

## [1.0.0] - Aporia: The Dark Flame Edition
This is the first stable release of Aporia, representing a complete leap from a simple theme to a high-performance shell ecosystem.

### ✨ Highlights
*   **Aporia Essentials**: Built-in support for ghost-text **Autosuggestions** and live **Syntax Highlighting** (Integrated Plugin Bundle).
*   **Context-Aware Branding**: High-fidelity, official icons for macOS and major Linux distros (Debian, Arch, Ubuntu, etc.)—NO emojis used.
*   **Polyglot Logic**: Real-time, project-aware version detection for 8+ languages (Go, Rust, Python, Node, Ruby, PHP, Java, etc.).
*   **Adaptive Intelligence**: Subtle OS-native root alerts and dynamic width detection (segments hide automatically in narrow windows).
*   **Homebrew & Plugin Support**: Officially packaged for `brew`, Oh My Zsh, Zinit, and Antigen.
*   **"Air" Minimalist UI**: A curated Slate / Electric Blue design with high-fidelity Unicode slants.

### 🔧 Hardening & Fixes
*   Shell-agnostic `install.sh` and `uninstall.sh`.
*   Hardened Zsh logic (added shell guards and localized path expansion).
*   Corrected Git status logic for detached heads and dirty state detection.
*   Auto-UTF8 locale enforcement for icon stability.
*   **Performance Optimization**: Added directory-level caching for language versions (`node`, `rustc`, etc.) to prevent prompt lag.
    *   *Note: If you switch language versions (e.g. `nvm use`) in the current directory, a quick `cd .` will invalidate the cache and update the icon.*

---
*MIT © 2026 Ahmed Mardi (fr3on)*
