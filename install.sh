#!/usr/bin/env bash
###############################################################################
#                                                                             #
# Bootstrap installer — run with:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/marromlam/dotfiles/main/install.sh)"
#                                                                             #
###############################################################################

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Workspaces/personal/dotfiles}"
REPO_URL="https://github.com/marromlam/dotfiles.git"

step() { echo; echo "==> $*"; }

# ------------------------------------------------------------------------------
# Detect machine type and write ~/.machine {{{
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

# }}}
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Install minimal apt packages needed to bootstrap (git, curl) {{{
# ------------------------------------------------------------------------------
# Only runs on Linux where apt is available

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

# }}}
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Download and run install_dependencies.sh from the repo {{{
# ------------------------------------------------------------------------------
# This installs Homebrew + all packages (including git and stow)
# before we can clone the full repo.

install_dependencies() {
	local raw_base="https://raw.githubusercontent.com/marromlam/dotfiles/main/install"
	# Every sibling script that install_dependencies.sh sources or execs must
	# be listed here so it lands next to the main script in the temp dir.
	# Mirroring the repo's install/ layout also lets install_dependencies.sh
	# resolve siblings via its own DOTFILES_ROOT logic if needed.
	local files=(
		"install_dependencies.sh"
		"install_sonarqube.sh"
		"install_keys.sh"
		"install_zsh.sh"
	)

	local tmp_root install_dir
	tmp_root="$(mktemp -d /tmp/dotfiles-bootstrap.XXXXXX)"
	install_dir="$tmp_root/install"
	mkdir -p "$install_dir"

	step "Downloading install scripts to $install_dir"
	local f
	for f in "${files[@]}"; do
		curl -fsSL "$raw_base/$f" -o "$install_dir/$f"
		chmod +x "$install_dir/$f"
	done

	step "Running install_dependencies.sh"
	bash "$install_dir/install_dependencies.sh"

	step "Running install_keys.sh"
	bash "$install_dir/install_keys.sh"

	step "Running install_zsh.sh"
	bash "$install_dir/install_zsh.sh"
}

# }}}
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Clone or update the dotfiles repo {{{
# ------------------------------------------------------------------------------
# Git is now available via Homebrew

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

# }}}
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Main {{{
# ------------------------------------------------------------------------------

detect_machine
apt_bootstrap
install_dependencies
clone_dotfiles

step "Running make install setup"
cd "$DOTFILES"
make install setup

# }}}
# ------------------------------------------------------------------------------


# vim: fdm=marker
