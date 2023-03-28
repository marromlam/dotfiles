echo "================================================================================"
echo "Installing homebrew"
echo "--------------------------------------------------------------------------------";

set -e

if [[ "$(uname -m)" == "x86_64" ]]; then
  # intel / rosseta
  export HOMEBREW_PREFIX="/usr/local"
else
  # running on Apple Silicon
  export HOMEBREW_PREFIX="/opt/homebrew"
fi

if test "$1" = "-f"; then
  # rm -rf $HOMEBREW_PREFIX
  echo "Forcing homebrew install"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Not forcing homebrew install..."
fi

if [[ -d "$HOMEBREW_PREFIX" ]]; then
  xcode-select --install
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed. Skipping."
fi

brew install stow

exit 0

echo "--------------------------------------------------------------------------------";
echo "Done "
echo "================================================================================"
