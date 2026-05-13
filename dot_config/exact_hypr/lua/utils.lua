local programs = require("lua.hyprland.programs")
require("lua.log")

-- Global utils

---@class WindowRule
---@field float? boolean


---@param cmd string
---@param opts? WindowRule
---@return HL.Dispatcher
function exec(cmd, opts)
    Log("Registering cmd dispatcher for: " .. cmd)

    return hl.dsp.exec_cmd(cmd, opts)
end

-- Opens a big application. For tiny scripts use `exec`
---@param app string
---@param opts? WindowRule
---@return HL.Dispatcher
function exec_app(app, opts)
  Log("Registering app dispatcher for: " .. app)

  return hl.dsp.exec_cmd(programs.launcher .. " " .. app, opts)
end

-- Scoped utils

local M = {
  table = {}
}

--- Creates a new table by merging two existing tables.
---@generic T : table, K : table
---@param base T # The initial table providing the base structure.
---@param overrides K # The table whose keys will overwrite or extend the base.
---@return T | K # A new table containing the combined keys of both.
function M.table.extend(base, overrides)
  local result = {}

  -- Copy base table
  for k, v in pairs(base) do
      result[k] = v
  end
  -- Apply overrides
  for k, v in pairs(overrides) do
      result[k] = v
  end

  return result
end

function M.inspect(val)
    if type(val) == "table" then
        local s = "{ "
        for k, v in pairs(val) do
            -- Format the key
            local key = type(k) == "string" and string.format("[%q]", k) or string.format("[%s]", tostring(k))
            -- Recursively format the value
            s = s .. key .. " = " .. M.inspect(v) .. ", "
        end
        return s .. "}"
    elseif type(val) == "string" then
        return string.format("%q", val) -- Wraps strings in quotes
    else
        return tostring(val)
    end
end

return M
