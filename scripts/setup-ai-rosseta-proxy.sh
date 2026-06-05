#!/usr/bin/env bash
# setup-ai-rosseta-proxy.sh
# Idempotent setup for Rosetta LLM Claude Code gateway service.

set -euo pipefail

UV_BIN="${UV_BIN:-$(command -v uv || true)}"
ROSETTA_BIN="${ROSETTA_BIN:-$(command -v rosetta-llm || true)}"
ROSETTA_CONFIG_DIR="${ROSETTA_CONFIG_DIR:-$HOME/.config/rosetta-llm}"
ROSETTA_CONFIG="${ROSETTA_CONFIG:-$ROSETTA_CONFIG_DIR/config.json}"
ROSETTA_ENV_FILE="${ROSETTA_ENV_FILE:-$ROSETTA_CONFIG_DIR/rosetta.env}"
ROSETTA_PORT="${ROSETTA_PORT:-4000}"

COPILOT_TOKEN_FILE="${COPILOT_TOKEN_FILE:-$HOME/.config/litellm/github_copilot/access-token}"
COPILOT_API_KEY_FILE="${COPILOT_API_KEY_FILE:-$HOME/.config/litellm/github_copilot/api-key.json}"
LITELLM_KEYS="${LITELLM_KEYS:-$HOME/litellm-keys.env}"

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

probe_rosetta_health() {
  local token="$1"
  local url="http://localhost:$ROSETTA_PORT/health"
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

  warn "Health check did not return 200 (last status: ${code:-n/a}); inspect logs with: journalctl --user -u rosetta-llm -f"
  return 1
}

ensure_rosetta_bin() {
  if [[ -n "$ROSETTA_BIN" && -x "$ROSETTA_BIN" ]]; then
    success "rosetta-llm found at $ROSETTA_BIN"
    return
  fi

  require_executable "uv" "$UV_BIN"
  info "Installing rosetta-llm with uv..."
  "$UV_BIN" tool install --upgrade rosetta-llm >/dev/null

  ROSETTA_BIN="$(command -v rosetta-llm || true)"
  if [[ -z "$ROSETTA_BIN" && -x "$HOME/.local/bin/rosetta-llm" ]]; then
    ROSETTA_BIN="$HOME/.local/bin/rosetta-llm"
  fi

  require_executable "rosetta-llm" "$ROSETTA_BIN"
}

read_proxy_auth_token() {
  python3 - "$ROSETTA_CONFIG" "$HOME/.claude/settings.json" "$LITELLM_KEYS" <<'PY'
import json
import uuid
from pathlib import Path
import sys

config_path = Path(sys.argv[1])
claude_settings = Path(sys.argv[2])
litellm_keys = Path(sys.argv[3])


def from_rosetta_config() -> str | None:
    if not config_path.exists():
        return None
    try:
        data = json.loads(config_path.read_text(encoding="utf-8"))
    except Exception:
        return None
    keys = data.get("proxy", {}).get("api_keys")
    if isinstance(keys, list) and keys:
        value = keys[0]
        if isinstance(value, str) and value.strip():
            return value.strip()
    return None


def from_claude_settings() -> str | None:
    if not claude_settings.exists():
        return None
    try:
        data = json.loads(claude_settings.read_text(encoding="utf-8"))
    except Exception:
        return None
    env = data.get("env")
    if isinstance(env, dict):
        value = env.get("ANTHROPIC_AUTH_TOKEN")
        if isinstance(value, str) and value.strip():
            return value.strip()
    return None


def from_litellm_env() -> str | None:
    if not litellm_keys.exists():
        return None
    for raw_line in litellm_keys.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        name, raw_value = line.split("=", 1)
        name = name.strip()
        if name.startswith("export "):
            name = name.split(None, 1)[1]
        if name == "LITELLM_MASTER_KEY":
            value = raw_value.strip().strip('"').strip("'")
            if value:
                return value
    return None


token = from_rosetta_config() or from_claude_settings() or from_litellm_env()
if not token:
    token = f"rosetta-{uuid.uuid4()}"

print(token)
PY
}

read_copilot_base_url() {
  python3 - "$COPILOT_API_KEY_FILE" <<'PY'
import json
from pathlib import Path
import sys

candidate = "https://api.githubcopilot.com"
path = Path(sys.argv[1])

if path.exists():
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        endpoint = data.get("endpoints", {}).get("api")
        if isinstance(endpoint, str) and endpoint.strip():
            candidate = endpoint.strip()
    except Exception:
        pass

print(candidate.rstrip("/"))
PY
}

read_copilot_token() {
  python3 - "$COPILOT_TOKEN_FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
if not path.exists():
    raise SystemExit(1)

token = path.read_text(encoding="utf-8").strip()
if not token:
    raise SystemExit(1)

print(token)
PY
}

write_rosetta_config() {
  local config_path="$1"
  local proxy_token="$2"
  local copilot_base_url="$3"

  python3 - "$config_path" "$proxy_token" "$copilot_base_url" "$ROSETTA_PORT" <<'PY'
import json
from pathlib import Path
import sys

config_path = Path(sys.argv[1])
proxy_token = sys.argv[2]
copilot_base_url = sys.argv[3]
port = int(sys.argv[4])

config = {
    "host": "0.0.0.0",
    "port": port,
    "proxy": {
        "api_keys": [proxy_token],
    },
    "log_level": "info",
    "providers": {
        "anthropic": {
            "format": "openai_chat",
            "base_url": copilot_base_url,
            "api_key_env": "COPILOT_ACCESS_TOKEN",
            "extra_headers": {
                "Editor-Version": "vscode/1.85.1",
                "Copilot-Integration-Id": "copilot-language-server",
            },
            "models": [
                {"id": "copilot-sonnet", "upstream_name": "claude-sonnet-4.5"},
                {"id": "claude-sonnet-4.5"},
                {"id": "claude-sonnet-4", "upstream_name": "claude-sonnet-4.5"},
                {"id": "claude-sonnet-4-0", "upstream_name": "claude-sonnet-4.5"},
                {"id": "claude-opus-4.5"},
                {"id": "claude-haiku-4.5"},
                {"id": "copilot-opus", "upstream_name": "claude-opus-4.5"},
                {"id": "copilot-haiku", "upstream_name": "claude-haiku-4.5"}
            ],
            "models_ttl_seconds": 300,
        }
    },
}

config_path.parent.mkdir(parents=True, exist_ok=True)
rendered = json.dumps(config, indent=2) + "\n"

if config_path.exists() and config_path.read_text(encoding="utf-8") == rendered:
    print("unchanged")
else:
    config_path.write_text(rendered, encoding="utf-8")
    print("written")
PY
}

update_claude_settings_rosetta() {
  local proxy_token="$1"
  local port="$2"

  python3 - "$proxy_token" "$port" <<'PY'
import json
import sys
from pathlib import Path

proxy_token = sys.argv[1]
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

env["ANTHROPIC_AUTH_TOKEN"] = proxy_token
env["ANTHROPIC_BASE_URL"] = f"http://localhost:{port}"
env["ANTHROPIC_MODEL"] = "anthropic/claude-sonnet-4.5"
env["ANTHROPIC_DEFAULT_OPUS_MODEL"] = "anthropic/claude-opus-4.5"
env["ANTHROPIC_DEFAULT_OPUS_MODEL_NAME"] = "Claude Opus 4.5 (Copilot)"
env["ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION"] = "Pinned via Rosetta gateway"
env["ANTHROPIC_DEFAULT_SONNET_MODEL"] = "anthropic/claude-sonnet-4.5"
env["ANTHROPIC_DEFAULT_SONNET_MODEL_NAME"] = "Claude Sonnet 4.5 (Copilot)"
env["ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION"] = "Pinned via Rosetta gateway"
env["ANTHROPIC_DEFAULT_HAIKU_MODEL"] = "anthropic/claude-haiku-4.5"
env["ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME"] = "Claude Haiku 4.5 (Copilot)"
env["ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION"] = "Pinned via Rosetta gateway"
env["ANTHROPIC_SMALL_FAST_MODEL"] = "anthropic/claude-haiku-4.5"
env["CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY"] = "1"

settings["env"] = env
settings["model"] = "anthropic/claude-sonnet-4.5"
settings.setdefault("$schema", "https://json.schemastore.org/claude-code-settings.json")

settings_file.write_text(json.dumps(settings, indent=2) + "\n", encoding="utf-8")
PY
}

main() {
  local rosetta_service
  local copilot_token
  local proxy_token
  local copilot_base_url
  local config_result

  info "Checking dependencies..."
  require_file "GitHub Copilot token" "$COPILOT_TOKEN_FILE"

  ensure_rosetta_bin

  copilot_token="$(read_copilot_token || true)"
  [[ -n "$copilot_token" ]] || die "Could not read GitHub Copilot token from $COPILOT_TOKEN_FILE"

  proxy_token="$(read_proxy_auth_token || true)"
  [[ -n "$proxy_token" ]] || die "Could not determine Rosetta proxy auth token"

  copilot_base_url="$(read_copilot_base_url)"

  mkdir -p "$SYSTEMD_DIR" "$WANTS_DIR" "$ROSETTA_CONFIG_DIR"

  cleanup_all_units
  cleanup_processes

  config_result="$(write_rosetta_config "$ROSETTA_CONFIG" "$proxy_token" "$copilot_base_url")"
  if [[ "$config_result" == "written" ]]; then
    success "Updated $(basename "$ROSETTA_CONFIG")"
  else
    info "$(basename "$ROSETTA_CONFIG") already up to date"
  fi

  write_if_changed "$ROSETTA_ENV_FILE" "COPILOT_ACCESS_TOKEN=$copilot_token"

  rosetta_service="[Unit]
Description=Rosetta LLM proxy (Claude Code gateway)
After=network.target

[Service]
Type=simple
ExecStart=$ROSETTA_BIN --config $ROSETTA_CONFIG --port $ROSETTA_PORT
EnvironmentFile=$ROSETTA_ENV_FILE
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target"

  write_if_changed "$SYSTEMD_DIR/rosetta-llm.service" "$rosetta_service"

  info "Reloading systemd user daemon..."
  systemctl --user daemon-reload
  systemctl --user reset-failed >/dev/null 2>&1 || true
  success "daemon-reload done"

  systemctl --user enable rosetta-llm.service >/dev/null
  systemctl --user restart rosetta-llm.service
  success "rosetta-llm.service enabled and running"

  ensure_linger

  update_claude_settings_rosetta "$proxy_token" "$ROSETTA_PORT"
  success "Updated ~/.claude/settings.json for Rosetta"
  restart_claude_daemon

  echo
  echo "----------------------------------------"
  echo " Rosetta proxy is active"
  echo "----------------------------------------"
  echo "  URL:      http://localhost:$ROSETTA_PORT"
  echo "  Service:  rosetta-llm.service"
  echo "  Upstream: $copilot_base_url"
  echo "  Note:     Restart open Claude terminals to refresh model banner"
  echo

  if command -v curl >/dev/null 2>&1; then
    probe_rosetta_health "$proxy_token" || true
  else
    warn "curl not found; skipped health check"
  fi
}

main "$@"
