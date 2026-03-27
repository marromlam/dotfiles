#!/usr/bin/env bash

set -euo pipefail

PLUGIN_ROOT="${HOME}/.local/share/zsh/plugins"
mkdir -p "$PLUGIN_ROOT"

clone_fresh() {
	local name="$1"
	local repo="$2"
	local dest="${PLUGIN_ROOT}/${name}"

	if [[ -d "$dest" ]]; then
		rm -rf "$dest"
	fi

	git clone --depth 1 "$repo" "$dest"
}

clone_fresh "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
clone_fresh "alias-tips" "https://github.com/djui/alias-tips.git"
clone_fresh "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
clone_fresh "fzf-marks" "https://github.com/urbainvaes/fzf-marks.git"
clone_fresh "zsh-auto-notify" "https://github.com/MichaelAquilina/zsh-auto-notify.git"
clone_fresh "zsh-autopair" "https://github.com/hlissner/zsh-autopair.git"
clone_fresh "zsh-completions" "https://github.com/zsh-users/zsh-completions.git"
