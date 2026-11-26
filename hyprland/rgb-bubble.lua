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

local GTK_MARKER_BEGIN = "/* BEGIN RGB BUBBLE GLASS */"
local GTK_MARKER_END = "/* END RGB BUBBLE GLASS */"

local GTK4_GLASS_BLOCK = table.concat({
  GTK_MARKER_BEGIN,
  "@define-color window_bg_color rgba(10, 16, 27, 0.78);",
  "@define-color window_fg_color #E6F0FF;",
  "@define-color view_bg_color rgba(10, 16, 27, 0.72);",
  "@define-color view_fg_color #E6F0FF;",
  "@define-color headerbar_bg_color rgba(16, 25, 41, 0.82);",
  "@define-color headerbar_fg_color #E6F0FF;",
  "@define-color headerbar_backdrop_color rgba(10, 16, 27, 0.82);",
  "@define-color sidebar_bg_color rgba(16, 25, 41, 0.78);",
  "@define-color sidebar_fg_color #E6F0FF;",
  "@define-color sidebar_backdrop_color rgba(10, 16, 27, 0.80);",
  "@define-color secondary_sidebar_bg_color rgba(16, 25, 41, 0.78);",
  "@define-color secondary_sidebar_fg_color #E6F0FF;",
  "@define-color secondary_sidebar_backdrop_color rgba(10, 16, 27, 0.80);",
  "@define-color card_bg_color rgba(25, 38, 60, 0.65);",
  "@define-color card_fg_color #E6F0FF;",
  "@define-color dialog_bg_color rgba(10, 16, 27, 0.84);",
  "@define-color dialog_fg_color #E6F0FF;",
  "@define-color popover_bg_color rgba(16, 25, 41, 0.92);",
  "@define-color popover_fg_color #E6F0FF;",
  "window, window.background, .nautilus-window {",
  "  background-color: rgba(10, 16, 27, 0.78);",
  "}",
  GTK_MARKER_END,
}, "\n")

local GTK3_GLASS_BLOCK = table.concat({
  GTK_MARKER_BEGIN,
  "window.filechooser decoration,",
  "window.filechooser decoration:backdrop,",
  "dialog.filechooser decoration,",
  "dialog.filechooser decoration:backdrop {",
  "  box-shadow: none;",
  "  margin: 0px;",
  "}",
  "window.filechooser,",
  "dialog.filechooser,",
  "dialog.filechooser .dialog-vbox,",
  "filechooser,",
  "filechooser stack,",
  "filechooser paned,",
  "filechooser scrolledwindow,",
  "filechooser .view,",
  "filechooser treeview.view,",
  "filechooser placessidebar,",
  "filechooser placessidebar list {",
  "  background-color: rgba(10, 16, 27, 0.76);",
  "  background-image: none;",
  "}",
  "window.filechooser headerbar,",
  "window.filechooser .titlebar,",
  "dialog.filechooser headerbar,",
  "dialog.filechooser .titlebar {",
  "  background-color: rgba(16, 25, 41, 0.84);",
  "  background-image: none;",
  "}",
  GTK_MARKER_END,
}, "\n")

local function strip_gtk_block(text)
  local pattern = "%s*/%* BEGIN RGB BUBBLE GLASS %*/.-/%* END RGB BUBBLE GLASS %*/%s*"
  return (text:gsub(pattern, "\n")):gsub("^%s+", ""):gsub("%s+$", "")
end

local function sync_gtk_css_file(path, block, enable)
  local existing = ""
  local in_file = io.open(path, "r")
  if in_file then
    existing = in_file:read("*a") or ""
    in_file:close()
  end

  local base = strip_gtk_block(existing)
  local desired = base
  if enable then
    if desired ~= "" then
      desired = desired .. "\n\n" .. block .. "\n"
    else
      desired = block .. "\n"
    end
  elseif desired ~= "" then
    desired = desired .. "\n"
  end

  if desired == existing then
    return false
  end

  local out_file = io.open(path, "w")
  if out_file then
    out_file:write(desired)
    out_file:close()
    return true
  end
  return false
end

local function sync_gtk_glass(enable)
  local home = os.getenv("HOME")
  if not home or home == "" then
    return
  end

  local gtk3_changed = sync_gtk_css_file(home .. "/.config/gtk-3.0/gtk.css", GTK3_GLASS_BLOCK, enable)
  local gtk4_changed = sync_gtk_css_file(home .. "/.config/gtk-4.0/gtk.css", GTK4_GLASS_BLOCK, enable)

  if gtk3_changed or gtk4_changed then
    if enable then
      os.execute("(systemctl --user set-environment GDK_WAYLAND_DISABLE=ext_background_effect_manager_v1; dbus-update-activation-environment --systemd GDK_WAYLAND_DISABLE; systemctl --user try-restart xdg-desktop-portal-gtk.service; hyprctl clients -j | grep -q '\"org.gnome.Nautilus\"' || nautilus -q) >/dev/null 2>&1 &")
    else
      os.execute("(systemctl --user unset-environment GDK_WAYLAND_DISABLE; dbus-update-activation-environment --systemd GDK_WAYLAND_DISABLE=; systemctl --user try-restart xdg-desktop-portal-gtk.service; hyprctl clients -j | grep -q '\"org.gnome.Nautilus\"' || nautilus -q) >/dev/null 2>&1 &")
    end
  end
end

if not is_rgb_bubble_theme() then
  hl.env("GDK_WAYLAND_DISABLE", "")
  sync_gtk_glass(false)
  return
end

-- Prevent GTK4 from binding ext_background_effect_manager_v1 with an empty blur
-- region (which otherwise instructs Hyprland to disable compositor blur on GTK4
-- windows such as org.gnome.Nautilus).
hl.env("GDK_WAYLAND_DISABLE", "ext_background_effect_manager_v1")
sync_gtk_glass(true)

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
      range = 4,
      render_power = 1,
      color = "rgba(00000020)",
      offset = { 0, 1 },
    },

    blur = {
      enabled = true,
      size = 10,
      passes = 4,
      ignore_opacity = true,
      new_optimizations = true,
      popups = true,
      popups_ignorealpha = 0.08,
      noise = 0.005,
      contrast = 0.95,
      brightness = 0.92,
      vibrancy = 0.28,
      special = false,
    },
  },
})

hl.layer_rule({
  match = {
    namespace = "^omarchy-(menu|launcher)$",
  },
  blur = true,
  blur_popups = true,
  ignore_alpha = 0.52,
})

hl.layer_rule({
  match = {
    namespace = "^omarchy-(bar|image-selector|emojis|clipboard|keyboard-panel|osd|notifications|polkit|lock-preview|reminders|network-qr|network-speedtest|disk-speedtest|speed-test)$",
  },
  blur = true,
  blur_popups = true,
  ignore_alpha = 0.10,
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
