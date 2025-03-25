# Cook PYTHONPATH {{{

# enables matplolib kitty backend globally
export PYTHONPATH="$HOME/.config/kitty/mplbackend":$PYTHONPATH

# }}}

# Cook TEXINPUTS {{{

export TEXINPUTS=".:~/beamer-compostela:"

# }}}

# Cook system PATH {{{

# System paths
SYS_PATHS=(
  "$HOME/.dotfiles/scripts"           # Personal scripts
  "$HOME/.local/share/nvim/mason/bin" # nvim mason binaries
  "$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin"
  "$HOMEBREW_PREFIX/sbin" # Brew scripts
  "$HOMEBREW_PREFIX/bin"  # Brew scripts
)

# User paths
USER_PATHS=(
  # "/usr/local/opt/fzf/bin" # Fzf
  "$HOME/.cargo/env"
  "$HOME/.dotfiles/scripts" # Personal scripts
  "$HOME/.local/bin"        # Personal scripts
  "$HOME/.dotfiles/scripts" # Personal scripts
  "$HOME/.cargo"            # Personal scripts
)

# Set PATH with ordering: SYS:PATH:USER
export PATH=$(dedup "$(join $SYS_PATHS):$PATH:$(join $USER_PATHS)")

# }}}

# vim: fdm=marker et ts=2 sw=2 tw=0
