# Source the full zsh environment configuration
[[ -f "$HOME/.config/zsh/zshenv" ]] && source "$HOME/.config/zsh/zshenv"

# Cargo environment (if it exists)
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

