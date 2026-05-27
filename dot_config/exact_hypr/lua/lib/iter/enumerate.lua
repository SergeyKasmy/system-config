local Iter = require("lua.lib.iter").Iter

---@generic T
---@class EnumerateIter<T> : Iter<T>
---@field source Iter<T>
---@field i integer
local EnumerateIter = setmetatable({}, { __index = Iter }) --[[@as EnumerateIter]]
EnumerateIter.__index = EnumerateIter

---@return integer?, T?
function EnumerateIter:next()
  local v = self.source:next()
  if v == nil then return nil end
  self.i = self.i + 1
  return self.i, v
end

return EnumerateIter
