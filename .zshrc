#!/usr/bin/env zsh

# shellcheck disable=SC2148
# functions with leading underscore that are used here come from the '.functions' file, which is sourced by '.profile'

# load dotfiles that are not bound to a specific shell
if [ -r "${HOME}/.profile" ] && [ -f "${HOME}/.profile" ]; then . "${HOME}/.profile"; fi

# exports
export WORDCHARS='*?[]~&;!$%^<>' # make ctrl-w delete back till last '/', '=', '_' or '.'
[ -d /usr/local/share/zsh/help ] && export HELPDIR=/usr/local/share/zsh/help
export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1 # ensure uniquenes of history entries for zsh-search-substring

# aliases
alias sz='. ${HOME}/.zshrc'
command -v thefuck >/dev/null 2>&1 && eval "$(thefuck --alias)" # programatically correct mistyped console commands

# bash-like-help 'run-help' command (in order to check for  builtins, e.g. 'run-help source')
unalias run-help 2>/dev/null
autoload -U run-help
help() {
	run-help "$@" |& command less
}

# zsh general options
setopt no_beep
setopt rm_star_silent
# setopt extended_glob
# unsetopt nomatch

# step forward through history with C-s the same way you would step backwards with C-r 
stty -ixon

# key bindings
# bind UP and DOWN arrow keys
zmodload zsh/terminfo
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# shellcheck disable=SC1001
# bash-like C-u, so that all characters from beginning of the line to the cursor are removed instead of the whole line
bindkey \^U backward-kill-line

# autocompletion
fpath=(/usr/local/share/zsh-completions $fpath)
autoload -U compinit && compinit # enable autocomplete function
autoload -U bashcompinit && bashcompinit # use bash completions scripts from zsh
zstyle ':completion:*' group-name '' # group auto-completions
zstyle ':completion:*' menu select # activate menu selection for auto-completion

# history
setopt hist_ignore_space
setopt hist_find_no_dups
setopt hist_ignore_dups
setopt share_history
export HISTSIZE=150000
export HISTFILE="${HOME}/.zsh_history"
export SAVEHIST="$HISTSIZE"

# "modified" xargs that accept a function as argument
autoload -U zargs 

# prompt
setopt prompt_subst
autoload -U colors && colors
# shellcheck disable=SC2016
export PROMPT='%{$fg_bold[green]%}%~ %{$fg_bold[red]%}$(_print_git_branch)%{$fg_bold[blue]%}$ %b%f'

# do not add google cloud sdk binaries to path it it's already there
if command -v _source_from_text_file >/dev/null; then
	_add_gcloud_sdk_to_path "zsh"
fi

# source scripts
if command -v _source_from_text_file >/dev/null; then
	_source_from_text_file "${HOME}/.scripts.zsh.txt"
fi

# lsvirtualenv alias
command -v lsvirtualenv >/dev/null && alias lsv="lsvirtualenv -b | less"
