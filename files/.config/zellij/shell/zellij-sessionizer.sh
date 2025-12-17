#!/usr/bin/env bash

# use fzf full screen mode

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/Projects ~/Projects/work ~/Projects/personal -mindepth 1 -maxdepth 1 -type d | fzf --height 100% --header "Select a project directory to attach to a zellij session")
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)

# Start a new zellij session or attach to existing one
# if ! zellij list-sessions | grep -q "^$selected_name$"; then
#     zellij attach -b "$selected_name"
# else
#     zellij attach -b "$selected_name"
# fi
#
zellij pipe -p sessionizer -n sessionizer-new \
    --args cwd="$selected",name="$selected_name"
