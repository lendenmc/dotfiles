#!/bin/sh

# shellcheck disable=SC1091
. ./utils.sh || exit 1

unset PIP_REQUIRE_VIRTUALENV

# get major version number of default python
_test_executable "python" || exit 1
python_version="$(python -c 'import sys; print(sys.version_info.major)' 2>/dev/null)"
if [ -z "$python_version" ]; then
	_print_error "Could not find major version number of default python"
	exit 1
fi

# check that python 3's pip is in the system and get the name of its command
if [ "$python_version" = 3 ]; then
	_test_executable "pip" || exit 1
	pip_name="pip"
else
	_test_executable "pip3" || exit 1
	pip_name="pip3"
fi

printf "Installing or upgrading global python packages\n"

# upgrade python 3's default packages that come with pip
eval "$pip_name install --upgrade pip setuptools wheel" || exit

# pip-install standalone python applications in dedicated virtualenvs with pipx
_test_executable "pipx" || exit 1
pipx_packages=./python/pipx_packages.txt
_parse_text_file "$pipx_packages"	\
	| while read -r package options; do
		eval "pipx install $options $package" || exit 1
	done
