local log = require("lua.log")
local tbl = require("lua.lib.table")

---@class MonitorConf : HL.MonitorSpec
---@field output? string
---@field scale? string|number

---@class Monitor
---@field outputs string[]
local Monitor = {}
Monitor.__index = Monitor

---@param conf MonitorConf
function Monitor:config(conf)
  for _, output in ipairs(self.outputs) do
    conf.output = output
    hl.monitor(conf)
  end
end

function Monitor:disable()
  log.info("Disabling monitor(s)", self.outputs)

  self:config({
    disabled = true
  })
end

function Monitor:enable()
  log.info("Enabling monitor(s)", self.outputs)

  self:config({
    disabled = false
  })
end

---@param outputs? string|string[]
---@return Monitor
local function new(outputs)
  local output_array
  if outputs == nil then
    output_array = {}
  elseif type(outputs) == "string" then
    output_array = { outputs }
  else
    output_array = outputs
  end

  ---@type Monitor
  local monitor = { outputs = output_array }
  return tbl.instance_of(Monitor, monitor)
end

return new
