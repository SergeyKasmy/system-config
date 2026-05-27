local Iter = require("lua.lib.iter").Iter

---@generic T, U
---@class MapIter<T, U> : Iter<U>
---@field source Iter<T>
---@field f fun(v: T): U
local MapIter = setmetatable({}, { __index = Iter }) --[[@as MapIter]]
MapIter.__index = MapIter

function MapIter:next()
  local v = self.source:next()
  if v == nil then return nil end
  return self.f(v)
end

return MapIter
