#!/usr/bin/bash
if shopt -q login_shell; then # if for some reason someone run 'source .bash_profile' in a non-login interactive shell, then '.bashrc' will already source '.profile'
	if [ -r "${HOME}/.profile" ] && [ -f "${HOME}/.profile" ]; then
		# shellcheck source=/dev/null
		. "${HOME}/.profile";
	fi
fi
case "$-" in *i*)
	if [ -r "${HOME}/.bashrc" ] && [ -f "${HOME}/.bashrc" ]; then
		# shellcheck source=/dev/null
		. "${HOME}/.bashrc";
	fi
	;;
esac
