#!/usr/bin/env bash

if [[ -d "$HOMEBREW_PREFIX" ]]; then
  eval $($HOMEBREW_PREFIX/bin/brew shellenv)
else
  git clone https://github.com/Homebrew/brew $HOMEBREW_PREFIX/Homebrew
  mkdir $HOMEBREW_PREFIX/bin
  ln -s $HOMEBREW_PREFIX/Homebrew/bin/brew $HOMEBREW_PREFIX/bin
  eval $($HOMEBREW_PREFIX/bin/brew shellenv)
fi

brew install stow

# vim: fdm=marker
