local log = require("lua.log")
local programs = require("lua.hyprland.programs")

local M = {
  dsp = require("lua.hyprland.api.dsp"),
}

---@param cmd string
function M.exec(cmd)
  log.debug("Executing", cmd)

  hl.exec_cmd(cmd)
end

---@param app string
function M.exec_app(app)
  log.debug("Launching app", app)

  hl.exec_cmd(programs.launcher .. " " .. app)
end

return M
