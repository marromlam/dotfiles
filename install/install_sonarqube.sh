#!/usr/bin/env bash

set -euo pipefail

install_sonarqube() {
	# Install OpenJDK (required for sonarlint-language-server)
	brew_install_once "openjdk"

	# Create macOS system symlink for system-wide Java access
	if [[ "$OS_NAME" == "Darwin" ]]; then
		local openjdk_path
		openjdk_path="$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk"
		local java_link="/Library/Java/JavaVirtualMachines/openjdk.jdk"
		if [[ ! -L "$java_link" ]] && [[ ! -d "$java_link" ]]; then
			sudo ln -sfn "$openjdk_path" "$java_link"
		fi
	fi

	# Install sonarlint-language-server via Mason (nvim headless)
	local mason_bin="$HOME/.local/share/nvim/mason/bin/sonarlint-language-server"
	if [[ ! -f "$mason_bin" ]]; then
		if command -v nvim >/dev/null 2>&1; then
			nvim --headless -c "MasonInstall sonarlint-language-server" -c "qa"
		else
			echo "nvim not found; skipping sonarlint-language-server Mason install."
		fi
	fi
}

# If sourced (from install_dependencies.sh), functions are available but not run.
# If executed directly, run install_sonarqube.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	# Need brew_install_once and OS_NAME when run standalone
	if ! command -v brew >/dev/null 2>&1; then
		echo "brew not found. Run install_dependencies.sh first."
		exit 1
	fi
	OS_NAME="$(uname -s)"
	brew_install_once() {
		local pkg="$1"
		if brew list --formula "$pkg" >/dev/null 2>&1; then return; fi
		brew install "$pkg" || brew reinstall "$pkg" || echo "Failed to install $pkg; continuing."
	}
	install_sonarqube
fi
