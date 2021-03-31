#!/usr/bin/env bash

THEME=$1
KITTYTHEMES=$HOME/.config/kitty/kitty-themes

# clone all kitty themes if needed
if [ ! -d $KITTYTHEMES ]; then
  git clone --depth 1 http://github.com/dexpota/kitty-themes.git $KITTYTHEMES
fi

# show all themes
ls $KITTYTHEMES/themes

# Change kitty theme
kitty @ set-colors -a "$KITTYTHEMES/themes/$THEME.conf"
rm -rf $HOME/.config/kitty/theme.conf
ln -s $KITTYTHEMES/themes/$THEME.conf $HOME/.config/kitty/theme.conf 
