# Bridge: import ~/.config/environment.d/*.conf into the shell.
#
# On the desktop, systemd --user + uwsm already process environment.d and the
# shell inherits it, so the sentinel ENVD_APPLIED is present and we bail out.
# On servers, sshd/PAM spawns the login shell directly, bypassing the systemd
# --user manager, so the sentinel is absent and we parse the files ourselves.

# Layer already applied (inherited) - nothing to do.
set -q ENVD_APPLIED; and return

# Expand ${VAR} / $VAR references against the current environment.
# Undefined references expand to empty, matching systemd's behavior.
function __envd_expand --argument-names val
    while set -l m (string match -r '\$\{?(\w+)\}?' -- $val)
        set -l repl ""
        set -q $m[2]; and set repl (string join : -- $$m[2])
        set val (string replace -- $m[1] $repl $val)
    end
    printf '%s' $val
end

for f in $HOME/.config/environment.d/*.conf
    test -r $f; or continue
    set -l key q val
    while read -l line
        # Parse KEY=VALUE. Blank lines and comments don't match.
        # Regex:
        # ^\s*          leading indentation, if any
        # (?<key>\w+)   the variable name
        # \s*=\s*       the separator, padding allowed on either side
        # (?<q>["']?)   opening quote if present; captured so we can match it below
        # (?<val>.*?)   the value, lazy so it stops at the first closing-quote spot
        # \k<q>         that same quote again
        # \s*$          trailing whitespace to end of line
        string match -qr '^\s*(?<key>\w+)\s*=\s*(?<q>["\']?)(?<val>.*?)\k<q>\s*$' -- $line; or continue
        set val (__envd_expand $val)
        # NOTE: Special-case PATH because PATH is always set and we skip set variables (+ we dedup PATH to avoid it growing in nested shells)
        if test $key = PATH
            # NOTE: Don't use `fish_add_path`. It stores entries in the global `fish_user_paths`, which fish hoists to the front of PATH.
            # Fed the trailing ":$PATH" from the .conf, it would promote /usr/bin &co. above earlier entries like `~/.pixi/bin`
            set -l merged
            for d in (string split : -- $val)
                test -n "$d"; or continue # empty field would inject '.' into PATH
                contains -- $d $merged; and continue # dedup, keep first seen
                set -a merged $d
            end
            set -gx PATH $merged
        else
            # fill only gaps; never clobber something already set
            set -q $key; or set -gx $key $val
        end
    end <$f
end

functions -e __envd_expand
