#!/usr/bin/env bash
# mcp-filesystem-wrapper.sh
# Launches the MCP filesystem server inside WSL Debian with a proper login environment.

# Source user environment (login shell via -lc flag in WSL invocation handles most of
# this, but .bashrc is guarded against non-interactive use so source it explicitly).
# shellcheck source=/dev/null
[[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc" >/dev/stderr 2>&1

exec npx -y @modelcontextprotocol/server-filesystem \
  "$HOME" \
  "$HOME/Workspaces"
