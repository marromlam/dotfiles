#!/usr/bin/env bash
# Create symlinks from the dotfiles repo into $HOME via GNU Stow.
# Idempotent: safe to run multiple times.
#
# Usage: bash extra/symlinks.sh [--force]
#   --force  Remove pre-existing symlinks not owned by stow before stowing.
#            Required on first migration from another symlink manager.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORCE=0
[[ "${1:-}" == "--force" ]] && FORCE=1

# ------------------------------------------------------------------------------
# Directories
# ------------------------------------------------------------------------------
mkdir -p ~/.ssh && chmod 700 ~/.ssh
mkdir -p ~/Projects/work ~/Projects/personal

# ------------------------------------------------------------------------------
# On --force: remove any existing symlinks for files in the stow package
# so stow can take ownership. Real files/dirs are left alone (resolve manually).
# ------------------------------------------------------------------------------
if [[ $FORCE -eq 1 ]]; then
  echo "==> Removing stale symlinks for stow package"
  while IFS= read -r -d '' f; do
    rel="${f#"$DOTFILES/files/"}"
    target="$HOME/$rel"
    [[ -L "$target" ]] && { echo "  unlink $target"; rm "$target"; }
  done < <(find "$DOTFILES/files" -maxdepth 1 -mindepth 1 -print0)
fi

# ------------------------------------------------------------------------------
# Stow the files/ package into $HOME
# --restow: re-links everything (idempotent, also cleans up obsolete links)
# ------------------------------------------------------------------------------
echo "==> Stowing files/ -> $HOME"
# --adopt moves any real files that conflict into the stow package (adopts them),
# then --restow re-creates all links cleanly. Together they are idempotent.
stow --dir="$DOTFILES" --target="$HOME" --adopt --restow files
echo "  done"

# ------------------------------------------------------------------------------
# Extras stow can't handle
# ------------------------------------------------------------------------------

# ~/.dotfiles self-link (used by scripts referencing $HOME/.dotfiles)
if [[ ! -e ~/.dotfiles || $FORCE -eq 1 ]]; then
  ln -sfn "$DOTFILES" ~/.dotfiles
  echo "  link  ~/.dotfiles -> $DOTFILES"
fi

# SSH keys from private-dotfiles (separate repo, separate location)
PRIVATE_SSH=~/Projects/personal/private-dotfiles/files/.ssh
if [[ -d "$PRIVATE_SSH" && ( ! -e ~/.ssh || $FORCE -eq 1 ) ]]; then
  ln -sfn "$PRIVATE_SSH" ~/.ssh
  echo "  link  ~/.ssh -> $PRIVATE_SSH"
fi

# ------------------------------------------------------------------------------
# Clean broken symlinks in $HOME (equivalent to dotbot's clean: ["~"])
# ------------------------------------------------------------------------------
echo "==> Cleaning broken symlinks in $HOME"
find "$HOME" -maxdepth 1 -type l | while read -r link; do
  [[ -e "$link" ]] || { echo "  clean $link"; rm "$link"; }
done

echo
echo "Done."

# vim: ft=bash
