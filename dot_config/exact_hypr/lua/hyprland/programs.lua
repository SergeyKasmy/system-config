---@return { bin: string, description: string }
local function app(bin, description)
  return {
    bin = bin,
    description = description,
  }
end

return {
  launcher = "uwsm-app --",

  terminal = app("alacritty", "Terminal"),
  bar = "waybar",

  bluetooth_config = app("alacritty -e bluetui", "Bluetooth"),
  browser = app("firefox", "Browser"),
  calculator = app("speedcrunch", "Calculator"),
  discord = app("com.discordapp.Discord", "Discord"),
  file_manager = app("alacritty -e yazi", "File Manager"),
  file_manager_alt = app("dolphin", "File Manager (alt)"),
  lutris = app("net.lutris.Lutris", "Lutris"),
  menu = app('rofi -show combi -run-command "uwsm-app -- {cmd}"', "Launcher"),
  notification_center = app("swaync-client --toggle-panel", "Notification Center"),
  notification_center_dismiss = app("swaync-client --close-latest"),
  service_manager = app("alacritty -e ducker", "Service Manager"),
  sysmon = app("alacritty -e btop", "System Monitor"),
  telegram = app("flatpak run org.telegram.desktop", "Telegram"),
  volume_control = app("pavucontrol-qt", "Volume"),
}
