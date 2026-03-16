#!/usr/bin/env bash
# ~/.dotfiles/scripts/neovim-mcp-wrapper.sh

SOCKET_PATH="${NVIM_SOCKET:-/tmp/nvim-mcp-server.sock}"
TIMEOUT=5

# Ensure Homebrew nvim is discoverable in non-login shells
export PATH="/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin:${PATH}"

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

export MACHINEOS=$($HOME/.dotfiles/scripts/machine.sh)

# Set OS-dependent stuff
if [[ "$MACHINEOS" == "Mac" ]]; then
    if [[ "$(uname -m)" == "x86_64" ]]; then
        export HOMEBREW_PREFIX="/usr/local"
    else
        export HOMEBREW_PREFIX="/opt/homebrew"
    fi
else
    export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export NVIM_SOCKET_PATH="${NVIM_SOCKET:-/tmp/nvim-mcp-server.sock}"
export ALLOW_SHELL_COMMANDS=true
exec npx -y mcp-neovim-server
