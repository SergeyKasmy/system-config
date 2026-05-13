local programs = require("lua.hyprland.programs")

require("lua.hyprland.monitors")
require("lua.hyprland.rendering")
require("lua.hyprland.binds")
require("lua.hyprland.permissions")
require("lua.hyprland.look_and_feel")
require("lua.hyprland.input")
require("lua.hyprland.window_rules")

hl.on("hyprland.start", require("lua.hyprland.autostart"))
