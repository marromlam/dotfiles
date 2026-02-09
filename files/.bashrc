# bashrc

# skip loading
[[ -f "$HOME/.skip" ]] && source $HOME/.skip

# Eval homebrew {{{
# Homebrew
if [[ "$(uname -m)" == "x86_64" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# }}}


# source basuc functions
source $HOME/.dotfiles/zsh/ufunctions.sh
# source $HOME/.dotfiles/zsh/zshenv

# variable with current host name
function whoismyhost() {
    echo "$(hostname)"
}

echo "Connected to $(whoismyhost) with bash"

# . ~/.sh_profile

# bind 'set show-all-if-ambiguous on'
# bind 'set completion-ignore-case on'
# bind 'TAB: menu-complete'

if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
    alias nvim=nvr -cc split --remote-wait +'set bufhidden=wipe'
fi
if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
    export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
else
    export VISUAL="nvim"
    export EDITOR="nvim"
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
# source $(brew --prefix)/etc/bash_completion
# source "$HOME/.dotfiles/zsh/prompt-basic.sh"

# finishing {{{

# source my aliases
source $HOME/.dotfiles/zsh/aliases.sh

# common settings for bash and zsh
source $HOME/.dotfiles/zsh/common.sh

# source local config file, if exists
# [[ -f "$HOME/.zshrc_local" ]] && source $HOME/.zshrc_local

# USGC BASH PROMPT
if [[ $- == *i* ]]; then
    export CLICOLOR=1
    export LSCOLORS=GxFxCxDxBxegedabagaced
    export PS1="\[$(tput setaf 7)\]❬\h❭ \[$(tput setaf 2)\]\W\[$(tput setaf 1)\] ●\[$(tput sgr0)\] "
fi

# check whether tmux is running or not, and export variable
if [ -n "$TMUX" ]; then
    export IS_TMUX=1
else
    if [ -z ${IS_TMUX+x} ]; then
        export IS_TMUX=0
    fi
fi

# Set KITTY_PORT env variable
if [ $SSH_TTY ] && ! [ -n "$TMUX" ]; then
    # if [ $SSH_TTY ]; then
    export KITTY_PORT=$(kitty @ ls 2>/dev/null | grep "[0-9]:/tmp/mykitty" | head -n 1 | cut -d : -f 1 | cut -d \" -f 2)
fi

# }}}

# vim: ft=bash fdm=marker
