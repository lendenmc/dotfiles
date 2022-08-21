#!/usr/bin/env ksh

# source '.profile' if non-login shell ('$-' constains a l when ksh is a login shell)
case "$-" in
	*l*)
		;;
	*)
		if [ -r "${HOME}/.profile" ] && [ -r "${HOME}/.profile" ]; then . "${HOME}/.profile"; fi
		;;
esac

# aliases
alias sk='. ${HOME}/.kshrc'

# history
export HISTFILE="${HOME}/.ksh_history"

# source scripts
if command -v _source_from_text_file >/dev/null 2>&1; then
	_source_from_text_file "${HOME}/.scripts.ksh.txt"
fi
