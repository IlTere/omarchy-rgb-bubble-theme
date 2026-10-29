# Omarchy compatibility

RGB Bubble supplies a dark `colors.toml`, `icons.theme`, and `shell.toml` for Omarchy's Quickshell surfaces. Omarchy generates app configs from the palette when the theme is applied. The installer adds a custom Vim colorscheme (`vim/colors/rgb-bubble.vim`) plus theme-isolated user-owned shell plugin overrides for the top bar and OSD.

The palette was resolved with Omarchy **4.0.6-1**. That install's generated theme templates and transparent-window support cover:

- **Desktop and Omarchy shell:** Hyprland borders and preview/share picker; the Quickshell bar, menus, notifications, OSD, lock screen, polkit prompts, and controls; and Gum prompts.
- **Terminals (full ANSI palette + transparent glass window):** Alacritty, Foot, Ghostty, Kitty, and TUI apps (`btop`, `yazi`, `cliamp`, `aether`).
- **Editors and coding tools (palette + transparent glass window):** Neovim, Vim (`:colorscheme rgb-bubble`), Helix, VS Code, Obsidian, Omawrite, Tensaku, Hermes, Pi, and T3 Code.
- **System utilities and file managers (transparent glass window):** Nautilus, file picker portals, LocalSend, Disk Usage, Calculator (`omacalc`), and Spotify.
- **Browsers, web apps, media & document viewers (kept 100% opaque for readability):** Chromium (`chromium.theme` still styles the browser chrome), Firefox, Qutebrowser, installed web apps (Discord, WhatsApp, YouTube, Google Photos/Maps/Messages/Contacts, Basecamp), video/streaming apps (`mpv`, `vlc`, Kdenlive, OBS Studio, Omacut), and image/document viewers (`imv`, Pinta, Xournal++, Evince, Papers, LibreOffice).
- **Hardware:** Keyboard RGB palette.
- **AeroFyl:** not installed by the theme installer. If its VS Code language extension is installed separately, the Omarchy-generated VS Code theme provides the editor colors.

Obsidian needs the generated Omarchy theme selected inside Obsidian. Apps outside Omarchy's generated templates still receive the translucent glass window treatment via Hyprland when `rgb-bubble` is active.

## Translucency, rounding, and strict theme isolation

RGB Bubble uses 14% surface opacity (86% transparency) for the bar, menus, popups, notifications, and lock screen, 45% for tooltips, and 40% for authentication prompts. These values style Omarchy shell surfaces natively via `shell.toml`; the separate Hyprland module (`hyprland/rgb-bubble.lua`) makes application windows translucent. The built-in Omarchy menu reads these theme colors directly and remains the stock plugin. All themed panel borders have zero width and alpha.

The installer clones only `omarchy.bar` and `omarchy.osd` (and patches `omarchy.tailscale` only if already cloned) so it never auto-enables optional bar widgets. Both the QML overrides and `hyprland/rgb-bubble.lua` are strictly gated on the active theme (`rgb-bubble` and `rgb-bubble.watermark = "true"` in `shell.toml`). Switching to any other Omarchy theme immediately disables the watermark, bar/OSD overrides, window opacity, corner rounding, and backdrop blur.

**Transparency support:** Omarchy shell and system panels use 14% surface opacity (86% transparency). The top bar alone shows the bubble watermark while RGB Bubble is active. Hyprland applies 90% focused / 95% unfocused opacity (10% / 5% transparency) to terminals, editors, notes, file managers, and system utilities. Browsers, web apps, video/media players, image/drawing/document viewers, Picture-in-Picture (`pip`), and fullscreen windows are excluded and remain 100% opaque. Backdrop blur is set to size 8 with 2 passes and `ignore_opacity = true` (`vibrancy = 0.28`) so blur remains strong behind both focused and unfocused glass windows. Window corner rounding (`rounding = 22`) remains a separate compositor effect scoped to RGB Bubble. App and window border colors remain unchanged.

## App theme selection

- Omarchy-generated themes automatically update Kitty, Foot, Alacritty, Ghostty, Neovim, Helix, VS Code, btop, and the other template-backed apps when `rgb-bubble` is applied.
- Chromium uses the generated `chromium.theme`; theme handling can depend on the installed Chromium-family browser.
- Vim: run `:colorscheme rgb-bubble` (or add `colorscheme rgb-bubble` to your `~/.vimrc` to make it persistent).

These app-specific theme choices change application colors only; the installer does not overwrite personal app settings or force a theme selection inside those applications.

The supported template set can change with Omarchy releases. This list reflects the installed 4.0.6-1 template inventory; re-check it when updating the theme for a newer release.
