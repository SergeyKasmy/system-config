local iter = require("lua.lib.iter")
local tbl = require("lua.lib.table")
local t = require("tests.common")
local new = iter.new

local test, eq = t.test, t.eq

local function table_eq(a, b)
  eq(#a, #b)
  for i = 1, #a do eq(a[i], b[i]) end
end

-- ArrayIter:next()

test("next returns elements in order", function()
  local it = new({ 10, 20, 30 })
  eq(it:next(), 10)
  eq(it:next(), 20)
  eq(it:next(), 30)
end)

test("next returns nil when exhausted", function()
  local it = new({ 1 })
  it:next()
  eq(it:next(), nil)
end)

test("next on empty array returns nil immediately", function()
  eq(new({}):next(), nil)
end)

-- Iter (for-in)

test("it produces a for-in compatible function", function()
  table_eq(new({ 1, 2, 3 }):collect(), { 1, 2, 3 })
end)

test("it on empty array produces no iterations", function()
  table_eq(new({}):collect(), {})
end)

test("it stops at nil sentinel", function()
  -- sparse array: stops at first nil
  table_eq(new({ 1, nil, 3 }):collect(), { 1 })
end)

-- Iter:chain()

test("chain produces elements from first then second", function()
  table_eq(new({ 1, 2 }):chain(new({ 3, 4 })):collect(), { 1, 2, 3, 4 })
end)

test("chain with empty first yields only second", function()
  table_eq(new({}):chain(new({ 1, 2 })):collect(), { 1, 2 })
end)

test("chain with empty second yields only first", function()
  table_eq(new({ 1, 2 }):chain(new({})):collect(), { 1, 2 })
end)

test("chain with both empty yields nothing", function()
  table_eq(new({}):chain(new({})):collect(), {})
end)

test("chain does not call second:next() before first is exhausted", function()
  local second_called = false
  ---@type Iter
  local second_iter = {
    next = function(_)
      second_called = true
      return nil
    end,
    clone = function(_) return nil end,
  }
  local second = tbl.instance_of(iter.Iter, second_iter)
  local it = new({ 1 }):chain(second)
  eq(it:next(), 1)
  eq(second_called, false)
  it:next()
  eq(second_called, true)
end)

-- chaining chains

test("chains can be chained", function()
  table_eq(new({ 1 }):chain(new({ 2 })):chain(new({ 3 })):collect(), { 1, 2, 3 })
end)

-- Iter:map()

test("map transforms each element", function()
  table_eq(new({ 1, 2, 3 }):map(function(x) return x * 2 end):collect(), { 2, 4, 6 })
end)

test("map on empty yields nothing", function()
  table_eq(new({}):map(function(x) return x end):collect(), {})
end)

test("map can change type", function()
  table_eq(new({ 1, 2, 3 }):map(tostring):collect(), { "1", "2", "3" })
end)

test("map chains with chain", function()
  table_eq(new({ 1, 2 }):chain(new({ 3 })):map(function(x) return x * 10 end):collect(), { 10, 20, 30 })
end)

-- Iter:filter()

test("filter keeps matching elements", function()
  table_eq(new({ 1, 2, 3, 4, 5 }):filter(function(x) return x % 2 == 0 end):collect(), { 2, 4 })
end)

test("filter with all-pass predicate keeps everything", function()
  table_eq(new({ 1, 2, 3 }):filter(function() return true end):collect(), { 1, 2, 3 })
end)

test("filter with none-pass predicate yields nothing", function()
  table_eq(new({ 1, 2, 3 }):filter(function() return false end):collect(), {})
end)

test("filter on empty yields nothing", function()
  table_eq(new({}):filter(function() return true end):collect(), {})
end)

-- Iter:enumerate()

test("enumerate yields 1-based index and value", function()
  local indices, values = {}, {}
  for pair in new({ "a", "b", "c" }):enumerate():it() do
    local i, v = pair[1], pair[2]
    indices[#indices + 1] = i
    values[#values + 1] = v
  end
  table_eq(indices, { 1, 2, 3 })
  table_eq(values, { "a", "b", "c" })
end)

test("enumerate on empty yields nothing", function()
  local count = 0
  for _ in new({}):enumerate():it() do count = count + 1 end
  eq(count, 0)
end)

test("enumerate then map extracts indices", function()
  table_eq(
    new({ "a", "b", "c" }):enumerate():map(function(val) return val[1] end):collect(),
    { 1, 2, 3 }
  )
end)

test("enumerate then filter keeps only even-indexed elements", function()
  local values = {}
  for val in new({ "a", "b", "c", "d" }):enumerate():filter(function(val) return val[1] % 2 == 0 end):it() do
    values[#values + 1] = val[2]
  end
  table_eq(values, { "b", "d" })
end)

test("enumerate then skip drops first N elements", function()
  table_eq(
    new({ "x", "y", "z" }):enumerate():skip(1):map(function(val) return val[1] end):collect(),
    { 2, 3 }
  )
end)

test("enumerate then map then skip", function()
  table_eq(
    new({ 10, 20, 30, 40 }):enumerate():map(function(val) return val[1] * val[2] end):skip(2):collect(),
    { 90, 160 }
  )
end)

-- Iter:collect()

test("collect returns all elements as an array", function()
  table_eq(new({ 1, 2, 3 }):collect(), { 1, 2, 3 })
end)

test("collect on empty returns empty table", function()
  table_eq(new({}):collect(), {})
end)

-- combinator combinations

test("filter then map", function()
  table_eq(
    new({ 1, 2, 3, 4 }):filter(function(x) return x % 2 == 0 end):map(function(x) return x * 3 end):collect(),
    { 6, 12 }
  )
end)

test("map then filter", function()
  table_eq(
    new({ 1, 2, 3, 4 }):map(function(x) return x * 2 end):filter(function(x) return x > 4 end):collect(),
    { 6, 8 }
  )
end)

test("enumerate after filter", function()
  local indices, values = {}, {}
  for pair in new({ 1, 2, 3, 4 }):filter(function(x) return x % 2 == 0 end):enumerate():it() do
    local i, v = pair[1], pair[2]
    indices[#indices + 1] = i
    values[#values + 1] = v
  end
  table_eq(indices, { 1, 2 })
  table_eq(values, { 2, 4 })
end)

test("enumerate after map", function()
  local indices, values = {}, {}
  for pair in new({ "a", "b", "c" }):map(string.upper):enumerate():it() do
    local i, v = pair[1], pair[2]
    indices[#indices + 1] = i
    values[#values + 1] = v
  end
  table_eq(indices, { 1, 2, 3 })
  table_eq(values, { "A", "B", "C" })
end)

-- Iter:find()

test("find returns first matching element", function()
  eq(new({ 1, 2, 3, 4 }):find(function(x) return x > 2 end), 3)
end)

test("find returns nil when no element matches", function()
  eq(new({ 1, 2, 3 }):find(function(x) return x > 10 end), nil)
end)

test("find returns nil on empty iter", function()
  eq(new({}):find(function() return true end), nil)
end)

test("find stops at first match", function()
  local calls = 0
  new({ 1, 2, 3, 4 }):find(function(x)
    calls = calls + 1
    return x == 2
  end)
  eq(calls, 2)
end)

-- Iter:position()

test("position returns 1-based index of first match", function()
  eq(new({ 10, 20, 30 }):position(function(x) return x == 20 end), 2)
end)

test("position returns 1 when first element matches", function()
  eq(new({ 5, 10, 15 }):position(function(x) return x == 5 end), 1)
end)

test("position returns nil when no element matches", function()
  eq(new({ 1, 2, 3 }):position(function(x) return x > 10 end), nil)
end)

test("position returns nil on empty iter", function()
  eq(new({}):position(function() return true end), nil)
end)

-- Iter:enumerate2()

test("enumerate2 yields 1-based index and value as separate returns", function()
  local indices, values = {}, {}
  for i, v in new({ "a", "b", "c" }):enumerate2():it() do
    indices[#indices + 1] = i
    values[#values + 1] = v
  end
  table_eq(indices, { 1, 2, 3 })
  table_eq(values, { "a", "b", "c" })
end)

test("enumerate2 on empty yields nothing", function()
  local count = 0
  for _ in new({}):enumerate2():it() do count = count + 1 end
  eq(count, 0)
end)

test("enumerate2 after filter re-indexes from 1", function()
  local indices = {}
  for i in new({ 1, 2, 3, 4 }):filter(function(x) return x % 2 == 0 end):enumerate2():it() do
    indices[#indices + 1] = i
  end
  table_eq(indices, { 1, 2 })
end)

-- Iter:skip()

test("skip omits the first N elements", function()
  table_eq(new({ 1, 2, 3, 4, 5 }):skip(2):collect(), { 3, 4, 5 })
end)

test("skip(0) returns all elements unchanged", function()
  table_eq(new({ 1, 2, 3 }):skip(0):collect(), { 1, 2, 3 })
end)

test("skip more than length returns nothing", function()
  table_eq(new({ 1, 2, 3 }):skip(10):collect(), {})
end)

test("skip on empty returns nothing", function()
  table_eq(new({}):skip(2):collect(), {})
end)

test("skip applies only once across multiple next() calls", function()
  local it = new({ 1, 2, 3, 4 }):skip(2)
  eq(it:next(), 3)
  eq(it:next(), 4)
  eq(it:next(), nil)
end)

test("skip chains with map", function()
  table_eq(new({ 1, 2, 3, 4 }):skip(1):map(function(x) return x * 10 end):collect(), { 20, 30, 40 })
end)

t.finish()
