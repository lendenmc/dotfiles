#!/bin/sh

. ./utils.sh || exit 1

mkdir -p "${HOME}/bin"
 
# symlink some deep-lying executables into commands
executables="$(_get_fullname "$1")" || exit 1
_parse_text_file "$executables"	\
	| while read -r executable; do
		_test_executable "$executable" 2>/dev/null || continue
		if _test_file "${HOME}/bin/$(basename "$executable")" 2>/dev/null; then
			printf "Exectutable %s is already linked into %s\n" "$executable" "${HOME}/bin"
		else
			printf "Linking executable %s into %s\n" "$executable" "${HOME}/bin"
			ln -fs "$executable" "${HOME}/bin"
		fi
	done

# install (external) scripts that may nor may not provided by a package manager
scripts="$(_get_fullname "$2")" || exit 1
_parse_text_file "$scripts"	\
	| while read -r script; do
		script_name="${HOME}/bin/$(basename "$script")"
		if _test_file "${script_name}" 2>/dev/null; then
			printf "Script %s is already installed\n" "$script_name"
		else
			printf "Downlading external script from %s into %s\n" "$script" "${HOME}/bin"
			curl -o "$script_name" -LsS "$script" && chmod +x "$script_name"
		fi
	done
