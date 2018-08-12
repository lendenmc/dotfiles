#!/bin/sh

. ./utils.sh || exit 1

# sublime text application folders
case "$(uname)" in
	Darwin*)
		sublime_folder="${HOME}/Library/Application Support/Sublime Text 3"
		;;
esac
if [ -z "$sublime_folder" ]; then
	printf "Sublime text 3 setup is not supported for this platform\n"
	exit 1
fi

packages_folder="${sublime_folder}/Installed Packages"
package_ctrl_url="https://packagecontrol.io/Package%20Control.sublime-package"
package_ctrl_file="${packages_folder}/Package Control.sublime-package"
old_settings_folder="${sublime_folder}/Packages/User"
new_settings_folder="$(_get_fullname ./sublime/User)" || exit 1

# package control
_make_dir "$sublime_folder" || exit 1
_make_dir "$packages_folder" || exit 1
if _test_file "$package_ctrl_file" 2>/dev/null; then
	printf "Package control is already installed\n"
else
	printf "Installing package control\n"
	curl -o "$package_ctrl_file" -LsS "$package_ctrl_url"
fi

# user settings
symlink_user_settings() {
	printf "Linking %s folder into %s\n" "$new_settings_folder" "$old_settings_folder"
	ln -s "$new_settings_folder" "$old_settings_folder" || exit 1
}
_make_dir "${sublime_folder}/Packages" || exit 1
if [ -L "$old_settings_folder" ]; then
	printf "User settings are already symlinked\n"
	printf "You might want to check manually if this is the right settings for you and remove that symlink if that's not the case\n"
elif [ -d "$old_settings_folder" ]; then
	printf "User settings are already installed."
	printf "Would you like to override the existing user settings or not ? (y/n) "
	while true; do
		read -r reply
		case "$reply" in
		    [yY][eE][sS]|[yY]) 
				printf "Removing existing user settings\n"
				rm -rf "$old_settings_folder"
				symlink_user_settings || exit 1
				break
		        ;;
		    [nN][oO]|[nN])
				break
				;;
		    *)
		        printf "Please answer yes or no\n"
		        ;;
		esac
	done
else
	symlink_user_settings || exit 1
fi
