local monitor = require("lua.hyprland.api.monitors")

local M = {}

M.main_monitor = {
  -- dGPU and iGPU
  names = { "DP-1", "DP-3" },
  scale = 1.25,
}

M.second_monitor = {
  -- dGPU and iGPU
  names = { "HDMI-A-1", "HDMI-A-3" },
  position = {
    main_monitor_scaled = "2048x32",
    main_monitor_native = "2560x32",
  }
}

M.tv = {
  name = "HDMI-A-2"
}

function M.configure()
  monitor(M.main_monitor.names):config({
    mode = "2560x1440@170",
    position = "0x0",
    scale = M.main_monitor.scale,
  })

  monitor(M.second_monitor.names):config({
    mode = "preferred",
    position = M.second_monitor.position.main_monitor_scaled,
  })

  monitor(M.tv.name):config({
    disabled = true,
    mode     = "3840x2160@144",
    -- mode  = "3840x2160@60",
    position = "auto",
    scale    = 3,

    -- HDR (less bright than Windows for some reason?)
    -- bitdepth      = 10,
    -- cm            = "hdr",
    -- max_luminance = 1500,
    -- min_luminance = 0.02,
    -- icc = "/home/ciren/documents/samsung-s95d-hdr-windows-calibrated-6-28-2025-04747.icc",
  })

  -- catch-all fallback
  monitor():config({
    mode = "preferred",
    position = "auto",
    scale = "auto"
  })
end

return M
