local Iter = require("lua.lib.iter").Iter

---@generic T
---@class FilterIter<T> : Iter<T>
---@field source Iter<T>
---@field pred fun(v: T): boolean
local FilterIter = setmetatable({}, { __index = Iter }) --[[@as FilterIter]]
FilterIter.__index = FilterIter

function FilterIter:next()
  while true do
    local v = self.source:next()
    if v == nil then return nil end
    if self.pred(v) then return v end
  end
end

return FilterIter
