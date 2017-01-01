#!/bin/sh

. ./utils.sh || exit 1

# install apt-cyg

apt_cyg_url="rawgit.com/transcode-open/apt-cyg/master/apt-cyg"
if _test_executable "apt-cyg" 2>/dev/null; then
	printf "Apt-cyg is already installed\n"
else
	printf "Apt-cyg is not installed\n"
	printf "Installing apt-cyg\n"
	if ! command -v lynx >/dev/null 2>&1; then
		printf "Lynx is not installed. In order to install apt-cyg, you need to install it manually first."
		exit 1
	else
		lynx -source "$apt_cyg_url" > apt-cyg
		install apt-cyg /bin
		rm apt-cyg
	fi
fi

# install cygwin packages
packages="$(_get_fullname "$1")" || exit 1
printf "Installing cygwin packages from file %s\n" "$packages"
_parse_text_file "$packages" |
while read -r package; do
	apt-cyg install "$package"
done;

# install pip (cygwin does not support any version above python 3.4)
if command -v easy_install-3.4 >/dev/null 2>&1; then
	easy_install-3.4 pip
else
	printf "Easy_install is not installed. It is required to install pip as the cygwin pip package does not work well."
	exit 1
fi
# this will fix cygwin pyconfig.h bug when using pip within virtualenvs (solution taken from https://maketips.net/tip/78/solve-error-unknown-type-name-u_int-when-use-pip-on-cygwin)
pyconfig_header_file="/usr/include/python3.4m/pyconfig.h"
if _test_file "$pyconfig_header_file" 2>/dev/null; then
	sed -i '/^#define __BSD_VISIBLE/s/1/0/' "$pyconfig_header_file"
fi
