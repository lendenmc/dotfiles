#!/bin/sh

# install remote public projects

set -eu

# shellcheck disable=SC1091
. ./utils.sh

projects=./projects/projects.txt
_parse_text_file "$projects"	\
	| while read -r project options; do
		project_name="$(basename "${project%.*}")"
		project_dir="${HOME}/projects/${project_name}"
		optional_dir=$(printf "%s" "$options" | GREP_OPTIONS="" command grep -Eo "^\\\$\S*")
		if [ -n "$optional_dir" ]; then
			eval "optional_dir=$optional_dir"
			! _test_empty_dir "$optional_dir" || continue
			options=$(printf "%s" "$optional_dir" | cut -d' ' -f 2-)
			cmd="git clone $project \"$optional_dir\" $options"
			printf "Cloning remote git repository %s\n" "$project"
		else
			mkdir -p "$project_dir"
			! _test_empty_dir "$project_dir" || continue
			cmd="git clone $project \"$project_dir\" $options"
			printf "Cloning remote git repository %s\n" "$project_name"
		fi
		eval "$cmd"
		printf "\n"
	done