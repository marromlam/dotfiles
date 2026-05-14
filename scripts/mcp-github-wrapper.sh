#!/usr/bin/env bash
# mcp-github-wrapper.sh

# Source user environment. The -lc flag in the WSL invocation already gives us a
# login shell, but .bashrc is typically guarded against non-interactive use, so we
# source it explicitly here.
# shellcheck source=/dev/null
[[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc" >/dev/stderr 2>&1

source $HOME/.ssh/work_token

docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_TOKEN ghcr.io/github/github-mcp-server

