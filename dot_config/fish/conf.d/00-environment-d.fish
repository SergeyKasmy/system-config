# Bridge: import ~/.config/environment.d/*.conf into the shell.
#
# On the desktop, systemd --user + uwsm already process environment.d and the
# shell inherits it, so the sentinel ENVD_APPLIED is present and we bail out.
# On servers, sshd/PAM spawns the login shell directly, bypassing the systemd
# --user manager, so the sentinel is absent and we parse the files ourselves.

# Layer already applied (inherited) — nothing to do.
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
    while read -l line
        # skip blank lines and comments
        string match -qr '^\s*(#|$)' -- $line; and continue
        set -l kv (string split -m1 = -- $line)
        set -q kv[2]; or continue
        set -l key (string trim -- $kv[1])
        set -l val (__envd_expand (string trim -- $kv[2]))
        if test $key = PATH
            # fish_add_path dedups and prepends; skip empty fields (a trailing
            # ':' or empty entry would inject '.' into PATH).
            for d in (string split : -- $val)
                test -n "$d"; and fish_add_path -gp $d
            end
        else
            # fill only gaps; never clobber something already set
            set -q $key; or set -gx $key $val
        end
    end < $f
end

functions -e __envd_expand
