#!/bin/sh

# shellcheck disable=SC1091
. ./utils.sh || exit 1

# install xcode command line tools
printf "Checking for xcode command line tools\n"
xcode-select --install >/dev/null 2>&1 
until xcode-select --print-path >/dev/null 2>&1; do # wait until xcode clts are installed
    sleep 5
done

# install homebrew
homebrew_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
if _test_executable "brew" 2>/dev/null; then
	pr f "Homebrew is already installed\n"
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
	/bin/bash -c "$(curl -fsSL $homebrew_url)" || exit 1
fi

# enable homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# install homebrew formulae
formulas="$(_get_fullname "$1")" || exit 1
printf "Installing homebrew formulas from file %s\n" "$formulas"
_parse_text_file "$formulas" |
while read -r formula options; do
	_test_program_folder "$formula" "formula" "$(brew --prefix)/Cellar" || continue
    if [ -n "$options" ]; then
        brew install "$options" "$formula" </dev/null
    else
        brew install "$formula" </dev/null
    fi
    printf "\n"
done;

printf "Cleaning up homebrew\n"
brew cleanup --prune=all -s
