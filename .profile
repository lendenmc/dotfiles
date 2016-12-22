# shellcheck disable=SC2148

# load dotfiles that are not bound to a specific shell, namely '.exports', '.aliases' and '.functions'
# load these two optional files:
#	* '.path', which is used for extension of your 'path' you don't want to commit 
# 	* '.extra', which is used for other settings you don’t want to commit
# this idea is coming from  https://github.com/mathiasbynens/dotfiles/blob/master/.bash_profile#L4-L9
dotfiles="\
${HOME}/.path
${HOME}/.exports
${HOME}/.aliases
${HOME}/.functions
${HOME}/.extra\
"
while read -r file; do
	if [ -r "$file" ] && [ -f "$file" ]; then . "$file"; fi
done <<EOF
	$dotfiles
EOF

unset dotfiles

# load platform-specific dotfiles
case "$(uname)" in
	Darwin*)
		dotfiles="\
		${HOME}/.exports.macos
		${HOME}/.aliases.macos
		${HOME}/.functions.macos\
		"
		while read -r file; do
			if [ -r "$file" ] && [ -f "$file" ]; then . "$file"; fi
		done <<EOF
			$dotfiles
EOF
		;;
	CYGWIN*)
		dotfiles="\
		${HOME}/.aliases.windows
		"
		while read -r file; do
			if [ -r "$file" ] && [ -f "$file" ]; then . "$file"; fi
		done <<EOF
			$dotfiles
EOF
		# load ssh authentication agent 'ssh-pageant' for cygwin to putty's pageant
		if command -v ssh-pageant >/dev/null 2>&1; then
			eval "$(/usr/bin/ssh-pageant -r -a "/tmp/.ssh-pageant-$USERNAME")" >/dev/null
		fi
		;;
		
esac

unset dotfiles
