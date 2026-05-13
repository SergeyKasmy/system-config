---@class HL.MonitorSpec
---@diagnostic disable-next-line: duplicate-doc-field
---@field scale? string|number

-- main monitor (dGPU and iGPU)
for _, output in ipairs({ "DP-1", "DP-3" }) do
  hl.monitor({
    output = output,
    mode = "2560x1440@170",
    position = "0x0",
    scale = 1.25,
  })
end

-- second monitor (dGPU and iGPU)
for _, output in ipairs({ "HDMI-A-1", "HDMI-A-3" }) do
  hl.monitor({
    output = output,
    mode = "preferred",
    position = "2048x32",
  })
end

-- TV
hl.monitor({
  output   = "HDMI-A-2",
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
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto"
})
