# ==============================================================================
# Environment Variables
# ==============================================================================

# Python path for matplotlib kitty backend
export PYTHONPATH="$HOME/.config/kitty/mplbackend":$PYTHONPATH

# LaTeX inputs
export TEXINPUTS=".:~/beamer-compostela:"

# ==============================================================================
# PATH Configuration
# ==============================================================================

# System paths (prepended to PATH)
path_exists() { [[ -d "$1" ]]; }

SYS_PATHS=(
  "$HOME/.local/share/nvim/mason/bin"
  "$HOME/go/bin"
  "$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin"
  "$HOMEBREW_PREFIX/sbin"
  "$HOMEBREW_PREFIX/bin"
)

# User paths (appended to PATH)
USER_PATHS=(
  "$HOME/.cargo/env"
  "$HOME/.dotfiles/scripts"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
)

# Filter paths that exist
SYS_PATHS=($(for p in "${SYS_PATHS[@]}"; do path_exists "$p" && echo "$p"; done))
USER_PATHS=($(for p in "${USER_PATHS[@]}"; do path_exists "$p" && echo "$p"; done))

# Set PATH with ordering: SYS:PATH:USER (removes duplicates)
export PATH=$(dedup "$(join $SYS_PATHS):$PATH:$(join $USER_PATHS)")

# vim: fdm=marker et ts=2 sw=2 tw=0
