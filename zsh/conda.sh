#!/bin/bash
# create a boostrap installer for conda
#

CONDA_PREFIX=$HOME/conda
export CONDA_ORIGIN=$HOME/conda


function __boostrap_conda() {
  # create a boostrap installer for conda taking into account
  # the operating system
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
      CONDA_OS="Linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
      CONDA_OS="MacOSX"
  elif [[ "$OSTYPE" == "cygwin" ]]; then
      CONDA_OS="Windows"
  elif [[ "$OSTYPE" == "msys" ]]; then
      CONDA_OS="Windows"
  elif [[ "$OSTYPE" == "win32" ]]; then
      CONDA_OS="Windows"
  elif [[ "$OSTYPE" == "freebsd"* ]]; then
      CONDA_OS="Linux"
  else
      echo "Unknown OS: $OSTYPE"
      exit 1
  fi

  # download the boostrap installer
  CONDA_URL="https://repo.continuum.io/miniconda/Miniconda3-latest-$CONDA_OS-x86_64.sh"
  CONDA_INSTALLER="$HOME/miniconda.sh"
  wget $CONDA_URL -O $CONDA_INSTALLER

  # install conda, withoud prompting the user
  # and without adding the conda path to the .bashrc
  bash $CONDA_INSTALLER -b -p $CONDA_ORIGIN
}

function conda() {
  # check if the conda prefix exists
  # if it does not exist, then install conda
  if [[ ! -d "$CONDA_PREFIX" ]]; then
      __boostrap_conda
  fi
  source $CONDA_PREFIX/bin/activate
  unset -f __boostrap_conda
  # unset -f conda
  conda $@
}

# vim: ft=bash
