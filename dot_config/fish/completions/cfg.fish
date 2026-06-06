set -l apps alacritty hypr fish helix nvim rofi swaync tmux uwsm waybar zellij

# disable default file suggestions
complete -c cfg -f -d "Edit a chezmoi-managed config"

# suggest apps if no --dir and no apps are already specified
complete -c cfg \
    -n "not __fish_seen_subcommand_from $apps; and not __fish_contains_opt dir" \
    -a "$apps"

# suggest --dir if no apps specified
complete -c cfg \
    -n "not __fish_seen_subcommand_from $apps" \
    -l dir -r -a "(__fish_complete_directories)" -d "Specific directory"
