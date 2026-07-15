local log = require("lua.log")

local M = {}

local current_workspace_id = nil
local previous_workspace_id = nil

--- Update history when workspace changes
---@param workspace? HL.Workspace
function M.on_workspace_active(workspace)
  if workspace == nil then return end
  log.trace("Switched to workspace", workspace.id)
  local id = workspace.id

  -- Only update if switching to a different workspace
  if id ~= current_workspace_id then
    previous_workspace_id = current_workspace_id
    current_workspace_id = id
  end
end

--- Toggle to the previous workspace
function M.toggle_previous()
  log.trace("Switching to previous workspace:", previous_workspace_id)
  if previous_workspace_id ~= nil then
    hl.dispatch(hl.dsp.focus({ workspace = previous_workspace_id }))
  end
end

return M
