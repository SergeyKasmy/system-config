local M = {}
-- register early so submodule circular requires receive this partial table
package.loaded["lua.lib.iter"] = M

---@generic T
---@class Iter<T>
---@field next fun(self: Iter<T>): T
-- Iter doesn't provide :next(), it should be provided by the inherited class instead
M.Iter = {}
M.Iter.__index = M.Iter

-- submodules require this module, so Iter must exist before they load
local ArrayIter = require("lua.lib.iter.array")
local ChainIter = require("lua.lib.iter.chain")
local MapIter = require("lua.lib.iter.map")
local FilterIter = require("lua.lib.iter.filter")
local EnumerateIter = require("lua.lib.iter.enumerate")

---@generic T
---@param self Iter<T>
---@return fun(): T
function M.Iter:it()
  return function() return self:next() end
end

---@generic T
---@param self Iter<T>
---@param other Iter<T>
---@return ChainIter<T>
function M.Iter:chain(other)
  ---@type ChainIter
  local iter = { first = self, second = other, first_done = false }
  return setmetatable(iter, ChainIter)
end

---@generic T, U
---@param self Iter<T>
---@param f fun(v: T): U
---@return MapIter<T, U>
function M.Iter:map(f)
  ---@type MapIter
  local iter = { source = self, f = f }
  return setmetatable(iter, MapIter)
end

---@generic T
---@param self Iter<T>
---@param pred fun(v: T): boolean
---@return FilterIter<T>
function M.Iter:filter(pred)
  ---@type FilterIter
  local iter = { source = self, pred = pred }
  return setmetatable(iter, FilterIter)
end

---@generic T
---@param self Iter<T>
---@return EnumerateIter<T>
function M.Iter:enumerate()
  ---@type EnumerateIter
  local iter = { source = self, i = 0 }
  return setmetatable(iter, EnumerateIter)
end

---@generic T
---@param self Iter<T>
---@return T[]
function M.Iter:collect()
  ---@type T[]
  local array = {}
  for v in self:it() do array[#array + 1] = v end
  return array
end

M.new = ArrayIter.new

return M
