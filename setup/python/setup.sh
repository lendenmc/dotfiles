#!/bin/sh

# shellcheck disable=SC1091
. ./utils.sh || exit 1

unset PIP_REQUIRE_VIRTUALENV

if _test_executable "pip3"
then
	pip_name="pip3"
else
	_test_executable "pip" || exit 1
	pip_name="pip"
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
