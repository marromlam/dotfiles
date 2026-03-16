#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_HS_DIR="$ROOT_DIR/files/.hammerspoon"
TARGET_HS_DIR="$HOME/.hammerspoon"
SPOONS_DIR="$TARGET_HS_DIR/Spoons"
SPOONINSTALL_URL="https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip"
TMP_SPOON_ZIP="/tmp/SpoonInstall.spoon.zip"

log() {
  printf '[setup_hammerspoon] %s\n' "$*"
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  log "This script is for macOS only."
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew is required but was not found in PATH."
  exit 1
fi

if [[ ! -d "$SOURCE_HS_DIR" ]]; then
  log "Source config not found: $SOURCE_HS_DIR"
  exit 1
fi

log "Installing Hammerspoon (if needed)..."
if ! brew list --cask hammerspoon >/dev/null 2>&1; then
  brew install --cask hammerspoon
else
  log "Hammerspoon already installed."
fi

if [[ -e "$TARGET_HS_DIR" && ! -L "$TARGET_HS_DIR" ]]; then
  BACKUP_PATH="$HOME/.hammerspoon.backup.$(date +%Y%m%d%H%M%S)"
  log "Backing up existing ~/.hammerspoon to $BACKUP_PATH"
  mv "$TARGET_HS_DIR" "$BACKUP_PATH"
fi

if [[ -L "$TARGET_HS_DIR" ]]; then
  CURRENT_LINK="$(readlink "$TARGET_HS_DIR" || true)"
  if [[ "$CURRENT_LINK" != "$SOURCE_HS_DIR" ]]; then
    log "Updating ~/.hammerspoon symlink -> $SOURCE_HS_DIR"
    ln -sfn "$SOURCE_HS_DIR" "$TARGET_HS_DIR"
  else
    log "~/.hammerspoon already linked to repo config."
  fi
else
  log "Linking ~/.hammerspoon -> $SOURCE_HS_DIR"
  ln -s "$SOURCE_HS_DIR" "$TARGET_HS_DIR"
fi

mkdir -p "$SPOONS_DIR"
log "Installing SpoonInstall spoon..."
curl -fL "$SPOONINSTALL_URL" -o "$TMP_SPOON_ZIP"
unzip -o "$TMP_SPOON_ZIP" -d "$SPOONS_DIR" >/dev/null

if [[ -f "$TARGET_HS_DIR/init.lua" ]]; then
  if command -v luac >/dev/null 2>&1; then
    luac -p "$TARGET_HS_DIR/init.lua"
    log "Lua syntax check: OK"
  else
    log "luac not found; skipping Lua syntax check."
  fi
else
  log "Warning: $TARGET_HS_DIR/init.lua not found."
fi

log "Launching Hammerspoon..."
open -a Hammerspoon || true

if command -v hs >/dev/null 2>&1; then
  hs -A -c "hs.reload()" >/dev/null 2>&1 || true
fi

log "Done."
log "If this is first launch, grant Accessibility permissions to Hammerspoon."
