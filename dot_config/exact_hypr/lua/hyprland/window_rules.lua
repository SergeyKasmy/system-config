----------------------
---- DEFAULT RULES ---
----------------------

-- Ignore maximize requests from all apps
hl.window_rule({
  name           = "suppress-maximize-events",
  match          = { class = ".*" },

  suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
  name     = "fix-xwayland-drags",
  match    = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },

  no_focus = true,
})

---------------------
---- CUSTOM RULES ---
---------------------

-- Make all windows on workspace #10 float by default
hl.window_rule({
  name  = "workspace-10-float-by-default",
  match = { workspace = "10" },
  float = true,
})

-- Don't tile ueberzug
hl.window_rule({
  name     = "ueberzugpp",
  match    = { class = "^ueberzugpp_.*" },
  float    = true,
  no_focus = true,
})
