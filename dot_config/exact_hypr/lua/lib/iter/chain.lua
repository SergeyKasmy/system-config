local Iter = require("lua.lib.iter").Iter
local tbl = require("lua.lib.table")

---@generic T
---@class ChainIter<T> : Iter<T>
---@field first Iter<T>
---@field second Iter<T>
---@field first_done boolean
local ChainIter = tbl.type(Iter)

---@generic T
---@param first Iter<T>
---@param second Iter<T>
---@return ChainIter<T>
function ChainIter.new(first, second)
  return tbl.instance_of(ChainIter, { first = first, second = second, first_done = false })
end

function ChainIter:clone()
  return tbl.instance_of(ChainIter, { first = self.first:clone(), second = self.second:clone(), first_done = self.first_done })
end

function ChainIter:next()
  if not self.first_done then
    local v = self.first:next()
    if v ~= nil then return v end
    self.first_done = true
  end

  return self.second:next()
end

return ChainIter
