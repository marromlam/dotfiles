#!/usr/bin/env bash
# Post-symlink setup steps.
# Run after extra/symlinks.sh to install packages and configure the system.
#
# Usage: bash extra/setup.sh

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

step() { echo; echo "==> $*"; }

# ------------------------------------------------------------------------------
# Homebrew packages
# ------------------------------------------------------------------------------
step "Installing Homebrew packages"
bash "$DOTFILES/install/install_dependencies.sh"

# ------------------------------------------------------------------------------
# Git submodules (tpm, zsh plugins, etc.)
# ------------------------------------------------------------------------------
step "Updating git submodules"
git -C "$DOTFILES" submodule update --init --recursive

# ------------------------------------------------------------------------------
# macOS system settings
# ------------------------------------------------------------------------------
if [[ "$(uname)" == "Darwin" ]]; then
  step "Applying macOS settings"
  bash "$DOTFILES/extra/macos/macos_settings.sh"

  step "Applying keyboard config"
  bash "$DOTFILES/extra/keyboard.sh"
fi

# ------------------------------------------------------------------------------
# Python packages
# ------------------------------------------------------------------------------
if [[ -f "$DOTFILES/requirements.txt" ]]; then
  step "Installing Python packages"
  python3 -m pip install -r "$DOTFILES/requirements.txt"
fi

# ------------------------------------------------------------------------------
# Local gitconfig (machine-specific overrides, not tracked)
# ------------------------------------------------------------------------------
if [[ ! -f ~/.gitconfig.local ]]; then
  step "Creating ~/.gitconfig.local from template"
  cp "$DOTFILES/files/config.template" ~/.gitconfig.local
  echo "  Edit ~/.gitconfig.local to set your name/email"
fi

# ------------------------------------------------------------------------------
# tmux plugins via TPM
# ------------------------------------------------------------------------------
step "Installing tmux plugins"
tmux start-server
tmux new-session -d -s __setup__ 2>/dev/null || true
~/.local/share/tmux/plugins/tpm/scripts/install_plugins.sh
tmux kill-session -t __setup__ 2>/dev/null || true

echo
echo "Setup complete."

# vim: ft=bash
