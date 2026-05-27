local Iter = require("lua.lib.iter").Iter

---@generic T
---@class ArrayIter<T> : Iter<T>
---@field inner T[]
---@field i integer
local ArrayIter = setmetatable({}, { __index = Iter }) --[[@as ArrayIter]]
ArrayIter.__index = ArrayIter

---@generic T
---@param array T[]
---@return ArrayIter<T>
function ArrayIter.new(array)
  ---@type ArrayIter
  local iter = { inner = array, i = 0 }
  return setmetatable(iter, ArrayIter)
end

function ArrayIter:next()
  self.i = self.i + 1
  return self.inner[self.i]
end

return ArrayIter
