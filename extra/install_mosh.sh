#!/usr/bin/env bash
# Sets up mosh on macOS or Linux.
# Installs mosh, enables SSH, and opens UDP 60000-61000 for mosh-server.
set -euo pipefail

MOSH_UDP_FROM=60000
MOSH_UDP_TO=61000

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

info()    { printf '\033[34m  =>\033[0m %s\n' "$*"; }
success() { printf '\033[32m  ✓\033[0m %s\n' "$*"; }
warn()    { printf '\033[33m  !\033[0m %s\n' "$*"; }

require_sudo() {
    if [[ $EUID -ne 0 ]]; then
        info "Some steps require sudo — you may be prompted for your password."
        sudo -v
        # Keep sudo alive for the duration of the script
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi
}

# ---------------------------------------------------------------------------
# macOS
# ---------------------------------------------------------------------------

setup_macos() {
    # Install mosh
    if ! command -v mosh &>/dev/null; then
        info "Installing mosh via Homebrew..."
        brew install mosh
    else
        success "mosh already installed ($(mosh --version 2>&1 | awk 'NR==1{print $2}'))"
    fi

    # Enable SSH (Remote Login)
    info "Enabling SSH (Remote Login)..."
    if sudo launchctl list com.openssh.sshd &>/dev/null; then
        success "SSH already running"
    else
        sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
        success "SSH enabled"
    fi

    # Application Firewall exception for mosh-server
    MOSH_SERVER=$(command -v mosh-server)
    FIREWALL_STATE=$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null || echo "disabled")
    if [[ "$FIREWALL_STATE" == *"enabled"* ]]; then
        info "Adding Application Firewall exception for mosh-server..."
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add "$MOSH_SERVER" 2>/dev/null || true
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblock "$MOSH_SERVER" 2>/dev/null || true
        success "Firewall exception added for mosh-server"
    else
        success "Application Firewall is disabled — no exception needed"
    fi

    # pf anchor for UDP 60000-61000 (persistent across reboots)
    ANCHOR_FILE="/etc/pf.anchors/mosh"
    PLIST_FILE="/Library/LaunchDaemons/com.dotfiles.mosh-pf.plist"

    info "Configuring pf to allow UDP $MOSH_UDP_FROM-$MOSH_UDP_TO..."

    sudo tee "$ANCHOR_FILE" >/dev/null <<EOF
pass in proto udp from any to any port $MOSH_UDP_FROM:$MOSH_UDP_TO
EOF

    # Add anchor reference to pf.conf if not already present
    if ! grep -q "anchor \"mosh\"" /etc/pf.conf 2>/dev/null; then
        sudo tee -a /etc/pf.conf >/dev/null <<'EOF'

# mosh
anchor "mosh"
load anchor "mosh" from "/etc/pf.anchors/mosh"
EOF
    fi

    # LaunchDaemon to load the pf anchor on boot
    sudo tee "$PLIST_FILE" >/dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.dotfiles.mosh-pf</string>
    <key>ProgramArguments</key>
    <array>
        <string>/sbin/pfctl</string>
        <string>-f</string>
        <string>/etc/pf.conf</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
    sudo launchctl load -w "$PLIST_FILE" 2>/dev/null || true
    sudo pfctl -f /etc/pf.conf 2>/dev/null && success "pf rules loaded" || warn "pf reload failed — try: sudo pfctl -f /etc/pf.conf"
}

# ---------------------------------------------------------------------------
# Linux (Ubuntu/Debian)
# ---------------------------------------------------------------------------

setup_linux() {
    if ! command -v mosh &>/dev/null; then
        info "Installing mosh..."
        if command -v apt-get &>/dev/null; then
            sudo apt-get update -qq && sudo apt-get install -y mosh
        elif command -v apk &>/dev/null; then
            sudo apk add mosh
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y mosh
        else
            warn "Unknown package manager — install mosh manually" && exit 1
        fi
    else
        success "mosh already installed ($(mosh --version 2>&1 | awk 'NR==1{print $2}'))"
    fi

    # Enable SSH
    if ! systemctl is-active --quiet ssh 2>/dev/null && ! systemctl is-active --quiet sshd 2>/dev/null; then
        info "Enabling SSH..."
        sudo systemctl enable --now ssh 2>/dev/null || sudo systemctl enable --now sshd
        success "SSH enabled"
    else
        success "SSH already running"
    fi

    # Firewall — ufw
    if command -v ufw &>/dev/null && sudo ufw status | grep -q "Status: active"; then
        info "Opening UDP $MOSH_UDP_FROM:$MOSH_UDP_TO in ufw..."
        sudo ufw allow "$MOSH_UDP_FROM:$MOSH_UDP_TO/udp"
        success "ufw rule added"
    fi

    # Firewall — iptables fallback
    if command -v iptables &>/dev/null && ! command -v ufw &>/dev/null; then
        info "Opening UDP $MOSH_UDP_FROM:$MOSH_UDP_TO in iptables..."
        sudo iptables -I INPUT -p udp --dport "$MOSH_UDP_FROM:$MOSH_UDP_TO" -j ACCEPT
        # Persist if iptables-persistent is available
        if command -v netfilter-persistent &>/dev/null; then
            sudo netfilter-persistent save
        fi
        success "iptables rule added"
    fi
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

OS="$(uname -s)"
require_sudo

case "$OS" in
    Darwin) setup_macos ;;
    Linux)  setup_linux ;;
    *)      warn "Unsupported OS: $OS" && exit 1 ;;
esac

# Summary
echo
success "mosh setup complete"
echo
printf "  Connect with:\n"
printf "    mosh %s\n" "${USER}@$(hostname)"
echo
