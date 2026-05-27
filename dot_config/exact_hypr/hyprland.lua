local log = require("lua.log")
log.config.min_log_level = "INFO"

Monitors = log.spanned("monitors", function()
  local mod = require("lua.hyprland.monitors")
  mod.configure()
  return mod
end)

log.spanned_require("rendering", "lua.hyprland.rendering")
log.spanned_require("binds", "lua.hyprland.binds")
log.spanned_require("permissions", "lua.hyprland.permissions")
log.spanned_require("look_and_feel", "lua.hyprland.look_and_feel")
log.spanned_require("input", "lua.hyprland.input")
log.spanned_require("window_rules", "lua.hyprland.window_rules")
log.spanned_require("events", "lua.hyprland.events")
log.spanned_require("autostart", "lua.hyprland.autostart")

Config = require("lua.hyprland.config_proxy")()
