#!/bin/sh

. ./utils.sh || exit 1

# add shells to /etc/shells
shells="zsh bash dash fish ksh pdksh xonsh"
for shell in $shells; do
	_test_executable "$shell" || return 1
	shell_path="$(command -v "$shell")"
	if grep -Fqx "$shell_path" /etc/shells; then
		printf "Shell %s is already installed\n" "$shell_path"
	else
		printf "Adding shell %s to /etc/shells\n" "$shell_path"
		printf "%s\n" "$shell_path"	\
			| sudo tee -a /etc/shells >/dev/null
	fi
done

# switch default shell to zsh
# _test_executable "zsh" && chsh -s "$(command -v zsh)"
