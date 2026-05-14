#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/marromlam/private-dotfiles.git"
DEST="${HOME}/Workspaces/personal/private-dotfiles"

if [[ "${1:-}" == "-f" ]]; then
	rm -rf "$DEST" "${HOME}/.ssh"
fi

echo "================================================================================"
echo "Installing ssh keys"
echo "--------------------------------------------------------------------------------"

if [[ ! -d "$DEST" ]]; then
	echo "Cloning $REPO_URL"
	echo "(git will prompt for username + personal access token)"
	git clone "$REPO_URL" "$DEST"
else
	echo "Updating existing clone at $DEST"
	git -C "$DEST" pull --ff-only
fi

case "$(uname)" in
	Linux)
		echo "Removing UseKeychain entries from ssh config (Linux)"
		sed -i '/UseKeychain/d' "$DEST/files/.ssh/config"
		;;
	Darwin)
		echo "Keychain may be used to unlock ssh keys (macOS)"
		;;
esac

ln -sf "$DEST/files/.ssh" "${HOME}/.ssh"
chmod 600 "${HOME}"/.ssh/* 2>/dev/null || true

echo "--------------------------------------------------------------------------------"
echo "Done"
echo "================================================================================"
