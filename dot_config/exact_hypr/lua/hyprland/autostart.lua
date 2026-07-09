local api = require("lua.hyprland.api")
local programs = require("lua.hyprland.programs")
local monitors = require("lua.hyprland.monitors")

-- Only add programs here if they don't have systemd user services.
local autostart = {
  programs.telegram.bin,
}


hl.on("hyprland.start", function()
  for _, app in ipairs(autostart) do
    api.exec_app(app)
  end

  -- move the second workspace to the second monitor on startup
  local second = monitors.instances.secondary:handle()

  if second ~= nil then
    hl.dispatch(hl.dsp.workspace.move({ workspace = 2, monitor = second.name }))
  end
end
)
