#!/bin/sh

# install remote public projects

set -eu

# shellcheck disable=SC1091
. ./utils.sh

projects=./projects/projects.txt
_parse_text_file "$projects"	\
	| while read -r project; do
		project_name=${project##*/}
		project_dir="$HOME/projects/$project_name"
	
	    mkdir -p "$project_dir"
	    ! _test_empty_dir "$project_dir" || continue
	
	    printf "Cloning remote git repository %s\n" "$project_name"
	    git clone "$project" "$project_dir"
	
	    printf "\n"
	done