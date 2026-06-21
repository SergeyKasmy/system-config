local tbl = require("lua.lib.table")

-- A Rust-like Option type
---@generic T
---@class Option<T>
---@field private _inner T
local Option = tbl.type()

-- Global Option.none singleton to avoid allocating separate Option.none tables
local NONE = tbl.instance_of(Option, {})

---@generic T
---@param val T?
---@return Option<T>
function Option.new(val)
  if val == nil then
    return NONE
  end

  ---@type Option<T>
  local self = {
    _inner = val,
  }

  return tbl.instance_of(Option, self)
end

---@generic T
---@param val T
---@return Option<T>
function Option.some(val)
  if val == nil then
    error("Attempted to construct Option.some with a nil value.", 2)
  end

  ---@type Option<T>
  local self = {
    _inner = val,
  }

  return tbl.instance_of(Option, self)
end

---@generic T
---@return Option<T>
function Option.none()
  return NONE
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

---@generic T
---@param cond boolean?
---@param f fun(): T
---@return Option<T>
function Option.then_some_with(cond, f)
  if cond ~= nil and cond then
    return Option.some(f())
  else
    return Option.none()
  end
end

---@generic T
---@param self Option<T>
---@return boolean
function Option:is_some()
  return self ~= NONE
end

---@generic T
---@param self Option<T>
---@return boolean
function Option:is_none()
  return self == NONE
end

-- Combines both Option::map and Option::filter_map from Rust
---@generic T, U
---@param f fun(val: T): U?
---@return Option<U>
function Option:map(f)
  if self == NONE then
    return NONE
  end

  local result = f(self._inner)
  if result == nil then
    return NONE
  end

  return Option.some(result)
end

---@generic T, U
---@param self Option<T>
---@param default U
---@param f fun(val: T): U
---@return U
function Option:map_or(default, f)
  if self == NONE then
    return default
  end

  return f(self._inner)
end

---@generic T, U
---@param self Option<T>
---@param default_fn fun(): U
---@param f fun(val: T): U
---@return U
function Option:map_or_else(default_fn, f)
  if self == NONE then
    return default_fn()
  end

  return f(self._inner)
end

---@generic T, U
---@param self Option<T>
---@param f fun(val: T): Option<U>
---@return Option<U>
function Option:and_then(f)
  if self == NONE then return NONE end
  return f(self._inner)
end

---@generic T
---@param self Option<T>
---@return T
function Option:unwrap()
  if self == NONE then
    error("Called unwrap() on a None value.", 2)
  end

  return self._inner
end

---@generic T
---@param self Option<T>
---@param message string
---@return T
function Option:expect(message)
  if self == NONE then
    error(message, 2)
  end

  return self._inner
end

---@generic T
---@param self Option<T>
---@param val T
---@return T
function Option:unwrap_or(val)
  if self ~= NONE then return self._inner end
  return val
end

---@generic T
---@param self Option<T>
---@param f fun(): T
---@return T
function Option:unwrap_or_else(f)
  if self ~= NONE then return self._inner end
  return f()
end

---@generic T
---@param self Option<T>
---@return T?
function Option:extract()
  if self == NONE then
    return nil
  end

  return self._inner
end

return Option
