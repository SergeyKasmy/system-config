if not contains "$HOME/.local/bin" $PATH
	set -gx PATH "$HOME/.local/bin" $PATH
end

set -gx EDITOR nvim

set -gx XDG_CURRENT_DESKTOP KDE
set -gx QT_QPA_PLATFORMTHEME qt5ct
set -gx GTK_USE_PORTAL 1

set -gx SSH_AUTH_SOCK "/run/user/"(id -u)"/ssh-agent.socket"



if status is-login
	if test -z "$DISPLAY" -a $XDG_VTNR = 1
		exec startx -- -keeptty >/dev/null 2>&1
	end
end

if status is-interactive
	
	# disable the greeting
	set fish_greeting
	

	## Variables
	
	# set global vars
	#
	set -gx GPG_TTY (tty)
	

	## Aliases and functions
	
	# config edit aliases
	#
	alias cfg-i3 '$EDITOR ~/.config/i3/config'
	alias cfg-fish '$EDITOR ~/.config/fish/config.fish'
	alias cfg-polybar '$EDITOR ~/.config/polybar/config'
	alias cfg-nvim '$EDITOR ~/.config/nvim/init.vim'
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
	
	## ls
	# 
	##   -A, --almost-all           do not list implied . and ..
	##   -l                         use a long listing format
	##   -F, --classify             append indicator (one of */=>@|) to entries
	##   -h, --human-readable       with -l and/or -s, print human readable sizes
	##   -C                         list entries by columns
	#alias l 'ls -CF'
	#alias la 'ls -A'
	#alias lla 'ls -AlFh'
	alias ls 'lsd'
	alias la 'ls -A'
	alias ll 'ls -l'
	alias lla 'ls -Al'
	alias ls_ '/bin/ls'
	
	begin
		set -g pkgman
		begin
			set -l package_managers yay pacman apt
			for pkgman in $package_managers
				if which $pkgman >/dev/null 2>&1
					break
				end
			end
		end
	
		function y -w $pkgman
			eval $pkgman $argv
		end
	end
	
	alias reboot-windows "sudo efibootmgr --bootnext (efibootmgr | grep Windows | tail -n1 | cut -d' ' -f1 | cut -d't' -f2) && syscontrol reboot"

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
	end

	if type virt-viewer >/dev/null 2>&1
		function virtview
			start virt-viewer -c qemu:///system --attach -- $argv[1]; exit
		end
	end

	if type nvim >/dev/null 2>&1
		alias vim nvim
	end

	# restart aliases
	#
	if type plasmashell >/dev/null 2>&1
		alias plasma-restart 'killall plasmashell; start plasmashell'
	end

	if type compton >/dev/null 2>&1
		alias compton-restart 'killall -USR1 compton'
	end
	
	# functions
	#
	
	if type pacman >/dev/null 2>&1
		
		# what packages depend on $pkg
		function whoneeds
			set -l pkg $argv[1]
			echo "Packages that depend on [$pkg]"
			comm -12 (pactree -ru $pkg | sort | psub) (pacman -Qqe | sort | psub) | grep -v '^$pkg$' | sed 's/^/  /'
		end

		# download a package from AUR
		function aur
			if set -q argv[1]
				git clone https://aur.archlinux.org/$argv[1].git
				cd $argv[1]
				makepkg -si
			else; false; end
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
