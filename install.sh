# Might as well ask for password up-front, right?
echo "Starting install script, please grant me sudo access..."
sudo -v

# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# machine type
export MACHINEOS=`$HOME/.dotfiles/scripts/machine.sh`

# Set OS-dependent stuff
if [[ "$MACHINEOS" == "Mac" ]]; then
  rm -rf ${HOME}/tmp/homebrew.sh
  curl --create-dirs -O --output-dir ${HOME}/tmp/ https://raw.githubusercontent.com/marromlam/dotfiles/main/homebrew/linuxbrew.sh
  bash ${HOME}/tmp/linuxbrew.sh
else
  # linuxbrew path
  export HOMEBREW_PREFIX="$HOME/.linuxbrew"
fi

# install private dotfiles
curl --create-dirs -O --output-dir ${HOME}/tmp/ https://raw.githubusercontent.com/marromlam/dotfiles/main/homebrew/keys.sh
bash ${HOME}/tmp/keys.sh
