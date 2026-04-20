# Changelog

## [1.1.0] - The Async Velocity Update
This update introduces a high-performance asynchronous engine and several modern UI refinements for a faster, more flexible terminal experience.

### Highlights
*   **Asynchronous Prompt Engine**: Eliminated UI blocking. Slow Git and language version checks now run in non-blocking background workers using `zle -F`.
*   **Theme Preset System**: Introducing `AP_THEME`. Switch between `deep_blue` (default), `light`, and `amber` (warm/earthy) palettes.
*   **Git Stash Tracking**: New real-time stash indicator (`󰟫`) displays the count of stashed changes.
*   **Contextual Left Segments**: Moved **Virtual Environments** and **Docker Contexts** to high-visibility, dedicated blocks on the left side of the prompt.
*   **Flat Design Aesthetic**: Refined the left segments to support a cleaner, background-less look with colored separators.

### Hardening & Optimizations
*   **Optimized Scanning**: Fast-path traversal in `_ap_find_up` reduces latency in deep project structures.
*   **Proxmox Support**: Integrated context-aware detection for Proxmox hosts and guest environments.
*   **Unified CLI Dashboard**: Updated `aporia` command to show system status, active theme, and environment health.
*   **State Integrity**: Migrated PWD tracking to associative arrays to prevent internal variables from leaking into the prompt via `AUTO_NAME_DIRS`.
*   **Remote Plugin Delivery**: Added curl-based remote installation for the bundled plugin suite.

---

## [1.0.0] - Aporia: The Dark Flame Edition
This is the first stable release of Aporia, representing a complete leap from a simple theme to a high-performance shell ecosystem.

### Highlights
*   **Aporia Essentials**: Built-in support for ghost-text **Autosuggestions** and live **Syntax Highlighting** (Integrated Plugin Bundle).
*   **Context-Aware Branding**: High-fidelity, official icons for macOS and major Linux distros (Debian, Arch, Ubuntu, etc.)—NO emojis used.
*   **Polyglot Logic**: Real-time, project-aware version detection for 8+ languages (Go, Rust, Python, Node, Ruby, PHP, Java, etc.).
*   **Adaptive Intelligence**: Subtle OS-native root alerts and dynamic width detection (segments hide automatically in narrow windows).
*   **Homebrew & Plugin Support**: Officially packaged for `brew`, Oh My Zsh, Zinit, and Antigen.
*   **"Air" Minimalist UI**: A curated Slate / Electric Blue design with high-fidelity Unicode slants.

### Hardening & Fixes
*   Shell-agnostic `install.sh` and `uninstall.sh`.
*   Hardened Zsh logic (added shell guards and localized path expansion).
*   Corrected Git status logic for detached heads and dirty state detection.
*   Auto-UTF8 locale enforcement for icon stability.
*   **Performance Optimization**: Added directory-level caching for language versions (`node`, `rustc`, etc.) to prevent prompt lag.
*     *Note: If you switch language versions (e.g. `nvm use`) in the current directory, a quick `cd .` will invalidate the cache and update the icon.*

---
*MIT © 2026 Ahmed Mardi (fr3on)*
