#!/bin/sh

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

# install python 3's global packages
global_packages=./python/global_packages.txt
_parse_text_file "$global_packages"	\
	| while read -r package options; do
		eval "$pip_name install $options $package" || exit 1
	done

# create an empty 'matplotlibrc' file to avoid complains which might occur when importing matplotlib-related packages such as seaborn
mkdir -p "${HOME}/.matplotlib"
matplotlibrc="${HOME}/.matplotlib/matplotlibrc"
_test_file "$matplotlibrc" 2>/dev/null || touch "$matplotlibrc"

# as virtualenvwrapper doesn't work with dash and ksh93 doesn't work well with virtualenv's 'deactivate' function, 
# we can only setup all virtualenvs from within a posix script when sh is bash
if [ -n "$BASH" ]; then
	printf "Setting up and generating python virtualenvs\n"
	if [ "$pip_name" = "pip3" ]; then
		alias python=python3
		alias pip=pip3
	fi
	export PROJECT_HOME="${HOME}/projects"
	export VIRTUALENVWRAPPER_PYTHON
	VIRTUALENVWRAPPER_PYTHON="$(command -v python3 2>/dev/null || command -v python)"
	. /usr/local/bin/virtualenvwrapper.sh || exit 1
	venvs_script="${PROJECT_HOME}/venvs/venvs.sh" # is supposed to have been installed with 'remote.sh' script before
	_test_file "$venvs_script" || exit
	chmod +x "$venvs_script"
	. "$venvs_script" || exit 1
	venvs ./python/venvs.txt || exit 1
fi
