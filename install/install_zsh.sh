#!/usr/bin/env bash

set -euo pipefail

FORCE_INSTALL=0
if [[ "${1:-}" == "--force" ]]; then
	FORCE_INSTALL=1
fi

PLUGIN_ROOT="${HOME}/.local/share/zsh/plugins"
mkdir -p "$PLUGIN_ROOT"

clone_plugin_once() {
	local name="$1"
	local repo="$2"
	local dest="${PLUGIN_ROOT}/${name}"

	if [[ -d "$dest" ]]; then
		if [[ "$FORCE_INSTALL" -eq 1 ]]; then
			rm -rf "$dest"
		else
			echo "${name} already installed. Skipping."
			return
		fi
	fi

	git clone --depth 1 "$repo" "$dest"
}

clone_plugin_once "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
clone_plugin_once "alias-tips" "https://github.com/djui/alias-tips.git"
clone_plugin_once "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
clone_plugin_once "fzf-marks" "https://github.com/urbainvaes/fzf-marks.git"
clone_plugin_once "zsh-auto-notify" "https://github.com/MichaelAquilina/zsh-auto-notify.git"
clone_plugin_once "zsh-autopair" "https://github.com/hlissner/zsh-autopair.git"
clone_plugin_once "zsh-completions" "https://github.com/zsh-users/zsh-completions.git"
