#!/bin/sh

set -eu

# originally taken from https://github.com/alrra/dotfiles/blob/master/src/os/setup.sh#L18-L44
_download() {
	url="$1"
	output="$2"
	if command -v "curl" >/dev/null 2>&1; then
		curl -LsSo "$output" "$url"
	else
		wget -qO "$output" "$url" >/dev/null 2>&1
	fi
}

# heavilly inspired from from https://github.com/alrra/dotfiles/blob/master/src/os/setup.sh#L46-L118
_download_dotfiles() {
	printf "Downloading and extracting dotfiles archive\n"

	temp_file="$(mktemp /tmp/XXXXX)"
	_download "$dotfiles_tarball_url" "$temp_file" || return 1

	printf "Do you want to store the dotfiles into %s ? (y/n) " "$dotfiles_dir"
	while true; do
		read -r reply
		case "$reply" in
			[yY][eE][sS]|[yY])
				break
				;;
			[nN][oO]|[nN])
				dotfiles_dir=""
				while [ -z "$dotfiles_dir" ]; do
					printf "Please specify another location for the dotfiles (path): "
					read -r dotfiles_dir
				done
				break
				;;
			*)
				printf "Please answer yes or no\n"
				;;
		esac
	done

	skip_msg=""
	while [ -e "$dotfiles_dir" ]; do
		[ -z "$skip_msg" ] && printf "Directory %s already exists, do you want to overwrite it ? " "$dotfiles_dir"
		read -r answer
		case "$answer" in
			[yY][eE][sS]|[yY])
				rm -rf "$dotfiles_dir"
				break
				;;
			[nN][oO]|[nN])
				dotfiles_dir=""
				while [ -z "$dotfiles_dir" ]; do
					printf "Please specify another location for the dotfiles (path): "
					read -r dotfiles_dir
				done
				skip_msg=""
				;;
			*)
				printf "Please answer yes or no\n"
				skip_msg="true"
				;;
		esac
	done

	printf "Creating dotfiles directory\n"
	mkdir -p "$dotfiles_dir"
	command -v "tar" >/dev/null && tar -zxf "$temp_file" --strip-components 1 -C "$dotfiles_dir" && rm -rf "$temp_file"
}

_setup() {
	mkdir -p "${HOME}/.bin" || return 1
	mkdir -p "${HOME}/projects" || return 1

	# platform-specific setup
	case "$(uname)" in
		Darwin*)
			_run_script "homebrew" ./macos/brew.sh ./macos/brew_formulas.txt || return 1
			_run_script "homebrew cask" ./macos/brew_cask.sh ./macos/brew_casks.txt || return 1
			softwareupdate --install-rosetta --agree-to-license # for docker-desktop to work
			_run_script "macos preferences" ./macos/preferences.sh || return 1
			_run_script "macos internal programs" ./macos/internal.sh ./macos/internal_programs.txt || return 1
			homebrew_prefix="$(brew --prefix)"
			_prepend_path "${homebrew_prefix}/bin"
			_prepend_path "${homebrew_prefix}/sbin"
			;;
	esac

	# program-specific setups
	for program in "python" "node.js" "rust" "docker" "projects" "vscode"; do
		_run_script "$program" "./${program}/setup.sh" || return 1
	done

	# setup shells
	_run_script "shells" ./shells.sh || return 1

    printf "Finally, syncing dotfiles\nPlease source your .zsh profile at the end of the setup script.\n"
	# shellcheck disable=SC1091
	. "$HOME"/projects/dotfiles/bootstrap.sh || return 1
}
 
# run the setup script
# if you have already download the dotfiles folder, please run this script from within its own location, which should be the 'dotfiles/setup' folder
# otherwise it will be asssumed that the dotfiles folder has not been downloaded yet
if [ -f ./utils.sh ] && [ -r ./utils.sh ]; then # check existence of 'utils' file to decide whether or not to download the dotfiles folder
	# shellcheck disable=SC1091
	. ./utils.sh
	_setup
else 
	github_repository="lendenmc/dotfiles"
	dotfiles_tarball_url="https://github.com/${github_repository}/tarball/master"
	dotfiles_dir="${HOME}/projects/dotfiles"
	_download_dotfiles
	cd "${dotfiles_dir}/setup"
	# shellcheck disable=SC1091
	. ./utils.sh
	_setup
	cd - >/dev/null
fi
