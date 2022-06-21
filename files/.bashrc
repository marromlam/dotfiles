# bashrc


# Eval homebrew {{{
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
# source $HOME/.dotfiles/zsh/zshenv

# variable with current host name
function whoismyhost (){
  echo "$(hostname)"
}

echo "Connected to $(whoismyhost) with bash"

# . ~/.sh_profile

export HOMEBREW_PREFIX="/home3/marcos.romero/.linuxbrew"
eval $($HOMEBREW_PREFIX/bin/brew shellenv)


bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'
bind 'TAB: menu-complete'

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
source "$HOME/.dotfiles/zsh/prompt-basic.sh"

# finishing {{{

# source my aliases
source $HOME/.dotfiles/zsh/aliases.sh

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
