hl.config({
  ecosystem = {
    enforce_permissions = true,
  },
})

hl.permission({
  binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland",
  type = "screencopy",
  mode = "allow"
})

hl.permission({
  binary = "/usr/(bin|local/bin)/grim",
  type = "screencopy",
  mode = "allow"
})
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")
