local programs = require("lua.hyprland.programs")
require("lua.utils")
require("lua.log")

hl.config({
  binds = {
    movefocus_cycles_groupfirst = true
  }
})

---@param mods string|string[]|nil # Mod keys - both have to be pressed
---@param keys string|string[] # Actual keys - either of them has to be pressed
---@param dispatcher function|HL.Dispatcher
---@param opts? HL.BindOptions
local function bind(mods, keys, dispatcher, opts)
  local mods_string
  if type(mods) == "table" then mods_string = table.concat(mods, " + ") else mods_string = mods end

  local keys_table
  if type(keys) == "string" then keys_table = { keys } else keys_table = keys end


  for _, key in ipairs(keys_table) do
    local parts = {}
    if mods_string ~= nil then table.insert(parts, mods_string) end
    table.insert(parts, key)

    local full_key_string = table.concat(parts, " + ")

    Log("Binding " .. full_key_string)

    hl.bind(full_key_string, dispatcher, opts)
  end
end

---------------------
---- KEYBINDINGS ----
---------------------

------------------------
---- System control ----
------------------------

local win = "SUPER"
local win_alt = "SUPER + ALT"
local win_shift = "SUPER + SHIFT"

bind(win_shift, "R", exec("hyprctl reload"))

-- Focus movement
bind(win, { "Left", "H" }, hl.dsp.focus({ direction = "l" }))
bind(win, { "Right", "L" }, hl.dsp.focus({ direction = "r" }))
bind(win, { "Up", "J" }, hl.dsp.focus({ direction = "d" }))
bind(win, { "Down", "K" }, hl.dsp.focus({ direction = "u" }))

-- Move window
bind(win_shift, { "Left", "H" }, hl.dsp.window.move({ direction = "l" }))
bind(win_shift, { "Right", "L" }, hl.dsp.window.move({ direction = "r" }))
bind(win_shift, { "Up", "J" }, hl.dsp.window.move({ direction = "d" }))
bind(win_shift, { "Down", "K" }, hl.dsp.window.move({ direction = "u" }))

-- Move current workspace to a monitor
bind(win_alt, { "Left", "H" }, hl.dsp.workspace.move({ monitor = "l" }))
bind(win_alt, { "Right", "L" }, hl.dsp.workspace.move({ monitor = "r" }))
bind(win_alt, { "Up", "J" }, hl.dsp.workspace.move({ monitor = "d" }))
bind(win_alt, { "Down", "K" }, hl.dsp.workspace.move({ monitor = "u" }))

-- Window management
bind(win, "F", hl.dsp.window.fullscreen())
bind(win, "W", hl.dsp.group.toggle())
bind(win, "V", hl.dsp.layout("togglesplit"))

bind(win, "Space", function()
  local window = hl.get_active_window()
  if window ~= nil and window.floating then
    hl.dispatch(hl.dsp.focus({ window = "tiled" }))
  else
    hl.dispatch(hl.dsp.focus({ window = "floating" }))
  end
end)
bind(win_shift, "Space", hl.dsp.window.float({ action = "toggle" }))

bind(win, "C", hl.dsp.window.close())
bind(win_shift, "C", exec("toggle-suspend hyprland"))

-- Workspace switching
for i = 1, 10 do
  local key = tostring(i % 10)
  bind(win, key, hl.dsp.focus({ workspace = i }))
  bind(win_shift, key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
bind(win, "S", hl.dsp.workspace.toggle_special("magic"))
bind(win_shift, "S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move/resize windows with Alt + LMB/RMB and dragging
bind("ALT", "mouse:272", hl.dsp.window.drag(), { mouse = true })
bind("ALT", "mouse:273", hl.dsp.window.resize(), { mouse = true })

local volume_opts = { locked = true, repeating = true }
bind(nil, "XF86AudioRaiseVolume", exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), volume_opts)
bind(nil, "XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), volume_opts)
bind(nil, "XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), volume_opts)
bind(nil, "XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), volume_opts)
bind(nil, "XF86MonBrightnessUp", exec("brightnessctl -e4 -n2 set 5%+"), volume_opts)
bind(nil, "XF86MonBrightnessDown", exec("brightnessctl -e4 -n2 set 5%-"), volume_opts)

-- Media keys
bind(nil, "XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
bind(nil, "XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind(nil, "XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind(nil, "XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------
---- Apps ----
--------------

bind(win, "Return", exec_app(programs.terminal))
bind(win_shift, "Return", exec_app(programs.terminal, { float = true }))
bind(win, "D", exec_app(programs.menu))
bind(win, "N", exec_app(programs.notification_center))

-- Screenshots
bind(nil, "Print", exec_app("way-screenshot --current-screen"))
bind("SHIFT", "Print", exec_app("way-screenshot --region"))
bind("CTRL", "Print", exec_app("way-screenshot --full"))
bind({ "SHIFT", "CTRL" }, "Print", exec_app("way-screenshot --current-window"))


-- ┌────────────────────────────────────────────────────┐
-- │                    SUBMAP: Apps                    │
-- └────────────────────────────────────────────────────┘

local submap_app_launcher = "App Launcher"
bind(win, "A", hl.dsp.submap(submap_app_launcher))
hl.define_submap(submap_app_launcher, "reset", function()
  ---@param key string
  ---@param program string
  ---@param floating? boolean
  local function app(key, program, floating)
    local float = floating ~= nil and floating or false
    bind(nil, key, exec_app(program, { float = float }))
  end

  app("C", programs.browser)
  app("E", programs.file_manager)
  app("H", programs.sysmon, true)
  app("B", programs.bluetooth_config, true)
  app("X", programs.calculator, true)
  app("V", programs.volume_control, true)
  app("T", programs.telegram)
  app("D", programs.discord)
  app("S", programs.service_manager, true)

  hl.bind("catchall", hl.dsp.submap("reset"))
end)


-- ┌───────────────────────────────────────────────┐
-- │                  SUBMAP: Links                │
-- └───────────────────────────────────────────────┘
local submap_link_opener = "Link Opener"
bind(win_shift, "A", hl.dsp.submap(submap_link_opener))
hl.define_submap(submap_link_opener, "reset", function()
  ---@param key string
  ---@param url string
  local function link(key, url)
    bind(nil, key, exec_app("xdg-open " .. url))
  end

  link("A", "https://anilist.co/home")
  link("B", "https://bing.com/")
  link("D", "https://drive.google.com/")
  link("G", "https://mail.google.com/")
  link("P", "https://photos.google.com/")
  link("M", "https://maps.google.com/")
  link("S", "https://steamcommunity.com/my/profile")
  link("Y", "https://youtube.com")

  hl.bind("catchall", hl.dsp.submap("reset"))
end)


-- ┌────────────────────────────────────────────────────────────┐
-- │                   SUBMAP: System Control                   │
-- └────────────────────────────────────────────────────────────┘
local submap_syscontrol = "System Control"
bind(win, "X", hl.dsp.submap(submap_syscontrol))
hl.define_submap(submap_syscontrol, "reset", function()
  ---@param key string
  ---@param cmd string
  local function sys(key, cmd)
    bind(nil, key, exec("syscontrol " .. cmd), { locked = true, release = true })
  end

  sys("S", "shutdown")
  sys("R", "reboot")
  sys("I", "logout")
  sys("D", "suspend")
  sys("L", "lock")

  hl.bind("catchall", hl.dsp.submap("reset"))
end)


-- ┌────────────────────────────────────────────┐
-- │              SUBMAP: passthrough           │
-- └────────────────────────────────────────────┘
local submap_passthrough = "Passthrough"
bind(win, "Escape", hl.dsp.submap(submap_passthrough))
hl.define_submap(submap_passthrough, function()
  bind(win, "Escape", hl.dsp.submap("reset"))
end)

-- Pass CTRL+F2 through to Discord
-- bindn (non-consuming) → { non_consuming = true }
-- TODO: verify hl.dsp.window.pass is the correct Lua dispatcher name for `pass`
-- hl.bind("CTRL + F2", hl.dsp.window.pass({ window = "class:discord" }), { non_consuming = true })
