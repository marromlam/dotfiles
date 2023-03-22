#!/usr/bin/env bash

echo "================================================================================"
echo "Spotify CLI"
echo "--------------------------------------------------------------------------------";

set -e

USERNAME="marcos"

# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.

sudo rm -rf /Library/LaunchDaemons/rustlang.spotifyd.plist
sudo cat > /Library/LaunchDaemons/rustlang.spotifyd.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>rustlang.spotifyd</string>
        <key>ProgramArguments</key>
        <array>
            <string>/opt/homebrew/bin/spotifyd</string>
            <string>--config-path=/Users/$USERNAME/.config/spotifyd/spotifyd.conf</string>
            <string>--no-daemon</string>
        </array>
        <key>UserName</key>
        <string>$USERNAME</string>
        <key>KeepAlive</key>
        <true/>
        <key>ThrottleInterval</key>
        <integer>30</integer>
    </dict>
</plist>

EOF

echo "Plist was created"

# sudo launchctl unload -w /Library/LaunchDaemons/rustlang.spotifyd.plist
# sudo launchctl stop /Library/LaunchDaemons/rustlang.spotifyd.plist &> /dev/null

# sudo launchctl load -w /Library/LaunchDaemons/rustlang.spotifyd.plist
# sudo launchctl start /Library/LaunchDaemons/rustlang.spotifyd.plist

echo "--------------------------------------------------------------------------------";
echo "Done "
echo "================================================================================"

exit 0

# vim:foldmethod=marker
