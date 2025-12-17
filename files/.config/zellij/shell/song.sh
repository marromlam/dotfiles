#!/bin/sh

# metadata=$(playerctl --player=cider metadata)
# artist=$(echo "$metadata" | grep "artist" | cut -d' ' -f3-)
# title=$(echo "$metadata" | grep "title" | cut -d' ' -f3-)
#
# status=$(playerctl --player=$1 status)
#
# pstatus=$(echo $status)
#
# if [[ "$pstatus" = "Playing" ]]; then
#     icon=󰏤
# elif [[ "$pstatus" = "Paused" ]]; then
#     icon=
# fi
#
# echo $artist "-" $title $icon

nowplaying() {
    osascript -e 'tell application "Music" to if it is running and player state is playing then artist of current track & " - " & name of current track'
}

song=$(nowplaying)
echo "${song:0:15}"
