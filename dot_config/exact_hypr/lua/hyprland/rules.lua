---@class RuleEntry
---@field class? string
---@field rules? HL.WindowRuleSpec
---@field on? EventCallbacks

---@class EventCallbacks
---@field hyprland.start? fun()
---@field hyprland.shutdown? fun()
---@field window.open? fun(window: HL.Window)
---@field window.open_early? fun(window: HL.Window)
---@field window.close? fun(window: HL.Window)
---@field window.destroy? fun(window: HL.Window)
---@field window.kill? fun(window: HL.Window)
---@field window.active? fun(window: HL.Window, focus_reason: integer)
---@field window.urgent? fun(window: HL.Window)
---@field window.title? fun(window: HL.Window)
---@field window.class? fun(window: HL.Window)
---@field window.pin? fun(window: HL.Window)
---@field window.fullscreen? fun(window: HL.Window)
---@field window.update_rules? fun(window: HL.Window)
---@field window.move_to_workspace? fun(window: HL.Window, workspace: HL.Workspace)
---@field layer.opened? fun(layer: HL.LayerSurface)
---@field layer.closed? fun(layer: HL.LayerSurface)
---@field monitor.added? fun(monitor: HL.Monitor)
---@field monitor.removed? fun(monitor: HL.Monitor)
---@field monitor.focused? fun(monitor: HL.Monitor)
---@field monitor.layout_changed? fun()
---@field workspace.active? fun(workspace: HL.Workspace)
---@field workspace.special_active? fun(workspace: HL.Workspace, monitor: HL.Monitor)
---@field workspace.created? fun(workspace: HL.Workspace)
---@field workspace.removed? fun(workspace: HL.Workspace)
---@field workspace.move_to_monitor? fun(workspace: HL.Workspace, monitor: HL.Monitor)
---@field config.reloaded? fun()
---@field config.props_refreshed? fun(scheduled: boolean)
---@field keybinds.submap? fun(submap: string)
---@field screenshare.state? fun(active: boolean, type: integer, name: string)
---@field input.keyboard.key? fun(keycode: integer, timestamp: integer, state: integer)

local register = require("lua.hyprland.rules.register")
local update_waybar_fullscreen = require("lua.hyprland.rules.waybar_fullscreen")

---@type table<string, RuleEntry>
local rules = {
  ----------------------
  ---- GLOBAL RULES ----
  ----------------------

  suppress_maximize_events = {
    rules = {
      match          = { class = ".*" },
      suppress_event = "maximize",
    },
  },

  fix_xwayland_drags = {
    rules = {
      match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
      },
      no_focus = true,
    },
  },

  workspace_10_float_by_default = {
    rules = {
      match = { workspace = "10" },
      float = true,
    },
  },

  ----------------------
  ---- CUSTOM RULES ----
  ----------------------

  waybar = {
    on = {
      ["config.reloaded"]           = update_waybar_fullscreen,
      ["window.fullscreen"]         = update_waybar_fullscreen,
      ["window.move_to_workspace"]  = update_waybar_fullscreen,
      ["workspace.active"]          = update_waybar_fullscreen,
      ["workspace.move_to_monitor"] = update_waybar_fullscreen,
    },
  },

  ueberzugpp = {
    class = "^ueberzugpp_.*",
    rules = { float = true, no_focus = true },
  },

  telegram = {
    class = "org.telegram.desktop",
    rules = { workspace = "2" },
    on = {
      ["window.open"] = function(window)
        hl.timer(function()
          -- TODO(Ciren): for some reason sometimes doesn't work. Can't figure out why
          hl.dispatch(hl.dsp.send_shortcut({
            mods = "CTRL",
            key = "2",
            window = "class:^(" .. window.class .. ")$",
          }))
        end, { timeout = 1400, type = "oneshot" })
      end,
    },
  },

  firefox = {
    class = "firefox",
    on = {
      ["window.open"] = (function()
        local count = 0
        return function(window)
          count = count + 1
          local ws = count % 2 == 1 and "3" or "1"
          hl.dispatch(hl.dsp.window.move({ workspace = ws, window = window }))
        end
      end)(),
    },
  },

  horizon_forbidden_west = {
    rules = {
      match = {
        class = "steam_app_default",
        title = "^Horizon Forbidden West.*"
      },
      fullscreen = true,
    }
  }
}

for name, entry in pairs(rules) do
  register(name, entry)
end
