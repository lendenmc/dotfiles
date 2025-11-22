#!/bin/sh

set -eu

# shellcheck disable=SC1091
. ./utils.sh

# for docker-desktop to work
softwareupdate --install-rosetta --agree-to-license

# install homebrew casks
casks="$(_get_fullname "$1")"
printf "Installing homebrew casks from file %s\n" "$casks"
_parse_text_file "$casks" |
while read -r cask; do
caskroom_dir="$(brew --caskroom "$cask")"
	_test_program_folder "$cask" "cask" "$caskroom_dir" || continue
	brew install --cask "$cask" </dev/null
	printf "\n"
done;

# cleanup
printf "Cleaning up homebrew\n"
brew cleanup --prune=all -s
