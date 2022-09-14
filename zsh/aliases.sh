# ALIASES


# the ls thing {{{

if [[ "$(uname)" == "Darwin" ]]; then
  # ls does not work on macos as it uses a BSD version
  alias ls="ls -G"
  alias ll="ls -lrth"                                  # show list of directory
else
  alias ls="ls --color=auto"
  alias l='ls -lFh'                             # size,show type,human readable
fi

# }}}


alias zshrc='${=EDITOR} ${ZDOTDIR:-$HOME}/.zshrc' # Quick access to the .zshrc file
alias grep='grep --color'
alias x="exit" # Exit Terminal
alias del="rm -rf"
alias dots="cd $DOTFILES"
alias coding="cd $PROJECTS_DIR"
alias lp="lsp"

#alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias digls="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"

# fzf for images
# ls *jpg | fzf --preview="kitty icat --clear --place 200x40@0x0 --transfer-mode file {}"

# vi, vim, nvim aliases {{{

alias mvim="nvim -u NONE"
alias nv="nvim"
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# This allow using neovim remote when nvim is called from inside a running vim instance
if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
    alias nvim=nvr -cc split --remote-wait +'set bufhidden=wipe'
fi

# }}}

alias cl='clear'
alias clc="clear && printf '\e[3J'"   # clear terminal window and clean history

alias restart="exec $SHELL"
alias src='restart'
alias dnd='do-not-disturb toggle'

alias md="mkdir -p"

alias cat='bat --paging=never --style=plain'

batdiff() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
}
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

alias bathelp='bat --plain --language=help'
help() {
    "$@" --help 2>&1 | bathelp
}

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


# Git aliases {{{
# source: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh#L53
# NOTE: a lot of these commands are single quoted ON PURPOSE to prevent them
# from being evaluated immediately rather than in the shell when the alias is
# expanded

alias g="git"
alias gss="git status -s"
alias gst="git status"
alias gc="git commit"
alias gd="git diff"
alias gco="git checkout"
alias ga='git add'
alias gaa='git add --all'
alias gcb='git checkout -b'
alias gb='git branch'
alias gbD='git branch -D'
alias gbl='git blame -b -w'
alias gbr='git branch --remote'
alias gc='git commit -v'
alias gd='git diff'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'
alias gm='git merge'
alias gma='git merge --abort'
alias gmom='git merge origin/$(git_main_branch)'
alias gp='git push'
alias gbda='git branch --no-color --merged | command grep -vE "^(\+|\*|\s*($(git_main_branch)|development|develop|devel|dev)\s*$)" | command xargs -n 1 git branch -d'
alias gpristine='git reset --hard && git clean -dffx'
alias gcl='git clone --recurse-submodules'
alias gl='git pull'
alias glum='git pull upstream $(git_main_branch)'
alias grhh='git reset --hard'
alias groh='git reset origin/$(git_current_branch) --hard'
alias grbi='git rebase -i'
alias grbm='git rebase $(git_main_branch)'
alias gcm='git checkout $(git_main_branch)'
alias gcd="git checkout development"
alias gcb="git checkout -b"
alias gstp="git stash pop"
alias gsts="git stash show -p"

function grename() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 old_branch new_branch"
    return 1
  fi

  # Rename branch locally
  git branch -m "$1" "$2"
  # Rename branch in origin remote
  if git push origin :"$1"; then
    git push --set-upstream origin "$2"
  fi
}

function gdnolock() {
  git diff "$@" ":(exclude)package-lock.json" ":(exclude)*.lock"
}
# compdef _git gdnolock=git-diff

# Check if main exists and use instead of master
function git_main_branch() {
  local branch
  for branch in main trunk; do
    if command git show-ref -q --verify refs/heads/$branch; then
      echo $branch
      return
    fi
  done
  echo master
}

# }}}


# vim:foldmethod=marker
