local Iter = require("lua.lib.iter").Iter
local tbl = require("lua.lib.table")

---@generic T
---@class SkipIter<T> : Iter<T>
---@field source Iter<T>
---@field count integer
local SkipIter = tbl.type(Iter)

---@generic T
---@param source Iter<T>
---@param count integer
---@return SkipIter<T>
function SkipIter.new(source, count)
  return tbl.instance_of(SkipIter, { source = source, count = count })
end

function SkipIter:clone()
  return tbl.instance_of(SkipIter, { source = self.source:clone(), count = self.count })
end

function SkipIter:next()
  for _ = 1, self.count do
    self.source:next()
  end

  self.count = 0

  return self.source:next()
end

return SkipIter
