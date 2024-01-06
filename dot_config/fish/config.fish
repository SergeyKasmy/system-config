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

	if type jump &>/dev/null
		jump shell fish | source
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
	alias cfg-sway '$EDITOR ~/.config/sway/config'
	alias cfg-i3 '$EDITOR ~/.config/i3/config'
	alias cfg-fish '$EDITOR ~/.config/fish/config.fish'
	alias cfg-polybar '$EDITOR ~/.config/polybar/config'
	alias cfg-nvim '$EDITOR ~/.config/nvim/init.lua'
	alias cfg-tmux '$EDITOR ~/.config/tmux/tmux.conf'
	
	# command shortcuts
	#
	alias systemctlu 'systemctl --user'
	alias whatsmyip 'curl ipinfo.io/ip'
	
	if type gio >/dev/null 2>&1
		alias tp 'gio trash'
	end

	if type tar >/dev/null 2>&1
		function tarz
			set cpus (cat /proc/cpuinfo | grep processor | wc -l)
			tar -I "zstd -T$cpus" $argv
		end
	end

	if type udisksctl >/dev/null 2>&1
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

	if type chezmoi &>/dev/null
		function chezmoi-cd
			cd (chezmoi source-path)
		end
	end
	
	if type rsync &>/dev/null
		function mvrs
			rsync -ah --info=progress,misc,stats --remove-source-files "$argv[1]" "$argv[2]"
			if type fd >/dev/null 2>&1
				fd . $argv[1] -Hte -x rmdir -p
			else
				find $argv[1] -empty -x rmdir -p /;
			end
		end
	end

	if type duf &>/dev/null
		# alias dff "df -h 2>/dev/null | head -n1 && df -h 2>/dev/null | grep '^/dev/' | sort"
		# alias dff "df -h"
		alias dff duf
	end

	if type hyperfine &>/dev/null
		alias bench 'hyperfine'
	end

	# these 2 are usually exlusive
	if type paru &>/dev/null
		alias y 'paru'
	end

	if type apt &>/dev/null
		alias y 'sudo apt update && sudo apt dist-upgrade'
	end

	if type topgrade &>/dev/null
		alias yy 'topgrade'
	end

	## ls
	# 
	##   -A, --almost-all           do not list implied . and ..
	##   -l                         use a long listing format
	##   -F, --classify             append indicator (one of */=>@|) to entries
	##   -h, --human-readable       with -l and/or -s, print human readable sizes
	##   -C                         list entries by columns
	if type lsd &>/dev/null
		alias ls 'lsd'
	end
	alias la 'ls -A'
	alias ll 'ls -l'
	alias lla 'ls -Al'
	alias ls_ '/bin/ls'
	

	# overrides
	#
	
	# dissalow nested ranger instances
	if type ranger >/dev/null 2>&1
		function ranger
			if [ -z "$RANGER_LEVEL" ]
				/usr/bin/ranger "$argv"	
			else
				exit
			end
		end
	end
	
	# use .config/tmux.conf as the tmux config
	if type tmux >/dev/null 2>&1
		alias tmux "tmux -f $HOME/.config/tmux/tmux.conf"
	end

	# use bat instead of cat
	if type bat >/dev/null 2>&1
		alias cat bat
	end

	# custom lsblk colums
	if type lsblk >/dev/null 2>&1
		alias lsblk 'lsblk -o NAME,FSTYPE,SIZE,RM,RO,MOUNTPOINT,LABEL,PARTLABEL,UUID'
	end

	# always create parent dirs
	if type mkdir >/dev/null 2>&1
		alias mkdir 'mkdir -p'
	end
	
	# colored ip
	if type ip >/dev/null 2>&1
		alias ip 'ip -c'
	end

	# virsh - connect to qemu:///system by default
	if type virsh >/dev/null 2>&1
		alias virsh 'virsh --connect qemu:///system'
		alias virsh_ /bin/virsh

		if [ -e /etc/libvirt/qemu/win.xml ]
			alias winvm 'virsh start win; virtview win || start virt-manager'
		end

		if [ -e /etc/libvirt/qemu/win-passthrough.xml ]
			alias winp 'virsh start win-passthrough'
		end
	end

	if type virt-viewer >/dev/null 2>&1
		function virtview
			start virt-viewer -c qemu:///system --attach -- $argv[1]; exit
		end
	end

	if type nvim >/dev/null 2>&1
		alias v nvim

		function cmp-tree
			nvim -d (tree $argv[1] | psub) (tree $argv[2] | psub)
		end
	end

	function cmp-hex
		nvim -d (xxd $argv[1] | psub) (xxd $argv[2] | psub)
	end

	# restart aliases
	#
	if type plasmashell >/dev/null 2>&1
		alias plasma-restart 'killall plasmashell; start plasmashell'
	end

	# functions
	#
	
	if type pacman &>/dev/null
		
		# what packages depend on $pkg
		function whoneeds
			set -l pkg $argv[1]
			echo "Packages that depend on [$pkg]"
			comm -12 (pactree -ru $pkg | sort | psub) (pacman -Qqe | sort | psub) | grep -v '^$pkg$' | sed 's/^/  /'
		end

		# download a package from AUR
		if ! type aur &>/dev/null
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
end

if [ -e $HOME/.config/fish/autoexec.fish ]
	source $HOME/.config/fish/autoexec.fish
end
