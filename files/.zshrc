# Get machine operative system
export MACHINEOS=`$HOME/fictional-couscous/scripts/machine.sh`

# Set homebrew path
if [[ "$MACHINEOS" == "Mac" ]]; then
  export HOMEBREW="/usr/local"
else
  export HOMEBREW="$HOME/.masterbrew"
  eval $($HOMEBREW/bin/brew shellenv)
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#export XDG_DATA_DIRS="/home3/marcos.romero/.linuxbrew/share:$XDG_DATA_DIRS"
source $HOMEBREW/opt/powerlevel10k/powerlevel10k.zsh-theme
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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

if [[ "$MACHINEOS" == "Mac" ]]; then
  export XDG_DATA_DIRS="$HOMEBREW/share:$XDG_DATA_DIRS"
  export CLICOLOR=1; export LSCOLORS=GxFxCxDxBxegedabagaced
else
  export CLICOLOR=1; export LSCOLORS=GxFxCxDxBxegedabagaced
  #export XDG_DATA_DIRS="$HOMEBREW/share:$XDG_DATA_DIRS"
fi

if [ -n "$TMUX" ]; then                                                                               
  export IS_TMUX=1
else                                                                                                  
  export IS_TMUX=0
fi

#eval "$(starship init zsh)"
#POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
