# Directory navigation {{{
# Quick navigation to parent directories
alias ...="cd ../../.."
alias ....="cd ../../../.."

# Directory stack navigation
alias d='dirs -v'  # List directory stack with numbers
# Jump to directory stack entry by number (1-9)
for index ({1..9}) alias "$index"="cd +${index}"; unset index
# }}}

alias digls="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"

# fzf for images
# ls *jpg | fzf --preview="kitty icat --clear --place 200x40@0x0 --transfer-mode file {}"

# vi, vim, nvim aliases {{{

alias mvim="nvim -u NONE"
alias nv="nvim"
alias v='nvim'
alias vi='nvim'
alias vim='nvim'


# funny aliases
alias :q='exit'
alias :w='echo "not in vim :)"'
alias cal='cal -m'
alias curl='curl -sJL#'

# This allow using neovim remote when nvim is called from inside a running vim instance
if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
        alias nvim=nvr -cc split --remote-wait +'set bufhidden=wipe'
fi

# }}}


alias restart="exec $SHELL"
alias src='restart'
alias dnd='do-not-disturb toggle'

alias md="mkdir -p"


batdiff() {
        git diff --name-only --relative --diff-filter=d | xargs bat --diff
}
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

alias bathelp='bat --plain --language=help'
help() {
        "$@" --help 2>&1 | bathelp
}
