#!/usr/bin/env bash

echo "================================================================================"
echo "Spotify CLI"
echo "--------------------------------------------------------------------------------";

# set -e

if [ ! -f "${HOME}/Library/Keychains/kitty.keychain-db" ]; then
  security create-keychain -P kitty.keychain
fi

echo "We need your Spotify username and password to install the Spotify CLI"
echo "The username is a set of characters that you can find in the URL of your"
echo "Spotify profile page:"
echo "https://www.spotify.com/us/account/overview/"
echo "The password is the one you use to login to Spotify. It will be added to"
echo "your Apple keychain and will be used to authenticate the CLI."
read -p "Spotify username: " USERNAME
# BINARY="/opt/homebrew/bin/spotifyd"
read -s -p "Spotify password: " PASSWORD
echo " "

echo "Creating password for Spotify"
security delete-generic-password -a "$USER" -s spotify kitty.keychain &> /dev/null
security add-generic-password -a "$USER" -s spotify -w $PASSWORD kitty.keychain

echo "Creating password for Spotify"

# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.

cat > $HOME/.config/spotifyd/rustlang.spotifyd.plist <<EOF1
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>rustlang.spotifyd</string>
        <key>ProgramArguments</key>
        <array>
            <string>$HOMEBREW_PREFIX/bin/spotifyd</string>
            <string>--config-path=/Users/$USER/.config/spotifyd/spotifyd.conf</string>
            <string>--no-daemon</string>
        </array>
        <key>UserName</key>
        <string>$USER</string>
        <key>KeepAlive</key>
        <true/>
        <key>ThrottleInterval</key>
        <integer>30</integer>
    </dict>
</plist>
EOF1


cat > $HOME/.config/spotifyd/spotifyd.conf <<EOF2
[global]
# Your Spotify account name.
username = "$USERNAME"
#
# Your Spotify account password.
password = "$PASSWORD"
#
# A command that gets executed and can be used to
# retrieve your password.
# The command should return the password on stdout.
#
# This is an alternative to the "password" field. Both
# can't be used simultaneously.
# password_cmd = "command_that_writes_password_to_stdout"
password_cmd = "./get_password"
#
# If set to true, "spotifyd" tries to look up your
# password in the system's password storage.
#
# Note, that the "password" field will take precedence, if set.
# use_keyring = true
#
# If set to true, "spotifyd" tries to bind to dbus (default is the session bus)
# and expose MPRIS controls. When running headless, without the session bus,
# you should set this to false, to avoid errors. If you still want to use MPRIS,
# have a look at the "dbus_type" option.
use_mpris = true
#
# The bus to bind to with the MPRIS interface.
# Possible values: "session", "system"
# The system bus can be used if no graphical session is available
# (e.g. on headless systems) but you still want to be able to use MPRIS.
# NOTE: You might need to add appropriate policies to allow spotifyd to
# own the name.
dbus_type = "session"
#
# The audio backend used to play music. To get
# a list of possible backends, run "spotifyd --help".
backend = "portaudio" # use portaudio for macOS [homebrew]
# backend = "alsa" # use portaudio for macOS [homebrew]
#
# The alsa audio device to stream audio. To get a
# list of valid devices, run "aplay -L",
# device = "alsa_audio_device"  # omit for macOS
#
# The alsa control device. By default this is the same
# name as the "device" field.
# control = "alsa_audio_device"  # omit for macOS
#
# The alsa mixer used by "spotifyd".
# mixer = "PCM"  # omit for macOS
#
# The volume controller. Each one behaves different to
# volume increases. For possible values, run
# "spotifyd --help".
# volume_controller = "alsa"  # use softvol for macOS
volume_controller = "softvol"  # use softvol for macOS
#
# A command that gets executed in your shell after each song changes.
# on_song_change_hook = "/Users/marcos/.config/spotifyd/song_notify"
#
# The name that gets displayed under the connect tab on
# official clients. Spaces are not allowed!
device_name = "daemon"
#
# The audio bitrate. 96, 160 or 320 kbit/s
bitrate = 160
#
# The directory used to cache audio data. This setting can save
# a lot of bandwidth when activated, as it will avoid re-downloading
# audio files when replaying them.
#
# Note: The file path does not get expanded. Environment variables and
# shell placeholders like $HOME or ~ don't work!
# cache_path = "cache_directory"
#
# The maximal size of the cache directory in bytes
# The example value corresponds to ~ 1GB
max_cache_size = 1000000000
#
# If set to true, audio data does NOT get cached.
no_audio_cache = true
#
# Volume on startup between 0 and 100
# NOTE: This variable's type will change in v0.4, to a number (instead of string)
initial_volume = "90"
#
# If set to true, enables volume normalisation between songs.
volume_normalisation = true
#
# The normalisation pregain that is applied for each song.
normalisation_pregain = -10
#
# After the music playback has ended, start playing similar songs based on the previous tracks.
autoplay = true
#
# The port "spotifyd" uses to announce its service over the network.
zeroconf_port = 1234
#
# The proxy "spotifyd" will use to connect to spotify.
# proxy = "http://proxy.example.org:8080"
#
# The displayed device type in Spotify clients.
# Can be unknown, computer, tablet, smartphone, speaker, t_v,
# a_v_r (Audio/Video Receiver), s_t_b (Set-Top Box), and audio_dongle.
device_type = "computer"
EOF2



sudo cp $HOME/.config/spotifyd/rustlang.spotifyd.plist /Library/LaunchDaemons/rustlang.spotifyd.plist
rm $HOME/.config/spotifyd/rustlang.spotifyd.plist

echo "Plist was created"

sudo launchctl unload -w /Library/LaunchDaemons/rustlang.spotifyd.plist
# sudo launchctl stop /Library/LaunchDaemons/rustlang.spotifyd.plist &> /dev/null

sudo launchctl load -w /Library/LaunchDaemons/rustlang.spotifyd.plist
# sudo launchctl start /Library/LaunchDaemons/rustlang.spotifyd.plist

echo "--------------------------------------------------------------------------------";
echo "Done "
echo "================================================================================"

exit 0

# vim:foldmethod=marker
