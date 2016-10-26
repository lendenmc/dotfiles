#!/bin/sh

. ./utils.sh || exit 1

# install homebrew cask taps
printf "Checking for homebrew cask taps\n"
brew tap caskroom/cask
brew tap caskroom/versions

# install homebrew casks
casks="$(_get_fullname "$1")" || exit 1
printf "Installing homebrew casks from file %s\n" "$casks"
_parse_text_file "$casks" |
while read -r cask; do
	_test_macos_program "$cask" "cask" "Caskroom" || continue
	brew cask install "$cask"
	printf "\n"
done;

# cleanup
printf "Cleaning up homebrew cask\n"
brew cask cleanup
