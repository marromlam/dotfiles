#!/usr/bin/env bash
# setup-ai-proxy.sh
# Idempotent script to install and enable LiteLLM + cursor-api-proxy systemd user services.
# Safe to run multiple times.

set -euo pipefail

LITELLM_BIN="/home/linuxbrew/.linuxbrew/bin/litellm"
LITELLM_CONFIG="$HOME/Workspaces/personal/claude-code-over-github-copilot/copilot-config.yaml"
LITELLM_KEYS="$HOME/litellm-keys.env"
LITELLM_PORT=4000

NODE_BIN="/home/linuxbrew/.linuxbrew/Cellar/node/25.9.0_2/bin/node"
CURSOR_PROXY_JS="/home/linuxbrew/.linuxbrew/Cellar/node/25.9.0_2/lib/node_modules/cursor-api-proxy/dist/cli.js"
CURSOR_PROXY_PORT=7301
CURSOR_AGENT_BIN="$HOME/.local/bin/cursor-agent"

SYSTEMD_DIR="$HOME/.config/systemd/user"

# ── Helpers ───────────────────────────────────────────────────────────────────

info()    { echo "  [INFO] $*"; }
success() { echo "    [OK] $*"; }
die()     { echo " [ERROR] $*" >&2; exit 1; }

check_dependency() {
  local name="$1" path="$2"
  [[ -f "$path" ]] || die "$name not found at $path"
  success "$name found"
}

write_service_if_changed() {
  local path="$1" content="$2"
  if [[ -f "$path" ]] && [[ "$(cat "$path")" == "$content" ]]; then
    info "$(basename "$path") already up to date, skipping"
  else
    echo "$content" > "$path"
    success "Written $(basename "$path")"
  fi
}

# ── Preflight checks ──────────────────────────────────────────────────────────

info "Checking dependencies..."
check_dependency "litellm"          "$LITELLM_BIN"
check_dependency "node"             "$NODE_BIN"
check_dependency "cursor-api-proxy" "$CURSOR_PROXY_JS"
check_dependency "LiteLLM config"   "$LITELLM_CONFIG"
check_dependency "LiteLLM keys"     "$LITELLM_KEYS"

# ── Create systemd dir ────────────────────────────────────────────────────────

mkdir -p "$SYSTEMD_DIR"

# ── Write service files ───────────────────────────────────────────────────────

info "Writing service files..."

write_service_if_changed "$SYSTEMD_DIR/litellm.service" \
"[Unit]
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

write_service_if_changed "$SYSTEMD_DIR/cursor-api-proxy.service" \
"[Unit]
Description=cursor-api-proxy (Cursor model bridge)
After=network.target

[Service]
Type=simple
ExecStart=$NODE_BIN $CURSOR_PROXY_JS
Environment=CURSOR_BRIDGE_PORT=$CURSOR_PROXY_PORT
Environment=CURSOR_AGENT_BIN=$CURSOR_AGENT_BIN
Environment=CURSOR_BRIDGE_PROMPT_VIA_STDIN=true
Environment=CURSOR_BRIDGE_CHAT_ONLY_WORKSPACE=false
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target"

# ── Reload, enable, start ─────────────────────────────────────────────────────

info "Reloading systemd..."
systemctl --user daemon-reload
success "daemon-reload done"

for svc in litellm cursor-api-proxy; do
  if systemctl --user is-enabled "$svc" &>/dev/null; then
    info "$svc already enabled"
  else
    systemctl --user enable "$svc"
    success "$svc enabled"
  fi

  if systemctl --user is-active "$svc" &>/dev/null; then
    info "$svc already running, restarting to pick up any changes..."
    systemctl --user restart "$svc"
    success "$svc restarted"
  else
    systemctl --user start "$svc"
    success "$svc started"
  fi
done

# ── WSL autostart (loginctl linger) ──────────────────────────────────────────

info "Enabling linger for user services to survive WSL session..."
if loginctl show-user "$USER" | grep -q "Linger=yes"; then
  info "Linger already enabled"
else
  sudo loginctl enable-linger "$USER"
  success "Linger enabled"
fi

# ── Final status ──────────────────────────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " All services running"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  LiteLLM:           http://localhost:$LITELLM_PORT"
echo "  cursor-api-proxy:  http://localhost:$CURSOR_PROXY_PORT"
echo ""
echo "  Useful commands:"
echo "  systemctl --user status litellm cursor-api-proxy"
echo "  systemctl --user restart litellm cursor-api-proxy"
echo "  journalctl --user -u litellm -f"
echo "  journalctl --user -u cursor-api-proxy -f"
