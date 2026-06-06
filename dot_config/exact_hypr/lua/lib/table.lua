local M = {}

---@generic T, U
---@param parent T?
---@return U
function M.type(parent)
  local type = {}

  -- inherit from the parent if there is one
  if parent ~= nil then
    type = setmetatable(type, { __index = parent })
  end

  -- define that this table is a "type-definition"
  -- and it will be used for looking up methods
  type.__index = type
  return type
end

---@generic T, U
---@param class T
---@param instance U
---@return U
function M.instance_of(class, instance)
  return setmetatable(instance, class)
end

return M
