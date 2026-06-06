local iter = require("lua.lib.iter")
local tbl = require("lua.lib.table")
local new = iter.new

local passed, failed = 0, 0

local function test(name, fn)
  local ok, err = pcall(fn)
  if ok then
    io.write("  PASS " .. name .. "\n")
    passed = passed + 1
  else
    io.write("  FAIL " .. name .. ": " .. tostring(err) .. "\n")
    failed = failed + 1
  end
end

local function eq(a, b)
  if a ~= b then
    error(string.format("expected %s, got %s", tostring(b), tostring(a)), 2)
  end
end

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
    end
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

io.write(string.format("\n%d passed, %d failed\n", passed, failed))
if failed > 0 then os.exit(1) end
