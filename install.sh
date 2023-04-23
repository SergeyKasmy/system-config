#!/bin/bash

# If run as root -> exit
if (( $UID == 0 )); then 
	echo 'The script is not supposed to be run as root!'
	exit 1
fi

# check current OS
# available options: arch, debian
OS=unknown
if grep "^ID_LIKE=" /etc/os-release &>/dev/null; then
	OS=$(grep "^ID_LIKE" /etc/os-release | cut -d= -f2)
elif grep "^ID=" /etc/os-release &>/dev/null; then
	OS=$(grep "^ID" /etc/os-release | cut -d= -f2)
fi
echo "Running on $OS"

SCRIPT_DIR="$PWD"

# ask a yes/no question
function get_input()
{
	read -n1 input
	echo ''
	if [[ "$input" != "y" && "$input" != "Y" && "$input" != "1" ]]; then return 1; fi
	return 0
}

if ! getent group wheel &>/dev/null; then
	echo "sudo isn't configured, setting up the wheel group..."
	su -c "groupadd wheel"
	su -c "gpasswd -a $(id -un) wheel"
	
	while true; do
		su -c "cp ./sudoers-wheel /etc/sudoers.d/10-wheel"
		if (( $? != 0 )); then 
			echo 'Error copying sudoers file. Try again'
			continue
		fi
		break
	done
else
	# TODO: prompt to still install sudoers file even if wheel already exists
	echo 'sudo is already set up, skipping...'
fi

if ! id -u island &>/dev/null; then
	echo -n 'Install second space? ->'
	if get_input; then
		sudo useradd --system --create-home --groups wheel island

		echo "$(id -un)	ALL=(island) NOPASSWD: ALL" | sudo cp /dev/stdin /etc/sudoers.d/30-island

		# TODO: check if empty
		mkdir "$HOME/.config/pulse"
		cat > "$HOME/.config/pulse/default.pa" <<- EOF
		.include /etc/pulse/default.pa

		load-module module-native-protocol-unix auth-group=audio socket=/tmp/pulse-server
		EOF
	fi
else
	echo 'Second space is already set up, skipping...'
fi

# install the meta packages
if [[ "$OS" == arch ]]; then
	echo 'Building meta packages'
	cd "$SCRIPT_DIR"/metapkg
	makepkg --sync --needed --clean
	for pkg in "$SCRIPT_DIR"/metapkg/*.pkg*; do
		BASE_NAME=$(basename "$pkg")
		echo -n "  -> Install $BASE_NAME? ->"
		if get_input; then
			sudo pacman -U "$pkg"
		fi
	done
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

echo 'Stowing user configs: '
for pkg in "$SCRIPT_DIR"/user/*/; do
	pkg=$(basename "$pkg")

	echo ' -> Stowing' "$pkg"
	stow --no-folding --dir "$SCRIPT_DIR"/user/ --target "$HOME" "$pkg"
done

echo 'Copying system configs: '
for pkg in "$SCRIPT_DIR"/system/*/; do
	echo ' -> Copying' "$pkg"
	cd "$pkg"
	sudo ./script.sh
	if (( $? != 0 )); then
		echo ' -> An error occured, skipping...'
		break
	fi
done

