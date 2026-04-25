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
	_download "$dotfiles_tarball_url" "$temp_file"

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

_setup_tools() {
	printf "\nSetting up tools\n"
	_parse_text_file ./tools.txt \
		| while read -r name url; do
			if _test_executable "$name" 2>/dev/null; then
				printf "%s is already installed\n" "$name"
				continue
			fi
			printf "Installing %s\n\n" "$name"
			if _test_executable "curl" 2>/dev/null; then
				curl -fsSL "$url" | sh
			else
				wget -qO- "$url" | sh
			fi
		done
	printf "Done with tools setup\n"
}

_setup_node() (
	printf "\nSetting up node.js\n"
	export NVM_DIR="$HOME/.nvm"
	if [ -s "$NVM_DIR/nvm.sh" ]; then
		# shellcheck disable=SC1091
		\. "$NVM_DIR/nvm.sh"
	else
		printf "NVM is not installed\n"
		return 0
	fi
	# Isolate CWD: pnpm/corepack can leak node_modules + package.json into it.
	tmp_dir="$(mktemp -d)"
	cd "$tmp_dir" || return 1
	nvm install --lts
	corepack enable pnpm
	export PNPM_HOME="${HOME}/.local/share/pnpm"
	mkdir -p "$PNPM_HOME"
	export PATH="$PNPM_HOME:$PATH"
	pnpm install --global git-open
	rm -rf "$tmp_dir"
	printf "Done with node.js setup\n"
)

_setup_pipx() {
	printf "\nSetting up pipx packages\n"
	if ! _test_executable "pipx" 2>/dev/null; then
		printf "Pipx is not installed\n"
		return 0
	fi
	export PIPX_HOME="${HOME}/.local/pipx"
	export PIPX_BIN_DIR="${HOME}/.local/bin"
	export PATH="$PIPX_BIN_DIR:$PATH"
	_parse_text_file ./pipx_packages.txt \
		| while read -r package options; do
			package_dir="${PIPX_HOME}/venvs/${package%%[*}"
			_test_program_folder "$package" "package" "$package_dir" || continue
			pipx install "$options" "$package"
		done
	printf "Done with pipx packages setup\n"
}

_setup_docker() {
	printf "\nSetting up docker\n"
	if ! _test_executable "docker" 2>/dev/null; then
		printf "Docker is not installed\n"
		return 0
	fi
	mkdir -p "${HOME}/.docker/completions"
	docker completion zsh > "${HOME}/.docker/completion_docker"
	# if docker info does not work, we are likely running Docker Desktop
	if ! docker info >/dev/null 2>&1; then
		open -a Docker || return 1
		printf "Waiting for Docker daemon to start"
		while ! docker info >/dev/null 2>&1; do
			printf "."
			sleep 2
		done
	fi
	docker pull jbarlow83/ocrmypdf-alpine
	printf "Done with docker setup\n"
}

_setup_projects() {
	printf "\nSetting up projects\n"
	_parse_text_file ./projects.txt \
		| while read -r project; do
			project_name=${project##*/}
			project_dir="$HOME/projects/$project_name"
			mkdir -p "$project_dir"
			! _test_empty_dir "$project_dir" || continue
			printf "Cloning remote git repository %s\n" "$project_name"
			git clone "$project" "$project_dir"
			printf "\n"
		done
	printf "Done with projects setup\n"
}

_setup_vscode() {
	printf "\nSetting up vscode\n"
	if command -v code >/dev/null 2>&1; then
		code_name="code"
	elif command -v code-insiders >/dev/null 2>&1; then
		code_name="code-insiders"
	else
		printf "Visual Studio Code is not installed\n"
		return 0
	fi

	vscode_folder=""
	case "$(uname)" in
		Darwin*)
			if [ "$code_name" = "code" ]; then
				vscode_folder="${HOME}/Library/Application Support/Code"
			elif [ "$code_name" = "code-insiders" ]; then
				vscode_folder="${HOME}/Library/Application Support/Code - Insiders"
			fi
			;;
	esac

	if [ -z "$vscode_folder" ]; then
		printf "Visual Studio Code setup is not supported for this platform\n"
		return 0
	fi

	mkdir -p "$vscode_folder"
	old_settings_folder="${vscode_folder}/User"
	mkdir -p "$old_settings_folder"
	new_settings_folder="$(_get_fullname .)"
	settings_filename="vscode_settings.json"
	keybindings_filename="vscode_keybindings.json"
	old_settings_file="${old_settings_folder}/settings.json"
	old_keybindings_file="${old_settings_folder}/keybindings.json"
	new_settings_file="${new_settings_folder}/${settings_filename}"
	new_keybindings_file="${new_settings_folder}/${keybindings_filename}"

	_make_dir "$vscode_folder"

	symlink_user_settings() {
		newfile="$1"
		oldfile="$2"
		printf "Linking file %s into %s\n" "$newfile" "$oldfile"
		ln -s "$newfile" "$oldfile"
	}

	process_user_settings() {
		newfile="$1"
		oldfile="$2"
		filename="$(basename "$newfile" .json)"

		if [ -L "$oldfile" ]; then
			printf "User %s are already symlinked\n" "$filename"
			printf "You might want to check manually if this is the right %s for you and remove that symlink if that's not the case\n" "$filename"
		elif [ -r "$oldfile" ] && [ -f "$oldfile" ]; then
			printf "User %s are already installed." "$filename"
			printf " Would you like to override the existing user %s or not ? (y/n) " "$filename"
			while true; do
				read -r reply
				case "$reply" in
					[yY][eE][sS]|[yY])
						printf "Removing existing user %s\n" "$filename"
						rm -f "$oldfile"
						symlink_user_settings "$newfile" "$oldfile"
						break
						;;
					[nN][oO]|[nN])
						break
						;;
					*)
						printf "Please answer yes or no\n"
						;;
				esac
			done
		else
			symlink_user_settings "$newfile" "$oldfile"
		fi
	}

	process_user_settings "$new_settings_file" "$old_settings_file"
	process_user_settings "$new_keybindings_file" "$old_keybindings_file"

	if ! _test_executable "$code_name" 2>/dev/null; then
		printf "Visual Studio Code CLI '%s' is not installed\n" "$code_name"
		return 0
	fi
	_parse_text_file ./vscode_extensions.txt \
		| while read -r extension; do
			printf "Installing extension %s\n" "$extension"
			"$code_name" --install-extension "$extension"
		done
	printf "Done with vscode setup\n"
}

_setup_shells() {
	printf "\nSetting up shells\n"
	shells="zsh bash dash ksh"
	for shell in $shells; do
		if ! _test_executable "$shell" 2>/dev/null; then
			printf "Shell %s is not installed\n" "$shell"
			continue
		fi
		shell_path="$(command -v "$shell")"
		if grep -Fqx "$shell_path" /etc/shells; then
			printf "Shell %s is already in /etc/shells\n" "$shell_path"
		else
			printf "Adding shell %s to /etc/shells\n" "$shell_path"
			printf "%s\n" "$shell_path" | sudo tee -a /etc/shells >/dev/null
		fi
	done

	if command -v chsh >/dev/null 2>&1 && _test_executable "zsh" 2>/dev/null; then
		zsh_path="$(command -v zsh)"
		if [ "$SHELL" = "$zsh_path" ]; then
			printf "Default shell is already %s\n" "$zsh_path"
		else
			chsh -s "$zsh_path"
		fi
	fi
	printf "Done with shells setup\n"
}

_setup() {
	mkdir -p "${HOME}/.bin"
	mkdir -p "${HOME}/projects"

	# platform-specific setup
	case "$(uname)" in
		Darwin*)
			if [ -x /opt/homebrew/bin/brew ]; then # Apple Silicon default
        		BREW_CMD=/opt/homebrew/bin/brew
    		elif [ -x /usr/local/bin/brew ]; then # Intel default
        		BREW_CMD=/usr/local/bin/brew
   			fi
    		eval "$($BREW_CMD shellenv)"

			_run_script "homebrew" ./macos/brew.sh ./macos/formulas.txt
			_run_script "homebrew cask" ./macos/brew_cask.sh ./macos/casks.txt
			_run_script "macos preferences" ./macos/preferences.sh
			_run_script "macos internal programs" ./macos/internal.sh ./macos/internal_programs.txt
			sudo chmod -R go-w "$HOMEBREW_PREFIX/share"
			;;
	esac

	_setup_tools

	_setup_node
	_setup_pipx
	_setup_docker
	_setup_projects
	_setup_vscode
	_setup_shells
}

# Resolve the setup directory so the script works from any working directory
SETUP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SETUP_DIR"

if [ -f ./utils.sh ] && [ -r ./utils.sh ]; then
	# shellcheck disable=SC1091
	. ./utils.sh
else
	github_repository="lendenmc/dotfiles"
	dotfiles_tarball_url="https://github.com/${github_repository}/tarball/master"
	dotfiles_dir="${HOME}/projects/dotfiles"
	_download_dotfiles
	cd "${dotfiles_dir}/setup"
	# shellcheck disable=SC1091
	. ./utils.sh
fi

# Keep the sudo timestamp fresh in the background.
sudo -v
while true; do
	sudo -n true || true
	sleep 60
done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!

_setup

kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
