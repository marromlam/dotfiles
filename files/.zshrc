#                                                        
#                         ,dPYb,                         
#                         IP'`Yb                         
#                         I8  8I                         
#                         I8  8'                         
#       ,gggg,    ,g,     I8 dPgg,    ,gggggg,    ,gggg, 
#      d8"  Yb   ,8'8,    I8dP" "8I   dP""""8I   dP"  "Yb
#     dP    dP  ,8'  Yb   I8P    I8  ,8'    8I  i8'      
#   ,dP  ,adP' ,8'_   8) ,d8     I8,,dP     Y8,,d8,_    _
#   8"   ""Y8d8P' "YY8P8P88P     `Y88P      `Y8P""Y8888PP
#         ,d8I'                                          
#       ,dP'8I                                           
#      ,8"  8I     zsh configuration file                                  
#      I8   8I                                           
#      `8, ,8I                                           
#       `Y8P"      Marcos Romero Lamas                                   
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
    export HOMEBREW="/usr/local"
  else
    # running on Apple Sillicon
    export HOMEBREW="/opt/homebrew"
  fi
else
  # linuxbrew path
  export HOMEBREW="$HOME/.linuxbrew"
fi
eval $($HOMEBREW/bin/brew shellenv)
export XDG_DATA_DIRS="$HOMEBREW/share:$XDG_DATA_DIRS"

# export languages
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# }}}


# Use Powerlevel10k if zsh is new enough, else use starship {{{

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
  function whoismyhost (){
    a="$(ip route get 1 | awk '{print $NF;exit}')"
    b=`echo "$a" | sed 's/^.*\.\([^.]*\)$/\1/'`
    #echo $a
    #echo $b
    if [[ $a == 172.16.57.* ]]; then
      echo "gpu"$b
    elif [[ $a == 172.16.58.1 ]]; then
      echo "master"
    elif [[ $a == 193.144.80.1 ]]; then
      echo "pool"
    else
      echo "nodo0"$b
    fi
  }
  export CURRENT_HOST="$(whoismyhost)"
fi

# }}}


# fuzzy finder configuration {{{

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --border --preview="cat {}" --preview-window=right:60%:wrap'

# }}}


# pyenv stuff {{{

#   eval "$(pyenv init -)"
#   if which pyenv-virtualenv-init > /dev/null; then 
#     eval "$(pyenv virtualenv-init -)"
#   fi

# }}}


# zsh completions {{{

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
#zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==34=34}:${(s.:.)LS_COLORS}")';
ls_colors="di=1;34:ln=36:so=35:pi=33:ex=32:bd=40;33:cd=40;33:su=37;41:sg=30;43:tw=30;42:ow=34;42"
zstyle ':completion:*:default' list-colors "${(s.:.)ls_colors}"
zstyle ':completion:*' menu yes select
autoload -Uz compinit
compinit

if [[ -n $ZSH_INIT_COMMAND ]]; then
  echo "Running: $ZSH_INIT_COMMAND"
  eval "$ZSH_INIT_COMMAND"
fi

# }}}


# OS-dependent stuff {{{

if [[ "$MACHINEOS" == "Mac" ]]; then
  # colorize
  export CLICOLOR=1
  export LSCOLORS=GxFxCxDxBxegedabagaced
  alias ls="ls --color='auto'"
  # jukitty to have same completion as vim
  compdef jukitty=nvim
  compdef texkitty=nvim
  # Completion for kitty
  kitty + complete setup zsh | source /dev/stdin
  if test -e "/Applications/kitty.app/Contents/Resources/kitty/shell-integration/kitty.zsh"; then source "/Applications/kitty.app/Contents/Resources/kitty/shell-integration/kitty.zsh"; fi
else
  # colorize
  export LSCOLORS=GxFxCxDxBxegedabagaced
  alias ls="ls --color='auto'"
fi

# }}}


# finishing {{{

# common settings for bash and zsh
source $HOME/.sh_profile
# source local config file, if exists
[[ -f "$HOME/.zshrc_local" ]] && source $HOME/.zshrc_local

# check whether tmux is running or not, and export variable
if [ -n "$TMUX" ]; then                                                                               
  export IS_TMUX=1
else                                                                                                  
  if [ -z ${IS_TMUX+x} ]; then
    export IS_TMUX=0
  fi
fi

# }}}


# vim:foldmethod=marker
