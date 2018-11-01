#!/bin/bash

# If run as root -> exit
if (( $UID == 0 )); then 
	echo 'The script is not supposed to be run as root!'
	exit 1
fi

case $1 in
	"install")
		MODE=0
		;;
	"update")
		MODE=1
		;;
	*)
		echo "Incorrect mode: neither install nor update"
		exit 1
esac

SCRIPT_DIR="$PWD"

function install_package
{
	cd "$SCRIPT_DIR/pkg/$1"
	makepkg --syncdeps --install --clean --noconfirm >/dev/null
}

function get_input()
{
	read -n1 input
	echo ''
	if [[ "$input" != "y" && "$input" != "Y" && "$input" != "1" ]]; then return 1; fi
	return 0
}

package_list=()
for pkg in "$SCRIPT_DIR"/pkg/*/; do
	pkg=$(basename "$pkg")
	package_list+=("$pkg")
done

if (( $MODE == 0 )); then
	echo -n "Copy sudoers-wheel?"
	if get_input; then
		while true; do
			su -c "cp ./sudoers-wheel /etc/sudoers.d/wheel"
			if (( $? != 0 )); then 
				echo 'Error copying sudoers file'
				continue
			fi
			break
		done
	fi
	for pkg in ${package_list[@]}; do
		echo -n "Install $pkg?"
		if get_input; then install_package "$pkg"; fi
	done
elif (( $MODE == 1 )); then
	for pkg in ${package_list[@]}; do
		full_pkg="gray-${pkg}"
		if pacman -Qq "${full_pkg}" &>/dev/null; then install_package "$pkg"; fi
	done
fi

for pkg in "$SCRIPT_DIR"/stow/*/; do
	pkg=$(basename "$pkg")
	stow --dir "$SCRIPT_DIR"/stow/ --target "$HOME" "$pkg"
done

# If $XDG_CONFIG_HOME is empty
if [[ -z "$XDG_CONFIG_HOME" ]]; then
	sudo su -c "cat >> /etc/security/pam_env.conf" <<- 'EOM'
	XDG_CONFIG_HOME DEFAULT=@{HOME}/.config/
	XDG_CACHE_HOME  DEFAULT=@{HOME}/.cache/
	XDG_DATA_HOME   DEFAULT=@{HOME}/.local/share/
	EOM
fi
