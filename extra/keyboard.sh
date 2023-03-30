#!/usr/bin/env bash

echo "================================================================================"
echo "Keyboard customization"
echo "--------------------------------------------------------------------------------";

set -e

export MACHINEOS=`$HOME/.dotfiles/scripts/machine.sh`

if [[ "$MACHINEOS" == "Mac" ]]; then
  echo "Remap caps-lock to control for all Keyboards"
  sudo mkdir -p ~/Library/LaunchAgents
  sudo cp com.ldaws.KeyMapsGeneral.plist ~/Library/LaunchAgents
  sudo launchctl unload -w ~/Library/LaunchAgents/com.ldaws.KeyMapsGeneral.plist &> /dev/null
  sudo launchctl load -w ~/Library/LaunchAgents/com.ldaws.KeyMapsGeneral.plist &> /dev/null
  # ensure media keys will work
  echo "Ensure media keys will work..."
  sudo launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist &> /dev/null
  sudo launchctl load -w /System/Library/LaunchAgents/com.apple.rcd.plist &> /dev/null
else
  echo "Nothing to do in linux"
fi

echo "--------------------------------------------------------------------------------";
echo "Done "
echo "================================================================================"

exit 0

# vim:foldmethod=marker
