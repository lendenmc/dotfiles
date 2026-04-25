#!/bin/sh

_log_section() {
	if [ -t 1 ]; then
		printf '\n\033[36m==> %s\033[0m\n' "$*"
	else
		printf '\n==> %s\n' "$*"
	fi
}

_log_success() {
	if [ -t 1 ]; then
		printf '\033[32m✓ %s\033[0m\n' "$*"
	else
		printf '✓ %s\n' "$*"
	fi
}

_log_warn() {
	if [ -t 2 ]; then
		printf '\033[93m⚠ %s\033[0m\n' "$*" >&2
	else
		printf '⚠ %s\n' "$*" >&2
	fi
}

_print_error() {
	if [ -t 2 ]; then
		printf '\033[31m✖ ERROR: %s\033[0m\n' "$1" >&2
	else
		printf '✖ ERROR: %s\n' "$1" >&2
	fi
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

_test_program_folder() {
	program_name="$1"
	program_type="$2"
	dir_name="$3"
	if [ -d "${dir_name}" ]; then
		_log_warn "$program_type $program_name is already installed"
		return 1
	else
		_log_section "Installing $program_type $program_name"
	fi
}

_run_script() {
	name="$1"
	shift
	script="$1"
	shift
	_log_section "Setting up $name"
	chmod +x "$script" && ./"$script" "$@"
	_log_success "Done with $name setup"
}

_get_fullname() {
	relative_filename="$1"
	absolute_filename="$(cd "$(dirname "$relative_filename")"; pwd)/$(basename "$relative_filename")" || return 1
	printf "%s" "$absolute_filename"
}

_test_empty_dir() {
	target_dir="$1"
	if [ -n "$(ls -A "$target_dir" 2>/dev/null)" ]; then
		_log_warn "Directory $target_dir is not empty"
	else
		return 1
	fi
}
