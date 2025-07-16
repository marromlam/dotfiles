# this is a list of tmux aliases

# start a new session with the name of the directory
# alias 't'='tmux new-session -A -s $(basename $PWD | tr -d .)'

function t() {
    # check if we are inside tmux, if the TMUX variable
    # first check it there is a session for this folder already
    # exists, if not, create it
    SESSION_NAME=$(basename $PWD | tr -d .)
    if tmux has-session -t $SESSION_NAME 2>/dev/null; then
        # do nothing
        echo "switching to session $SESSION_NAME"
    else
        # if not, create a new session with the name of
        # the directory we are in
        echo "creating and switching to session $SESSION_NAME"
        tmux new-session -s $SESSION_NAME -d
    fi

    if [ -z "$TMUX" ]; then
        tmux attach-session -t $SESSION_NAME
    else
        # if we are already inside tmux, just switch to it
        tmux switch -t $SESSION_NAME
    fi
}

function z() {
    # check if we are inside tmux, if the TMUX variable
    # first check it there is a session for this folder already
    # exists, if not, create it
    SESSION_NAME=$(basename $PWD | tr -d .)
    # if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    # 	# do nothing
    # 	echo "switching to session $SESSION_NAME"
    # else
    # 	# if not, create a new session with the name of
    # 	# the directory we are in
    # 	echo "creating and switching to session $SESSION_NAME"
    # 	tmux new-session -s $SESSION_NAME -d
    # fi

    if [ -z "$ZELLIJ" ]; then
        zellij attach -c $SESSION_NAME
    else
        # 	# if we are already inside tmux, just switch to it
        # 	tmux switch -t $SESSION_NAME
        zellij pipe -p sessionizer -n sessionizer-new --args cwd="$PWD",name="$SESSION_NAME"
    fi
}

# list sessions
alias 'tl'="tmux list-sessions -F '#{s/ [a-f0-9][a-f0-9][a-f0-9][a-f0-9]$//:session_name}' 2>/dev/null || echo 'no sessions'"

# attach to session
# alias 'to'='tmux attach-session -t'
function to() {
    if [ -z "$TMUX" ]; then
        tmux attach-session -t $1
    else
        # if we are already inside tmux, just switch to it
        tmux switch -t $1
    fi
}

# vim: ft=sh fdm=marker et
