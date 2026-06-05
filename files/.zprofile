# Eval Homebrew {{{

[[ -f "$HOME/.dotfiles/scripts/machine-env.sh" ]] && source "$HOME/.dotfiles/scripts/machine-env.sh"

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
