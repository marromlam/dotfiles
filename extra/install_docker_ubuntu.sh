#!/usr/bin/env bash
set -euo pipefail

. /etc/os-release

install_docker() {
  local os="$1"
  local codename="$2"

  echo "Installing Docker for $os ($codename)..."

  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL "https://download.docker.com/linux/${os}/gpg" -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${os} \
    ${codename} stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  echo "Docker installed successfully."
  docker --version
}

if [[ "$ID" == "ubuntu" ]]; then
  install_docker "ubuntu" "${UBUNTU_CODENAME:-$VERSION_CODENAME}"
elif [[ "$ID" == "debian" ]]; then
  install_docker "debian" "$VERSION_CODENAME"
else
  echo "Unsupported OS: $ID. This script supports Ubuntu and Debian only." >&2
  exit 1
fi

echo "Docker installed successfully."
docker --version

sudo usermod -aG docker "$USER"
newgrp docker
echo "User '$USER' added to the docker group."
