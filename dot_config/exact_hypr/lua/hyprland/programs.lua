return {
  launcher = "uwsm-app --",

  terminal = "alacritty",
  bar = "waybar",

  bluetooth_config = "alacritty -e bluetui",
  browser = "firefox",
  calculator = "speedcrunch",
  discord = "flatpak run com.discordapp.Discord",
  file_manager = "dolphin",
  menu = 'rofi -show combi -run-command "uwsm-app -- {cmd}"',
  notification_center = "swaync-client -t",
  service_manager = "alacritty -e ducker",
  sysmon = "alacritty -e btop",
  telegram = "flatpak run org.telegram.desktop",
  volume_control = "pavucontrol-qt",
}
