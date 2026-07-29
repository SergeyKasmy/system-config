function zellij --wraps zellij
    # Use a managed scope only when a systemd user manager is actually reachable
    if systemctl --user show-environment >/dev/null 2>&1
        systemd-run --user --scope --quiet --collect \
            --slice=app.slice \
            -u "zellij-$fish_pid-$(date +%s%N)" \
            -p TimeoutStopSec=2s \
            (command -v zellij) $argv
    else
        command zellij $argv
    end
end
