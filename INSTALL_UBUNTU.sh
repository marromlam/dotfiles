# first give access to internet
# check if ~/.machine contains wsl substring

sudo -v

# check is machine is wsl

sudo sed -i -E 's/nameserver [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/nameserver 8.8.8.8/'
# now WSL should have internet access

# install meson
#

sudo apt-get update
sudo apt-get upgrade

sudo apt-get install software-properties-common python3-software-properties -y

sudo add-apt-repository ppa:kisak/kisak-mesa
sudo apt-get upgrade

# sudo apt install x11-apps mesa-utils

# install all necesary packages for installing homebrew
sudo apt-get install build-essential curl file git ruby zsh -y

# install docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
