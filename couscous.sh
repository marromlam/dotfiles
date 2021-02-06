#!/usr/bin/env bash

THEME=$1

ls ~/.config/kitty/kitty-themes/themes 


# Change kitty theme
kitty @ set-colors -a "~/.config/kitty/kitty-themes/themes/$THEME.conf"
rm $HOME/.config/kitty/theme.conf
ln -s $HOME/.config/kitty/kitty-themes/themes/$THEME.conf $HOME/.config/kitty/theme.conf 
