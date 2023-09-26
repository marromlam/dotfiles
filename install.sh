# Might as well ask for password up-front, right?
set -e
echo "Starting install script, please grant me sudo access..."
sudo -v

# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# machine type
unameOut="$(uname -s)"
case "${unameOut}" in
  Linux*)     MACHINEOS=Linux;;
  Darwin*)    MACHINEOS=Mac;;
  CYGWIN*)    MACHINEOS=Cygwin;;
  MINGW*)     MACHINEOS=MinGw;;
  *)          MACHINEOS="UNKNOWN:${unameOut}"
esac

# clone temp dir
curl --create-dirs -O --output-dir ${HOME}/tmp/ https://raw.githubusercontent.com/marromlam/dotfiles/main/homebrew/linuxbrew.sh
curl --create-dirs -O --output-dir ${HOME}/tmp/ https://raw.githubusercontent.com/marromlam/dotfiles/main/homebrew/homebrew.sh
curl --create-dirs -O --output-dir ${HOME}/tmp/ https://raw.githubusercontent.com/marromlam/dotfiles/main/extra/keys.sh
curl --create-dirs -O --output-dir ${HOME}/tmp/ https://raw.githubusercontent.com/marromlam/dotfiles/main/extra/dotfiles.sh
curl --create-dirs -O --output-dir ${HOME}/tmp/ https://raw.githubusercontent.com/marromlam/dotfiles/main/scripts/reload_shell

if [[ "$MACHINEOS" == "Mac" ]]; then
  echo "Installing homebrew on macOS (forced=$0)"
  bash ${HOME}/tmp/homebrew.sh $0
else
  echo "Installing homebrew on Linux (forced=$0)"
  export HOMEBREW_PREFIX="$HOME/.linuxbrew"
  bash ${HOME}/tmp/linuxbrew.sh $0
fi

# install private dotfiles
printf " \n\n"
bash ${HOME}/tmp/keys.sh $1

# create projects folder
mkdir -p ~/Projects/{work,personal}

# clone dotfiles
printf " \n\n"
bash ${HOME}/tmp/dotfiles.sh $1
source ${HOME}/tmp/reload_shell
chsh -s `which zsh`

# clone dotfiles
printf " \n\n"
./.dotfiles/install

