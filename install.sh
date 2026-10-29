#!/usr/bin/env bash
set -euo pipefail

RGB_BUBBLE_REPOSITORY="${RGB_BUBBLE_REPOSITORY:-https://github.com/IlTere/omarchy-rgb-bubble-theme.git}"
RGB_BUBBLE_BRANCH="${RGB_BUBBLE_BRANCH:-main}"
RGB_BUBBLE_MODE="${1:-install}"
RGB_BUBBLE_SOURCE=""
RGB_BUBBLE_TEMP=""
RGB_BUBBLE_USER="${USER:-$(id -un)}"
RGB_BUBBLE_THEME="rgb-bubble"

case "$RGB_BUBBLE_MODE" in
  install|full|dark|"")
    RGB_BUBBLE_MODE="install"
    ;;
  tweaks|--tweaks)
    RGB_BUBBLE_MODE="tweaks"
    ;;
  hyprland|--hyprland)
    RGB_BUBBLE_MODE="hyprland"
    ;;
  panels|--panels)
    RGB_BUBBLE_MODE="panels"
    ;;
  vim|--vim)
    RGB_BUBBLE_MODE="vim"
    ;;
  cbubbles|--cbubbles)
    RGB_BUBBLE_MODE="cbubbles"
    ;;
  uninstall|--uninstall)
    RGB_BUBBLE_MODE="uninstall"
    ;;
  *)
    echo "Usage: install.sh [install|tweaks|hyprland|panels|vim|cbubbles|uninstall]" >&2
    exit 2
    ;;
esac

cleanup() {
  [[ -z $RGB_BUBBLE_TEMP ]] || rm -rf "$RGB_BUBBLE_TEMP"
}
trap cleanup EXIT

refresh_theme_selector_cache() {
  local cache_root="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy"
  rm -f \
    "$cache_root/theme-selector/fast-signature" \
    "$cache_root/theme-selector/signature" \
    "$cache_root/image-selector/"*.fast-signature \
    "$cache_root/image-selector/"*.signature \
    "$cache_root/image-selector/"*.rows 2>/dev/null || true

  if [[ -d $HOME/.config/omarchy/themes/$RGB_BUBBLE_THEME ]]; then
    touch "$HOME/.config/omarchy/themes/$RGB_BUBBLE_THEME" 2>/dev/null || true
  fi

  if command -v omarchy-theme-switcher >/dev/null 2>&1; then
    omarchy-theme-switcher --preload >/dev/null 2>&1 || true
  fi

  if command -v omarchy-menu-images >/dev/null 2>&1 && [[ -d $cache_root/theme-selector/previews ]]; then
    omarchy-menu-images --cache-only "$cache_root/theme-selector/previews" >/dev/null 2>&1 || true
  fi

  if command -v omarchy-theme-switcher >/dev/null 2>&1; then
    omarchy-theme-switcher --preload >/dev/null 2>&1 || true
  fi
}

reload_desktop_session() {
  if pgrep -x Hyprland >/dev/null 2>&1 && command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null || echo "Hyprland reload failed; inspect hyprctl configerrors." >&2
  else
    echo "No running Hyprland session detected; appearance settings will load at the next login."
  fi

  if pgrep -x quickshell >/dev/null 2>&1 && command -v omarchy-restart-shell >/dev/null 2>&1; then
    omarchy-restart-shell || echo "Could not restart Omarchy shell; restart it from the desktop session." >&2
  fi

  refresh_theme_selector_cache
}

uninstall_rgb_bubble() {
  local hypr_dir="$HOME/.config/hypr"
  local hyprland_config="$hypr_dir/hyprland.lua"
  local module_file="$hypr_dir/rgb-bubble.lua"
  local plugin_root="$HOME/.config/omarchy/plugins"

  if [[ -f $hyprland_config ]] && grep -Fq 'require("hypr.rgb-bubble")' "$hyprland_config"; then
    local backup="$hyprland_config.bak.rgb-bubble-uninstall.$(date +%Y%m%d%H%M%S)"
    cp -p -- "$hyprland_config" "$backup"
    python3 - "$hyprland_config" <<'PY'
import pathlib, re, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text()
updated = re.sub(
    r"\n*-- RGB Bubble rounded glass surfaces, blur, and app opacity\.\nrequire\(\"hypr\.rgb-bubble\"\)\n?",
    "\n",
    text,
)
updated = re.sub(r'(?m)^\s*require\("hypr\.rgb-bubble"\)\s*\n?', "", updated)
path.write_text(updated)
PY
    echo "Removed require(\"hypr.rgb-bubble\") from $hyprland_config (backup: $backup)"
  fi

  if [[ -f $module_file ]]; then
    rm -f -- "$module_file"
    echo "Removed $module_file"
  fi

  if [[ -f $HOME/.local/bin/cbubbles ]]; then
    rm -f -- "$HOME/.local/bin/cbubbles"
    echo "Removed $HOME/.local/bin/cbubbles"
  fi

  if [[ -d $plugin_root ]]; then
    python3 - "$plugin_root" "$RGB_BUBBLE_USER" <<'PY'
import pathlib, re, shutil, sys, time

root = pathlib.Path(sys.argv[1])
user = sys.argv[2]

bar_qml = root / f"{user}.bar" / "Bar.qml"
if bar_qml.is_file():
    text = bar_qml.read_text()
    updated = re.sub(r"(?m)^\s*BubbleWatermark\s*\{[^}]*\}\s*\n?", "", text)
    updated = updated.replace(
        'borderSpec: Commons.Color.shellValues["rgb-bubble.watermark"] === "true" ? Border.none() : Border.flat(root.barForeground, 1)',
        "borderSpec: Border.flat(root.barForeground, 1)",
    ).replace(
        "borderSpec: Border.none()",
        "borderSpec: Border.flat(root.barForeground, 1)",
    )
    if updated != text:
        backup = bar_qml.with_name(f"{bar_qml.name}.rgb-bubble-uninstall.bak.{time.strftime('%Y%m%d%H%M%S')}")
        shutil.copy2(bar_qml, backup)
        bar_qml.write_text(updated)
        print(f"Restored stock Bar.qml settings in {bar_qml} (backup: {backup})")

for asset_name in ("BubbleWatermark.qml", "bubble-watermark.png"):
    asset = root / f"{user}.bar" / asset_name
    if asset.is_file():
        asset.unlink()

osd_qml = root / f"{user}.osd" / "Osd.qml"
if osd_qml.is_file():
    text = osd_qml.read_text()
    updated = text.replace(
        'color: Commons.Color.shellValues["rgb-bubble.watermark"] === "true" ? Commons.Color.popups.background : Util.alpha(Commons.Color.background, 0.97)',
        "color: Util.alpha(Commons.Color.background, 0.97)",
    ).replace(
        "color: Commons.Color.popups.background",
        "color: Util.alpha(Commons.Color.background, 0.97)",
    )
    if updated != text:
        backup = osd_qml.with_name(f"{osd_qml.name}.rgb-bubble-uninstall.bak.{time.strftime('%Y%m%d%H%M%S')}")
        shutil.copy2(osd_qml, backup)
        osd_qml.write_text(updated)
        print(f"Restored stock Osd.qml settings in {osd_qml} (backup: {backup})")

tailscale_qml = root / f"{user}.tailscale" / "Panel.qml"
if tailscale_qml.is_file():
    text = tailscale_qml.read_text()
    updated = text.replace(
        'color: Commons.Color.shellValues["rgb-bubble.watermark"] === "true" ? Commons.Color.popups.background : Commons.Color.background',
        "color: Commons.Color.background",
    ).replace(
        "color: Commons.Color.popups.background",
        "color: Commons.Color.background",
    )
    if updated != text:
        backup = tailscale_qml.with_name(f"{tailscale_qml.name}.rgb-bubble-uninstall.bak.{time.strftime('%Y%m%d%H%M%S')}")
        shutil.copy2(tailscale_qml, backup)
        tailscale_qml.write_text(updated)
        print(f"Restored stock Tailscale Panel.qml settings in {tailscale_qml} (backup: {backup})")
PY
  fi

  reload_desktop_session
  echo "Uninstalled RGB Bubble compositor and panel overrides. Theme package in ~/.config/omarchy/themes/rgb-bubble was kept."
}

if [[ $RGB_BUBBLE_MODE == "uninstall" ]]; then
  uninstall_rgb_bubble
  exit 0
fi

if [[ -n ${BASH_SOURCE[0]:-} && -f ${BASH_SOURCE[0]} ]]; then
  RGB_BUBBLE_CANDIDATE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
  if [[ -f $RGB_BUBBLE_CANDIDATE/colors.toml && -f $RGB_BUBBLE_CANDIDATE/shell.toml ]]; then
    RGB_BUBBLE_SOURCE=$RGB_BUBBLE_CANDIDATE
  fi
fi

if [[ -z $RGB_BUBBLE_SOURCE && -f $HOME/.config/omarchy/themes/$RGB_BUBBLE_THEME/colors.toml && -f $HOME/.config/omarchy/themes/$RGB_BUBBLE_THEME/hyprland/rgb-bubble.lua ]]; then
  if [[ $RGB_BUBBLE_MODE != "install" ]]; then
    RGB_BUBBLE_SOURCE="$HOME/.config/omarchy/themes/$RGB_BUBBLE_THEME"
  fi
fi

if [[ -z $RGB_BUBBLE_SOURCE ]]; then
  command -v git >/dev/null || { echo "git is required to download RGB Bubble." >&2; exit 1; }
  RGB_BUBBLE_TEMP=$(mktemp -d)
  git clone --quiet --depth 1 --branch "$RGB_BUBBLE_BRANCH" -- "$RGB_BUBBLE_REPOSITORY" "$RGB_BUBBLE_TEMP/source"
  RGB_BUBBLE_SOURCE="$RGB_BUBBLE_TEMP/source"
fi

install_cbubbles_tweak() {
  [[ -f $RGB_BUBBLE_SOURCE/bin/cbubbles ]] || { echo "cbubbles binary is missing from the source." >&2; exit 1; }
  mkdir -p "$HOME/.local/bin"
  cp -f -- "$RGB_BUBBLE_SOURCE/bin/cbubbles" "$HOME/.local/bin/cbubbles"
  chmod +x "$HOME/.local/bin/cbubbles"
  echo "Installed cbubbles to $HOME/.local/bin/cbubbles. Run 'cbubbles', 'cbubbles -l', or 'cbubbles help'."
}

install_vim_tweak() {
  local source="$RGB_BUBBLE_SOURCE/vim/colors/rgb-bubble.vim"
  local destination="$HOME/.vim/colors/rgb-bubble.vim"
  local backup
  [[ -f $source ]] || { echo "Missing Vim colorscheme: $source" >&2; exit 1; }
  mkdir -p "$(dirname -- "$destination")"
  if [[ -f $destination ]] && ! cmp -s "$source" "$destination"; then
    backup="$destination.rgb-bubble.bak.$(date +%Y%m%d%H%M%S)"
    cp -p -- "$destination" "$backup"
    echo "Backed up existing Vim colorscheme to $backup"
  fi
  cp -f -- "$source" "$destination"
  echo "Installed Vim colorscheme to $destination (:colorscheme rgb-bubble)."
}

install_hyprland_tweak() {
  [[ -f $RGB_BUBBLE_SOURCE/hyprland/rgb-bubble.lua ]] || { echo "Hyprland appearance module is missing from the source." >&2; exit 1; }
  local hypr_dir="$HOME/.config/hypr"
  local hyprland_config="$hypr_dir/hyprland.lua"
  local looknfeel_config="$hypr_dir/looknfeel.lua"
  [[ -f $hyprland_config && -f $looknfeel_config ]] || {
    echo "Expected Omarchy Lua config files in $hypr_dir." >&2
    exit 1
  }

  local module_file="$hypr_dir/rgb-bubble.lua"
  if [[ -f $module_file ]] && ! cmp -s "$RGB_BUBBLE_SOURCE/hyprland/rgb-bubble.lua" "$module_file"; then
    cp -p -- "$module_file" "$module_file.bak.$(date +%Y%m%d%H%M%S)"
  fi
  cp -f -- "$RGB_BUBBLE_SOURCE/hyprland/rgb-bubble.lua" "$module_file"

  if ! grep -Fq 'require("hypr.rgb-bubble")' "$hyprland_config"; then
    cp -p -- "$hyprland_config" "$hyprland_config.bak.rgb-bubble.$(date +%Y%m%d%H%M%S)"
    cat >>"$hyprland_config" <<'LUA'

-- RGB Bubble rounded glass surfaces, blur, and app opacity.
require("hypr.rgb-bubble")
LUA
  fi

  if grep -Fq 'RGB Bubble: rounded glass surfaces' "$looknfeel_config"; then
    local looknfeel_backup="$looknfeel_config.bak.rgb-bubble.$(date +%Y%m%d%H%M%S)"
    cp -p -- "$looknfeel_config" "$looknfeel_backup"
    python3 - "$looknfeel_config" <<'PY'
import pathlib, re, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text()
pattern = re.compile(
    r"-- RGB Bubble: rounded glass surfaces.*?\n"
    r"hl\.config\(\{\s*decoration = \{.*?\},\s*\}\)\s*\n*"
    r"(?:-- Blur Omarchy's translucent Quickshell surfaces.*?\n"
    r"hl\.layer_rule\(\{.*?\}\)\s*\n*)?",
    re.DOTALL,
)
replacement = """-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })
"""
updated = pattern.sub(replacement, text)
if updated != text:
    path.write_text(updated)
PY
    echo "Migrated legacy unscoped RGB Bubble block out of $looknfeel_config (backup: $looknfeel_backup)"
  fi

  echo "Installed theme-isolated Hyprland frosted-glass window opacity, blur, and rounding ($module_file)."
}

RGB_BUBBLE_SKIPPED_PLUGINS=()

record_skipped_plugin() {
  local source_id="$1" existing
  for existing in "${RGB_BUBBLE_SKIPPED_PLUGINS[@]}"; do
    [[ $existing == "$source_id" ]] && return 0
  done
  RGB_BUBBLE_SKIPPED_PLUGINS+=("$source_id")
}

ensure_shell_clone() {
  local source_id="$1"
  local clone_id="$RGB_BUBBLE_USER.${source_id#omarchy.}"
  local clone_dir="$HOME/.config/omarchy/plugins/$clone_id"
  if [[ ! -d $clone_dir ]]; then
    command -v omarchy-plugin-clone >/dev/null || {
      echo "omarchy-plugin-clone is required to customize $source_id without editing Omarchy's packaged files." >&2
      record_skipped_plugin "$source_id"
      return 1
    }
    if ! omarchy-plugin-clone "$source_id"; then
      echo "Could not clone $source_id right now; rerun the installer from an active Omarchy shell to include this panel treatment." >&2
      record_skipped_plugin "$source_id"
      return 1
    fi
  fi
}

patch_qml_theme_scoped() {
  local qml_file="$1" stock_snippet="$2" legacy_unscoped="$3" scoped_replacement="$4"
  local backup

  [[ -f $qml_file ]] || {
    echo "Expected user-owned plugin clone file was not found: $qml_file" >&2
    return 1
  }

  if grep -Fq "$scoped_replacement" "$qml_file"; then
    return 0
  fi

  if ! grep -Fq "$stock_snippet" "$qml_file" && ! grep -Fq "$legacy_unscoped" "$qml_file"; then
    echo "Unsupported QML version in $qml_file; refusing to patch an unknown structure." >&2
    return 1
  fi

  backup="$qml_file.rgb-bubble.bak.$(date +%Y%m%d%H%M%S)"
  cp -p -- "$qml_file" "$backup"
  python3 - "$qml_file" "$stock_snippet" "$legacy_unscoped" "$scoped_replacement" <<'PY'
import pathlib, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text()
stock, legacy, scoped = sys.argv[2], sys.argv[3], sys.argv[4]
if stock in text:
    updated = text.replace(stock, scoped)
elif legacy in text:
    updated = text.replace(legacy, scoped)
else:
    raise SystemExit(f"Expected target snippet not found in {path}")
path.write_text(updated)
PY
  echo "Updated theme-isolated QML override in $qml_file; backup: $backup"
}

install_bar_watermark() {
  local clone_id="$RGB_BUBBLE_USER.bar"
  local clone_dir="$HOME/.config/omarchy/plugins/$clone_id"
  local qml_file="$clone_dir/Bar.qml" original replacement backup
  local component_source="$RGB_BUBBLE_SOURCE/panel-qml/BubbleWatermark.qml"
  local component_dest="$clone_dir/BubbleWatermark.qml"
  if ! ensure_shell_clone omarchy.bar; then return 0; fi
  [[ -f $qml_file ]] || { echo "Top bar clone is missing: $qml_file" >&2; return 1; }
  if [[ -f $component_dest ]] && ! cmp -s "$component_source" "$component_dest"; then
    backup="$component_dest.rgb-bubble.bak.$(date +%Y%m%d%H%M%S)"
    cp -p -- "$component_dest" "$backup"
  fi
  cp -f -- "$component_source" "$component_dest"
  rm -f -- "$clone_dir/bubble-watermark.png"
  grep -Fq 'BubbleWatermark { anchors.fill: parent }' "$qml_file" && return 0
  original=$'    color: root.transparent ? "transparent" : root.background\n    surfaceFormat.opaque: false'
  replacement=$'    color: root.transparent ? "transparent" : root.background\n    BubbleWatermark { anchors.fill: parent }\n    surfaceFormat.opaque: false'
  grep -Fq "$original" "$qml_file" || { echo "Unsupported top bar QML; watermark not inserted." >&2; return 1; }
  backup="$qml_file.rgb-bubble.bak.$(date +%Y%m%d%H%M%S)"
  cp -p -- "$qml_file" "$backup"
  python3 - "$qml_file" "$original" "$replacement" <<'PYTHON'
import pathlib, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text()
old, new = sys.argv[2], sys.argv[3]
if text.count(old) != 1:
    raise SystemExit(f"Expected one top bar insertion point in {path}; no change made")
path.write_text(text.replace(old, new, 1))
PYTHON
  echo "Added the RGB Bubble watermark to the top bar; backup: $backup"
}

remove_other_panel_watermarks() {
  local plugin_root="$HOME/.config/omarchy/plugins"
  [[ -d $plugin_root ]] || return 0
  python3 - "$plugin_root" "$RGB_BUBBLE_USER.bar" <<'PYTHON'
import pathlib, re, shutil, sys, time
root = pathlib.Path(sys.argv[1])
bar_name = sys.argv[2]
for plugin in root.iterdir():
    if not plugin.is_dir() or plugin.name == bar_name:
        continue
    for qml in plugin.rglob("*.qml"):
        text = qml.read_text(errors="replace")
        updated = re.sub(r"(?m)^\s*BubbleWatermark\s*\{[^}]*\}\s*\n?", "", text)
        if updated != text:
            backup = qml.with_name(qml.name + ".rgb-bubble.bak." + time.strftime("%Y%m%d%H%M%S"))
            shutil.copy2(qml, backup)
            qml.write_text(updated)
            print(f"Removed watermark from {qml}; backup: {backup}")
    for relative in ("BubbleWatermark.qml", "bubble-watermark.png", "components/BubbleWatermark.qml", "components/bubble-watermark.png"):
        asset = plugin / relative
        if asset.is_file():
            asset.unlink()
PYTHON
}

install_panels_tweak() {
  [[ -f $RGB_BUBBLE_SOURCE/panel-qml/BubbleWatermark.qml ]] || { echo "Top-bar watermark QML is missing from the source." >&2; exit 1; }
  if ensure_shell_clone omarchy.osd; then
    patch_qml_theme_scoped \
      "$HOME/.config/omarchy/plugins/$RGB_BUBBLE_USER.osd/Osd.qml" \
      'color: Util.alpha(Commons.Color.background, 0.97)' \
      'color: Commons.Color.popups.background' \
      'color: Commons.Color.shellValues["rgb-bubble.watermark"] === "true" ? Commons.Color.popups.background : Util.alpha(Commons.Color.background, 0.97)'
  fi

  if ensure_shell_clone omarchy.bar; then
    patch_qml_theme_scoped \
      "$HOME/.config/omarchy/plugins/$RGB_BUBBLE_USER.bar/Bar.qml" \
      'borderSpec: Border.flat(root.barForeground, 1)' \
      'borderSpec: Border.none()' \
      'borderSpec: Commons.Color.shellValues["rgb-bubble.watermark"] === "true" ? Border.none() : Border.flat(root.barForeground, 1)'
  fi

  if [[ -f $HOME/.config/omarchy/plugins/$RGB_BUBBLE_USER.tailscale/Panel.qml ]]; then
    patch_qml_theme_scoped \
      "$HOME/.config/omarchy/plugins/$RGB_BUBBLE_USER.tailscale/Panel.qml" \
      'color: Commons.Color.background' \
      'color: Commons.Color.popups.background' \
      'color: Commons.Color.shellValues["rgb-bubble.watermark"] === "true" ? Commons.Color.popups.background : Commons.Color.background'
  fi

  install_bar_watermark
  remove_other_panel_watermarks

  local shell_config="$HOME/.config/omarchy/shell.json"
  if [[ -f $shell_config ]]; then
    python3 - "$shell_config" "$RGB_BUBBLE_USER" <<'PY'
import json
import pathlib
import shutil
import sys
import time

path = pathlib.Path(sys.argv[1])
username = sys.argv[2]
data = json.loads(path.read_text())
layout = data.get("bar", {}).get("layout", {})
menu_clone = f"{username}.menu"
restored = []

for section, entries in layout.items():
    if not isinstance(entries, list):
        continue
    kept = []
    for entry in entries:
        if isinstance(entry, dict) and entry.get("id") == menu_clone:
            entry = dict(entry)
            entry["id"] = "omarchy.menu"
            kept.append(entry)
            restored.append(f"{menu_clone} -> omarchy.menu")
        else:
            kept.append(entry)
    layout[section] = kept

if isinstance(data.get("plugins"), list):
    kept = [
        entry for entry in data["plugins"]
        if not (isinstance(entry, dict) and entry.get("id") == menu_clone)
    ]
    if len(kept) != len(data["plugins"]):
        restored.append(f"removed plugin instance {menu_clone}")
    data["plugins"] = kept

for key, value in (("disabledPlugins", "omarchy.menu"),
                   ("cloneSourceRestores", menu_clone)):
    entries = data.get(key)
    if isinstance(entries, list) and value in entries:
        data[key] = [entry for entry in entries if entry != value]
        if not data[key]:
            del data[key]
        restored.append(f"cleared {key} entry {value}")

if restored:
    backup = path.with_name(f"{path.name}.bak.rgb-bubble-{time.strftime('%Y%m%d%H%M%S')}")
    shutil.copy2(path, backup)
    path.write_text(json.dumps(data, indent=2) + "\n")
    print(f"Restored the stock Omarchy menu in {path}; backup: {backup}")
PY
  fi

  echo "Installed theme-isolated top-bar vector bubble watermark and translucent OSD override."
}

case "$RGB_BUBBLE_MODE" in
  cbubbles)
    install_cbubbles_tweak
    exit 0
    ;;
  vim)
    install_vim_tweak
    exit 0
    ;;
  hyprland)
    install_hyprland_tweak
    reload_desktop_session
    exit 0
    ;;
  panels)
    install_panels_tweak
    reload_desktop_session
    exit 0
    ;;
  tweaks)
    install_panels_tweak
    install_vim_tweak
    install_cbubbles_tweak
    install_hyprland_tweak
    reload_desktop_session
    echo "Installed all RGB Bubble extra tweaks (Hyprland frosted glass, top-bar watermark, Vim colorscheme, and cbubbles)."
    exit 0
    ;;
esac

[[ -f $RGB_BUBBLE_SOURCE/colors.toml ]] || { echo "Dark theme files are missing from the source." >&2; exit 1; }
[[ -f $RGB_BUBBLE_SOURCE/hyprland/rgb-bubble.lua ]] || { echo "Hyprland appearance module is missing from the source." >&2; exit 1; }

for RGB_BUBBLE_REQUIRED_FILE in \
  backgrounds/01-bubble-omarchy.webp \
  backgrounds/02-bubble-float.webp \
  backgrounds/03-bubble-omarchy-pixel.webp \
  bin/cbubbles \
  panel-qml/BubbleWatermark.qml \
  vim/colors/rgb-bubble.vim; do
  [[ -f $RGB_BUBBLE_SOURCE/$RGB_BUBBLE_REQUIRED_FILE ]] || {
    echo "Required RGB Bubble file is missing: $RGB_BUBBLE_REQUIRED_FILE" >&2
    exit 1
  }
done

command -v omarchy-theme-set >/dev/null || { echo "Run this installer from Omarchy." >&2; exit 1; }

install_theme_files() {
  local source_dir="$1" destination="$2" entry name
  mkdir -p "$destination"
  if [[ $(realpath -m "$source_dir") == $(realpath -m "$destination") ]]; then
    return 0
  fi
  for entry in "$source_dir"/*; do
    [[ -e $entry ]] || continue
    name=${entry##*/}
    case "$name" in
      .git|.gitignore|variants|app-themes|packaging|pyproject.toml|AI_AGENT_HANDOFF.md|OMARCHY_SITE_PR_GUIDE.md|RGB-Bubble-project-export.zip)
        continue
        ;;
    esac
    cp -a -- "$entry" "$destination/"
  done
}

install_theme_files "$RGB_BUBBLE_SOURCE" "$HOME/.config/omarchy/themes/rgb-bubble"

remove_obsolete_backgrounds() {
  local theme_dir="$1" file_name path
  for file_name in \
    1-teretube-ink-flow.png \
    2-teretube-ink-strata.png \
    3-teretube-ivory-strata.png \
    4-teretube-ivory-waves.png \
    5-teretube-geometric.png \
    01-bubble-float.webp \
    02-bubble-omarchy.webp \
    01-bubble-drift.webp \
    01-bubble-float.png \
    02-bubble-omarchy.png \
    01-bubble-drift.png; do
    path="$theme_dir/backgrounds/$file_name"
    if [[ -f $path ]]; then
      rm -- "$path"
      echo "Removed obsolete wallpaper $path"
    fi
  done
}
remove_obsolete_backgrounds "$HOME/.config/omarchy/themes/rgb-bubble"

remove_legacy_split_overrides() {
  local theme_dir="$1" override backup
  shopt -s nullglob
  for override in "$theme_dir"/shell.*.toml; do
    backup="$override.bak.$(date +%Y%m%d%H%M%S)"
    cp -p -- "$override" "$backup"
    rm -- "$override"
    echo "Moved obsolete split override to $backup"
  done
  shopt -u nullglob
}
remove_legacy_split_overrides "$HOME/.config/omarchy/themes/rgb-bubble"

install_panels_tweak
install_vim_tweak
install_cbubbles_tweak
install_hyprland_tweak

if ! omarchy-theme-set "$RGB_BUBBLE_THEME"; then
  echo "Files are installed, but Omarchy could not activate $RGB_BUBBLE_THEME. Run omarchy-theme-set $RGB_BUBBLE_THEME in your desktop session." >&2
  exit 1
fi

if ((${#RGB_BUBBLE_SKIPPED_PLUGINS[@]} > 0)); then
  printf 'Theme is active, but these panel customizations were skipped: %s\n' "${RGB_BUBBLE_SKIPPED_PLUGINS[*]}" >&2
  echo "Start the Omarchy shell, then rerun this installer to complete the panels." >&2
  exit 1
fi

echo "Installed RGB Bubble dark theme, app palettes, translucent system panels, and theme-isolated Hyprland settings."
echo "Panel opacity: 14% surface opacity via shell.toml across Omarchy bar, menus, notifications, calendar/clock, audio, Bluetooth, display, Wi-Fi/network, battery/power, agent usage, weather, clipboard, emoji picker, and reminders; 40% for polkit prompts; cloned overrides for bar and OSD."
echo "Bubble watermark: top bar only, and strictly isolated to RGB Bubble."
echo "App window opacity (90% focused / 95% unfocused — 10% / 5% transparency): terminals, editors, notes, file managers, and system utilities when RGB Bubble is active (browsers, web apps, media/video players, image/PDF viewers, Office apps, PiP, and fullscreen windows remain 100% opaque)."
echo "Backdrop blur: size 8 with 2 passes, ignore_opacity enabled, and 0.28 vibrancy (active only in RGB Bubble)."
echo "Color themes & transparent window apps: Alacritty, Foot, Ghostty, Kitty, Vim, Neovim, Helix, VS Code, btop, Chromium, Obsidian, Hermes, Pi, and T3 Code."
echo "Terminal bubble animation command: run 'cbubbles' (or 'cbubbles -l' for the interactive Omarchy pixel logo, 'cbubbles --help' for all flags)."

reload_desktop_session

echo "Selected $RGB_BUBBLE_THEME."
