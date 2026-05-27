local Iter = require("lua.lib.iter").Iter

---@generic T
---@class ChainIter<T> : Iter<T>
---@field first Iter<T>
---@field second Iter<T>
---@field first_done boolean
local ChainIter = setmetatable({}, { __index = Iter }) --[[@as ChainIter]]
ChainIter.__index = ChainIter

function ChainIter:next()
  if not self.first_done then
    local v = self.first:next()
    if v ~= nil then return v end
    self.first_done = true
  end

  return self.second:next()
end

return ChainIter
