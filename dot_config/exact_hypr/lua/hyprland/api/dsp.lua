local iter = require("lua.lib.iter")
local log = require("lua.log")
local programs = require("lua.hyprland.programs")

local M = {}

---@class WindowRule
---@field float? boolean

-- Start a short-lived background script or command
---@param cmd string
---@param opts? WindowRule
---@return HL.Dispatcher
function M.exec(cmd, opts)
  log.trace("Registering cmd dispatcher for:", cmd)

  return hl.dsp.exec_cmd(cmd, opts)
end

-- Launch a big application. For tiny scripts use `exec`
---@param app string
---@param opts? WindowRule
---@return HL.Dispatcher
function M.exec_app(app, opts)
  log.trace("Registering app dispatcher for:", {
    launcher = programs.launcher,
    app = app,
    opts = opts,
  })

  return hl.dsp.exec_cmd(programs.launcher .. " " .. app, opts)
end

M.focus = {}

---@return HL.Dispatcher
function M.focus.left()
  return hl.dsp.focus({ direction = "l" })
end

---@return HL.Dispatcher
function M.focus.right()
  return hl.dsp.focus({ direction = "r" })
end

---@return HL.Dispatcher
function M.focus.up()
  return hl.dsp.focus({ direction = "u" })
end

---@return HL.Dispatcher
function M.focus.down()
  return hl.dsp.focus({ direction = "d" })
end

---@return function
function M.focus.next()
  return function()
    local ws = hl.get_active_workspace()
    if ws == nil then return end

    local current_window = ws.last_window
    if current_window == nil then return end

    local windows = ws:get_windows()
    local i = iter.new(windows):position(function(w) return w.stable_id == current_window.stable_id end)
    if i == nil then return end

    hl.dispatch(hl.dsp.focus({ window = windows[i + 1] or windows[1] }))
    hl.dispatch(hl.dsp.window.bring_to_top())
  end
end

---@return function
function M.focus.prev()
  return function()
    local ws = hl.get_active_workspace()
    if ws == nil then return end

    local current_window = ws.last_window
    if current_window == nil then return end

    local windows = ws:get_windows()
    local i = iter.new(windows):position(function(w) return w.stable_id == current_window.stable_id end)
    if i == nil then return end

    hl.dispatch(hl.dsp.focus({ window = windows[i - 1] or windows[#windows] }))
    hl.dispatch(hl.dsp.window.bring_to_top())
  end
end

M.window = {}

---@return HL.Dispatcher
function M.window.move_left()
  return hl.dsp.window.move({ direction = "l", group_aware = true })
end

---@return HL.Dispatcher
function M.window.move_right()
  return hl.dsp.window.move({ direction = "r", group_aware = true })
end

---@return HL.Dispatcher
function M.window.move_up()
  return hl.dsp.window.move({ direction = "u", group_aware = true })
end

---@return HL.Dispatcher
function M.window.move_down()
  return hl.dsp.window.move({ direction = "d", group_aware = true })
end

M.workspace = {}

---@return HL.Dispatcher
function M.workspace.move_left()
  return hl.dsp.workspace.move({ monitor = "l" })
end

---@return HL.Dispatcher
function M.workspace.move_right()
  return hl.dsp.workspace.move({ monitor = "r" })
end

---@return HL.Dispatcher
function M.workspace.move_up()
  return hl.dsp.workspace.move({ monitor = "u" })
end

---@return HL.Dispatcher
function M.workspace.move_down()
  return hl.dsp.workspace.move({ monitor = "d" })
end

return M
