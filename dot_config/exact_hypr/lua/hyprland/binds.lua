local api = require("lua.hyprland.api")
local bind = require("lua.hyprland.binds.bind")
local dsp = require("lua.hyprland.api.dsp")
local links = require("lua.hyprland.binds.links")
local monitor = require("lua.hyprland.api.monitor")
local monitors = require("lua.hyprland.monitors")
local programs = require("lua.hyprland.programs")
local submap = require("lua.hyprland.binds.submap")

local Option = require("lua.lib.option")
local opt = Option.some
---@diagnostic disable-next-line: unused-local
local utils = require("lua.utils")
---@diagnostic disable-next-line: unused-local
local log = require("lua.log")

hl.config({
  binds = {
    movefocus_cycles_groupfirst = true,
  },

  group = {
    group_on_movetoworkspace = true,
  }
})

------------------------
---- System control ----
------------------------

local win = "SUPER"
local win_alt = "SUPER + ALT"
local win_shift = "SUPER + SHIFT"

bind(win_shift, "R", dsp.exec("hyprctl reload"))

bind(win, { "Left", "H" }, dsp.focus.left())
bind(win, { "Right", "L" }, dsp.focus.right())
bind(win, { "Up", "J" }, dsp.focus.up())
bind(win, { "Down", "K" }, dsp.focus.down())

-- Move window
bind(win_shift, { "Left", "H" }, dsp.window.move_left())
bind(win_shift, { "Right", "L" }, dsp.window.move_right())
bind(win_shift, { "Up", "J" }, dsp.window.move_up())
bind(win_shift, { "Down", "K" }, dsp.window.move_down())

-- Move current workspace to a monitor
bind(win_alt, { "Left", "H" }, dsp.workspace.move_left())
bind(win_alt, { "Right", "L" }, dsp.workspace.move_right())
bind(win_alt, { "Up", "J" }, dsp.workspace.move_up())
bind(win_alt, { "Down", "K" }, dsp.workspace.move_down())

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
bind(win_shift, "C", dsp.exec("toggle-suspend hyprland"))

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
bind(nil, "XF86AudioRaiseVolume", dsp.exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), volume_opts)
bind(nil, "XF86AudioLowerVolume", dsp.exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), volume_opts)
bind(nil, "XF86AudioMute", dsp.exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), volume_opts)
bind(nil, "XF86AudioMicMute", dsp.exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), volume_opts)
bind(nil, "XF86MonBrightnessUp", dsp.exec("brightnessctl -e4 -n2 set 5%+"), volume_opts)
bind(nil, "XF86MonBrightnessDown", dsp.exec("brightnessctl -e4 -n2 set 5%-"), volume_opts)

-- Media keys
bind(nil, "XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
bind(nil, "XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind(nil, "XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind(nil, "XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Toggle main monitor scale
bind(win, "M", function()
  local main = hl.get_monitor(monitors.main_monitor.names[1]) or hl.get_monitor(monitors.main_monitor.names[2])
  if main == nil then return end

  local is_scaled    = main.scale > 1.1
  local new_scale    = is_scaled and 1.0 or monitors.main_monitor.scale
  local new_position = is_scaled and monitors.second_monitor.position.main_monitor_native
      or monitors.second_monitor.position.main_monitor_scaled

  monitor(main.name):config({ scale = new_scale })

  local second = hl.get_monitor(monitors.second_monitor.names[1]) or hl.get_monitor(monitors.second_monitor.names[2])
  if second ~= nil then
    monitor(second.name):config({ position = new_position })
  end
end)

--- Toggle TV mode
bind(win, "T", Monitors.tv.toggle, { locked = true })

--------------
---- Apps ----
--------------

bind(win, "Return", dsp.exec_app(programs.terminal.bin))
bind(win_shift, "Return", dsp.exec_app(programs.terminal.bin, { float = true }))
bind(win, "D", dsp.exec_app(programs.menu.bin))
bind(win, "N", dsp.exec_app(programs.notification_center.bin))
bind(win_shift, "N", dsp.exec_app(programs.notification_center_dismiss.bin))

-- Screenshots
bind(nil, "Print", dsp.exec_app("way-screenshot --current-screen"))
bind("SHIFT", "Print", dsp.exec_app("way-screenshot --region"))
bind("CTRL", "Print", dsp.exec_app("way-screenshot --full"))
bind({ "SHIFT", "CTRL" }, "Print", dsp.exec_app("way-screenshot --current-window"))

-- ┌──────────────────────────────────────────────────────┐
-- │                    SUBMAP: Resize                    │
-- └──────────────────────────────────────────────────────┘

submap("Resize", { win, "R" }, { reset_to = "reset", reset_only_on_escape = true }, function()
  -- 7%
  local step = 0.07

  local function resize(dx, dy)
    local size = hl.get_active_window().size
    hl.dispatch(hl.dsp.window.resize({ x = size.x * dx, y = size.y * dy, relative = true }))
  end

  local opts = { repeating = true }

  ---@format disable
  bind(nil, { "Left", "H" },  function() resize(-step,  0)    end, opts)
  bind(nil, { "Right", "L" }, function() resize( step,  0)    end, opts)
  bind(nil, { "Up", "K" },    function() resize( 0,    -step) end, opts)
  bind(nil, { "Down", "J" },  function() resize( 0,     step) end, opts)
  ---@format enable
end)

-- ┌────────────────────────────────────────────────────┐
-- │                    SUBMAP: Apps                    │
-- └────────────────────────────────────────────────────┘

submap("App Launcher", { win, "A" }, { reset_to = "reset" }, function(add_help)
  ---@param program { bin: string, description: string }
  ---@param floating? boolean
  ---@param alt? boolean
  local function app(key, program, floating, alt)
    local mod = Option.then_some(alt, "SHIFT")
    bind(mod.inner, key, dsp.exec_app(program.bin, { float = opt(floating):unwrap_or(false) }))
    add_help(mod:map_or("", function(m) return m .. " + " end) .. key, program.description)
  end

  app("C", programs.browser)
  app("E", programs.file_manager)
  app("E", programs.file_manager_alt, nil, true)
  app("L", programs.lutris)
  app("H", programs.sysmon, true)
  app("B", programs.bluetooth_config, true)
  app("X", programs.calculator, true)
  app("V", programs.volume_control, true)
  app("T", programs.telegram)
  app("D", programs.discord)
  app("S", programs.service_manager, true)
end)

-- ┌───────────────────────────────────────────────┐
-- │                  SUBMAP: Links                │
-- └───────────────────────────────────────────────┘

submap("Link Opener", { win_shift, "A" }, { reset_to = "reset", catchall_reset = true }, function(add_help)
  local function link(key, website)
    bind(nil, key, function()
      api.exec_app("xdg-open " .. website.url)

      local event_listener
      event_listener = hl.on("window.urgent", function(window)
        hl.dispatch(hl.dsp.focus({ window = window }))
        event_listener:remove()
      end)
    end)

    add_help(key, website.description)
  end

  link("B", links.search)
  link("G", links.email)
  link("Y", links.youtube)
  link("P", links.photos)
  link("M", links.maps)
  link("A", links.anime)
  link("S", links.steam)
end)


-- ┌────────────────────────────────────────────────────────────┐
-- │                   SUBMAP: System Control                   │
-- └────────────────────────────────────────────────────────────┘

submap("System Control", { win, "X" }, { reset_to = "reset", catchall_reset = true }, function(add_help)
  local function sys(key, cmd)
    bind(nil, key, dsp.exec("syscontrol " .. cmd), { locked = true, release = true })
    add_help(key, cmd)
  end

  sys("S", "shutdown")
  sys("R", "reboot")
  sys("I", "logout")
  sys("D", "suspend")
  sys("L", "lock")
end)


-- ┌────────────────────────────────────────────┐
-- │              SUBMAP: passthrough           │
-- └────────────────────────────────────────────┘
local submap_passthrough = "Passthrough"
hl.define_submap(submap_passthrough, function()
  bind(win, "Escape", hl.dsp.no_op())
end)

bind(win, "Escape", function()
  if hl.get_current_submap() == submap_passthrough then
    hl.dispatch(hl.dsp.submap("reset"))
  else
    hl.dispatch(hl.dsp.submap(submap_passthrough))
  end
end, { submap_universal = true })

-------------------------------
---- Key combo passthrough ----
-------------------------------

-- Pass CTRL+F2 through to Discord (toggle mute)
hl.bind("CTRL + F2", hl.dsp.pass({ window = "class:discord" }), { non_consuming = true })
