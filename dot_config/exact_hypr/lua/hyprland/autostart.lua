local programs = require("lua.hyprland.programs")

-- Only add programs here if they don't have systemd user services.
local autostart = {
  programs.telegram,
  "hyprpaper",
  "hyprpaper-random",
  "gammastep -vvv -t 6500:3500 -l 48.6912399:10.1298479",
}

return function()
  for _, app in ipairs(autostart) do
    hl.exec_cmd(string.format("%s %s", programs.launcher, app))
  end
end
