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

local function make_config_proxy(path, depth)
  depth = depth or 0
  local proxy = {}
  setmetatable(proxy, {
    __newindex = function(_, key, value)
      local result = { [key] = value }
      for i = depth, 1, -1 do
        result = { [path[i]] = result }
      end
      hl.config(result)
    end,
    __index = function(_, key)
      local child_depth = depth + 1
      local child_path = {}
      for i = 1, depth do
        child_path[i] = path[i]
      end
      child_path[child_depth] = key
      return make_config_proxy(child_path, child_depth)
    end,
    __call = function(_)
      return hl.get_config(table.concat(path, ".", 1, depth))
    end,
  })
  return proxy
end

Config = make_config_proxy({}, 0)
