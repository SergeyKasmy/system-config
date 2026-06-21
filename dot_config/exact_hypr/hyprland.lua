local config_dir = debug.getinfo(1, "S").source:match("^@(.+/)") or "./"
package.path = config_dir .. "lua/vendor/crnlib/?.lua;" .. config_dir .. "lua/vendor/crnlib/?/init.lua;" .. package.path

local log = require("lua.log")
log.config.min_log_level = "INFO"

log.spanned("monitors", function()
  local mod = require("lua.hyprland.monitors")
  mod.configure()
end)

log.spanned_require("rendering", "lua.hyprland.rendering")
log.spanned_require("binds", "lua.hyprland.binds")
log.spanned_require("permissions", "lua.hyprland.permissions")
log.spanned_require("look_and_feel", "lua.hyprland.look_and_feel")
log.spanned_require("input", "lua.hyprland.input")
log.spanned_require("window_rules", "lua.hyprland.window_rules")
log.spanned_require("events", "lua.hyprland.events")
log.spanned_require("autostart", "lua.hyprland.autostart")

-- globals - for use with `hyprctl eval`

Config = require("lua.hyprland.config_proxy")()

function LogLevel(level)
  log.config.min_log_level = level
end

local api = require("lua.hyprland.api")
Exec = api.exec
ExecApp = api.exec_app
