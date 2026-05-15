local monitors = require("lua.hyprland.monitors")

os.execute("pkill -f 'waybar.*fullscreen-config' || true")
local waybar_fs_running = false

local function monitor_has_fullscreen(names)
  for _, name in ipairs(names) do
    local monitor = hl.get_monitor(name)
    if monitor ~= nil then
      local ws = monitor.active_workspace
      return ws ~= nil and ws.has_fullscreen
    end
  end

  return false
end

local function update_waybar_fullscreen()
  local main_fs   = monitor_has_fullscreen(monitors.main_monitor.names)
  local second_fs = monitor_has_fullscreen(monitors.second_monitor.names)

  if main_fs and not second_fs and not waybar_fs_running then
    hl.exec_cmd("waybar --config ~/.config/waybar/fullscreen-config.jsonc")
    waybar_fs_running = true
  elseif not main_fs and waybar_fs_running then
    os.execute("pkill -f 'waybar.*fullscreen-config'")
    waybar_fs_running = false
  end
end

hl.on("window.fullscreen", update_waybar_fullscreen)
hl.on("workspace.active", update_waybar_fullscreen)
hl.on("window.move_to_workspace", update_waybar_fullscreen)
hl.on("config.reloaded", update_waybar_fullscreen)
hl.on("workspace.move_to_monitor", update_waybar_fullscreen)
