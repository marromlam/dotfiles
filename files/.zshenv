# Sourced by every zsh invocation (login, interactive, script)

. "$HOME/.cargo/env"

# Directory paths
export DOTFILES=$HOME/.dotfiles
export PROJECTS_DIR=$HOME/Workspaces
export PERSONAL_PROJECTS_DIR=$PROJECTS_DIR/personal
export TMPDIR=$HOME/tmp

# History
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=999999999
export SAVEHIST=999999999

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Editor
# Use neovim-remote if inside a running neovim instance, otherwise use nvim
if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
  export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
  export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
else
  export VISUAL="nvim"
  export EDITOR="nvim"
fi
export USE_EDITOR=$EDITOR

# Conda
export CONDA_AUTO_ACTIVATE_BASE=false
export CONDA_ALWAYS_YES=true
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Python
export PYTHONSTARTUP=$HOME/.config/python/pythonrc.py
