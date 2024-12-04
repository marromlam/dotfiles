#!/usr/bin/env bash

if [[ -d "$HOMEBREW_PREFIX/Cellar/kitty" ]]; then
	echo "kitty is already installed"
else
	VERSION=0.36.4 # latest centOS 7 compatible kitty
	mkdir $HOMEBREW_PREFIX/Cellar/kitty
	pushd $HOMEBREW_PREFIX/Cellar/kitty
	wget https://github.com/kovidgoyal/kitty/releases/download/v$VERSION/kitty-$VERSION-x86_64.txz -O kitty.txz
	tar xf kitty.txz -C $HOMEBREW_PREFIX/Cellar/kitty
	ln -sf $HOMEBREW_PREFIX/Cellar/kitty/bin/kitty $HOMEBREW_PREFIX/bin
	rm kitty.txz
	popd
fi

# vim: fdm=marker
