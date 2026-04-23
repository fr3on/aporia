# Changelog

## [1.1.3] - The Auto-Setup Update
This patch introduces a smoother installation experience for Homebrew users and minor architecture refinements.

### Highlights
*   **Brew Auto-Setup**: Introduced the `aporia-setup` command for Homebrew users to automatically configure their `.zshrc`.
*   **Identity Variable**: Added `ZSH_THEME_NAME` for standard identification by shell utilities.

---

## [1.1.2] - The Architectural Harmony Update
This major refactor aligns the repository structure and internal logic with the core design principles and architectural standards.

### Highlights
*   **Logic Consolidation**: Moved all core intelligence, plugin management, and the `aporia` CLI from the plugin wrapper into the main theme file.
*   **Thin Wrapper Architecture**: Refactored `aporia.plugin.zsh` into a lightweight loader, ensuring the theme remains fully functional even when sourced directly.
*   **Standardized Naming**: Renamed internal segment functions and helpers to follow strict naming conventions (`_ap_segment_*` and `_ap_<verb>_<noun>`).
*   **Self-Healing History**: Integrated automatic history persistence setup for high-fidelity forensic monitoring.

### Improvements & Fixes
*   **Improved Modularity**: Unified plugin registries and dependency checks.
*   **CI Hardening**: Updated smoke tests to reflect the new internal naming and architecture.
*   **Performance Optimization**: Refined async handler logic for faster prompt rendering.

---

## [1.1.1] - The Forensic Intelligence Expansion
This update transforms Aporia into a specialized forensic and digital intelligence environment, introducing real-time monitoring and operational scope tracking.

### Highlights
*   **Forensic Plugin Suite**: New modules for **VPN detection** (Tailscale, Mullvad, WireGuard), **Operational Target tracking** (`aporia-target`), and **Live Telemetry** (CPU/RAM).
*   **Theme Engine Overhaul**: Added **`crimson_void`** (Hacker aesthetic) and **`forest_matrix`** (Digital green) themes. Fixed color persistence bugs when switching themes.
*   **Cloud & Infrastructure Identity**: Integrated context tracking for **Azure Subscription**, **GCP Project**, and **GitHub CLI** identity.
*   **Enhanced Dashboard**: The `aporia info` dashboard now displays live telemetry data and more accurate plugin status reporting.
*   **Repository Governance**: Added official GitHub Issue/PR templates and a Security Policy for better community engagement.

### Improvements & Fixes
*   **Persistence Fix**: Theme changes are now correctly saved to `~/.zshrc` using portable logic.
*   **Math Safety**: Hardened telemetry logic with defensive math expressions to prevent shell startup errors.
*   **Variable Renaming**: Resolved conflicts with Zsh read-only variables (like `status`) in vpn segments.

---

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
