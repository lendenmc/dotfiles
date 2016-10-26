#!/bin/sh

_print_error() {
	error="$1"
	printf "ERROR: %s\n" "$error" >&2
}

_test_executable() {
	executable="$1"
	fullpath="$(command -v "$executable")"
	if ! [ -f "$fullpath" ] || ! [ -x "$fullpath" ]; then
		_print_error "No such file executable $executable"
		return 1
	fi
}

_test_file() {
	file="$1"
	if ! [ -r "$file" ] || ! [ -f "$file" ]; then
		_print_error "No such file $file"
		return 1
	fi
}

_parse_text_file() {
	text_file="$1"
	_test_file "$text_file" || return 1
	grep -Ev "^\s*(#|$)" "$text_file"	\
		| awk -F'#' '{print $1}'
}

_test_dir(){
	dir="$1"
	if ! [ -d "$dir" ]; then
		_print_error "No such directory $dir"
		return 1
	fi
}

_make_dir() {
	if ! _test_dir "$1" 2>/dev/null; then
		mkdir -p "$1"
	fi
}

_test_macos_program() {
	program_name="$1"
	program_type="$2"
	dir_name="$3"
	program_short_name="$(basename "$program_name")"
	if [ -d "$(brew --prefix)/${dir_name}/${program_short_name}" ]; then
		printf "%s %s is already installed\n" "$program_type" "$program_name"
		return 1
	else
		printf "\nInstalling %s %s\n" "$program_type" "$program_short_name"
	fi
}

_run_script() {
	name="$1"
	shift
	script="$1"
	shift
	printf "\nSetting up %s\n" "$name"
	chmod +x "$script" && ./"$script" "$@"
	printf "Done with %s setup\n" "$name"
}

_get_fullname() {
	relative_filename="$1"
	absolute_filename="$(cd "$(dirname "$relative_filename")"; pwd)/$(basename "$relative_filename")" || return 1
	printf "%s" "$absolute_filename"
}
