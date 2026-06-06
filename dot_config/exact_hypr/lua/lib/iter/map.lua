local Iter = require("lua.lib.iter").Iter
local tbl = require("lua.lib.table")

---@generic T, U
---@class MapIter<T, U> : Iter<U>
---@field source Iter<T>
---@field f fun(v: T): U
local MapIter = tbl.type(Iter)

---@generic T, U
---@param source Iter<T>
---@param f fun(v: T): U
---@return MapIter<T, U>
function MapIter.new(source, f)
  return tbl.instance_of(MapIter, { source = source, f = f })
end

function MapIter:clone()
  return tbl.instance_of(MapIter, { source = self.source:clone(), f = self.f })
end

function MapIter:next()
  local v = self.source:next()
  if v == nil then return nil end
  return self.f(v)
end

return MapIter
