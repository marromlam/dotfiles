# ALIASES

# the ls thing {{{

if [[ "$(uname)" == "Darwin" ]]; then
    alias clc="clear && printf '\e[3J'" # clear terminal window and clean history
    alias ls='eza --icons'
    alias ll="eza -lr --icons" # show list of directory
else
    alias clc="/bin/clear && printf '\e[3J'" # clear terminal window and clean history
    alias ls='eza --icons'
    alias ll="eza -lr --icons" # show list of directory
fi

# }}}

alias zshrc='${=EDITOR} ${ZDOTDIR:-$HOME}/.zshrc' # Quick access to the .zshrc file
alias grep='grep --color'
alias x="exit" # Exit Terminal
alias del="rm -rf"
alias dots="cd $DOTFILES"
alias coding="cd $PROJECTS_DIR"
alias lp="lsp"

# ssh aliases {{{

if ! [ $SSH_TTY ]; then
        alias ssh='ssh -R 50000:${KITTY_LISTEN_ON#*:}'
fi

# }}}

# tmux {{{

alias ta="tmux attach -t"
alias td="tmux detach"
alias tls="tmux ls"
alias tkss="killall tmux"
alias tkill="tmux kill-session -t"

# }}}

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"

# suffix aliases {{{
# suffix aliases set the program type to use to open a particular file with an extension
# alias -s py=nvim
# alias -s cpp=nvim
# alias -s c=nvim
# alias -s hpp=nvim
# alias -s h=nvim
# alias -s lua=nvim

# }}}

# alias serve='python -m SimpleHTTPServer'
# alias fuckit='export THEFUCK_REQUIRE_CONFIRMATION=False; fuck; export THEFUCK_REQUIRE_CONFIRMATION=True'

# if use kitty, simplify the image cat command
if which kitty >/dev/null; then
        alias icat="kitty +kitten icat"
fi

alias docker-cleanup='docker system prune -a --volumes'
