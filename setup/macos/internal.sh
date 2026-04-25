#!/bin/sh

set -eu

# shellcheck disable=SC1091
. ./utils.sh

# symlink some deep-lying executables into commands
internal_programs="$(_get_fullname "$1")"
_parse_text_file "$internal_programs"	\
	| while read -r program; do
		if _test_file "${HOME}/.bin/$(basename "$program")" 2>/dev/null; then
			_log_warn "Internal program $program is already linked into ${HOME}/.bin"
		else
			printf "Linking internal program %s into %s\n" "$program" "${HOME}/.bin"
			ln -fs "$program" "${HOME}/.bin"
		fi
	done

