# zsh shell config file
# add some fancy text with mr zshrc




source $HOME/.zprofile

# source basuc functions
source $HOME/.config/zsh/ufunctions.sh
source $HOME/.config/zsh/zshenv
source $HOME/.config/zsh/conda.sh

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


# Use a minimal prompt in Cursor to avoid command detection issues
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  PROMPT='%n@%m:%~%# '
  RPROMPT=''
  return
fi


# Plugins {{{

zmodload zsh/datetime

# Create a hash table for globally stashing variables without polluting main
# scope with a bunch of identifiers.
typeset -A __DOTS

## __DOTS[ITALIC_ON]=$'\e[3m'
## __DOTS[ITALIC_OFF]=$'\e[23m'


PLUGIN_DIR=$DOTFILES/zsh/plugins

# Init completions
autoload -Uz compinit && compinit
eval "$(pixi completion --shell zsh)"


# These should be source *BEFORE* setting up hooks

# zsh suggestions
source $HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.config/zsh/plugins/alias-tips/alias-tips.plugin.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=241'
# ZSH_AUTOSUGGEST_USE_ASYNC=1
CASE_SENSITIVE="false"
setopt MENU_COMPLETE
setopt no_list_ambiguous
#zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==34=34}:${(s.:.)LS_COLORS}")';
ls_colors="di=1;34:ln=36:so=35:pi=33:ex=32:bd=40;33:cd=40;33:su=37;41:sg=30;43:tw=30;42:ow=34;42"
zstyle ':completion:*:default' list-colors "${(s.:.)ls_colors}"
zstyle ':completion:*' menu yes select

# syntax highlighting
source $HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
## 
## # source $HOMEBREW_PREFIX/share/zsh-completions/zsh-completions.zsh
## 
## source $HOMEBREW_PREFIX/share/zsh-alias-tips/alias-tips.plugin.zsh
## 
## autoload zmv # builtin zsh rename command
## 
## # }}}
## 
## 
## # zsh completions {{{
## 
## # Completion for kitty
## if [[ "$TERM" == "xterm-kitty" ]]; then
##   kitty + complete setup zsh | source /dev/stdin
## fi
## 
## # Colorize completions using default `ls` colors.
## zstyle ':completion:*' list-colors ''
## 
## # Enable keyboard navigation of completions in menu
## # (not just tab/shift-tab but cursor keys as well):
## zstyle ':completion:*' menu select
## 
## # persistent reshahing i.e puts new executables in the $path
## # if no command is set typing in a line will cd by default
## zstyle ':completion:*' rehash true
## 
## # Allow completion of ..<Tab> to ../ and beyond.
## zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(..) ]] && reply=(..)'
## 
## # Categorize completion suggestions with headings:
## zstyle ':completion:*' group-name ''
## # Style the group names
## zstyle ':completion:*' format %F{yellow}%B%U%{$__DOTS[ITALIC_ON]%}%d%{$__DOTS[ITALIC_OFF]%}%b%u%f
## 
## # Added by running `compinstall`
## zstyle ':completion:*' expand suffix
## zstyle ':completion:*' file-sort modification
## zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
## zstyle ':completion:*' list-suffixes true
## # End of lines added by compinstall
## 
## # Make completion:
## # (stolen from Wincent)
## # - Try exact (case-sensitive) match first.
## # - Then fall back to case-insensitive.
## # - Accept abbreviations after . or _ or - (ie. f.b -> foo.bar).
## # - Substring complete (ie. bar -> foobar).
## zstyle ':completion:*' matcher-list '' '+m:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}' '+m:{_-}={-_}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
## 
## # }}}
## 
## 
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

# source "$HOME/.dotfiles/zsh/prompt.sh"
# source "$HOME/.dotfiles/zsh/prompt2.sh"
# source "$HOME/.dotfiles/zsh/prompt3.sh"

case `uname` in
  Darwin)
    source "$HOME/.config/zsh/macos.sh"
    source "$HOME/.config/zsh/prompt.sh"
    ;;
  Linux)
    source "$HOME/.config/zsh/linux.sh"
    source "$HOME/.config/zsh/prompt.sh"
    [[ ! -f /etc/resolv.conf ]] && echo nameserver 8.8.8.8 | sudo tee /etc/resolv.conf
    # source "$HOME/.dotfiles/zsh/prompt-basic.sh"
    # source "$HOME/.dotfiles/zsh/prompt2.sh"
    ;;
esac


# # USGC BASH PROMPT
# if [[ $- == *i* ]]; then
#   export CLICOLOR=1
#   export LSCOLORS=GxFxCxDxBxegedabagaced
#   export PS1="\[$(tput setaf 7)\]❬\h❭ \[$(tput setaf 2)\]\W\[$(tput setaf 1)\] ●\[$(tput sgr0)\] "
# fi


# test if ~/.wsl exists and source zsh/windows.sh if it does
if [[ -f ~/.wsl ]]; then
  source "$HOME/.config/zsh/windows.sh"
fi

# }}}


# fuzzy finder configuration {{{

export FZF_DEFAULT_OPTS='
--bind ctrl-a:select-all,ctrl-d:deselect-all,tab:toggle+down,shift-tab:toggle+up
--height 50%
'
# --color header:italic
# --pointer '❯'
# '

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:-1,fg+:3,bg:-1,bg+:0
  --color=hl:5,hl+:5,info:4,marker:6
  --color=prompt:4,spinner:6,pointer:3,header:1
  --color=gutter:-1,border:-1,label:0,query:#d9d9d9
  --preview-window="border-sharp"
  --prompt="󰍉 "
  --marker="◆"
  --pointer="▸"
  --separator=""
  --scrollbar="🮉"
  --layout="reverse-list"
  --info="inline"'






# --color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
# --border
# --preview="bat {}"
# --color=dark
# --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
# --preview-window=right:60%:wrap
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh  # fzf-completions

# }}}






# zsh keybindings {{{

# bindkey -v # enables vi mode
bindkey -e # emacs
# }}}


# finishing {{{

# source my aliases
source $HOME/.config/zsh/aliases.sh

# common settings for bash and zsh
source $HOME/.config/zsh/common.sh
source $HOME/.config/zsh/tmux_aliases.sh
source $HOME/.config/zsh/scripts/fzf.sh
source $HOME/.config/zsh/scripts/docker.sh
# source $HOME/.dotfiles/zsh/nvims.sh

# source local config file, if exists
[[ -f "$HOME/.zshrc_local" ]] && source $HOME/.zshrc_local

# auto activate environment on .aa-env file
# eval "$(direnv hook zsh)"
# source $(brew --prefix)/opt/autoenv/activate.sh
export DIRENV_LOG_FORMAT=""
eval "$(asdf exec direnv hook zsh)"

alias docker-cleanup='docker system prune -a --volumes'


# }}}


# vim: fdm=marker ft=zsh
