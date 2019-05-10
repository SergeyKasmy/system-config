if status is-interactive
	
	# disable the greeting
	set fish_greeting
	
	
	## Variables
	
	# set global vars
	#
	set -gx PATH $PATH ~/.local/bin /opt/android-sdk/platform-tools
	set -gx EDITOR vim
	set -g GPG_TTY (tty)
	
	## Aliases and functions
	
	# config edit aliases
	#
	alias edit-i3-cfg 'vim ~/.config/i3/config'
	alias edit-fish-cfg 'vim ~/.config/fish/config.fish'
	
	# command shortcuts
	#
	alias systemctlu 'systemctl --user'
	alias whatsmyip 'curl ipinfo.io/ip'
	alias tp trash-put
	
	# ls
	 
	#   -A, --almost-all           do not list implied . and ..
	#   -l                         use a long listing format
	#   -F, --classify             append indicator (one of */=>@|) to entries
	#   -h, --human-readable       with -l and/or -s, print human readable sizes
	#   -C                         list entries by columns
	alias l 'ls -CF'
	alias la 'ls -A'
	alias ll 'ls -AlFh'
	
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
	
	# overrides
	#
	
	# disable rm in favor of tp
	#alias rm 'echo "This is not the command you are looking for. Use tp"; false'
	function rm -w rm
		echo 'This is not the command you are looking for. Use tp'
		false
	end
	alias rm_ /bin/rm
	
	# use bat instead of cat
	alias cat bat
	
	# configure custom lsblk colums
	alias lsblk 'lsblk -o NAME,FSTYPE,SIZE,RM,RO,MOUNTPOINT,LABEL,PARTLABEL,UUID'
	
	# always create parent dirs
	alias mkdir 'mkdir -p'
	
	# colored ip
	alias ip 'ip -c'

	# virsh - connect to qemu:///system by default
	alias virsh 'virsh --connect qemu:///system'
	alias virsh_ /bin/virsh
	
	# restart aliases
	#
	alias plasma-restart 'killall plasmashell; and start plasmashell'
	alias compton-restart 'killall -USR1 compton'
	
	# functions
	#
	
	# what packages depend on $pkg
	function whoneeds
		set -l pkg $argv[1]
		echo "Packages that depend on [$pkg]"
		comm -12 (pactree -ru $pkg | sort | psub) (pacman -Qqe | sort | psub) | grep -v '^$pkg$' | sed 's/^/  /'
	end
	
	function start
		set -q argv
		and nohup $argv >/dev/null 2>&1 &; disown
	end
	
	function aur
		if set -q argv[1]
			git clone https://aur.archlinux.org/$argv[1].git
			cd $argv[1]
			makepkg -si
		else; false; end
	end
end

if status is-login
	if test -z "$DISPLAY" -a $XDG_VTNR = 1
		exec startx -- -keeptty >/dev/null 2>&1
	end
end
