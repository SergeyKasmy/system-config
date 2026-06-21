local Option = require("lua.lib.option")
local t = require("tests.common")

local test, eq, errors = t.test, t.eq, t.errors

-- Option.new

test("new with value returns some", function()
  eq(Option.new(42):is_some(), true)
end)

test("new with nil returns none", function()
  eq(Option.new(nil):is_none(), true)
end)

test("new with false is some (false is a valid value)", function()
  eq(Option.new(false):is_some(), true)
end)

-- Option.some

test("some wraps a value", function()
  eq(Option.some(99):is_some(), true)
end)

test("some with nil errors", function()
  errors(function() Option.some(nil) end)
end)

-- Option.none

test("none returns a none", function()
  eq(Option.none():is_none(), true)
end)

test("none is a singleton", function()
  eq(Option.none(), Option.none())
end)

-- Option.then_some

test("then_some with true condition returns some", function()
  eq(Option.then_some(true, "x"):is_some(), true)
  eq(Option.then_some(true, "x"):unwrap(), "x")
end)

test("then_some with false condition returns none", function()
  eq(Option.then_some(false, "x"):is_none(), true)
end)

test("then_some with nil condition returns none", function()
  eq(Option.then_some(nil, "x"):is_none(), true)
end)

-- Option.then_some_with

test("then_some_with with true calls f and returns some", function()
  local called = false
  local result = Option.then_some_with(true, function()
    called = true
    return 7
  end)
  eq(called, true)
  eq(result:unwrap(), 7)
end)

test("then_some_with with false does not call f and returns none", function()
  local called = false
  local result = Option.then_some_with(false, function()
    called = true
    return 7
  end)
  eq(called, false)
  eq(result:is_none(), true)
end)

test("then_some_with with nil condition returns none", function()
  eq(Option.then_some_with(nil, function() return 1 end):is_none(), true)
end)

-- is_some / is_none

test("is_some returns false for none", function()
  eq(Option.none():is_some(), false)
end)

test("is_none returns false for some", function()
  eq(Option.some(1):is_none(), false)
end)

-- Option:map

test("map transforms value when some", function()
  eq(Option.some(3):map(function(x) return x * 2 end):unwrap(), 6)
end)

test("map returns none when none", function()
  eq(Option.none():map(function(x) return x end):is_none(), true)
end)

test("map returning nil acts as filter_map and yields none", function()
  eq(Option.some(5):map(function(_) return nil end):is_none(), true)
end)

-- Option:map_or

test("map_or applies f when some", function()
  eq(Option.some(10):map_or(0, function(x) return x + 1 end), 11)
end)

test("map_or returns default when none", function()
  eq(Option.none():map_or(42, function(x) return x end), 42)
end)

-- Option:map_or_else

test("map_or_else applies f when some", function()
  eq(Option.some(5):map_or_else(function() return 0 end, function(x) return x * 3 end), 15)
end)

test("map_or_else calls default_fn when none", function()
  local called = false
  local result = Option.none():map_or_else(function()
    called = true
    return 99
  end, function(x) return x end)
  eq(called, true)
  eq(result, 99)
end)

-- Option:and_then

test("and_then chains into some", function()
  eq(Option.some(3):and_then(function(x) return Option.some(x * 2) end):unwrap(), 6)
end)

test("and_then returns none when none", function()
  eq(Option.none():and_then(function(x) return Option.some(x) end):is_none(), true)
end)

test("and_then returns none when f returns none", function()
  eq(Option.some(1):and_then(function(_) return Option.none() end):is_none(), true)
end)

test("and_then chains multiple steps", function()
  local result = Option.some(2)
    :and_then(function(x) return Option.some(x + 1) end)
    :and_then(function(x) return Option.some(x * 10) end)
  eq(result:unwrap(), 30)
end)

-- Option:unwrap

test("unwrap returns inner value when some", function()
  eq(Option.some("hello"):unwrap(), "hello")
end)

test("unwrap errors when none", function()
  errors(function() Option.none():unwrap() end)
end)

-- Option:expect

test("expect returns inner value when some", function()
  eq(Option.some(7):expect("should not fail"), 7)
end)

test("expect errors with message when none", function()
  local ok, err = pcall(function() Option.none():expect("custom message") end)
  eq(ok, false)
  eq(tostring(err):find("custom message") ~= nil, true)
end)

-- Option:unwrap_or

test("unwrap_or returns inner value when some", function()
  eq(Option.some(3):unwrap_or(99), 3)
end)

test("unwrap_or returns fallback when none", function()
  eq(Option.none():unwrap_or(99), 99)
end)

test("unwrap_or returns false when inner is false", function()
  eq(Option.some(false):unwrap_or(99), false)
end)

-- Option:unwrap_or_else

test("unwrap_or_else returns inner value when some", function()
  eq(Option.some(3):unwrap_or_else(function() return 99 end), 3)
end)

test("unwrap_or_else returns false when inner is false", function()
  eq(Option.some(false):unwrap_or_else(function() return 99 end), false)
end)

test("unwrap_or_else calls f and returns result when none", function()
  local called = false
  local result = Option.none():unwrap_or_else(function()
    called = true
    return 55
  end)
  eq(called, true)
  eq(result, 55)
end)

t.finish()
