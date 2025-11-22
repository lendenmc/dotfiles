#!/bin/sh

# shellcheck disable=SC1091
. ./utils.sh || exit 1

# pip-install standalone python applications in dedicated virtualenvs with pipx
_test_executable "pipx" || exit 1
export PIPX_HOME="${HOME}/.local/pipx"
export PIPX_BIN_DIR="${HOME}/.local/bin"
export PATH="$PIPX_BIN_DIR:$PATH"
pipx_packages=./python/pipx_packages.txt
_parse_text_file "$pipx_packages"	\
	| while read -r package options; do
		package_dir="${PIPX_HOME}/venvs/${package%%[*}"
		_test_program_folder "$package" "package" "$package_dir" || continue
		eval "pipx install $options $package" || exit 1
	done
