# Cook PYTHONPATH {{{

# enables matplolib kitty backend globally
export PYTHONPATH="$HOME/.config/kitty/mplbackend":$PYTHONPATH

# }}}


# Cook TEXINPUTS {{{

export TEXINPUTS=".:~/beamer-compostela:"

# }}}


# Cook system PATH {{{

# System paths
SYS_PATHS=(
  "/usr/local/opt/coreutils/libexec/gnubin" # Prefer coreutils
  "/usr/local/opt/gnu-sed/libexec/gnubin" # Custom sed
  "/usr/local/sbin" # Brew scripts
  "/usr/local/bin" # Brew scripts
)

# User paths
USER_PATHS=(
  # "/usr/local/opt/fzf/bin" # Fzf
  "$HOME/.dotfiles/scripts" # Personal scripts
)

#echo $SYS_PATHS
#echo $USER_PATHS

## Set PATH with ordering: SYS:PATH:USER
export PATH=$(dedup "$(join $SYS_PATHS):$PATH:$(join $USER_PATHS)")

# }}}


# vim: fdm=marker
