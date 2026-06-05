#!/usr/bin/env bash
# Bootstrap installer — run with:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/marromlam/dotfiles/main/install.sh)"

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/personal/dotfiles}"
REPO_URL="https://github.com/marromlam/dotfiles.git"

step() { echo; echo "==> $*"; }

# ------------------------------------------------------------------------------
# Validate machine type from ~/.machine
# ------------------------------------------------------------------------------
ensure_machine_file() {
	if [[ ! -f "$HOME/.machine" ]]; then
		echo "Missing ~/.machine"
		echo "Create it with one allowed identifier, for example:"
		echo '  export MACHINE="x64-linux"'
		exit 1
	fi

	# shellcheck disable=SC1090
	source "$HOME/.machine"

	case "${MACHINE:-}" in
		arm64-darwin|x64-darwin|x64-linux|x64-wsl|x64-nodos|x64-codespaces|arm64-linux|x32-linux)
			echo "$HOME/.machine set: $MACHINE"
			;;
		*)
			echo "Invalid MACHINE='${MACHINE:-}' in ~/.machine"
			echo "Allowed: arm64-darwin, x64-darwin, x64-linux, x64-wsl, x64-nodos, x64-codespaces, arm64-linux, x32-linux"
			exit 1
			;;
	esac
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
ensure_machine_file
apt_bootstrap
install_dependencies
clone_dotfiles

step "Running make install setup"
cd "$DOTFILES"
make install setup
