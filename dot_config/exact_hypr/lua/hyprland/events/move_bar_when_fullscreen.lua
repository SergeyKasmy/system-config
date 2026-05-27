local api = require("lua.hyprland.api")
local monitors = require("lua.hyprland.monitors")

os.execute("pkill -f 'waybar.*fullscreen-config' || true")
local waybar_fs_running = false

---@param names string[]
---@return boolean
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
    api.exec("waybar --config ~/.config/waybar/fullscreen-config.jsonc")
    waybar_fs_running = true
  elseif not main_fs and waybar_fs_running then
    os.execute("pkill -f 'waybar.*fullscreen-config'")
    waybar_fs_running = false
  end
end

local events_that_change_fullscreen_state = {
  "config.reloaded",           -- hyprland started
  "window.fullscreen",         -- fullscreen a window
  "window.move_to_workspace",  -- move a fullscreen window to a different workspace
  "workspace.active",          -- switch to a workspace with a fulscreen window
  "workspace.move_to_monitor", -- move a fullscreen workspace to a different monitor
}

for _, event in ipairs(events_that_change_fullscreen_state) do
  hl.on(event, update_waybar_fullscreen)
end
