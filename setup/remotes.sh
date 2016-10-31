#!/bin/sh

# install remote public projects
. ./utils.sh || exit 1

mkdir -p "${HOME}/projects"
remotes="$(_get_fullname "$1")" || exit 1

_test_empty_dir() {
	target_dir="$1"
	if [ -n "$(ls -A "$target_dir" 2>/dev/null)" ]; then
		printf "Directory %s is not empty\n\n" "$target_dir"
	else
		return 1
	fi
}

_parse_text_file "$remotes"	\
	| while read -r remote options; do
		project_name="$(basename "${remote%.*}")"
		project_dir="${HOME}/projects/${project_name}"
		optional_dir=$(printf "%s" "$options" | GREP_OPTIONS="" command grep -Eo "^\\\$\S*")
		if [ -n "$optional_dir" ]; then
			eval "optional_dir=$optional_dir"
			! _test_empty_dir "$optional_dir" || continue
			cmd="git clone $remote $options"
			printf "Cloning remote git repository %s\n" "$remote"
		else
			mkdir -p "$project_dir"
			! _test_empty_dir "$project_dir" || continue
			cmd="git clone $remote $project_dir $options"
			printf "Cloning remote git repository %s\n" "$project_name"
		fi
		eval "$cmd" || exit 1
		printf "\n"
	done
