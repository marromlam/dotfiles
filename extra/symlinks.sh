#!/usr/bin/env bash
# Create symlinks from the dotfiles repo into $HOME.
# Replaces what dotbot's install.conf.yaml used to do.
#
# Usage: bash extra/symlinks.sh [--force]

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORCE=0
[[ "${1:-}" == "--force" ]] && FORCE=1

link() {
  local src="$1" dst="$2"
  if [[ $FORCE -eq 1 ]]; then
    ln -sfn "$src" "$dst"
  elif [[ -e "$dst" || -L "$dst" ]]; then
    echo "  skip  $dst (already exists, use --force to overwrite)"
    return
  else
    ln -sn "$src" "$dst"
  fi
  echo "  link  $dst -> $src"
}

# ------------------------------------------------------------------------------
# Create directories
# ------------------------------------------------------------------------------
mkdir -p ~/.ssh && chmod 600 ~/.ssh
mkdir -p ~/.config
mkdir -p ~/Projects/work ~/Projects/personal

# ------------------------------------------------------------------------------
# Symlinks
# ------------------------------------------------------------------------------
link "$DOTFILES/files/.gitconfig"    ~/.gitconfig
link "$DOTFILES/files/.gitmessage"   ~/.gitmessage
link "$DOTFILES/files/.bash_profile" ~/.bash_profile
link "$DOTFILES/files/.bashrc"       ~/.bashrc
link "$DOTFILES/files/.zshrc"        ~/.zshrc
link "$DOTFILES/files/.zprofile"     ~/.zprofile
link "$DOTFILES/files/.sh_profile"   ~/.sh_profile
link "$DOTFILES/files/.rgignore"     ~/.rgignore
link "$DOTFILES/files/.config"       ~/.config
link "$DOTFILES/files/.hammerspoon"  ~/.hammerspoon
link "$DOTFILES/files/.amethyst.yml" ~/.amethyst.yml
link "$DOTFILES"                     ~/.dotfiles

# SSH keys live in private-dotfiles
if [[ -d ~/Projects/personal/private-dotfiles/files/.ssh ]]; then
  link ~/Projects/personal/private-dotfiles/files/.ssh ~/.ssh
fi

echo "Done."

# vim: ft=bash
