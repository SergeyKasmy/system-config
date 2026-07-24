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
---@field mirror? string Output name to permanently mirror.

---@class MonitorConfig : BaseMonitorConfig
---@field connectors string[]
---@field mirroring? boolean Whether this monitor is currently mirroring another monitor. Automatically tracked by `Monitor:set` on every call, not just ones that pass a `mirror` field. Not a valid `hl.monitor` field, must be excluded from `Monitor:configure`'s config.

---@class Monitor : MonitorConfig
local Monitor = tbl.type()

---@param config MonitorConfig
---@return Monitor
function Monitor.new(config)
  local instance = tbl.instance_of(Monitor, config --[[ @as Monitor ]])

  -- Snapshot the originally configured state so `Monitor:reset` can undo any
  -- runtime toggling (disable/enable/mirror/...), instead of just reapplying it.
  local defaults = {}
  for k, v in pairs(config) do
    defaults[k] = v
  end
  instance._defaults = defaults

  return instance
end

---@param config BaseMonitorConfig
function Monitor.configure_fallback(config)
  ---@cast config MonitorConfig
  config.connectors = { "" }

  Monitor.new(config):configure()
end

-- Set all parameters to the defaults
function Monitor:configure()
  local conf = {}
  for k, v in pairs(self) do
    if k ~= "connectors" and k ~= "position_unscaled" and k ~= "mirroring" and k ~= "_defaults" then
      conf[k] = v
    end
  end
  -- `self.mirror` is never written back by `Monitor:set`, so unless we say so
  -- explicitly here, a monitor currently mirroring another one would keep
  -- doing so even though mirroring isn't part of its configured defaults.
  conf.mirror = self.mirror or "none"

  self:set(conf)
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
  self.mirroring = (conf.mirror or "none") ~= "none"

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

function Monitor:toggle()
  if self.disabled then
    self:enable()
  else
    self:disable()
  end
end

---@param target Monitor Monitor whose output this monitor should mirror
function Monitor:mirror_to(target)
  if target.disabled then
    -- TODO: use hl.timer to wait for the monitor to come up before continuing, instead of enabling and immediately bailing
    target:enable()
  end

  local handle = target:handle()
  if handle == nil then
    log.warn("Cannot mirror monitor(s) " .. table.concat(self.connectors, ", ") ..
      ": target monitor is not connected")
    return
  end

  log.info("Mirroring monitor(s)", self.connectors, "to", handle.name)

  self:set({ mirror = handle.name })
end

---@param target Monitor Monitor whose output this monitor should mirror
function Monitor:toggle_mirror(target)
  if self.mirroring then
    log.info("Unmirroring monitor(s)", self.connectors)

    self:set({ mirror = "none" })
  else
    self:mirror_to(target)
  end
end

--- Restore this monitor to its originally configured state, undoing any
--- runtime toggling (disable/enable/mirror/...) done since `Monitor.new`.
function Monitor:reset()
  for k, v in pairs(self._defaults) do
    self[k] = v
  end

  self:configure()
end

function Monitor:unscale()
  local position = self.position_unscaled or self.position

  self:set({
    scale = 1.0,
    position = position,
  })
end

return Monitor
