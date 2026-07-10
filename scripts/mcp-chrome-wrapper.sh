#!/usr/bin/env bash
# mcp-chrome-wrapper.sh
# Cross-platform wrapper around chrome-devtools-mcp.
# - macOS/Linux: launches local Chrome via chrome-devtools-mcp defaults.
# - WSL: connects to Windows Chrome through a debug port.
#
# Defaults:
# - CDP_PORT defaults to 9222 (single shared browser across chats)
# - MCP_CHROME_AUTOLAUNCH defaults to false
#
# Optional behavior:
# - CDP_PORT=auto enables per-session port allocation (multi-session isolation)
# - MCP_CHROME_AUTOLAUNCH=true enables automatic browser launch from WSL

set -euo pipefail

BASE_NPX_ARGS=(
  -y
  chrome-devtools-mcp@latest
  --no-usage-statistics
)

LOCK_ROOT="/tmp/mcp-chrome-locks"
LOCK_PATH=""

is_wsl() {
  [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null
}

is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

log_info() {
  printf '[mcp-chrome] %s\n' "$*" >&2
}

log_warn() {
  printf '[mcp-chrome][warn] %s\n' "$*" >&2
}

log_error() {
  printf '[mcp-chrome][error] %s\n' "$*" >&2
}

cleanup() {
  if [[ -n "$LOCK_PATH" ]]; then
    rm -rf "$LOCK_PATH" >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Missing required command: $cmd"
    exit 1
  fi
}

is_cdp_ready() {
  local host="$1"
  local port="$2"
  curl -fsS --connect-timeout 2 "http://${host}:${port}/json/version" >/dev/null 2>&1
}

try_lock_port() {
  local port="$1"
  local lock_path="${LOCK_ROOT}/port-${port}"

  mkdir -p "$LOCK_ROOT"

  if mkdir "$lock_path" 2>/dev/null; then
    printf '%s\n' "$$" >"${lock_path}/pid"
    LOCK_PATH="$lock_path"
    return 0
  fi

  local lock_pid=""
  if [[ -f "${lock_path}/pid" ]]; then
    lock_pid="$(cat "${lock_path}/pid" 2>/dev/null || true)"
  fi

  if [[ -n "$lock_pid" ]] && kill -0 "$lock_pid" 2>/dev/null; then
    return 1
  fi

  rm -rf "$lock_path"
  if mkdir "$lock_path" 2>/dev/null; then
    printf '%s\n' "$$" >"${lock_path}/pid"
    LOCK_PATH="$lock_path"
    return 0
  fi

  return 1
}

find_windows_user() {
  if [[ -n "${WIN_USER:-}" ]]; then
    printf '%s\n' "$WIN_USER"
    return 0
  fi

  local candidate
  for path in /mnt/c/Users/*; do
    [[ -d "$path" ]] || continue
    candidate="$(basename "$path")"
    case "$candidate" in
      Public|Default|"Default User"|"All Users")
        continue
        ;;
    esac

    if [[ -d "$path/AppData" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  if command -v cmd.exe >/dev/null 2>&1; then
    candidate="$(cmd.exe /C "echo %USERNAME%" 2>/dev/null | tr -d '\r' || true)"
    if [[ -n "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  fi

  return 1
}

detect_wsl_host() {
  local win_user="$1"
  local wslconfig="/mnt/c/Users/${win_user}/.wslconfig"

  if [[ -f "$wslconfig" ]] && grep -qi 'networkingMode=mirrored' "$wslconfig" 2>/dev/null; then
    printf '%s\n' "localhost"
    return 0
  fi

  local gateway
  gateway="$(ip route show default 2>/dev/null | awk '{print $3}' | head -n1)"
  if [[ -n "$gateway" ]]; then
    printf '%s\n' "$gateway"
    return 0
  fi

  printf '%s\n' "localhost"
}

ensure_windows_launcher_script() {
  local win_user="$1"
  local source_script="$HOME/.dotfiles/scripts/chrome-debug.ps1"
  local target_dir="/mnt/c/Users/${win_user}/scripts"
  local target_script="${target_dir}/chrome-debug.ps1"

  if [[ ! -f "$source_script" ]]; then
    return 0
  fi

  mkdir -p "$target_dir"
  if [[ ! -f "$target_script" || "$source_script" -nt "$target_script" ]]; then
    cp "$source_script" "$target_script"
  fi
}

launch_windows_chrome() {
  local win_user="$1"
  local port="$2"
  local profile_name="claude-debug-${port}"
  local ps_script_win="${CHROME_DEBUG_PS_SCRIPT:-C:\\Users\\${win_user}\\scripts\\chrome-debug.ps1}"
  local -a ps_args=(
    -NoProfile
    -ExecutionPolicy
    Bypass
    -File
    "$ps_script_win"
    -Port
    "$port"
    -ProfileName
    "$profile_name"
  )

  if ! command -v powershell.exe >/dev/null 2>&1; then
    log_error "powershell.exe is required to auto-launch Windows Chrome from WSL"
    return 1
  fi

  if [[ "${MCP_CHROME_HEADLESS:-false}" == "true" ]]; then
    ps_args+=("-Headless")
  fi

  powershell.exe "${ps_args[@]}" >&2
}

wait_for_cdp() {
  local host="$1"
  local port="$2"
  local attempts=12
  local i

  for ((i = 1; i <= attempts; i += 1)); do
    if is_cdp_ready "$host" "$port"; then
      return 0
    fi
    sleep 1
  done

  return 1
}

run_mcp_server() {
  local -a args=("$@")

  if command -v chrome-devtools-mcp >/dev/null 2>&1; then
    exec chrome-devtools-mcp "${args[@]}"
  fi

  exec npx "${args[@]}"
}

find_auto_port() {
  local host="$1"
  local min_port="$2"
  local max_port="$3"
  local port

  for port in $(seq "$min_port" "$max_port"); do
    if ! try_lock_port "$port"; then
      continue
    fi

    if is_cdp_ready "$host" "$port"; then
      cleanup
      LOCK_PATH=""
      continue
    fi

    printf '%s\n' "$port"
    return 0
  done

  return 1
}

build_common_args() {
  local args=("${BASE_NPX_ARGS[@]}")

  if [[ "${MCP_CHROME_HEADLESS:-false}" == "true" ]]; then
    args+=(--headless)
  fi

  if [[ "${MCP_CHROME_SLIM:-false}" == "true" ]]; then
    args+=(--slim)
  fi

  printf '%s\n' "${args[@]}"
}

run_local_mode() {
  local -a mcp_args
  mapfile -t mcp_args < <(build_common_args)

  if [[ -n "${MCP_CHROME_BROWSER_URL:-}" ]]; then
    mcp_args+=("--browser-url=${MCP_CHROME_BROWSER_URL}")
  elif [[ "${CDP_PORT:-auto}" != "auto" ]]; then
    mcp_args+=("--browser-url=http://127.0.0.1:${CDP_PORT}")
  fi

  log_info "Starting chrome-devtools-mcp in local mode"
  run_mcp_server "${mcp_args[@]}" "$@"
}

run_wsl_mode() {
  require_cmd curl

  local win_user
  win_user="$(find_windows_user)" || {
    log_error "Unable to determine Windows user from WSL"
    exit 1
  }

  local host
  host="$(detect_wsl_host "$win_user")"

  local min_port="${CDP_PORT_MIN:-9222}"
  local max_port="${CDP_PORT_MAX:-9232}"
  local configured_port="${CDP_PORT:-9222}"
  local port

  if [[ "$configured_port" == "auto" ]]; then
    port="$(find_auto_port "$host" "$min_port" "$max_port")" || {
      log_error "No free debug port found in range ${min_port}-${max_port}"
      exit 1
    }
    log_info "Allocated debug port ${port}"
  else
    port="$configured_port"
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
      log_error "CDP_PORT must be an integer or 'auto'"
      exit 1
    fi
    if ! try_lock_port "$port"; then
      log_error "Port ${port} is already in use by another mcp-chrome wrapper"
      log_error "Use CDP_PORT=auto to let the wrapper choose a free port"
      exit 1
    fi
    log_info "Using fixed debug port ${port}"
  fi

  if ! is_cdp_ready "$host" "$port"; then
    if [[ "${MCP_CHROME_AUTOLAUNCH:-false}" == "true" ]]; then
      ensure_windows_launcher_script "$win_user"
      log_info "Chrome debug endpoint not reachable; attempting auto-launch"

      if [[ "${MCP_CHROME_AUTOLAUNCH_SYNC:-false}" == "true" ]]; then
        launch_windows_chrome "$win_user" "$port" || log_warn "Auto-launch command failed"
        if ! is_cdp_ready "$host" "$port"; then
          log_warn "CDP still unavailable at startup (http://${host}:${port}); MCP will start anyway"
        fi
      else
        if command -v powershell.exe >/dev/null 2>&1; then
          launch_windows_chrome "$win_user" "$port" >/dev/null 2>&1 &
        else
          log_warn "powershell.exe unavailable, cannot auto-launch Chrome"
        fi
      fi
    else
      log_warn "CDP unavailable at startup (http://${host}:${port}); MCP will still start"
      log_warn "Start Chrome manually or set MCP_CHROME_AUTOLAUNCH=true"
      log_warn "Manual launch: powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\\Users\\${win_user}\\scripts\\chrome-debug.ps1 -Port ${port} -ProfileName claude-debug-${port} [-Headless]"
    fi
  fi

  local -a mcp_args
  mapfile -t mcp_args < <(build_common_args)
  mcp_args+=("--browser-url=http://${host}:${port}")

  log_info "Starting chrome-devtools-mcp for WSL via http://${host}:${port}"
  run_mcp_server "${mcp_args[@]}" "$@"
}

main() {
  require_cmd npx

  if is_wsl; then
    run_wsl_mode "$@"
    return
  fi

  if is_macos; then
    run_local_mode "$@"
    return
  fi

  run_local_mode "$@"
}

main "$@"
