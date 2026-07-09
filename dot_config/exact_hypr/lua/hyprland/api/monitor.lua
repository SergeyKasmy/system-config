local log = require("lua.log")
local tbl = require("crnlib.table")

---@class MonitorSpec : HL.MonitorSpec
---@field output nil 
---@field scale? string|number

---@class BaseMonitorConfig
---@field mode string|"preferred"
---@field position string|"auto"
---@field position_unscaled? string|"auto" Position to use when unscaled (scale = 1.0) via `Monitor:unscale`, since a monitor's position typically has to shift to stay aligned with its neighbors once its scale changes.
---@field scale? number|"auto"
---@field disabled? boolean

---@class MonitorConfig : BaseMonitorConfig
---@field connectors string[]

---@class Monitor : MonitorConfig
local Monitor = tbl.type()

---@param config MonitorConfig
---@return Monitor
function Monitor.new(config)
  return tbl.instance_of(Monitor, config --[[ @as Monitor ]])
end

---@param config BaseMonitorConfig
function Monitor.configure_fallback(config)
  ---@cast config MonitorConfig
  config.connectors = { "" }

  Monitor.new(config):configure()
end

-- Set all parameters to the defaults
function Monitor:configure()
  self:set({
    mode = self.mode,
    position = self.position,
    scale = self.scale,
    disabled = self.disabled,
  })
end

---@return HL.Monitor|nil
function Monitor:handle()
  for _, name in ipairs(self.connectors) do
    local hndl = hl.get_monitor(name)
    if hndl ~= nil then return hndl end
  end

  return nil
end

---@param conf MonitorSpec
function Monitor:set(conf)
  for _, conn in ipairs(self.connectors) do
    ---@type HL.MonitorSpec
    local this_conf = {
      output = conn
    }
    for k, v in pairs(conf) do
      this_conf[k] = v
    end
    hl.monitor(this_conf)
  end
end


function Monitor:disable()
  log.info("Disabling monitor(s)", self.connectors)

  self.disabled = true

  self:set({
    disabled = true
  })
end

function Monitor:enable()
  log.info("Enabling monitor(s)", self.connectors)

  self.disabled = false

  self:set({
    disabled = false
  })
end

function Monitor:unscale()
  self:set({
    position = self.position_unscaled,
    scale = 1.0,
  })
end

return Monitor
