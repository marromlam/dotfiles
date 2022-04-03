# zsh shell config file
#
#


# Eval Homebrew {{{

# Get machine operative system
export MACHINEOS=`$HOME/.dotfiles/scripts/machine.sh`
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

# Set OS-dependent stuff
if [[ "$MACHINEOS" == "Mac" ]]; then
  # homebrew path
  if [[ "$(uname -m)" == "x86_64" ]]; then
    # intel / rosseta
    export HOMEBREW_PREFIX="/usr/local"
  else
    # running on Apple Sillicon
    export HOMEBREW_PREFIX="/opt/homebrew"
  fi
else
  # linuxbrew path
  export HOMEBREW_PREFIX="$HOME/.linuxbrew"
fi
eval $($HOMEBREW_PREFIX/bin/brew shellenv)
export XDG_DATA_DIRS="$HOMEBREW_PREFIX/share:$XDG_DATA_DIRS"

# }}}


# source basuc functions
source $HOME/.dotfiles/zsh/ufunctions.sh
source $HOME/.dotfiles/zsh/zshenv


# get current environment name {{{

export CONDA_AUTO_ACTIVATE_BASE=false
export CONDA_ALWAYS_YES=true

export VIRTUAL_ENV_DISABLE_PROMPT=0
#conda config --set changeps1 False

# get virtualenv
function get_env {
 if [ $VIRTUAL_ENV ]; then
   echo "('`basename $VIRTUAL_ENV`') "
 elif [ $CONDA_DEFAULT_ENV ]; then
   echo "${CONDA_DEFAULT_ENV}"
 else
   echo "syst"
 fi
}

# disables prompt mangling in virtual_env/bin/activate
export VIRTUAL_ENV_DISABLE_PROMPT=1

# }}}


# Use Powerlevel10k if zsh is new enough, else starship -- DEPRECATED -- {{{

# MIN_ZSH_VERSION=5.1.0
# THE_ZSH_VERSION=`echo $ZSH_VERSION`
# if [ $(version $THE_ZSH_VERSION) -ge $(version $MIN_ZSH_VERSION) ]; then
#   # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
#   # Initialization code that may require console input (password prompts, [y/n]
#   # confirmations, etc.) must go above this block; everything else may go below.
#   source $HOMEBREW/opt/powerlevel10k/powerlevel10k.zsh-theme
#   if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#     source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#   fi
#   # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#   [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# else
#   function whoismyhost (){
#     a="$(ip route get 1 | awk '{print $NF;exit}')"
#     b=`echo "$a" | sed 's/^.*\.\([^.]*\)$/\1/'`
#     #echo $a
#     #echo $b
#     if [[ $a == 172.16.57.* ]]; then
#       echo "gpu"$b
#     elif [[ $a == 172.16.58.1 ]]; then
#       echo "master"
#     elif [[ $a == 193.144.80.1 ]]; then
#       echo "pool"
#     else
#       echo "nodo0"$b
#     fi
#   }
#   export CURRENT_HOST="$(whoismyhost)"
# fi

# }}}


# Plugins {{{

zmodload zsh/datetime

# Create a hash table for globally stashing variables without polluting main
# scope with a bunch of identifiers.
typeset -A __DOTS

__DOTS[ITALIC_ON]=$'\e[3m'
__DOTS[ITALIC_OFF]=$'\e[23m'


PLUGIN_DIR=$DOTFILES/zsh/plugins

# Init completions
autoload -Uz compinit
compinit


# These should be source *BEFORE* setting up hooks

# zsh suggestions
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=241'
ZSH_AUTOSUGGEST_USE_ASYNC=1
CASE_SENSITIVE="false"
setopt MENU_COMPLETE
setopt no_list_ambiguous
#zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==34=34}:${(s.:.)LS_COLORS}")';
ls_colors="di=1;34:ln=36:so=35:pi=33:ex=32:bd=40;33:cd=40;33:su=37;41:sg=30;43:tw=30;42:ow=34;42"
zstyle ':completion:*:default' list-colors "${(s.:.)ls_colors}"
zstyle ':completion:*' menu yes select

# syntax highlighting
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# source $HOMEBREW_PREFIX/share/zsh-completions/zsh-completions.zsh

source $HOMEBREW_PREFIX/share/zsh-alias-tips/alias-tips.plugin.zsh

autoload zmv # builtin zsh rename command

# }}}


# zsh completions {{{

# Completion for kitty
if [[ "$TERM" == "xterm-kitty" ]]; then
  kitty + complete setup zsh | source /dev/stdin
fi

# Colorize completions using default `ls` colors.
zstyle ':completion:*' list-colors ''

# Enable keyboard navigation of completions in menu
# (not just tab/shift-tab but cursor keys as well):
zstyle ':completion:*' menu select

# persistent reshahing i.e puts new executables in the $path
# if no command is set typing in a line will cd by default
zstyle ':completion:*' rehash true

# Allow completion of ..<Tab> to ../ and beyond.
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(..) ]] && reply=(..)'

# Categorize completion suggestions with headings:
zstyle ':completion:*' group-name ''
# Style the group names
zstyle ':completion:*' format %F{yellow}%B%U%{$__DOTS[ITALIC_ON]%}%d%{$__DOTS[ITALIC_OFF]%}%b%u%f

# Added by running `compinstall`
zstyle ':completion:*' expand suffix
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-suffixes true
# End of lines added by compinstall

# Make completion:
# (stolen from Wincent)
# - Try exact (case-sensitive) match first.
# - Then fall back to case-insensitive.
# - Accept abbreviations after . or _ or - (ie. f.b -> foo.bar).
# - Substring complete (ie. bar -> foobar).
zstyle ':completion:*' matcher-list '' '+m:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}' '+m:{_-}={-_}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# }}}


# set some history options {{{

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=999999999
export SAVEHIST=999999999
setopt SHARE_HISTORY # Share your history across all your terminal windows
setopt APPEND_HISTORY

setopt AUTO_CD
setopt RM_STAR_WAIT
setopt CORRECT # command auto-correction
setopt COMPLETE_ALIASES
setopt AUTOPARAMSLASH # tab completing directory appends a slash

# }}}


# os-dependent config {{{

source "$HOME/.dotfiles/zsh/prompt2.sh"

case `uname` in
  Darwin)
    source "$HOME/.dotfiles/zsh/macos.sh"
    ;;
  Linux)
    source "$HOME/.dotfiles/zsh/linux.sh"
    ;;
esac

# }}}

# source my aliases
source $HOME/.dotfiles/zsh/aliases.sh

# fuzzy finder configuration {{{

# export FZF_DEFAULT_OPTS='--height 40% --border --preview="cat {}" --preview-window=right:60%:wrap'

#export FZF_PREVIEW_COMMAND='bat {}'
#export FZF_DEFAULT_OPTS="
#  --color=dark
#  --color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
#  --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
#  --bind ctrl-a:select-all,ctrl-d:deselect-all,tab:toggle+up,shift-tab:toggle+down
#"
# Fzf completions
#source "/usr/local/opt/fzf/shell/completion.bash"
#source "/usr/local/opt/fzf/shell/key-bindings.bash"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# }}}


# pyenv stuff {{{

#   eval "$(pyenv init -)"
#   if which pyenv-virtualenv-init > /dev/null; then 
#     eval "$(pyenv virtualenv-init -)"
#   fi

# }}}


# autoinit {{{

# if [[ -n $ZSH_INIT_COMMAND ]]; then
#   echo "Running: $ZSH_INIT_COMMAND"
#   eval "$ZSH_INIT_COMMAND"
# fi

# }}}


# zsh keybindings {{{

# bindkey -v # enables vi mode, using -e = emacs
bindkey -e # enables vi mode, using -e = emacs
#
# export KEYTIMEOUT=1
# bindkey ‘^R’ history-incremental-search-backward
# bindkey '^P' up-history
# bindkey '^N' down-history
# bindkey '^U' autosuggest-accept

# }}}


# finishing {{{

# source my aliases
source $DOTFILES/zsh/aliases.sh

# common settings for bash and zsh
source $HOME/.dotfiles/zsh/common.sh

# source local config file, if exists
# [[ -f "$HOME/.zshrc_local" ]] && source $HOME/.zshrc_local

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
  export KITTY_PORT=`kitty @ ls 2>/dev/null | grep "[0-9]:/tmp/mykitty" | head -n 1 | cut -d : -f 1 | cut -d \" -f 2`
fi

# }}}


# vim: fdm=marker ft=zsh
