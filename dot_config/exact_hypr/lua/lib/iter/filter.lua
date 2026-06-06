local Iter = require("lua.lib.iter").Iter
local tbl = require("lua.lib.table")

---@generic T
---@class FilterIter<T> : Iter<T>
---@field source Iter<T>
---@field pred fun(v: T): boolean
local FilterIter = tbl.type(Iter)

---@generic T
---@param source Iter<T>
---@param pred fun(v: T): boolean
---@return FilterIter<T>
function FilterIter.new(source, pred)
  return tbl.instance_of(FilterIter, { source = source, pred = pred })
end

function FilterIter:clone()
  return tbl.instance_of(FilterIter, { source = self.source:clone(), pred = self.pred })
end

function FilterIter:next()
  while true do
    local v = self.source:next()
    if v == nil then return nil end
    if self.pred(v) then return v end
  end
end

return FilterIter
