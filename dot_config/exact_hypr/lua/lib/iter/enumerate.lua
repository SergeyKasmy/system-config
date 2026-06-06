local Iter = require("lua.lib.iter").Iter
local tbl = require("lua.lib.table")

---@generic T
---@class EnumerateIter<T> : Iter<T>
---@field source Iter<T>
---@field i integer
local EnumerateIter = tbl.type(Iter)

---@generic T
---@param source Iter<T>
---@return EnumerateIter<T>
function EnumerateIter.new(source)
  return tbl.instance_of(EnumerateIter, { source = source, i = 0 })
end

function EnumerateIter:clone()
  return tbl.instance_of(EnumerateIter, { source = self.source:clone(), i = self.i })
end

---@return integer?, T?
function EnumerateIter:next()
  local v = self.source:next()
  if v == nil then return nil end
  self.i = self.i + 1
  return self.i, v
end

return EnumerateIter
