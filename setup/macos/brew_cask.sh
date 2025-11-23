#!/bin/sh

set -eu

# shellcheck disable=SC1091
. ./utils.sh

# for docker-desktop install to work on apple silicon
if [ "$(uname -m)" = "arm64" ]; then
	softwareupdate --install-rosetta --agree-to-license
fi

# install homebrew casks
casks="$(_get_fullname "$1")"
printf "Installing homebrew casks from file %s\n" "$casks"
_parse_text_file "$casks" |
while read -r cask; do
caskroom_dir="$(brew --caskroom "$cask")"
	_test_program_folder "$cask" "cask" "$caskroom_dir" || continue
	if ! brew install --cask "$cask" </dev/null; then
    	printf 'Skipping cask "%s" (brew install failed)\n\n' "$cask"
    	continue
	fi
done;

# cleanup
printf "Cleaning up homebrew\n"
brew cleanup --prune=all -s
