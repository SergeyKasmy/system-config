# takes directory path relative to .config, or --dir argument for specific directory
# e.g.
# cfg fish -> edits ~/.config/fish
# cfg --dir=/tmp/fish -> edits /tmp/fish
function cfg
    argparse 'dir=' -- $argv
    if set -ql _flag_dir[1]
        set dir $_flag_dir[1]
    else if set -ql argv[1]
        set dir "$HOME/.config/$argv[1]"
    else
        echo 'cfg: config directory not provided' >&2
        return 1
    end

    # wrap function in new shell invokation to avoid changing current directory
    $SHELL -c "_cfg_inner $dir"
end
