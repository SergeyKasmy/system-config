local tbl = require("lua.lib.table")
local M = {}
-- register early so submodule circular requires receive this partial table
package.loaded["lua.lib.iter"] = M

---@generic T
---@class Iter<T>
---@field next fun(self: Iter<T>): T
---@field clone fun(self: Iter<T>): Iter<T>
-- Iter doesn't provide :next(), it must be provided by the inherited class instead
M.Iter = tbl.type()

-- submodules require this module, so Iter must exist before they load
local ArrayIter = require("lua.lib.iter.array")
local ChainIter = require("lua.lib.iter.chain")
local MapIter = require("lua.lib.iter.map")
local FilterIter = require("lua.lib.iter.filter")
local EnumerateIter = require("lua.lib.iter.enumerate")
local SkipIter = require("lua.lib.iter.skip")
local DestructuredEnumerateIter = require("lua.lib.iter.destructured_enumerate")

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
  return ChainIter.new(self, other)
end

---@generic T, U
---@param self Iter<T>
---@param f fun(v: T): U
---@return MapIter<T, U>
function M.Iter:map(f)
  return MapIter.new(self, f)
end

---@generic T
---@param self Iter<T>
---@param pred fun(v: T): boolean
---@return FilterIter<T>
function M.Iter:filter(pred)
  return FilterIter.new(self, pred)
end

---@generic T
---@param self Iter<T>
---@return EnumerateIter<T>
function M.Iter:enumerate()
  return EnumerateIter.new(self)
end

---@generic T
---@param self Iter<T>
---@param pred fun(V: T): boolean
---@return T?
function M.Iter:find(pred)
  local elem = self:next()
  while elem ~= nil do
    if pred(elem) then
      return elem
    end

    elem = self:next()
  end

  return nil
end

---@generic T
---@param self Iter<T>
---@param pred fun(v: T): boolean
---@return integer?
function M.Iter:position(pred)
  local i = 0
  local elem = self:next()

  while elem ~= nil do
    i = i + 1
    if pred(elem) then return i end
    elem = self:next()
  end

  return nil
end

---@generic T
---@param self Iter<T>
---@return DestructuredEnumerateIter<T>
function M.Iter:enumerate2()
  return DestructuredEnumerateIter.new(self)
end

---@generic T
---@param self Iter<T>
---@param count number
---@return SkipIter<T>
function M.Iter:skip(count)
  return SkipIter.new(self, count)
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
