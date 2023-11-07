# Might as well ask for password up-front, right?
set -e
echo "Starting install script, please grant me sudo access..."
sudo -v

# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
while true; do
	sudo -n true
	sleep 60
	kill -0 "$$" || exit
done 2>/dev/null &

# machine type
# first check if there is a .machine file in the home directory
# if not, then check the hostname
if [ -f ~/.machine ]; then
	MACHINEOS=$(cat ~/.machine)
else
	unameOut="$(uname -s)"
	case "${unameOut}" in
	Linux*) MACHINEOS=Linux ;;
	Darwin*) MACHINEOS=Mac ;;
	CYGWIN*) MACHINEOS=Cygwin ;;
	MINGW*) MACHINEOS=MinGw ;;
	*) MACHINEOS="UNKNOWN:${unameOut}" ;;
	esac
	echo $MACHINEOS >~/.machine
fi
echo "Machine: $MACHINEOS"

# clone temp dir
REPO_URL=https://raw.githubusercontent.com/marromlam/dotfiles
REPO_BRANCH=main
mkdir -p ${HOME}/tmp
curl -o ${HOME}/tmp/linuxbrew.sh $REPO_URL/$REPO_BRANCH/homebrew/linuxbrew.sh
curl -o ${HOME}/tmp/homebrew.sh $REPO_URL/$REPO_BRANCH/homebrew/homebrew.sh
curl -o ${HOME}/tmp/keys.sh $REPO_URL/$REPO_BRANCH/extra/keys.sh
curl -o ${HOME}/tmp/dotfiles.sh $REPO_URL/$REPO_BRANCH/extra/dotfiles.sh
curl -o ${HOME}/tmp/reload_shell $REPO_URL/$REPO_BRANCH/scripts/reload_shell

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
bash ${HOME}/tmp/dotfiles.sh -dotfiles
sudo chsh -s $(which zsh)

# clone dotfiles
printf " \n\n"
~/Projects/personal/dotfiles/install
