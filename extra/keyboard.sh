#!/usr/bin/env bash

echo "================================================================================"
echo "Keyboard customization"
echo "--------------------------------------------------------------------------------";

set -e

echo "Remap caps-lock to control for all Keyboards"
sudo cp com.ldaws.KeyMapsGeneral.plist ~/Library/LaunchAgents 
sudo launchctl unload -w ~/Library/LaunchAgents/com.ldaws.KeyMapsGeneral.plist &> /dev/null
sudo launchctl load -w ~/Library/LaunchAgents/com.ldaws.KeyMapsGeneral.plist &> /dev/null


# here I will remap caps-lock to control for Ducky
# (I no longer have a Ducky keyboard, so commented out)


# ensure media keys will work
echo "Ensure media keys will work..."
sudo launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist &> /dev/null
sudo launchctl load -w /System/Library/LaunchAgents/com.apple.rcd.plist &> /dev/null

echo "--------------------------------------------------------------------------------";
echo "Done "
echo "================================================================================"

exit 0

# vim:foldmethod=marker
