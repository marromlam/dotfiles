#!/usr/bin/env bash

machine_file="$HOME/.machine"

machine_file_is_env() {
  local file="$1"
  local line

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*(export[[:space:]]+)?[A-Za-z_][A-Za-z0-9_]*= ]] && continue
    return 1
  done < "$file"

  return 0
}

is_valid_machine() {
  case "$1" in
    arm64-darwin|x64-darwin|x64-linux|x64-wsl|x64-nodos|x64-codespaces|arm64-linux|x32-linux)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

fail_machine_env() {
  local message="$1"
  printf '%s\n' "$message" >&2
  if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    return 1
  fi
  exit 1
}

if [[ ! -f "$machine_file" ]]; then
  fail_machine_env "Missing ~/.machine. Create it with: export MACHINE=\"<machine>\""
fi

if ! machine_file_is_env "$machine_file"; then
  fail_machine_env "~/.machine must be a sourceable env file (e.g. export MACHINE=\"x64-linux\")"
fi

# shellcheck disable=SC1090
source "$machine_file"

if [[ -z "${MACHINE:-}" ]]; then
  fail_machine_env "~/.machine must define MACHINE"
fi

if ! is_valid_machine "$MACHINE"; then
  fail_machine_env "Invalid MACHINE '$MACHINE'. Allowed: arm64-darwin, x64-darwin, x64-linux, x64-wsl, x64-nodos, x64-codespaces, arm64-linux, x32-linux"
fi

if [[ -z "${MACHINEOS:-}" ]]; then
  case "$MACHINE" in
    *-darwin)
      MACHINEOS="Mac"
      ;;
    *)
      MACHINEOS="Linux"
      ;;
  esac
fi

if [[ -z "${HOMEBREW_PREFIX:-}" ]]; then
  case "$MACHINE" in
    x64-darwin)
      HOMEBREW_PREFIX="/usr/local"
      ;;
    arm64-darwin)
      HOMEBREW_PREFIX="/opt/homebrew"
      ;;
    *)
      HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
      ;;
  esac
fi

HOMEBREW_CELLAR="${HOMEBREW_CELLAR:-$HOMEBREW_PREFIX/Cellar}"

export MACHINE
export MACHINEOS
export HOMEBREW_PREFIX
export HOMEBREW_CELLAR
