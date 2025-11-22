#!/bin/sh

set -eu

# shellcheck disable=SC1091
. ./utils.sh

# install xcode command line tools
printf "Checking for xcode command line tools\n"
xcode-select --install >/dev/null 2>&1 
until xcode-select --print-path >/dev/null 2>&1; do # wait until xcode clts are installed
    sleep 5
done

# install homebrew
homebrew_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
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
	/bin/bash -c "$(curl -fsSL $homebrew_url)"
fi

# enable homebrew
homebrew_prefix="$(brew --prefix)"
eval "$(/opt/homebrew/bin/brew shellenv)"
_prepend_path "${homebrew_prefix}/bin"
_prepend_path "${homebrew_prefix}/sbin"

# install homebrew formulae
formulas="$(_get_fullname "$1")"
printf "Installing homebrew formulas from file %s\n" "$formulas"
_parse_text_file "$formulas" |
while read -r formula options; do
	 cellar_dir="$(brew --cellar "$formula")"
	_test_program_folder "$formula" "formula" "$cellar_dir" || continue
    if [ -n "$options" ]; then
        brew install "$options" "$formula" </dev/null
    else
        brew install "$formula" </dev/null
    fi
    printf "\n"
done;

printf "Cleaning up homebrew\n"
brew cleanup --prune=all -s
