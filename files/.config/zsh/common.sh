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
SYS_PATHS=(
  "$HOME/.dotfiles/scripts"
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

# Set PATH with ordering: SYS:PATH:USER (removes duplicates)
export PATH=$(dedup "$(join $SYS_PATHS):$PATH:$(join $USER_PATHS)")

# vim: fdm=marker et ts=2 sw=2 tw=0
