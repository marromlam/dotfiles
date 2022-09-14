#!/bin/bash

TMUX_BINARY=`which tmux`
TMUX_BINARY="$TMUX_BINARY -S /home3/marcos.romero/tmux.socket"
if [ $SSH_TTY ] && ! [ -n "$TMUX" ]; then
  echo "within tmux"
fi

# customizable
LIST_DATA="#{session-name} #{window_name} #{pane_title} #{pane_current_path} #{pane_current_command}"
FZF_COMMAND="fzf-tmux -p --delimiter=: --with-nth 4"
FZF_COMMAND="fzf"

# do not change
TARGET_SPEC="#{session_name}:#{window_id}:#{pane_id}:"
TARGET_SPEC="#{session_name}:#{window_name}:#{pane_id}:"

# select pane
LINE=$(ssh nodo051 -- "${TMUX_BINARY} list-windows -a -F '#{session_name}§#{window_name}§#{window_id}'"  | $FZF_COMMAND) || exit 0

echo $LINE
# split the result
COMPLETE_INFO=(${LINE//§/ })
# WINDOW_AND_PANE=${COMPLETE_INFO[1]}
# WINDOW_AND_PANE=(${WINDOW_AND_PANE//./ })
echo ${COMPLETE_INFO[1]}

# activate session/window/pane
# ssh nodo051 -- "${TMUX_BINARY} select-pane -t ${WINDOW_AND_PANE[1]} && ${TMUX_BINARY} select-window -t ${WINDOW_AND_PANE[0]} && ${TMUX_BINARY} switch-client -t ${COMPLETE_INFO[0]}"
ssh nodo051 -- "${TMUX_BINARY} select-window -t '${COMPLETE_INFO[2]}' && ${TMUX_BINARY} switch-client -t '${COMPLETE_INFO[0]}'"

# vim:fdm=marker
