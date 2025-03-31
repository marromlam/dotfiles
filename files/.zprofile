# Eval Homebrew {{{

# Get machine operative system
export MACHINEOS=`$HOME/.dotfiles/scripts/machine.sh`

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
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi
export HOMEBREW_PREFIX="/opt/homebrew"
# read contents of ~/.machine
# if x64-wsl then 
if [[ -f ~/.machine ]]; then
  export MACHINE=`cat ~/.machine`
  if [[ "$MACHINE" == "x64-wsl" ]]; then
    export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  fi
fi
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
eval $($HOMEBREW_PREFIX/bin/brew shellenv)
export XDG_DATA_DIRS="$HOMEBREW_PREFIX/share:$XDG_DATA_DIRS"

# }}}
