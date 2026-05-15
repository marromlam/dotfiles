#!/usr/bin/env bash
# shell-mcp-wrapper.sh
# Launches the MCP shell server inside WSL Debian with a proper login environment.
 
# Source user environment. The -lc flag in the WSL invocation already gives us a
# login shell, but .bashrc is typically guarded against non-interactive use, so we
# source it explicitly here.
# shellcheck source=/dev/null
[[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc" >/dev/stderr 2>&1
 
# Whitelist the commands you want Claude to be able to run.
# Separate with commas; spaces around commas are fine.
export ALLOW_COMMANDS="bash,cat,cd,echo,find,git,grep,ls,mkdir,mv,pwd,rm,touch,wc"
 
exec uvx mcp-shell-server
 
