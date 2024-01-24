if not contains "$HOME/.local/bin" $PATH
	set -gx PATH "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/.local/share/flatpak/exports/bin" "/var/lib/flatpak/exports/bin" "$PATH"
end

# set -l XDG_DATA_HOME $XDG_DATA_HOME ~/.local/share
# set -gx --path XDG_DATA_DIRS $XDG_DATA_HOME/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share
# 
# for flatpakdir in ~/.local/share/flatpak/exports/bin /var/lib/flatpak/exports/bin
#     if test -d $flatpakdir
#         contains $flatpakdir $PATH; or set -a PATH $flatpakdir
#     end
# end

set -gx --path XDG_DATA_DIRS '/home/ciren/.local/share/flatpak/exports/share' $XDG_DATA_DIRS


#set -gx XDG_CURRENT_DESKTOP KDE
set -gx QT_QPA_PLATFORMTHEME qt5ct
set -gx GTK_USE_PORTAL 1

#set -gx (gnome-keyring-daemon --start | string split "=")

if status is-login
	set tty (tty)
	if [ -z $DISPLAY ]; and [ $tty = /dev/tty1 ]
		gui
	end
end

if status is-interactive
	# disable the greeting
	set fish_greeting

	# util
	function is_defined
		type $argv[1] &>/dev/null
	end

	function alias_if_defined
		is_defined $argv[2] && alias $argv[1] $argv[2]
	end


	# replace shell with zellij if this session is run through ssh
	if [ -n "$SSH_CLIENT" ] && is_defined zellij && [ -z "$ZELLIJ" ]
		exec zellij attach --create
	end

	

	## Variables
	
	# set global vars
	#
	set -gx GPG_TTY (tty)
	set -gx EDITOR nvim
	set -gx AUR_PAGER nvim

	if [ -e "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh" ]
		set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh"
	end

	## Aliases and functions
	
	# config edit aliases
	#
	alias cfg-fish		'chezmoi edit -av ~/.config/fish/'
	alias cfg-nvim		'chezmoi edit -av ~/.config/nvim/'
	alias cfg-sway		'chezmoi edit -av ~/.config/sway/config'
	alias cfg-tmux		'chezmoi edit -av ~/.config/tmux/tmux.conf'
	alias cfg-waybar	'chezmoi edit -av ~/.config/waybar/'
	
	# command shortcuts
	#


	# chezmoi should always be defined because the config wouldn't exist without it
	alias ch 'chezmoi'
	alias ch-git 'chezmoi git --'
	alias ch-cd 'cd (chezmoi source-path)'
	is_defined systemctl	&& alias systemctlu 'systemctl --user'
	is_defined df			&& alias dff "df -h 2>/dev/null | head -n1 && df -h 2>/dev/null | grep '^/dev/' | sort"
	is_defined curl			&& alias whatsmyip 'curl ipinfo.io/ip'
	
	is_defined gio && alias tp 'gio trash'

	if is_defined tar
		function tarz
			set cpus (cat /proc/cpuinfo | grep processor | wc -l)
			tar -I "zstd -T$cpus" $argv
		end
	end

	if is_defined udisksctl
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
	end

	if is_defined rsync
		function mvrs
			rsync -ah --info=progress,misc,stats --remove-source-files "$argv[1]" "$argv[2]"
			if type fd >/dev/null 2>&1
				fd . $argv[1] -Hte -x rmdir -p
			else
				find $argv[1] -empty -x rmdir -p /;
			end
		end
	end

	alias_if_defined bench 'hyperfine'
	is_defined zellij && alias z 'zellij attach --create'

	if is_defined paru
		alias y 'paru'
	else if is_defined pacman
		alias y 'sudo pacman'
	else if is_defined nala
		alias y 'sudo nala'
	else if is_defined apt
		alias y 'sudo apt'
	end

	if is_defined topgrade
		alias yy 'topgrade'
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
	end

	## ls
	# 
	##   -A, --almost-all           do not list implied . and ..
	##   -l                         use a long listing format
	##   -F, --classify             append indicator (one of */=>@|) to entries
	##   -h, --human-readable       with -l and/or -s, print human readable sizes
	##   -C                         list entries by columns
	alias_if_defined ls 'lsd'
	alias la 'ls -A'
	alias ll 'ls -l'
	alias lla 'ls -Al'
	alias ls_ '/bin/ls'

	if is_defined jump
		jump shell fish | source
	end
	

	# overrides
	#
	
	# dissalow nested ranger instances
	if is_defined ranger
		function ranger
			if [ -z "$RANGER_LEVEL" ]
				/usr/bin/ranger "$argv"	
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

	# always create parent dirs
	alias_if_defined mkdir 'mkdir -p'
	
	# colored ip
	alias_if_defined ip 'ip -c'

	# virsh - connect to qemu:///system by default
	if is_defined virsh
		alias virsh 'virsh --connect qemu:///system'
		alias virsh_ /bin/virsh

		if [ -e /etc/libvirt/qemu/win.xml ]
			alias winvm 'virsh start win; virtview win || start virt-manager'
		end

		if [ -e /etc/libvirt/qemu/win-passthrough.xml ]
			alias winp 'virsh start win-passthrough'
		end
	end

	if is_defined virt-viewer
		function virtview
			start virt-viewer -c qemu:///system --attach -- $argv[1]; exit
		end
	end

	if is_defined nvim
		alias v 'nvim'

		function voil
			nvim oil://$argv[1]
		end

		if is_defined tree
			function cmp-tree
				nvim -d (tree $argv[1] | psub) (tree $argv[2] | psub)
			end
		end

		if is_defined xxd
			function cmp-hex
				nvim -d (xxd $argv[1] | psub) (xxd $argv[2] | psub)
			end
		end
	else if is_defined vim
		alias v vim
	else if is_defined vi
		alias v vi
	end

	# functions
	#
	
	if is_defined pacman
		if is_defined pactree
			# what packages depend on $pkg
			function whoneeds
				set -l pkg $argv[1]
				echo "Packages that depend on [$pkg]"
				comm -12 (pactree -ru $pkg | sort | psub) (pacman -Qqe | sort | psub) | grep -v '^$pkg$' | sed 's/^/  /'
			end
		end

		# download a package from AUR
		if ! is_defined aur && is_defined git && is_defined makepkg
			function aur
				if set -q argv[1]
					git clone https://aur.archlinux.org/$argv[1].git
					cd $argv[1]
					makepkg -si
				else; false; end
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
		source $HOME/.config/fish/autoexec.fish
	end
end

