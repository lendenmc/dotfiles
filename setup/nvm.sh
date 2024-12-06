#!/bin/sh

. ./utils.sh || exit 1

# download and install nvm
if [ -d "$NVM_DIR" ]; then
	printf "Nvm is already installed\n"
else
	printf "Installing nvm\n\n"
	nvm_url="https://raw.githubusercontent.com/creationix/nvm/v0.40.1/install.sh"
	if _test_executable "curl" 2>/dev/null; then
		curl -sSf "$nvm_url" | sh
	else
		wget -qO- "$nvm_url" | sh
	fi
fi

# download latest supported node.js version
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts