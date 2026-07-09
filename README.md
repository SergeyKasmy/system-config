# system-config
My personal set of scripts to ease up setting up a new system and sync the settings between them.
Beware that the repo is still WIP, especially the readme file.

## Environment Variables

- Global variables are defined in `dot_config/environment.d`
- GUI-related variables are defined in `dot_config/uwsm/env`

## Chezmoi `.personal` Config Fields

Defined in `~/.config/chezmoi/chezmoi.toml`, used across template files:

- `name` — full name
- `nickname` — username/account name
- `email` — email address
- `machine_type` — machine classification (e.g. "home"/"work")
