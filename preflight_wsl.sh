# first give access to internet
# check if ~/.machine contains wsl substring
set -e
sudo -v

# check is machine is wsl

sudo sed -i -E 's/nameserver [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/nameserver 8.8.8.8/' /etc/resolv.conf

# install meson
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install software-properties-common python3-software-properties python3-launchpadlib -y
sudo add-apt-repository ppa:kisak/kisak-mesa -y
sudo apt-get upgrade -y

# install kitty
sudo apt-get install kitty -y
# remove kisak
sudo rm -rf /etc/apt/sources.list.d/kisak-ubuntu-kisak-mesa-bookworm.list
sudo apt-get update -y

# install mesa-utils
sudo apt install x11-apps mesa-utils -y

# install all necesary packages for installing homebrew
sudo apt-get install build-essential curl file git ruby zsh -y

# # install docker
# sudo apt-get update
# sudo apt-get install ca-certificates curl gnupg
# sudo install -m 0755 -d /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# sudo chmod a+r /etc/apt/keyrings/docker.gpg
#
# # Add the repository to Apt sources:
# echo \
# 	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
# 	sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
# sudo apt-get update
# sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# install docker daemon for debian {{{
#
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
	sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# }}}

echo 'Finished preparing the system for installing homebrew'
echo 'Test kitty is working using the following command:'
echo 'KITTY_DISABLE_WAYLAND=1 LIBGL_ALWAYS_INDIRECT=0 LIBGL_ALWAYS_SOFTWARE=1 kitty -o linux_display_server=x11'
