#!/bin/sh

# shellcheck disable=SC1091
. ./utils.sh || exit 1

# pip-install standalone python applications in dedicated virtualenvs with pipx
_test_executable "pipx" || exit 1
pipx ensurepath
pipx_packages=./python/pipx_packages.txt
_parse_text_file "$pipx_packages"	\
	| while read -r package options; do
		eval "pipx install $options $package" || exit 1
	done
