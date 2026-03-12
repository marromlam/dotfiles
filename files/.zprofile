# Eval Homebrew {{{

# Detect Homebrew prefix using zsh builtins (no subprocesses)
if [[ "$OSTYPE" == darwin* ]]; then
  if [[ "$CPUTYPE" == x86_64 ]]; then
    export HOMEBREW_PREFIX="/usr/local"
  else
    export HOMEBREW_PREFIX="/opt/homebrew"
  fi
else
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi
# WSL override
[[ -f ~/.machine ]] && export MACHINE="$(<~/.machine)"
[[ "$MACHINE" == "x64-wsl" ]] && export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"

# Cache brew shellenv to avoid spawning brew subprocess every shell start
_brew_shellenv_cache="$HOME/.cache/zsh/brew-shellenv.sh"
if [[ ! -f $_brew_shellenv_cache || "$(<"$_brew_shellenv_cache.prefix")" != "$HOMEBREW_PREFIX" ]]; then
  mkdir -p "${_brew_shellenv_cache:h}"
  $HOMEBREW_PREFIX/bin/brew shellenv >| "$_brew_shellenv_cache"
  echo "$HOMEBREW_PREFIX" >| "$_brew_shellenv_cache.prefix"
fi
source "$_brew_shellenv_cache"
unset _brew_shellenv_cache

export XDG_DATA_DIRS="$HOMEBREW_PREFIX/share:$XDG_DATA_DIRS"

# }}}
