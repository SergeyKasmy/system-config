hl.config({
  general = {
    allow_tearing = true
  },

  misc = {
    vrr = 2
  },

  render = {
    direct_scanout = true
    -- cm_auto_hdr = 2,
  },
})

-- HDR (experimental — uncomment to enable)
-- hl.config({
--     experimental = { xx_color_management_v4 = true },
--     quirks       = { prefer_hdr = 1 },
-- })

-- Tearing / immediate rendering per-client

-- don't tear by default. Enable tearing only for clients manually allowed to tear
hl.window_rule({ match = { class = ".*" }, immediate = false })

local tearing_clients = {
  "gamescope",
  "cs2",              -- CS2
  "cstring_linux64",  -- CSS
  "hl_linux",         -- CS 1.6
  "momentum",         -- Momentum Mod
}

for _, client in ipairs(tearing_clients) do
  hl.window_rule({
    match = { class = client },

    immediate = true
  })
end
