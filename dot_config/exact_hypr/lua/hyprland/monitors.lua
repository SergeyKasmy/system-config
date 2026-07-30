local Monitor = require("lua.hyprland.api.monitor")
local api = require("lua.hyprland.api")

local M = {
  ---@type table<string, Monitor>
  instances = {},

  --- Whether the monitors are currently in their unscaled (scale = 1.0) state,
  --- as toggled by `M.toggle_scale`.
  is_unscaled = false,
}

M.instances.main = Monitor.new({
  connectors = { "DP-1", "DP-3" },
  mode = "2560x1440@170",
  position = "0x0",
  scale = 1.25,
})

M.instances.secondary = Monitor.new({
  connectors = { "HDMI-A-1", "HDMI-A-3" },
  mode = "preferred",
  position = "2048x32",
  position_unscaled = "2560x32",
})

M.instances.tv = Monitor.new({
  connectors = { "HDMI-A-2" },
  disabled = true,
  mode = "3840x2160@120",
  position = "auto",
  scale = 3,

  -- HDR
  bitdepth      = 10,
  cm            = "auto",
  max_luminance = 1300,
  min_luminance = 0.02,

  -- default value. TODO: if too high at night and too low in the day, can be changed to be toggle with a keybind, like scale
  sdr_max_luminance = 80,
  -- max_avg_luminance = 300,
})

-- TODO: automate calling this exactly once after any monitor-configuring action, so callers can't forget it (don't hook into Monitor:set(), it'd fire once per monitor/call instead of once per action)
function M.restart_hyprpaper()
  api.exec("systemctl --user restart hyprpaper")
end

function M.configure()
  for _, mon in pairs(M.instances) do
    mon:configure()
  end

  Monitor.configure_fallback({
      mode = "preferred",
      position = "auto",
      scale = "auto"
  })
end

function M.unscale()
  for _, mon in pairs(M.instances) do
    mon:unscale()
  end

  M.is_unscaled = true
  M.restart_hyprpaper()
end

function M.reset()
  for _, mon in pairs(M.instances) do
    mon:reset()
  end

  M.is_unscaled = false
  M.restart_hyprpaper()
end

function M.toggle_scale()
  if M.is_unscaled then
    M.reset()
  else
    M.unscale()
  end
end

function M.enable_tv_mode()
  M.instances.main:disable()
  M.instances.secondary:disable()
  M.instances.tv:enable()

  M.restart_hyprpaper()
end

function M.disable_tv_mode()
  M.instances.main:enable()
  M.instances.secondary:enable()
  M.instances.tv:disable()

  M.restart_hyprpaper()
end

function M.toggle_tv_mode()
  local tv = M.instances.tv

  if tv.disabled then
    M.enable_tv_mode()
  else
    M.disable_tv_mode()
  end
end

return M
