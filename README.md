# RGB Bubble

Throw yourself into the mysterious underwater world of Omarchy with this dark, translucent, bubbly theme developed by **@terelux**. Midnight surfaces, a vivid red/green/blue palette, and a glass look and feel.

![RGB Bubble Desktop Preview](preview.png)

This is an independent community theme for Omarchy. It is not affiliated with Bubble or an official Omarchy release.

## Install everything

One command installs the dark RGB Bubble theme, the `cbubbles` terminal animation utility, rounded-window and optimized-blur settings, and transparent window and app styling (including custom colorschemes such as Vim, alongside Omarchy's supported terminals, editors, and browsers):

```sh
curl -fsSL https://raw.githubusercontent.com/IlTere/omarchy-bubble-theme/main/install.sh | bash
```

Use this command for the complete RGB Bubble setup. [Omarchy's built-in repository-theme installer](https://github.com/omacom/omarchy/blob/quattro/manual/43-making-your-own-theme.md) intentionally omits Lua-based window opacity, blur, and rounding; it does not run this repo's panel-patching installer. This script installs those additional treatments in user-owned configuration and plugin clones, while strictly isolating them to the RGB Bubble theme.

To cleanly revert the compositor and plugin overrides at any time:

```sh
bash install.sh uninstall
```

### Installing `cbubbles` (Terminal RGB Bubble Animation)

![cbubbles Terminal Animation](assets/cbubbles-demo.gif)

`cbubbles` is installed automatically with the theme (into both `~/.config/omarchy/themes/rgb-bubble/bin/cbubbles` and `~/.local/bin/cbubbles`). You can also install `cbubbles` standalone as a package:

- **Standalone via installer script:**
  ```sh
  curl -fsSL https://raw.githubusercontent.com/IlTere/omarchy-bubble-theme/main/install.sh | bash -s -- cbubbles
  ```
- **As an Arch Linux / Omarchy system package (`pacman` / `makepkg`):**
  ```sh
  cd packaging && makepkg -si
  ```
- **As a Python CLI package (`pipx` or `uv`):**
  ```sh
  pipx install git+https://github.com/IlTere/omarchy-bubble-theme.git
  ```

Run `cbubbles`, `cbubbles -l` (with the interactive centered Omarchy pixel logo), or `cbubbles help` for the full reference guide.

The centered Omarchy wordmark wallpaper (`01-bubble-omarchy.webp`) is first in the sorted wallpaper list, so Omarchy selects it by default when switching to RGB Bubble. Two alternates—the bubble-only wallpaper (`02-bubble-float.webp`) and the minimalist pixel-stepped RGB Bubble wordmark (`03-bubble-omarchy-pixel.webp`)—remain available in the background switcher.

The installer keeps Omarchy's packaged files untouched. Most Omarchy surfaces—including the built-in Omarchy menu, notifications, clipboard, emoji picker, calendar/clock, audio, Bluetooth, display/monitor, network/Wi-Fi, battery/power, agent usage, weather, and reminder panels—receive 14% surface opacity (86% transparency) directly from `shell.toml`, while authentication prompts use 40% opacity for readability. The installer clones user-owned versions of only `omarchy.bar` and `omarchy.osd` (plus `omarchy.tailscale` if already cloned) where QML overrides are needed, and gates every override on `rgb-bubble.watermark` so switching to any other Omarchy theme restores 100% stock behavior.

When RGB Bubble is active, Hyprland applies 90% focused / 95% unfocused opacity (10% / 5% transparency) to workspace windows—giving terminals (Alacritty, Foot, Ghostty, Kitty), editors (Vim, Neovim, Helix, VS Code), notes (Obsidian), and system utilities (`btop`, Nautilus, Spotify) a consistent underwater glass look while keeping browsers, web apps, video/media players, image/document viewers, and fullscreen windows 100% opaque. Backdrop blur is set to 2 passes at size 8 with `ignore_opacity = true` (`vibrancy = 0.28`) so both focused and unfocused glass windows have a rich frosted-glass blur.

The installer does not install applications or language extensions. It installs theme assets and configuration for the desktop and apps listed below; for example, it does not install AeroFyl.

## Contents

- `colors.toml` — dark palette used by Omarchy's generated app themes
- `shell.toml` — translucent glass colors and RGB control states for Omarchy's shell
- `chromium.theme` — matching dark chrome color for Chromium-based browsers
- `vim/colors/rgb-bubble.vim` — custom Vim colorscheme matching the RGB Bubble palette
- `bin/cbubbles` — interactive terminal RGB bubble ASCII/pixel animation (`cbubbles`, `cbubbles -l`, `cbubbles help`)
- `packaging/PKGBUILD` & `pyproject.toml` — Arch Linux and Python package definitions for `cbubbles`
- `install.sh` — one-command installer and uninstaller for the theme, `cbubbles`, and Hyprland appearance module
- `hyprland/rgb-bubble.lua` — theme-isolated app opacity, rounded windows, and reduced backdrop blur
- `panel-qml/` — top-bar watermark Quickshell component and assets
- `icons.theme` — the Yaru blue icon variant
- `backgrounds/` — lightweight WebP RGB glass-bubble wallpapers; the centered Omarchy wordmark version is the default
- `preview.png` — live desktop capture showcasing the theme, translucent windows, and `cbubbles`
- `assets/rgb-bubble.webp` — 1200×675 (<100 KB) WebP capture ready for the Omarchy theme listing
- `assets/cbubbles-demo.gif` — animated GIF showcase of `cbubbles`

Omarchy generates Kitty, Foot, Alacritty, Ghostty, Neovim, Helix, VS Code, btop, Chromium, and Obsidian palettes from `colors.toml`, and the installer adds the dedicated Vim colorscheme (`:colorscheme rgb-bubble`). See [COMPATIBILITY.md](COMPATIBILITY.md) for the full list of compatible transparent-window applications and remaining app-specific steps.

## Transparency & Theme Isolation

Translucency is applied across Omarchy's bar, menu, clipboard, emoji picker, notifications, OSD, calendar/clock, audio, Bluetooth, display, Wi-Fi/network, battery/power, agent usage, weather, authentication, and reminder panels. The bubble watermark appears only in the top bar, and both the Quickshell overrides and Hyprland compositor rules (`hyprland/rgb-bubble.lua`) check that `rgb-bubble` is the active theme—meaning every other Omarchy theme stays completely untouched when you switch themes. Hyprland applies 90% focused / 95% unfocused opacity (10% / 5% transparency) to terminals, editors, notes, file managers, and system utilities while RGB Bubble is active; browsers, web apps, video/media apps, image/document viewers, Picture-in-Picture, and fullscreen windows remain 100% opaque. Backdrop blur uses 2 passes at size 8 with `ignore_opacity = true`. See [COMPATIBILITY.md](COMPATIBILITY.md) for the full support boundary.

## Preview and checks

To preview the latest dark theme from this checkout, run `bash install.sh` in an active Omarchy desktop session. Open the Omarchy menu and system panels, then trigger an OSD notification with a volume key to inspect the translucent surfaces and subtle watermark in the top bar. Switch to another Omarchy theme to confirm the watermark, rounding, blur, and window opacity all revert cleanly to stock defaults. Run `omarchy theme current` to confirm the selected theme.

## Omarchy theme listing

The current [Omarchy site submission guide](https://github.com/omacom/omarchy-site#adding-your-theme) requires a real 16:9 desktop screenshot at 1200×675 and under about 100 KB, plus an alphabetical figure entry in the site's `themes/index.html`. A pre-formatted 75 KB copy is already included at [`assets/rgb-bubble.webp`](assets/rgb-bubble.webp), ready to add to the site's `assets/themes/` directory.

## Credits

See [CREDITS.md](CREDITS.md) for wallpaper and wordmark provenance.

## License

Released under the [MIT License](LICENSE). See [CREDITS.md](CREDITS.md) for artwork provenance notes.
