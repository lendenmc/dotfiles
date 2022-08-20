#!/bin/sh

. ./utils.sh || exit 1

# install homebrew casks
casks="$(_get_fullname "$1")" || exit 1
printf "Installing homebrew casks from file %s\n" "$casks"
_parse_text_file "$casks" |
while read -r cask; do
	_test_program_folder "$cask" "cask" "$(brew --prefix)/Caskroom" || continue
	brew install "$cask"
	printf "\n"
done;

# cleanup
printf "Cleaning up homebrew\n"
brew cleanup --prune=all -s
