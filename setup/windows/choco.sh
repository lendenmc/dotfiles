#!/bin/sh

. ./utils.sh || exit 1

# test that chocolatey is installed
if ! command -v choco >/dev/null 2>&1; then
	printf "Chocolatey is not installed. Please install it manually."
	exit 1
fi

# install chocolatey packages
packages="$(_get_fullname "$1")" || exit 1
printf "Installing chocolatey packages from file %s\n" "$packages"
_parse_text_file "$packages" |
while read -r package; do
	_test_program_folder "$package" "package" "/cygdrive/c/ProgramData/chocolatey/lib" || continue
	choco install "$package"
done;
