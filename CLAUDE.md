## Version Control

This repo uses **Jujutsu (`jj`)**, not git.

## Chezmoi Overview

This is a [chezmoi](https://chezmoi.io/) dotfiles repository. Files are prefixed according to chezmoi conventions:
- `dot_` → `.` (e.g. `dot_config/` → `~/.config/`)
- `exact_` → directory contents are managed exactly (extra files removed on apply)
- `executable_` → chezmoi makes sure the executable bit is set when copying the files to their respective directories
- `.tmpl` suffix → chezmoi Go template, processed before applying

## Hyprland Configuration

The Hyprland config (`dot_config/exact_hypr/`) uses the **Lua API** (not hyprlang). Entry point is `hyprland.lua`, which requires modules from `lua/hyprland/`.

Key conventions:
- **Never** use `hl.exec_cmd("hyprctl dispatch ...")`. Use `hl.dispatch(hl.dsp.something(...))` directly — `hyprctl dispatch` doesn't work with the Lua config.
- **Never** use `os.execute()`, use `api.exec()` instead. If the output is needed, `io.popen()` may be used but the program blocks the compositor, so it should run as little as possible
- `api.exec(cmd)` is for small scripts; `api.exec_app(app)` wraps the configured app with a launcher for GUI apps.
- Binds are in `lua/hyprland/binds.lua`.
- Window rules and Hyprland event handlers are registered in `lua/hyprland/rules.lua` as a table of named `RuleEntry` objects (each with an optional `class` matcher, `rules` window-rule spec, and `on` event callbacks),
  applied via `lua/hyprland/rules/register.lua`. Add new window rules/event handlers there rather than reintroducing separate rules/events files.
- `lua/vendor/crnlib` is a git submodule (`.gitmodules`, tracked via the colocated git repo) providing shared Lua utilities (e.g. `crnlib.table`, iterators, `Option`).
- If there's not enough information about the Hyprland Lua API or the inner workings of Hyprland itself, its source code is located at `~/dev/projects/pc/forks/Hyprland`.
- The `.luarc.json` at the hypr config root points the Lua LSP at `/usr/share/hypr/stubs` for type hints.

## Key Tools Configured

| Directory | Tool |
|-----------|------|
| `dot_config/exact_hypr/` | Hyprland WM (Lua API) + hypridle + hyprlock + hyprpaper |
| `dot_config/fish/` | Fish shell |
| `dot_config/nvim/` | Neovim (lazy.nvim) |
| `dot_config/zellij/` | Zellij terminal multiplexer (KDL config + `.tmpl` chezmoi templated layouts) |
| `dot_config/waybar/` | Waybar status bar |
| `dot_local/bin/` | Custom executable scripts (e.g. `gamewrapper` temporarily applies game-specific fixes before launching) |
| `dot_gitconfig.tmpl` | Git config with machine-type-based conditionals |


## Template Files

`.tmpl` files use Go template syntax with chezmoi variables:
- `{{ .personal.name }}` / `{{ .personal.email }}` — from `chezmoi.toml`
- `{{ .personal.machine_type }}` — machine-type branching (e.g. `dot_gitconfig.tmpl` and `dot_config/private_jj/config.toml.tmpl` check `ne .personal.machine_type "work"`)

Custom variables are defined inside the chezmoi config at `~/.config/chezmoi/chezmoi.toml` (outside this repo).
