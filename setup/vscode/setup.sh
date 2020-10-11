#!/bin/sh

. ./utils.sh || exit 1

# sublime text application folders
case "$(uname)" in
	Darwin*)
		vscode_folder="${HOME}/Library/Application Support/Code"
        code_name="code"
        if [ ! -d "$vscode_folder" ]; then
            vscode_folder="${HOME}/Library/Application Support/Code - Insiders"
            code_name="code-insiders"
        fi
		;;
esac
if [ ! -d "$vscode_folder" ]; then
	printf "Visual Studio Code setup is not supported for this platform\n"
	exit 1
fi

old_settings_folder="${vscode_folder}/User"
new_settings_folder="$(_get_fullname ./vscode)" || exit 1
settings_filename="settings.json"
keybindings_filename="keybindings.json"
old_settings_file="${old_settings_folder}/${settings_filename}"
old_keybindings_file="${old_settings_folder}/${keybindings_filename}"
new_settings_file="${new_settings_folder}/${settings_filename}"
new_keybindings_file="${new_settings_folder}/${keybindings_filename}"

_make_dir "$vscode_folder" || exit 1

# user settings
symlink_user_settings() {
    newfile="$1"
    oldfile="$2"
	printf "Linking file %s into %s\n" "$newfile" "$oldfile"
	ln -s "$newfile" "$oldfile" || exit 1
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
	    			symlink_user_settings "$newfile" "$oldfile" || exit 1
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
	    symlink_user_settings "$newfile" "$oldfile" || exit 1
    fi
}

process_user_settings "$new_settings_file" "$old_settings_file" || exit 1
process_user_settings "$new_keybindings_file" "$old_keybindings_file" || exit 1

# install vscode extensions
vscode_extensions=./vscode/vscode_extensions.txt
_test_executable "$code_name" || exit 1
_parse_text_file "$vscode_extensions"	\
	| while read -r extension; do
		printf "Installing extension %s\n" "$extension"
        eval "$code_name --install-extension $extension" || exit 1
	done
