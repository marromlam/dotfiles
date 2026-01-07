# ==============================================================================
# Tmux Session Management Functions
# ==============================================================================

# Create or attach to tmux session named after current directory
function t() {
  SESSION_NAME=$(basename $PWD | tr -d .)
  
  if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    echo "switching to session $SESSION_NAME"
  else
    echo "creating and switching to session $SESSION_NAME"
    tmux new-session -s $SESSION_NAME -d
  fi

  if [ -z "$TMUX" ]; then
    tmux attach-session -t $SESSION_NAME
  else
    tmux switch -t $SESSION_NAME
  fi
}

# Create or attach to zellij session named after current directory
function z() {
  SESSION_NAME=$(basename $PWD | tr -d .)

  if [ -z "$ZELLIJ" ]; then
    zellij attach -c $SESSION_NAME
  else
    zellij pipe -p sessionizer -n sessionizer-new --args cwd="$PWD",name="$SESSION_NAME"
  fi
}

# List tmux sessions
alias 'tl'="tmux list-sessions -F '#{s/ [a-f0-9][a-f0-9][a-f0-9][a-f0-9]$//:session_name}' 2>/dev/null || echo 'no sessions'"

# Attach to or switch to tmux session
function to() {
  if [ -z "$TMUX" ]; then
    tmux attach-session -t $1
  else
    tmux switch -t $1
  fi
}

# vim: ft=sh fdm=marker et
