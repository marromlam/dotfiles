# This script installs xdg-open on Windows Subsystem for Linux (WSL) using
# Homebrew.
# WARNING: Do no install on a non-WSL system, it will break your xdg-open!

# Skip installation if not on WSL
if [ ! -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
	echo "Not on WSL"
	exit 0
fi

# Skip installation if xdg-open is already installed
if [ -f $HOMEBREW_PREFIX/Cellar/xdg-open/xdg_open_wsl.py ]; then
	echo "xdg-open already installed"
	exit 0
fi

# create a dir for xdg-open script in Homebrew/Cellar
mkdir -p $HOMEBREW_PREFIX/Cellar/xdg-open

# download xdg-open script from github
pushd $HOMEBREW_PREFIX/Cellar/xdg-open
wget -O xdg_open_wsl.py https://raw.githubusercontent.com/cpbotha/xdg-open-wsl/master/xdg_open_wsl/xdg_open_wsl.py

chmod +x xdg_open_wsl.py
popd

# link xdg-open to open and put it in Homebrew bin
ln -sf $HOMEBREW_PREFIX/Cellar/xdg-open/xdg_open_wsl.py $HOMEBREW_PREFIX/bin/xdg-open
ln -sf $HOMEBREW_PREFIX/bin/xdg-open $HOMEBREW_PREFIX/bin/open

# vim: ft=sh
