local monitors = require("lua.hyprland.monitors")
local api = require("lua.hyprland.api")

os.execute("pkill -f 'waybar.*fullscreen-config' || true")
local waybar_fs_running = false

---@param monitor Monitor
---@return boolean
local function monitor_has_fullscreen(monitor)
  local handle = monitor:handle()
  if handle == nil then return false end

  local ws = handle.active_workspace
  return ws ~= nil and ws.has_fullscreen
end

return function()
  local main_fs   = monitor_has_fullscreen(monitors.instances.main)
  local second_fs = monitor_has_fullscreen(monitors.instances.secondary)

  if main_fs and not second_fs and not waybar_fs_running then
    api.exec("waybar --config ~/.config/waybar/fullscreen-config.jsonc")
    waybar_fs_running = true
  elseif not main_fs and waybar_fs_running then
    os.execute("pkill -f 'waybar.*fullscreen-config'")
    waybar_fs_running = false
  end
end
