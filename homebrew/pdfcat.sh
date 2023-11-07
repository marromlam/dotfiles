#!/usr/bin/env bash

if [[ -d "$HOMEBREW_PREFIX/Cellar/termpdf.py" ]]; then
  echo "termpdf is already installed"
else
  git clone git@github.com:marromlam/pdfcat.git $HOMEBREW_PREFIX/Cellar/termpdf.py
  pushd $HOMEBREW_PREFIX/Cellar/termpdf.py
  $HOMEBREW_PREFIX/bin/python3 -m pip install -r requirements.txt
  $HOMEBREW_PREFIX/bin/python3 -m pip install -e ../termpdf.py
  ln -sf $HOMEBREW_PREFIX/Cellar/termpdf.py/termpdf.py $HOMEBREW_PREFIX/bin
  ln -sf $HOMEBREW_PREFIX/Cellar/termpdf.py/termpdf.py $HOMEBREW_PREFIX/bin/pdfcat
  popd
fi

# vim: fdm=marker
