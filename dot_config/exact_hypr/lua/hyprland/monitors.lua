local Monitor = require("lua.hyprland.api.monitor")

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
  mode = "3840x2160@144",
  position = "auto",
  scale = 3,

  -- HDR (less bright than Windows for some reason?)
  -- bitdepth      = 10,
  -- cm            = "hdr",
  -- max_luminance = 1500,
  -- min_luminance = 0.02,
  -- icc = os.getenv("HOME") .. "/documents/samsung-s95d-hdr-windows-calibrated-6-28-2025-04747.icc",
})

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
end

function M.reset()
  for _, mon in pairs(M.instances) do
    mon:configure()
  end

  M.is_unscaled = false
end

function M.toggle_scale()
  if M.is_unscaled then
    M.reset()
  else
    M.unscale()
  end
end

function M.enable_tv()
  M.instances.main:disable()
  M.instances.secondary:disable()
  M.instances.tv:enable()
end

function M.disable_tv()
  M.instances.main:enable()
  M.instances.secondary:enable()
  M.instances.tv:disable()
end

function M.toggle_tv()
  local tv = M.instances.tv

  if tv.disabled then
    tv:enable()
  else
    tv:disable()
  end
end

return M
