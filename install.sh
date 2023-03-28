# Might as well ask for password up-front, right?
set -e
echo "Starting install script, please grant me sudo access..."
sudo -v

# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# machine type
export MACHINEOS=`$HOME/.dotfiles/scripts/machine.sh`

# clone temp dir
curl --create-dirs -O --output-dir ${HOME}/tmp/ https://raw.githubusercontent.com/marromlam/dotfiles/main/homebrew/linuxbrew.sh
curl --create-dirs -O --output-dir ${HOME}/tmp/ https://raw.githubusercontent.com/marromlam/dotfiles/main/homebrew/homebrew.sh
curl --create-dirs -O --output-dir ${HOME}/tmp/ https://raw.githubusercontent.com/marromlam/dotfiles/main/extra/keys.sh
curl --create-dirs -O --output-dir ${HOME}/tmp/ https://raw.githubusercontent.com/marromlam/dotfiles/main/extra/dotfiles.sh

if [[ "$MACHINEOS" == "Mac" ]]; then
  # rm -rf ${HOME}/tmp/homebrew.sh
  bash ${HOME}/tmp/homebrew.sh
else
  # linuxbrew path
  export HOMEBREW_PREFIX="$HOME/.linuxbrew"
  bash ${HOME}/tmp/linuxbrew.sh
fi

# install private dotfiles
printf " \n\n"
bash ${HOME}/tmp/keys.sh $1

# clone dotfiles
printf " \n\n"
bash ${HOME}/tmp/dotfiles.sh $1
source ${HOME}/.dotfiles/scripts/reload_shell
chsh -s `which zsh`

# clone dotfiles
printf " \n\n"
./.dotfiles/install

