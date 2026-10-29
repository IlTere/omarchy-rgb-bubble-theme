-- RGB Bubble's optional compositor finish. Installed by install.sh into
-- ~/.config/hypr/rgb-bubble.lua because Omarchy intentionally excludes
-- theme-supplied Lua when a repository is staged as a theme.
--
-- Strictly isolated to RGB Bubble editions: when switching to any other
-- Omarchy theme (which triggers `hyprctl reload`), this module exits early
-- so stock Omarchy look-and-feel and window opacity remain untouched.

local function is_rgb_bubble_theme()
  local home = os.getenv("HOME")
  if not home or home == "" then
    return false
  end

  local name_file = io.open(home .. "/.local/state/omarchy/current/theme.name", "r")
  if name_file then
    local theme_name = (name_file:read("*a") or ""):gsub("%s+", "")
    name_file:close()
    if theme_name == "rgb-bubble" then
      return true
    end
  end

  local shell_file = io.open(home .. "/.local/state/omarchy/current/theme/shell.toml", "r")
  if shell_file then
    local content = shell_file:read("*a") or ""
    shell_file:close()
    if content:match("%[rgb%-bubble%]") and content:match('watermark%s*=%s*"true"') then
      return true
    end
  end

  return false
end

if not is_rgb_bubble_theme() then
  return
end

-- Focused: 90% opacity (10% transparency).
-- Unfocused: 95% opacity (5% transparency).
local FOCUSED_OPACITY = "0.90"
local UNFOCUSED_OPACITY = "0.95"

hl.config({
  decoration = {
    rounding = 22,
    rounding_power = 3.0,

    dim_inactive = true,
    dim_strength = 0.08,

    shadow = {
      enabled = true,
      range = 24,
      render_power = 3,
      color = "rgba(03071190)",
      offset = { 0, 8 },
    },

    blur = {
      enabled = true,
      size = 8,
      passes = 2,
      ignore_opacity = true,
      new_optimizations = true,
      popups = true,
      popups_ignorealpha = 0.08,
      noise = 0.006,
      contrast = 0.95,
      brightness = 0.92,
      vibrancy = 0.28,
      special = false,
    },
  },
})

hl.layer_rule({
  match = {
    namespace = "^omarchy-(bar|menu|image-selector|emojis|clipboard|keyboard-panel|osd|notifications|polkit|lock-preview|reminders|network-qr|network-speedtest|disk-speedtest|speed-test)$",
  },
  blur = true,
  blur_popups = true,
  ignore_alpha = 0.12,
})

-- Apply the translucent glass treatment to non-fullscreen app windows by default
-- (Terminals, Editors, Notes, File Managers, and System Utilities).
hl.window_rule({
  match = {
    class = ".*",
    fullscreen = false,
  },
  opacity = FOCUSED_OPACITY .. " override " .. UNFOCUSED_OPACITY .. " override",
})

-- Exclude Category 1 (Video, Media, Streaming & Gaming),
-- Category 2 (Image Viewers, Drawing, PDF & Office Documents),
-- and Category 3 (Browsers & Web Apps) so they remain 100% opaque.
local OPAQUE_APP_CLASSES = table.concat({
  -- Category 1: Video, Media, Streaming & Gaming
  "mpv",
  "vlc",
  "org\\.kde\\.kdenlive",
  "com\\.obsproject\\.Studio",
  "omacut",
  ".*[Rr]esolve.*",
  "WebcamOverlay-.*",
  "qv4l2",
  "qvidcap",
  "com\\.moonlight_stream\\.Moonlight",
  "steam.*",
  "com\\.libretro\\.RetroArch",
  "GeForceNOW",
  "qemu",
  "zoom",
  -- Category 2: Image Viewers, Drawing, PDF & Office
  "imv",
  "org\\.gnome\\.NautilusPreviewer",
  "Pinta",
  "com\\.github\\.PintaProject\\.Pinta",
  "com\\.github\\.xournalpp\\.xournalpp",
  "xournalpp",
  "org\\.gnome\\.Evince.*",
  "evince",
  "org\\.gnome\\.Papers.*",
  "papers",
  "libreoffice-.*",
  "soffice.*",
  -- Category 3: Browsers & Web Apps
  "(google-)?[cC]hrom(e|ium).*",
  "[bB]rave-browser",
  "[mM]icrosoft-edge",
  "Vivaldi-stable",
  "helium",
  "chrome-.*",
  "[fF]irefox.*",
  "zen",
  "librewolf",
  "org\\.qutebrowser\\.qutebrowser",
  "qutebrowser",
  "[dD]iscord",
  "vesktop",
  "[wW]hatsapp.*",
}, "|")

hl.window_rule({
  match = {
    class = "^(" .. OPAQUE_APP_CLASSES .. ")$",
  },
  opacity = "1.0 override 1.0 override",
})

for _, tag_name in ipairs({ "pip", "chromium-based-browser", "firefox-based-browser" }) do
  hl.window_rule({
    match = {
      tag = tag_name,
    },
    opacity = "1.0 override 1.0 override",
  })
end
