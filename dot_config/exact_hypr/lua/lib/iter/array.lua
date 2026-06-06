local Iter = require("lua.lib.iter").Iter
local tbl = require("lua.lib.table")

---@generic T
---@class ArrayIter<T> : Iter<T>
---@field inner T[]
---@field i integer
local ArrayIter = tbl.type(Iter)

---@generic T
---@param array T[]
---@return ArrayIter<T>
function ArrayIter.new(array)
  return tbl.instance_of(ArrayIter, { inner = array, i = 0 })
end

function ArrayIter:clone()
  return tbl.instance_of(ArrayIter, { inner = self.inner, i = self.i })
end

function ArrayIter:next()
  self.i = self.i + 1
  return self.inner[self.i]
end

return ArrayIter
