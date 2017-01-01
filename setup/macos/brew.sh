#!/bin/sh

. ./utils.sh || exit 1

# install xcode command line tools
printf "Checking for xcode command line tools\n"
xcode-select --install >/dev/null 2>&1 
until xcode-select --print-path >/dev/null 2>&1; do # wait until xcode clts are installed
    sleep 5
done

# install homebrew
homebrew_url="https://raw.githubusercontent.com/Homebrew/install/master/install"
if _test_executable "brew" 2>/dev/null; then
	printf "Homebrew is already installed\n"
	printf "Checking for updates\n"
	brew update
	printf "List installed packages\n"
	brew list
	printf "List outdated packages\n"
	brew outdated
	printf "Upgrading outdated packages\n"
	brew upgrade
else
	printf "Homebrew is not installed\n"
	printf "Installing homebrew\n"
	/usr/bin/ruby -e "$(curl -fsSL $homebrew_url)" || exit 1
fi

# install homebrew taps
printf "Checking for homebrew taps\n"
brew tap homebrew/boneyard
brew tap homebrew/dupes
brew tap homebrew/php
brew tap homebrew/python
brew tap homebrew/science
brew tap homebrew/versions
brew tap homebrew/x11

# install homebrew formulae
formulas="$(_get_fullname "$1")" || exit 1
printf "Installing homebrew formulas from file %s\n" "$formulas"
_parse_text_file "$formulas" |
while read -r formula options; do
	_test_program_folder "$formula" "formula" "$(brew --prefix)/Cellar" || continue
	brew_cmd="brew install $options --ignore-dependencies $formula"
	if ! eval "$brew_cmd"; then
		# some 'brew install' with python3 option will break if the '-ignore-dependencies' option is enabled
		# moreover, tcpdump and lftp install for instance break with the '-ignore-dependencies' option, although without any other option
		brew_cmd="brew install $options $formula"
		printf "So trying to install formula %s again, this time without the '--ignore-dependencies' option\n" "$formula"
		eval "$brew_cmd"
	fi;
	printf "\n"
done;

# cleanup
printf "Cleaning up homebrew\n"
brew cleanup -s
