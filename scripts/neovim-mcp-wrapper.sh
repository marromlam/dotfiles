#!/usr/bin/env bash
# ~/.dotfiles/scripts/neovim-mcp-wrapper.sh

SOCKET_PATH="${NVIM_SOCKET:-/tmp/nvim-mcp-server.sock}"
TIMEOUT=5

# Ensure Homebrew nvim is discoverable in non-login shells
export PATH="/usr/local/bin:/usr/bin:/bin:${PATH}"

# Quick health check - if it fails, systemd will restart the service
if [[ ! -S "$SOCKET_PATH" ]] || ! timeout $TIMEOUT nvim --server "$SOCKET_PATH" --remote-expr "1+1" &>/dev/null; then
    echo "Neovim server not ready, triggering restart..." >&2
    systemctl --user restart neovim-mcp.service
    sleep 2

    # One more check after restart
    if [[ ! -S "$SOCKET_PATH" ]]; then
        echo "Failed to start Neovim server" >&2
        exit 1
    fi
fi

[[ -f "$HOME/.dotfiles/scripts/machine-env.sh" ]] && source "$HOME/.dotfiles/scripts/machine-env.sh"

export PATH="$HOMEBREW_PREFIX/bin:$PATH"
export NVIM_SOCKET_PATH="${NVIM_SOCKET:-/tmp/nvim-mcp-server.sock}"
export ALLOW_SHELL_COMMANDS=true
exec npx -y mcp-neovim-server
