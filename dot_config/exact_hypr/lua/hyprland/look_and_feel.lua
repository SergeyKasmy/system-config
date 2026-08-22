hl.config({
  general = {
    gaps_in     = 3,
    gaps_out    = 5,

    -- macOS windows have no visible border, relying on shadow + dim_inactive
    -- instead (see FireDrop6000/hyprland-mydots)
    border_size = 0,

    layout      = "dwindle",
  },

  decoration = {
    rounding = 10,

    -- macOS distinguishes focus mostly via a soft diffuse shadow + a dimmed
    -- unfocused window, not a bright border (see FireDrop6000/hyprland-mydots)
    -- dim_inactive = true,
    dim_inactive = false,
    dim_strength = 0.15,

    shadow = {
      enabled      = true,
      range        = 25,
      render_power = 4,
      -- cool blue-gray tint (see FireDrop6000/hyprland-mydots: rgba(42, 52, 57, 50))
      color        = "rgba(2a343932)",
    },

    blur = {
      enabled = true,
      size    = 6,
      passes  = 2,
      popups  = true,
    },

    glow = {
      enabled = true,
      range   = 3,
    }
  },

  dwindle = {
    force_split    = 2, -- always open on the right/bottom
    preserve_split = true,
  },

  master = {
    new_status = "master",
  },

  misc = {
    middle_click_paste        = false,
    on_focus_under_fullscreen = 0,
    disable_hyprland_logo     = true,
  },

  xwayland = {
    force_zero_scaling = true,
  },

  ecosystem = {
    no_donation_nag = true,
  },
})


--------------------
---- ANIMATIONS ----
--------------------

hl.config({
  animations = {
    enabled = true
  }
})

-- Bezier curves
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
-- see FireDrop6000/hyprland-mydots
hl.curve("myBezier", { type = "bezier", points = { { 0.5, 1 }, { 0.89, 1 } } })
hl.curve("myBezier2", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })

-- Animations
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 6.7, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 5.36, bezier = "default" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.69, bezier = "myBezier2", style = "popin" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 16.75, bezier = "myBezier2", style = "slide bottom" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 4.69, bezier = "default" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.02, bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3.35, bezier = "myBezier", style = "slide" })

hl.layer_rule({
  name = "waybar",
  match = {
    namespace = "waybar"
  },

  blur = true,
  xray = false
})

hl.layer_rule({
  name = "rofi",
  match = {
    namespace = "rofi"
  },

  blur = true,
  -- xray = false
})

hl.layer_rule({
  name = "swaync",
  match = {
    namespace = "swaync.*"
  },

  blur = true,
  -- xray = false,
  ignore_alpha = 0.5,
})
