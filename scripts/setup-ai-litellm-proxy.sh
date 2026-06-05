#!/usr/bin/env bash
# setup-ai-litellm-proxy.sh
# Idempotent setup for LiteLLM Claude Code gateway service.

set -euo pipefail

LITELLM_BIN="${LITELLM_BIN:-$(command -v litellm || true)}"
LITELLM_CONFIG="${LITELLM_CONFIG:-$HOME/Workspaces/personal/claude-code-over-github-copilot/copilot-config.yaml}"
LITELLM_KEYS="${LITELLM_KEYS:-$HOME/litellm-keys.env}"
LITELLM_PORT="${LITELLM_PORT:-4000}"

SYSTEMD_DIR="$HOME/.config/systemd/user"
WANTS_DIR="$SYSTEMD_DIR/default.target.wants"
MANAGED_UNITS=(
  "litellm.service"
  "rosetta-llm.service"
  "cursor-api-proxy.service"
)

info() {
  printf '  [INFO] %s\n' "$*"
}

success() {
  printf '    [OK] %s\n' "$*"
}

warn() {
  printf '  [WARN] %s\n' "$*" >&2
}

die() {
  printf ' [ERROR] %s\n' "$*" >&2
  exit 1
}

require_executable() {
  local name="$1"
  local path="$2"
  [[ -n "$path" && -x "$path" ]] || die "$name not found"
  success "$name found at $path"
}

require_file() {
  local name="$1"
  local path="$2"
  [[ -f "$path" ]] || die "$name not found at $path"
  success "$name found at $path"
}

write_if_changed() {
  local path="$1"
  local content="$2"
  local tmp

  tmp="$(mktemp)"
  printf '%s\n' "$content" > "$tmp"

  if [[ -f "$path" ]] && cmp -s "$tmp" "$path"; then
    rm -f "$tmp"
    info "$(basename "$path") already up to date"
    return
  fi

  mkdir -p "$(dirname "$path")"
  mv "$tmp" "$path"
  success "Written $(basename "$path")"
}

extract_env_value() {
  local file="$1"
  local key="$2"

  python3 - "$file" "$key" <<'PY'
import sys

path, key = sys.argv[1], sys.argv[2]
value = None

with open(path, "r", encoding="utf-8") as handle:
    for raw_line in handle:
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue

        name, raw_value = line.split("=", 1)
        name = name.strip()
        if name.startswith("export "):
            name = name.split(None, 1)[1]

        if name == key:
            value = raw_value.strip().strip('"').strip("'")
            break

if not value:
    raise SystemExit(1)

print(value)
PY
}

stop_disable_remove_unit() {
  local unit="$1"

  if systemctl --user is-active "$unit" >/dev/null 2>&1; then
    systemctl --user stop "$unit" >/dev/null 2>&1 || true
    success "Stopped $unit"
  fi

  if systemctl --user is-enabled "$unit" >/dev/null 2>&1; then
    systemctl --user disable "$unit" >/dev/null 2>&1 || true
    success "Disabled $unit"
  fi

  rm -f "$SYSTEMD_DIR/$unit" "$WANTS_DIR/$unit"
}

cleanup_all_units() {
  info "Cleaning managed services..."
  for unit in "${MANAGED_UNITS[@]}"; do
    stop_disable_remove_unit "$unit"
  done
}

cleanup_processes() {
  pkill -f '[/]litellm' >/dev/null 2>&1 || true
  pkill -f '[/]rosetta-llm' >/dev/null 2>&1 || true
  pkill -f 'python -m rosetta' >/dev/null 2>&1 || true
  pkill -f '[/]cursor-api-proxy' >/dev/null 2>&1 || true
}

ensure_linger() {
  info "Ensuring linger is enabled for user services..."
  if loginctl show-user "$USER" | grep -q 'Linger=yes'; then
    info "Linger already enabled"
  else
    sudo loginctl enable-linger "$USER"
    success "Linger enabled"
  fi
}

restart_claude_daemon() {
  if ! command -v claude >/dev/null 2>&1; then
    return
  fi

  if claude daemon stop --any >/dev/null 2>&1; then
    success "Stopped Claude daemon to apply new settings"
  else
    info "Claude daemon was not running"
  fi
}

probe_litellm_health() {
  local token="$1"
  local url="http://localhost:$LITELLM_PORT/health"
  local code=""
  local attempt

  for attempt in {1..20}; do
    code="$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $token" "$url" 2>/dev/null || true)"
    if [[ "$code" == "200" ]]; then
      success "Health check passed"
      return 0
    fi
    sleep 0.5
  done

  warn "Health check did not return 200 (last status: ${code:-n/a}); inspect logs with: journalctl --user -u litellm -f"
  return 1
}

update_claude_settings_litellm() {
  local master_key="$1"
  local port="$2"

  python3 - "$master_key" "$port" <<'PY'
import json
import sys
from pathlib import Path

master_key = sys.argv[1]
port = sys.argv[2]

claude_dir = Path.home() / ".claude"
settings_file = claude_dir / "settings.json"
claude_dir.mkdir(parents=True, exist_ok=True)

settings = {}
if settings_file.exists():
    try:
        settings = json.loads(settings_file.read_text(encoding="utf-8"))
    except Exception:
        settings = {}

env = settings.get("env")
if not isinstance(env, dict):
    env = {}

env["ANTHROPIC_AUTH_TOKEN"] = master_key
env["ANTHROPIC_BASE_URL"] = f"http://localhost:{port}"
env["ANTHROPIC_MODEL"] = "copilot-sonnet"
env["ANTHROPIC_SMALL_FAST_MODEL"] = "copilot-haiku"
env.pop("CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY", None)

settings["env"] = env
settings["model"] = "copilot-sonnet"
settings.setdefault("$schema", "https://json.schemastore.org/claude-code-settings.json")

settings_file.write_text(json.dumps(settings, indent=2) + "\n", encoding="utf-8")
PY
}

main() {
  local litellm_service
  local master_key

  info "Checking dependencies..."
  require_executable "litellm" "$LITELLM_BIN"
  require_file "LiteLLM config" "$LITELLM_CONFIG"
  require_file "LiteLLM keys" "$LITELLM_KEYS"

  master_key="$(extract_env_value "$LITELLM_KEYS" "LITELLM_MASTER_KEY" || true)"
  [[ -n "$master_key" ]] || die "LITELLM_MASTER_KEY not found in $LITELLM_KEYS"

  mkdir -p "$SYSTEMD_DIR" "$WANTS_DIR"

  cleanup_all_units
  cleanup_processes

  litellm_service="[Unit]
Description=LiteLLM proxy (Claude Code gateway)
After=network.target

[Service]
Type=simple
ExecStart=$LITELLM_BIN --config $LITELLM_CONFIG --port $LITELLM_PORT
EnvironmentFile=$LITELLM_KEYS
Environment=PORT=$LITELLM_PORT
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target"

  write_if_changed "$SYSTEMD_DIR/litellm.service" "$litellm_service"

  info "Reloading systemd user daemon..."
  systemctl --user daemon-reload
  systemctl --user reset-failed >/dev/null 2>&1 || true
  success "daemon-reload done"

  systemctl --user enable litellm.service >/dev/null
  systemctl --user restart litellm.service
  success "litellm.service enabled and running"

  ensure_linger

  update_claude_settings_litellm "$master_key" "$LITELLM_PORT"
  success "Updated ~/.claude/settings.json for LiteLLM"
  restart_claude_daemon

  echo
  echo "----------------------------------------"
  echo " LiteLLM proxy is active"
  echo "----------------------------------------"
  echo "  URL:      http://localhost:$LITELLM_PORT"
  echo "  Service:  litellm.service"
  echo "  Note:     Restart open Claude terminals to refresh model banner"
  echo

  if command -v curl >/dev/null 2>&1; then
    probe_litellm_health "$master_key" || true
  else
    warn "curl not found; skipped health check"
  fi
}

main "$@"
