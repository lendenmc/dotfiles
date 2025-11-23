#!/bin/sh

set -eu

# shellcheck disable=SC1091
. ./utils.sh

# vscode text application folders
if command -v code >/dev/null 2>&1; then
	code_name="code"
elif command -v code-insiders >/dev/null 2>&1; then
	code_name="code-insiders"
else
	printf "Visual Studio Code is not installed\n"
	exit 0
fi;

case "$(uname)" in
	Darwin*)
		if [ $code_name = "code" ]; then
			vscode_folder="${HOME}/Library/Application Support/Code"
		elif [ $code_name = "code-insiders" ]; then
			vscode_folder="${HOME}/Library/Application Support/Code - Insiders"
        else
			printf "Visual Studio Code is not installed\n"
			exit 0
		fi;
		;;
esac

if [ -z "$vscode_folder" ]; then
	printf "Visual Studio Code setup is not supported for this platform\n"
	exit 0
fi;

mkdir -p "$vscode_folder"
old_settings_folder="${vscode_folder}/User"
mkdir -p "$old_settings_folder"
new_settings_folder="$(_get_fullname ./vscode)"
settings_filename="settings.json"
keybindings_filename="keybindings.json"
old_settings_file="${old_settings_folder}/${settings_filename}"
old_keybindings_file="${old_settings_folder}/${keybindings_filename}"
new_settings_file="${new_settings_folder}/${settings_filename}"
new_keybindings_file="${new_settings_folder}/${keybindings_filename}"

_make_dir "$vscode_folder"

# user settings
symlink_user_settings() {
    newfile="$1"
    oldfile="$2"
	printf "Linking file %s into %s\n" "$newfile" "$oldfile"
	ln -s "$newfile" "$oldfile"
}

process_user_settings() {
    newfile="$1"
    oldfile="$2"
    filename="$(basename "$newfile" .json)"

    if [ -L "$oldfile" ]; then
	    printf "User %s are already symlinked\n" "$filename"
	    printf "You might want to check manually if this is the right %s for you and remove that symlink if that's not the case\n" "$filename"
    elif [ -r "$oldfile" ] && [ -f "$oldfile" ]; then
	    printf "User %s are already installed." "$filename"
	    printf " Would you like to override the existing user %s or not ? (y/n) " "$filename"
	    while true; do
	    	read -r reply
	    	case "$reply" in
	    	    [yY][eE][sS]|[yY]) 
	    			printf "Removing existing user %s\n" "$filename"
	    			rm -f "$oldfile"
	    			symlink_user_settings "$newfile" "$oldfile"
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
	    symlink_user_settings "$newfile" "$oldfile"
    fi
}

process_user_settings "$new_settings_file" "$old_settings_file"
process_user_settings "$new_keybindings_file" "$old_keybindings_file"

# install vscode extensions
vscode_extensions=./vscode/vscode_extensions.txt

if ! _test_executable "pipx"; then
	printf "Visual Studo Code CLI '%s' is not installed\n" "$code_name"
	exit 0
fi
_parse_text_file "$vscode_extensions"	\
	| while read -r extension; do
		printf "Installing extension %s\n" "$extension"
        eval "$code_name --install-extension $extension"
	done
