echo $IS_TMUX
# Get machine operative system
export MACHINEOS=`$HOME/fictional-couscous/scripts/machine.sh`
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

# Set homebrew path
if [[ "$MACHINEOS" == "Mac" ]]; then
  export HOMEBREW="/usr/local"
else
  export HOMEBREW="$HOME/.masterbrew"
  eval $($HOMEBREW/bin/brew shellenv)
fi
export XDG_DATA_DIRS="$HOMEBREW/share:$XDG_DATA_DIRS"

# Use Powerlevel10k if zsh is new enough, else use starship
MIN_ZSH_VERSION=5.1.0
THE_ZSH_VERSION=`echo $ZSH_VERSION`
if [ $(version $THE_ZSH_VERSION) -ge $(version $MIN_ZSH_VERSION) ]; then
  # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
  # Initialization code that may require console input (password prompts, [y/n]
  # confirmations, etc.) must go above this block; everything else may go below.
  source $HOMEBREW/opt/powerlevel10k/powerlevel10k.zsh-theme
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
else
  eval "$(starship init zsh)"
fi

# export languages
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# navigate words with arrows
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word



# fuzzy finder configuration --------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --border --preview="cat {}" --preview-window=right:60%:wrap'



# pyenv stuff -----------------------------------------------------------------
#   eval "$(pyenv init -)"
#   if which pyenv-virtualenv-init > /dev/null; then 
#     eval "$(pyenv virtualenv-init -)"
#   fi



# zsh completions -------------------------------------------------------------

# save history
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=999999999
export SAVEHIST=999999999
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# zsh suggestions
source $HOMEBREW/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# syntax highlighting                                                       
source $HOMEBREW/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

CASE_SENSITIVE="false"
setopt MENU_COMPLETE
setopt no_list_ambiguous

autoload -Uz compinit
compinit
zstyle ':completion:*' menu yes select
# Completion for kitty
kitty + complete setup zsh | source /dev/stdin

if [[ -n $ZSH_INIT_COMMAND ]]; then
    echo "Running: $ZSH_INIT_COMMAND"
    eval "$ZSH_INIT_COMMAND"
fi



# finishing -------------------------------------------------------------------
# common denominator (bash/zsh) profile
source $HOME/.sh_profile

# colorize everything
if [[ "$MACHINEOS" == "Mac" ]]; then
  export CLICOLOR=1
  export LSCOLORS=GxFxCxDxBxegedabagaced
else
  export LSCOLORS=GxFxCxDxBxegedabagaced
  alias ls="ls --color='auto'"
fi

if [ -n "$TMUX" ]; then                                                                               
  export IS_TMUX=1
else                                                                                                  
  if [ -z ${IS_TMUX+x} ]; then
    export IS_TMUX=0
  fi
fi

eval "$(starship init zsh)"
#POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/marcos/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/marcos/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/marcos/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/marcos/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

