echo "================================================================================"
echo "Clone dotfiles"
echo "--------------------------------------------------------------------------------"

set -e

DOTFILES=${HOME}/Projects/personal/dotfiles

if test "$1" = "-dotfiles"; then
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

echo "--------------------------------------------------------------------------------"
echo "Done "
echo "================================================================================"
exit 0
