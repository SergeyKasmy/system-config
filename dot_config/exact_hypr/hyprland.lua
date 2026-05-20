local log = require("lua.log")
log.config.min_log_level = "INFO"

log.spanned_require("monitors", "lua.hyprland.monitors")
log.spanned_require("rendering", "lua.hyprland.rendering")
log.spanned_require("binds", "lua.hyprland.binds")
log.spanned_require("permissions", "lua.hyprland.permissions")
log.spanned_require("look_and_feel", "lua.hyprland.look_and_feel")
log.spanned_require("input", "lua.hyprland.input")
log.spanned_require("window_rules", "lua.hyprland.window_rules")
log.spanned_require("events", "lua.hyprland.events")

log.spanned("autorun", function()
  hl.on("hyprland.start", require("lua.hyprland.autostart"))
end)


Config = require("lua.hyprland.config_proxy")()
