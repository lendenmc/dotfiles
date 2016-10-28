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
		if [ -n "$(ls -A "$project_dir" 2>/dev/null)" ]; then
			printf "Directory %s is not empty\n\n" "$project_dir"
		else
			printf "Cloning remote git repository %s\n" "$project_name"
			git clone "$remote" "$project_dir" >/dev/null || exit 1
			printf "\n"
		fi
	done
