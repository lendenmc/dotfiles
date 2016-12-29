#!/bin/sh

. ./utils.sh || exit 1

# add shells to /etc/shells
shells="zsh bash dash fish ksh pdksh xonsh"
for shell in $shells; do
	if ! _test_executable "$shell" 2>/dev/null; then
		printf "Shell %s is not installed\n" "$shell"
		continue
	fi
	shell_path="$(command -v "$shell")"
	if grep -Fqx "$shell_path" /etc/shells; then
		printf "Shell %s is already in /etc/shells\n" "$shell_path"
	else
		printf "Adding shell %s to /etc/shells\n" "$shell_path"
		if command -v sudo >/dev/null 2>&1; then
			printf "%s\n" "$shell_path"	\
				| sudo tee -a /etc/shells >/dev/null
		else
			printf "%s\n" "$shell_path"	\
				| tee -a /etc/shells >/dev/null
		fi
	fi
done

# switch default shell to zsh
if command -v chsh >/dev/null 2>&1; then
	_test_executable "zsh" 2>/dev/null && chsh -s "$(command -v zsh)"
fi
