# disable lsp lints
# "use functions instead of aliases": I prefer aliases
# "local function unused": a false positive
set -gx fish_lsp_diagnostic_disable_error_codes 2002 4004

if not contains "$HOME/.local/bin" $PATH
    set -gx PATH \
        "$HOME/.cargo/bin" \
        "$HOME/.deno/bin" \
        "$HOME/.local/bin" \
        "$HOME/.local/share/flatpak/exports/bin" \
        /var/lib/flatpak/exports/bin \
        "$PATH"
end
systemctl --user import-environment PATH

# set -l XDG_DATA_HOME $XDG_DATA_HOME ~/.local/share
# set -gx --path XDG_DATA_DIRS $XDG_DATA_HOME/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share
# 
# for flatpakdir in ~/.local/share/flatpak/exports/bin /var/lib/flatpak/exports/bin
#     if test -d $flatpakdir
#         contains $flatpakdir $PATH; or set -a PATH $flatpakdir
#     end
# end

if not contains "$HOME/.local/share/flatpak/exports/share" $XDG_DATA_DIRS
    set -gx --path XDG_DATA_DIRS "$HOME/.local/share/flatpak/exports/share" $XDG_DATA_DIRS
end

set -gx QT_QPA_PLATFORMTHEME qt5ct:qt6ct
set -gx QT_WAYLAND_DISABLE_WINDOWDECORATION 1
set -gx GTK_USE_PORTAL 1
set -gx GNUPGHOME "~/.config/gpg"

#set -gx (gnome-keyring-daemon --start | string split "=")

# set up android tools

if not contains "$HOME/.local/opt/android/cmdline-tools/latest/bin/" $PATH
    set -gx PATH "$HOME/.local/opt/android/cmdline-tools/latest/bin/" "$PATH"
    set -gx ANDROID_HOME "$HOME/.local/opt/android"
    set -gx ANDROID_NDK_HOME "$HOME/.local/opt/android/ndk-bundle"
end

if status is-interactive
    # disable the greeting
    set fish_greeting

    # util
    function is_defined
        type -q $argv[1]
    end

    function alias_if_defined
        set alias $argv[1]
        set target $argv[2]

        # get the first part of the target cmd, before the first space if any
        set basename (echo -- $target | string split ' ')[1]

        # if this binary exists
        if is_defined $basename
            alias $alias $target
        end
    end

    ## Variables

    # set global vars
    #
    set -gx GPG_TTY (tty)
    set -gx EDITOR hx
    set -gx AUR_PAGER nvim

    if [ -e "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh" ]
        set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh"
    end

    ## Aliases and functions

    # config edit aliases
    #
    alias cfg-fish 'chezmoi edit -av ~/.config/fish/'
    alias cfg-helix 'chezmoi edit -av ~/.config/helix/'
    alias cfg-nvim 'chezmoi edit -av ~/.config/nvim/'
    alias cfg-sway 'chezmoi edit -av ~/.config/sway/config'
    alias cfg-tmux 'chezmoi edit -av ~/.config/tmux/tmux.conf'
    alias cfg-waybar 'chezmoi edit -av ~/.config/waybar/'

    # command shortcuts
    #

    alias chcd 'cd (chezmoi source-path)'
    alias ch chezmoi
    alias che 'chezmoi edit -av'
    alias chgit 'chezmoi git --'

    alias dff "df -h 2>/dev/null | head -n1 && df -h 2>/dev/null | grep '^/dev/' | sort"
    alias systemctlu 'systemctl --user'
    alias tp 'gio trash'
    alias whatsmyip 'curl ipinfo.io/ip'

    function bins
        pacman -Ql $argv[1] | grep /usr/bin/
    end

    alias dua-root 'dua -i /home/.snapshots i (fd . --exclude '/mnt' --exclude '/tmp' --max-depth=1 --type=directory /)'
    alias dua-home 'dua -i /home/.snapshots i /home/ciren'
    function dua-raid
        if test -d /mnt/raid
            dua i /mnt/raid
        else
            echo "/mnt/raid not found"
        end
    end

    function tarz
        set cpus (cat /proc/cpuinfo | grep processor | wc -l)
        tar -I "zstd -T$cpus" $argv
    end

    function mountusr
        udisksctl mount -b $argv[1]
    end

    function umountusr
        udisksctl unmount -b $argv[1]
    end

    function mountusr-loop
        mountusr (udisksctl loop-setup -f $argv[1] | sed -E 's:.*(/dev/loop[0-9]+).*:\1:')
    end

    function umountusr-loop
        umountusr /dev/$argv[1]
        udisksctl loop-delete -b "/dev/"$argv[1]
    end

    function mvrs
        rsync -ah --info=progress,misc,stats --remove-source-files "$argv[1]" "$argv[2]"
        if is_defined fd
            fd . $argv[1] -Hte -x rmdir -p
        else
            find $argv[1] -empty -x rmdir -p ";"
        end
    end

    alias bench hyperfine
    alias zj zellij

    if is_defined paru
        alias y paru
    else if is_defined pacman
        alias y 'sudo pacman'
    else if is_defined nala
        alias y 'sudo nala'
    else if is_defined apt
        alias y 'sudo apt'
    else if is_defined zypper
        alias y 'sudo zypper'
    else
        alias y 'echo Can\'t find any of the supported package managers: paru, pacman, nala, apt, zypper'
    end

    if is_defined topgrade
        alias yy topgrade
    else if is_defined paru
        alias yy 'paru -Syu'
    else if is_defined pacman
        alias yy 'sudo pacman -Syu'
    else if is_defined nala
        alias yy 'sudo nala upgrade'
    else if is_defined apt
        alias yy 'sudo apt update && sudo apt dist-upgrade'
    else if is_defined zypper
        alias yy 'sudo zypper update && sudo zypper dist-upgrade'
    else
        alias yy 'echo Can\'t find any of the supported system update tools: topgrade, paru, pacman, nala, apt, zypper'
    end

    ## ls
    # 
    ##   -A, --almost-all           do not list implied . and ..
    ##   -l                         use a long listing format
    ##   -F, --classify             append indicator (one of */=>@|) to entries
    ##   -h, --human-readable       with -l and/or -s, print human readable sizes
    ##   -C                         list entries by columns
    alias_if_defined ls lsd
    alias la 'ls -A'
    alias ll 'ls -l'
    alias lla 'ls -Al'

    if is_defined jump
        jump shell fish | source
    end

    # overrides
    #

    # dissalow nested ranger instances
    if is_defined yazi
        alias ranger yazi
    else if is_defined joshuto
        alias ranger joshuto
    else if is_defined ranger
        function ranger
            if [ -z "$RANGER_LEVEL" ]
                command ranger "$argv"
            else
                exit
            end
        end
    end

    # use .config/tmux.conf as the tmux config
    alias_if_defined tmux "tmux -f $HOME/.config/tmux/tmux.conf"

    # use bat instead of cat
    alias_if_defined cat 'bat -pp'

    # custom lsblk colums
    alias_if_defined lsblk 'lsblk -o NAME,FSTYPE,SIZE,RM,RO,MOUNTPOINT,LABEL,PARTLABEL,UUID'
    alias_if_defined lsblk-watch 'watch "lsblk -o NAME,FSTYPE,SIZE,RM,RO,MOUNTPOINT,LABEL,PARTLABEL,UUID"'

    # always create parent dirs
    alias_if_defined mkdir 'mkdir -p'

    # colored ip
    alias_if_defined ip 'ip -c'

    # virsh - connect to qemu:///system by default
    if is_defined virsh
        alias virsh 'virsh --connect qemu:///system'

        if [ -e /etc/libvirt/qemu/win.xml ]
            alias winvm 'virsh start win; virtview win || start virt-manager'
        end

        if [ -e /etc/libvirt/qemu/win-passthrough.xml ]
            alias winp 'virsh start win-passthrough'
        end
    end

    function virtview
        if is_defined virt-viewer
            start virt-viewer -c qemu:///system --attach -- $argv[1]
            exit
        else
            echo "virt-viewer not installed"
        end
    end

    if is_defined nvim
        alias v nvim

        function voil
            nvim oil://$argv[1]
        end

        if is_defined tree
            function cmp-tree
                nvim -d (tree $argv[1] | psub) (tree $argv[2] | psub)
            end

            function cmp-tree-all
                nvim -d (tree -a $argv[1] | psub) (tree -a $argv[2] | psub)
            end
        end

        if is_defined xxd
            function cmp-hex
                nvim -d (xxd $argv[1] | psub) (xxd $argv[2] | psub)
            end
        end
    else if is_defined vim
        alias v vim
    else
        alias v vi
    end

    # edit files in PATH (vim path)
    if is_defined v
        function vp
            v (which $argv[1])
        end
    end

    # functions
    #

    if is_defined pacman
        if is_defined pactree
            # what packages depend on $pkg
            function whoneeds
                set -l pkg $argv[1]
                echo "Packages that depend on [$pkg]"
                # not actually a variable
                # @fish-lsp-disable-next-line 2001
                comm -12 (pactree -ru $pkg | sort | psub) (pacman -Qqe | sort | psub) | grep -v '^$pkg$' | sed 's/^/  /'
            end
        end

        # download a package from AUR
        if not is_defined aur
            if not is_defined git
                alias aur 'echo git is not installed'
            else if not is_defined makepkg
                alias aur 'makepkg is not installed'
            else
                function aur
                    if set -q argv[1]
                        git clone https://aur.archlinux.org/$argv[1].git
                        cd $argv[1]
                        makepkg -si
                    else
                        false
                    end
                end
            end
        end
    end

    if id -u island >/dev/null 2>&1
        alias island 'sudo -iu island --preserve-env=DISPLAY'
        alias stisland 'start sudo -iu island --preserve-env=DISPLAY'
    end

    #if command -s tmux >/dev/null 2>&1; and not string match "*screen*" $TERM >/dev/null 2>&1; and not set -q TMUX
    #	exec tmux -f $HOME/.config/tmux/tmux.conf new-session
    #end

    if [ -e $HOME/.config/fish/autoexec.fish ]
        # disable "file doesn't exist error" (I mean, I just checked if it exists...)
        # @fish-lsp-disable-next-line 1004
        source $HOME/.config/fish/autoexec.fish
    end

    zoxide init --cmd cd fish | source
end
