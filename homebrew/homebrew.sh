echo "================================================================================"
echo "Installing homebrew"
echo "--------------------------------------------------------------------------------";

set -e

if [[ "$(uname -m)" == "x86_64" ]]; then
  # intel / rosseta
  export HOMEBREW_PREFIX="/usr/local/homebrew"
else
  # running on Apple Silicon
  export HOMEBREW_PREFIX="/opt/homebrew"
fi

if test "$1" = "-f"; then
  sudo rm -rf $HOMEBREW_PREFIX
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
