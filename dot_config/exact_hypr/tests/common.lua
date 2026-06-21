local M = {}

local passed, failed = 0, 0

function M.test(name, fn)
  local ok, err = pcall(fn)
  if ok then
    io.write("  PASS " .. name .. "\n")
    passed = passed + 1
  else
    io.write("  FAIL " .. name .. ": " .. tostring(err) .. "\n")
    failed = failed + 1
  end
end

function M.eq(a, b)
  if a ~= b then
    error(string.format("expected %s, got %s", tostring(b), tostring(a)), 2)
  end
end

function M.errors(fn)
  local ok = pcall(fn)
  if ok then error("expected an error but none was raised", 2) end
end

function M.finish()
  io.write(string.format("\n%d passed, %d failed\n", passed, failed))
  if failed > 0 then os.exit(1) end
end

return M
