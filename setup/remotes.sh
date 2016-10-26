#!/bin/sh

# install remote public projects
. ./utils.sh || exit 1

mkdir -p "${HOME}/projects"
remotes="$(_get_fullname "$1")" || exit 1

_parse_text_file "$remotes"	\
	| while read -r remote; do
		project_name="$(basename "${remote%.*}")"
		project_dir="${HOME}/projects/${project_name}"
		mkdir -p "$project_dir"
		if ls -A "$project_dir" >/dev/null 2>&1; then
			printf "Directory %s is not empty\n" "$project_dir"
		else
			git clone "$remote" "$project_dir"
		fi
	done
