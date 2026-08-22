# system-config
My personal dotfiles and scripts :P

## Environment Variables

- Global variables are defined in `dot_config/environment.d`
- GUI-related variables are defined in `dot_config/uwsm/env`

## Theme

Configured in just 1 single place: `./.chezmoidata/theme.yml`. All other configs use these settings via templates.

## Scripts

`.chezmoiscripts/` holds `run_onchange_` scripts that chezmoi executes on `apply` without creating anything in the home directory.
Any other directory in this repo would be cloned there, unfortunately, and `.chezmoiignore`-ing it stops its scripts from running at all,
so this reserved name is the only place such scripts can live. Sad it's so easy to miss.

`theming.sh` covers settings that no dotfile can express.
This can be because something else owns the file at runtime (like KDE configs often are),
or because the settings aren't stored in a text file (I'm looking at you, `gsettings` (Windows Registry in disguise)).

## Chezmoi `.personal` Config Fields

Defined in `~/.config/chezmoi/chezmoi.toml`, used across template files:

- `name` — full name
- `nickname` — username/account name
- `email` — email address
- `machine_type` — machine classification (e.g. "home"/"work")
