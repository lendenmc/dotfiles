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
if command -v _source_from_text_file >/dev/null; then
	case "$(command ps -o args="" -p $$)" in
		-pdksh*|pdksh*|*/pdksh*)
			_source_from_text_file "${HOME}/.scripts.pdksh.txt" # nvm work on pdksh, but not on ksh93
			;;
		-ksh*|ksh*|*/ksh*)
			venvwrap_file="/usr/local/bin/virtualenvwrapper.sh"
			if [ -f "$venvwrap_file" ] && [ -w "$venvwrap_file" ]; then # fix ksh complaining "'&>file' is nonstandard"
				if GREP_OPTIONS="" command grep -qE "&> /dev/null"  "$venvwrap_file"; then
					command sed -i.bak 's/\&> \/dev\/null/>\/dev\/null 2>\&1/g' "$venvwrap_file"
					command rm "${venvwrap_file}.bak"
				fi
			fi
			unset venvwrap_file
			_source_from_text_file "${HOME}/.scripts.ksh.txt"
			;;
	esac
fi

command -v lsvirtualenv >/dev/null && alias lsv="lsvirtualenv -b | less"
