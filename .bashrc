#!/usr/bin/env/bash
# functions with leading underscore that are used here come from the '.functions' file, which is sourced by '.profile'

# if not running interactively, don't do anything (which will prevent any command from printing to standard output)
# as it turns out, there are a few cases (namely when bash's parent is rshd or sshd) where bash reads '.bashrc' as a non-interactive login shell
# see 'http://unix.stackexchange.com/a/18647/104230' and 'http://unix.stackexchange.com/a/257613/104230' for more details
[[ $- != *i* ]] && return

# '.bash_profile' already handles the login-shell case
if ! shopt -q login_shell; then
	if [ -r "${HOME}/.profile" ] && [ -f "${HOME}/.profile" ]; then . "${HOME}/.profile"; fi
fi

# aliases
alias sb='. ${HOME}/.bashrc'
command -v thefuck >/dev/null 2>&1 && eval "$(thefuck --alias)" # programatically correct mistyped console commands

# history
export HISTFILE="${HOME}/.bash_history" # bash will otherwise reads zsh history file when it is run as subshell of zsh with 'histfile' already set
export HISTSIZE=
export HISTFILESIZE=
export HISTCONTROL=ignorespace:ignoredups
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
shopt -s histappend # append to history, don't overwrite it

# step forward through history with C-s the same way you would step backwards with C-r 
stty -ixon

# custom prompt
PS1='\[\033[01;32m\]\w \[\033[01;31m\]$(_print_git_branch)\[\033[01;34m\]$\[\033[00m\] '

# do not add google cloud sdk binaries to path it it's already there
if command -v _add_gcloud_sdk_to_path >/dev/null 2>&1; then
	_add_gcloud_sdk_to_path "bash"
fi

# source scripts
if command -v _source_from_text_file >/dev/null 2>&1; then
	_source_from_text_file "${HOME}/.scripts.bash.txt"
fi

# enforce bash-completion for bash version 4 on macos
if [ "${BASH_VERSINFO[0]}" = 4 ]; then
	bashcomp=/usr/local/etc/profile.d/bash_completion.sh
	_test_file "$bashcomp" && . "$bashcomp"
	unset bashcomp
fi

# lsvirtualenv alias
command -v lsvirtualenv >/dev/null 2>&1 && alias lsv="lsvirtualenv -b | less"
