#!/bin/bash

# If run as root -> exit
if (( $UID == 0 )); then 
	echo 'The script is not supposed to be run as root!'
	exit 1
fi

# set current mode from the argument
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

# check current OS
# available options: arch, debian
OS=unknown
if grep "^ID_LIKE=" /etc/os-release &>/dev/null; then
	OS=$(grep "^ID_LIKE" /etc/os-release | cut -d= -f2)
elif grep "^ID=" /etc/os-release &>/dev/null; then
	OS=$(grep "^ID" /etc/os-release | cut -d= -f2)
fi

SCRIPT_DIR="$PWD"

# ask a yes/no question
function get_input()
{
	read -n1 input
	echo ''
	if [[ "$input" != "y" && "$input" != "Y" && "$input" != "1" ]]; then return 1; fi
	return 0
}

# get a list of the all custom arch packages
package_list=()
for pkg in "$SCRIPT_DIR"/metapkg/*/; do
	pkg=$(basename "$pkg")
	package_list+=("$pkg")	
done

function arch_build_install_package
{
       cd "$SCRIPT_DIR/pkg/$1"
       makepkg --syncdeps --install --clean --noconfirm >/dev/null
}
arch_custom_package_list=('ttf-ubuntu-font-family')

if (( $MODE == 0 )); then
	echo -n "Copy sudoers-wheel?"
	if get_input; then
		while true; do
			su -c "cp ./sudoers-wheel /etc/sudoers.d/10-wheel"
			if (( $? != 0 )); then 
				echo 'Error copying sudoers file'
				continue
			fi
			break
		done
	fi

	if [[ "$OS" == arch ]]; then
		for pkg in ${package_list[@]}; do
			echo -n "Install $pkg? ->"
			if get_input; then arch_build_install_package "$pkg"; fi
		done
		
		# install custom packages
		for pkg in ${arch_custom_package_list[@]}; do
			echo -n "Install $pkg? ->"
			if get_input; then sudo pacman -S --noconfirm "$pkg"; fi
		done
	fi

	function create_second_space
	{
		if id -u island >/dev/null 2>&1; then
			echo "Second space user account already exists, skipping..."
			return
		fi
		
		sudo useradd --system --create-home island

		echo "$(id -un)	ALL=(island) NOPASSWD: ALL" | sudo cp /dev/stdin /etc/sudoers.d/30-island

		# TODO: check if empty
		mkdir "$HOME/.config/pulse"
		cat > "$HOME/.config/pulse/default.pa" <<- EOF
		.include /etc/pulse/default.pa

		load-module module-native-protocol-unix auth-group=audio socket=/tmp/pulse-server
		EOF
	}

	create_second_space

elif (( $MODE == 1 )); then

	if [[ "$OS" == arch ]]; then
		for pkg in ${package_list[@]}; do
			full_pkg="gray-${pkg}"
			if pacman -Qq "${full_pkg}" &>/dev/null; then arch_build_install_package "$pkg"; fi
		done
	fi

fi
if ! which stow &>/dev/null; then
	echo "Stow is not installed, installing"
	case "$OS" in
		arch)
			sudo pacman -S --noconfirm stow
			;;
		debian)
			sudo apt-get install stow
			;;
	esac
fi

for pkg in "$SCRIPT_DIR"/user/*/; do
	pkg=$(basename "$pkg")
	stow --no-folding --dir "$SCRIPT_DIR"/user/ --target "$HOME" "$pkg"
done

for pkg in "$SCRIPT_DIR"/system/*/; do
	cd "$pkg"
	sudo ./script.sh
done

