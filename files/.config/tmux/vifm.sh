tmux has-session -t pasta 2>/dev/null

if [ $? != 0 ]; then
  # Session 'pasta' does not exist, so create it and the 'vifm' window
  #
  tmux new-session -s pasta -n vifm -d
  tmux set-option -t pasta status off
  tmux send-keys -t pasta:vifm 'vifm' C-m
else
  # Session 'pasta' exists
  if ! tmux list-windows -F "#W" -t pasta | grep -q '^vifm$'; then
    # No window named 'vifm', so create it
    tmux new-window -t pasta -n vifm
    tmux send-keys -t pasta:vifm 'vifm' C-m
  fi
fi

# Attach to the 'pasta' session and switch to the 'vifm' window
tmux attach-session -t pasta \; select-window -t vifm
