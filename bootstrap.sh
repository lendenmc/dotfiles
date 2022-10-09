#!/bin/sh

# originally copied from from 'https://github.com/mathiasbynens/dotfiles/blob/master/bootstrap.sh'
# extended to not only work with a bash shell, but also with a zsh or ksh93 shell
# it won't work from a dash shell or other ksh variant such as pdksh
# as it turns out, posix doesn't offer any reliable way to get the sourced script's absolute path

force_builtin() {
	cmd="$1"
	shift
	# shellcheck disable=SC2039
	if [ -n "$ZSH_VERSION" ]; then
		builtin "$cmd" "$@" || return 1
	else
		command "$cmd" "$@" || return 1
	fi
}

cd_builtin() {
	force_builtin cd "$@"
}

printf_builtin() {
	force_builtin printf "$@"
}

read_builtin() {
	force_builtin read "$@"
}

# inspiration for the shell case differentiation drawn from 'http://unix.stackexchange.com/a/96238/104230'
# shellcheck disable=SC2128
if [ -n "$BASH_SOURCE" ]; then
	script_name="$BASH_SOURCE"
elif [ -n "$ZSH_VERSION" ]; then
	# shellcheck disable=SC2039
	builtin setopt function_argzero
	script_name="$0"
elif eval '[ -n "$(command echo ${.sh.version})" ]' 2>/dev/null; then # ksh93 flavor
	eval 'script_name="${.sh.file}"'
else
	printf_builtin "Unsupported shell. Please use bash, zsh or ksh93\n" >&2
	return 1
fi

script_dir="$(command dirname "$script_name")"
cd_builtin "$script_dir"

do_it() {
	command rsync --exclude ".git/" \
		--exclude ".gitignore" \
		--exclude ".DS_Store" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE.txt" \
		--exclude "setup/" \
		-avh --no-perms . "$HOME"
	if [ -n "$BASH" ]; then
		case "$BASH" in
			*/sh)
				# shellcheck source=/dev/null
				. "${HOME}/.shrc"
				;;
			*)
				# shellcheck source=/dev/null
				. "${HOME}/.bash_profile"
				;;
		esac
	elif [ -n "${ZSH_VERSION}" ]; then
		# shellcheck source=/dev/null
		. "${HOME}/.zshrc"
	else
		# shellcheck source=/dev/null
		. "${HOME}/.kshrc"
	fi
}
if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
	do_it
elif [ -n "$1" ]; then
	printf_builtin "Unsupported option or argument \"%s\"\n" "$1" >&2
	return 1
else
	printf_builtin "This may overwrite existing files in your home directory. Are you sure? (y/n) "
	while true; do
		read_builtin -r reply
		# shellcheck disable=SC2154
		case "$reply" in
			[yY][eE][sS]|[yY]) 
				do_it
				return
				;;
			[nN][oO]|[nN])
				return
				;;
			*)
				printf_builtin "Please answer yes or no: "
			    ;;
		esac
	done
fi

cd_builtin "$OLDPWD" >/dev/null


unset cmd script_name script_dir old_dir reply
unset -f force_builtin cd_builtin printf_builtin read_builtin do_it
