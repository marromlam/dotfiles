echo "================================================================================"
echo "Clone dotfiles"
echo "--------------------------------------------------------------------------------";

set -e

DOTFILES=${HOME}/.dotfiles

if test "$1" = "-f"; then
  rm -rf $DOTFILES
fi

echo $DOTFILES

if [ -d "$DOTFILES" ]; then
  echo "Dotfiles have already been cloned into the home dir"
else
  echo "Cloning dotfiles"
  git clone git@github.com:marromlam/dotfiles.git $DOTFILES
fi

cd $DOTFILES
git pull
git submodule update --init --recursive

exit 0

echo "--------------------------------------------------------------------------------";
echo "Done "
echo "================================================================================"