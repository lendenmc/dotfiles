#!/bin/sh

. ./utils.sh || exit 1

# download and setup nvm folder
if [ -d "$NVM_DIR" ]; then
	printf "Nvm is already installed\n"
else
	printf "Installing nvm\n\n"
	nvm_url="https://raw.githubusercontent.com/creationix/nvm/v0.39.1/install.sh"
	if _test_executable "curl" 2>/dev/null; then
		curl -sS "$nvm_url" | bash
	else
		wget -qO- "$nvm_url" | bash
	fi
fi

# install npm global packages
printf "Installing global node.js packages\n"
global_packages=./node.js/global_packages.txt
_test_executable "npm" || exit 1
global_modules="$(npm root -g)"
_parse_text_file "$global_packages"	\
	| while read -r package; do
		if ! [ -d "${global_modules}/${package}" ]; then
			printf "Installing package %s\n" "$package"
			npm install -g "$package" >/dev/null
		else
			printf "Package %s is already installed\n" "$package"
		fi
	done
