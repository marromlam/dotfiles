#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"
ARCH="$(uname -m)"

if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Please install it first: https://brew.sh"
  exit 1
fi
echo "Installing AWS CLI via Homebrew..."
brew install awscli

install_session_manager_plugin_linux() {
  local deb_arch
  case "$ARCH" in
  x86_64) deb_arch="ubuntu_64bit" ;;
  aarch64) deb_arch="ubuntu_arm64" ;;
  *)
    echo "Unsupported architecture for Session Manager plugin: $ARCH"
    exit 1
    ;;
  esac

  echo "Installing Session Manager plugin for Linux ($deb_arch)..."
  curl -fsSL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/${deb_arch}/session-manager-plugin.deb" -o /tmp/session-manager-plugin.deb
  sudo dpkg -i /tmp/session-manager-plugin.deb
  rm -f /tmp/session-manager-plugin.deb
}

install_session_manager_plugin_macos() {
  echo "Installing AWS CLI and Session Manager plugin via Homebrew..."
  brew install --cask session-manager-plugin
}

case "$OS" in
Darwin)
  install_session_manager_plugin_macos
  ;;
Linux)
  if ! command -v apt-get &>/dev/null; then
    echo "This Linux installer requires apt (Debian/Ubuntu). Exiting."
    exit 1
  fi
  install_session_manager_plugin_linux
  ;;
*)
  echo "Unsupported OS: $OS"
  exit 1
  ;;
esac

echo "Done! Verify with: aws --version && session-manager-plugin"
