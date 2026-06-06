local Iter = require("lua.lib.iter").Iter
local tbl = require("lua.lib.table")

---@generic T
---@class DestructuredEnumerateIter<T> : Iter<T>
---@field source Iter<T>
---@field i integer
local DestructuredEnumerateIter = tbl.type(Iter)

---@generic T
---@param source Iter<T>
---@return DestructuredEnumerateIter<T>
function DestructuredEnumerateIter.new(source)
  return tbl.instance_of(DestructuredEnumerateIter, { source = source, i = 0 })
end

function DestructuredEnumerateIter:clone()
  return tbl.instance_of(DestructuredEnumerateIter, { source = self.source:clone(), i = self.i })
end

---@return integer?, T?
function DestructuredEnumerateIter:next()
  local v = self.source:next()
  if v == nil then return nil end
  self.i = self.i + 1
  return self.i, v
end

return DestructuredEnumerateIter
