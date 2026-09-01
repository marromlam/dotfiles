#!/usr/bin/env bash
set -euo pipefail

# Basic Zsh sanity checks
zsh -i -c 'echo ok' >/dev/null
zsh -i -c 'autoload -Uz compdef; compdef -h >/dev/null' >/dev/null
zsh -i -c '(( $+functions[compinit] ))' >/dev/null

echo "zsh sanity: OK"
