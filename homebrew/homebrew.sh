echo "================================================================================"
echo "Installing homebrew"
echo "--------------------------------------------------------------------------------";

set -e

if [[ "$(uname -m)" == "x86_64" ]]; then
  # intel / rossetta
  export HOMEBREW_PREFIX="/usr/local"
else
  # running on Apple Silicon
  export HOMEBREW_PREFIX="/opt/homebrew"
fi

unset HOMEBREW_CELLAR
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"

if test "$1" = "-f"; then
  if [[ -d "$HOMEBREW_PREFIX" ]]; then
    # Remove contents without deleting the prefix directory itself.
    sudo bash -c 'shopt -s dotglob nullglob; rm -rf "$1"/*' _ "$HOMEBREW_PREFIX"
  fi
  echo "Forcing homebrew install"
else
  echo "Not forcing homebrew install..."
fi

if [[ ! -d "$HOMEBREW_PREFIX" ]]; then
  [[ ! -x git ]] && xcode-select --install || echo "cmd-line tools installed"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed. Skipping."
fi

eval $($HOMEBREW_PREFIX/bin/brew shellenv)
export XDG_DATA_DIRS="$HOMEBREW_PREFIX/share:$XDG_DATA_DIRS"
brew install stow

exit 0

echo "--------------------------------------------------------------------------------";
echo "Done "
echo "================================================================================"
