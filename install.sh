#!/usr/bin/env bash
# Bootstrap installer — run with:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/marromlam/dotfiles/main/install.sh)"

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/personal/dotfiles}"
REPO_URL="https://github.com/marromlam/dotfiles.git"

step() { echo; echo "==> $*"; }

# ------------------------------------------------------------------------------
# Detect machine type and write ~/.machine
# ------------------------------------------------------------------------------
detect_machine() {
	if [[ -f "$HOME/.machine" ]]; then
		echo "$HOME/.machine already set: $(cat "$HOME/.machine")"
		return
	fi

	local os arch
	os="$(uname -s)"
	arch="$(uname -m)"

	local machine
	case "$os" in
		Darwin)
			if [[ "$arch" == "arm64" ]]; then machine="arm64-darwin"
			else machine="x64-darwin"
			fi ;;
		Linux)
			if grep -qi microsoft /proc/version 2>/dev/null; then machine="x64-wsl"
			elif [[ "$arch" == "x86_64" ]]; then machine="x64-linux"
			elif [[ "$arch" == "aarch64" ]]; then machine="arm64-linux"
			elif [[ "$arch" == "i686" ]]; then machine="x32-linux"
			else machine="x64-linux"
			fi ;;
		*) machine="x64-linux" ;;
	esac

	echo "$machine" > "$HOME/.machine"
	echo "Detected machine: $machine"
}

# ------------------------------------------------------------------------------
# Install minimal apt packages needed to bootstrap (git, curl)
# Only runs on Linux where apt is available
# ------------------------------------------------------------------------------
apt_bootstrap() {
	if ! command -v apt-get >/dev/null 2>&1; then
		return
	fi
	if ! command -v curl >/dev/null 2>&1; then
		step "Installing curl via apt"
		sudo apt-get update -qq
		sudo apt-get install -y curl
	fi
}

# ------------------------------------------------------------------------------
# Download and run install_dependencies.sh from the repo
# This installs Homebrew + all packages (including git and stow)
# before we can clone the full repo.
# ------------------------------------------------------------------------------
install_dependencies() {
	local raw_url="https://raw.githubusercontent.com/marromlam/dotfiles/main/install/install_dependencies.sh"
	local tmp_script
	tmp_script="$(mktemp /tmp/install_dependencies.XXXXXX.sh)"
	step "Downloading install_dependencies.sh"
	curl -fsSL "$raw_url" -o "$tmp_script"
	chmod +x "$tmp_script"
	step "Running install_dependencies.sh"
	bash "$tmp_script"
	rm -f "$tmp_script"
}

# ------------------------------------------------------------------------------
# Clone or update the dotfiles repo
# git is now available via Homebrew
# ------------------------------------------------------------------------------
clone_dotfiles() {
	if [[ -d "$DOTFILES/.git" ]]; then
		step "Updating dotfiles repo"
		git -C "$DOTFILES" pull --ff-only
	else
		step "Cloning dotfiles to $DOTFILES"
		mkdir -p "$(dirname "$DOTFILES")"
		git clone "$REPO_URL" "$DOTFILES"
	fi

	step "Updating submodules"
	git -C "$DOTFILES" submodule update --init --recursive
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
detect_machine
apt_bootstrap
install_dependencies
clone_dotfiles

step "Running make install setup"
cd "$DOTFILES"
make install setup
