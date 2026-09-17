#!/usr/bin/env bash

# Pick from every window in every session.  The final hidden field is the tmux
# window ID, which keeps the selection unambiguous when names contain spaces.
selection=$(tmux list-windows -a -F '#{session_name}\t#{window_index}\t#{window_name}\t#{window_id}' |
  fzf --delimiter=$'\t' --with-nth=1,2,3 --prompt='tmux window> ' --height=100% --reverse) || exit 0

window_id=${selection##*$'\t'}
tmux switch-client -t "$window_id"

# vim:fdm=marker
