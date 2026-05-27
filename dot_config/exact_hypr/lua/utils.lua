-- Note: make sure NOT to depend on log to avoid a circular dependency

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

---@param table table
---@return boolean
function M.table.is_empty(table)
  return next(table) == nil
end

-- TODO: add Iterator object that has map, filter, and others as methods
---@generic T, U
---@param iter T[]
---@param fn fun(t: T): U
---@return U[]
function M.table.map(iter, fn)
  local result = {}

  for i, v in ipairs(iter) do
    result[i] = fn(v)
  end

  return result
end

---@param val any
---@return string
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
    return string.format("%q", val)     -- Wraps strings in quotes
  else
    return tostring(val)
  end
end

---@param val any
---@return string
function M.to_string(val)
  if type(val) == "string" then
    return val
  end

  return M.inspect(val)
end

return M
