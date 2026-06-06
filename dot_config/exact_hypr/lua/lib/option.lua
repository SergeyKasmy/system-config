local tbl = require("lua.lib.table")

---@generic T
---@class Option<T>
---@field inner? T
local Option = {}
Option.__index = Option

---@generic T
---@param val T?
---@return Option<T>
function Option.new(val)
  ---@type Option<T>
  local self = {
    inner = val,
  }

  return tbl.instance_of(Option, self)
end

---@generic T
---@param val T
---@return Option<T>
function Option.some(val)
  return Option.new(val)
end

---@generic T
---@return Option<T>
function Option.none()
  return Option.new(nil)
end

---@generic T
---@param cond boolean?
---@param val T
---@return Option<T>
function Option.then_some(cond, val)
  if cond ~= nil and cond then
    return Option.some(val)
  else
    return Option.none()
  end
end

-- Combines Rust's Option::map and Option::filter_map in one
---@generic T, U
---@param self Option<T>
---@param f fun(val: T): U?
---@return Option<U>
function Option:map(f)
  if self.inner == nil then return self end
  self.inner = f(self.inner)
  return self
end

---@generic T, U
---@param self Option<T>
---@param default U | fun(): U
---@param f fun(val: T): U?
---@return U
function Option:map_or(default, f)
  if self.inner == nil then
    return type(default) == "function" and default() or default
  end

  return f(self.inner)
end

---@generic T, U
---@param self Option<T>
---@param f fun(val: T): U?
---@return U?
function Option:map_or_nil(f)
  if self.inner == nil then return nil end
  self.inner = f(self.inner)
  return self
end

---@generic T
---@param self Option<T>
---@param val T
---@return T
function Option:unwrap_or(val)
  return self.inner ~= nil and self.inner or val
end

return Option
