local init = require("lua.log.init")
local utils = require("lua.utils")

---@alias MinLogLevel "NO" | "ERROR" | "INFO" | "DEBUG" | "TRACE"
---@alias LogLevel "ERROR" | "INFO" | "DEBUG" | "TRACE"

local M = {
  config = {
    ---@type MinLogLevel
    min_log_level = "INFO"
  }
}

local log_file = init()
local spans = {}

---@param log_level LogLevel
---@return boolean
local function skip_log(log_level)
  local min = M.config.min_log_level

  ---@format disable
  local is_filtered_out = {
    log_level == "ERROR" and (min == "NO"),
    log_level == "INFO"  and (min == "NO" or min == "ERROR"),
    log_level == "DEBUG" and (min == "NO" or min == "ERROR" or min == "INFO"),
    log_level == "TRACE" and (min == "NO" or min == "ERROR" or min == "INFO" or min == "DEBUG"),
  }
  ---@format enable

  for _, condition in ipairs(is_filtered_out) do
    if condition then return true end
  end

  return false
end

---@param log_level LogLevel
---@param ... any
function M.log(log_level, ...)
  if skip_log(log_level) then return end

  local timestamp = os.date("%Y-%m-%d %H:%M:%S")

  local message = table.concat(utils.table.map({ ... }, function(v) return utils.to_string(v) end), " ")

  local log_message
  if #spans == 0 then
    log_message = string.format("[%s %s] %s\n", timestamp, log_level, message)
  else
    log_message = string.format("[%s %s %s] %s\n", timestamp, log_level, table.concat(spans, "::"), message)
  end

  log_file:write(log_message)
end

---@param ... any
function M.error(...)
  M.log("ERROR", ...)
end

---@param ... any
function M.info(...)
  M.log("INFO", ...)
end

---@param ... any
function M.debug(...)
  M.log("DEBUG", ...)
end

---@param ... any
function M.trace(...)
  M.log("TRACE", ...)
end

---@generic T
---@param span string
---@param fn fun(): T?
---@return T?
function M.spanned(span, fn)
  table.insert(spans, span)
  local result = fn()
  table.remove(spans)

  return result
end

---@param span string
---@param path string
function M.spanned_require(span, path)
  table.insert(spans, span)
  require(path)
  table.remove(spans)
end

return M
