# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

alias tmux="tmux -2"

# Configure gpg-agent
GPG_TTY=$(tty)
export GPG_TTY

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Generate a password 
genpasswd() {
                local l=$1
                [ "$l" == "" ] && l=20
                tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}

glog() {
    git log --graph --abbrev-commit --decorate --date=relative --all
}
