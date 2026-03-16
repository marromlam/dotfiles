#!/usr/bin/env bash
#
# Safe Java + SonarLint Installer for macOS
# Installs everything via Homebrew to keep it clean and manageable
#
# Usage: ./install-java-sonarlint.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Check if running on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    log_error "This script is designed for macOS only"
    exit 1
fi

# Determine Homebrew prefix (supports both Intel and Apple Silicon)
if [[ -d "/opt/homebrew" ]]; then
    BREW_PREFIX="/opt/homebrew"
elif [[ -d "/usr/local" ]]; then
    BREW_PREFIX="/usr/local"
else
    log_error "Homebrew installation not found"
    exit 1
fi

log_info "Using Homebrew prefix: $BREW_PREFIX"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    log_error "Homebrew is not installed. Please install it first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

log_success "Homebrew is installed"

# Update Homebrew
log_info "Updating Homebrew..."
brew update || log_warning "Failed to update Homebrew (continuing anyway)"

# Check if Java is already installed
if command -v java &> /dev/null && java -version &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    log_success "Java is already installed: $JAVA_VERSION"

    # Ask if user wants to reinstall
    read -p "Do you want to reinstall/update Java? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping Java installation"
        SKIP_JAVA=true
    fi
fi

# Install OpenJDK via Homebrew
if [[ "${SKIP_JAVA:-false}" != "true" ]]; then
    log_info "Installing OpenJDK 21 (LTS) via Homebrew..."

    # Install openjdk@21
    if brew list openjdk@21 &> /dev/null; then
        log_info "OpenJDK 21 is already installed, upgrading if needed..."
        brew upgrade openjdk@21 || log_warning "OpenJDK 21 is already up to date"
    else
        brew install openjdk@21
    fi

    log_success "OpenJDK 21 installed successfully"

    # Determine the correct openjdk path
    OPENJDK_PATH="$BREW_PREFIX/opt/openjdk@21"

    if [[ ! -d "$OPENJDK_PATH" ]]; then
        log_error "OpenJDK installation directory not found: $OPENJDK_PATH"
        exit 1
    fi

    log_info "OpenJDK installed at: $OPENJDK_PATH"
fi

# Determine shell config file
if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [[ -n "${BASH_VERSION:-}" ]] || [[ "$SHELL" == *"bash"* ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    SHELL_CONFIG="$HOME/.profile"
fi

log_info "Detected shell config: $SHELL_CONFIG"

# Update shell configuration with JAVA_HOME and PATH
if [[ "${SKIP_JAVA:-false}" != "true" ]]; then
    log_info "Configuring environment variables in $SHELL_CONFIG..."

    # Create backup
    cp "$SHELL_CONFIG" "$SHELL_CONFIG.backup-$(date +%Y%m%d-%H%M%S)"
    log_info "Created backup: $SHELL_CONFIG.backup-$(date +%Y%m%d-%H%M%S)"

    # Remove old Java entries if they exist
    sed -i.tmp '/# Java (OpenJDK) - Homebrew/d' "$SHELL_CONFIG" 2>/dev/null || true
    sed -i.tmp '/export JAVA_HOME.*openjdk/d' "$SHELL_CONFIG" 2>/dev/null || true
    sed -i.tmp '/export PATH.*openjdk.*bin/d' "$SHELL_CONFIG" 2>/dev/null || true
    rm -f "$SHELL_CONFIG.tmp"

    # Add new Java configuration
    cat >> "$SHELL_CONFIG" << EOF

# Java (OpenJDK) - Homebrew
export JAVA_HOME="$BREW_PREFIX/opt/openjdk@21"
export PATH="\$JAVA_HOME/bin:\$PATH"
EOF

    log_success "Environment variables configured in $SHELL_CONFIG"

    # Export for current session
    export JAVA_HOME="$BREW_PREFIX/opt/openjdk@21"
    export PATH="$JAVA_HOME/bin:$PATH"
fi

# Verify Java installation
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    log_success "Java verification: $JAVA_VERSION"

    # Show Java path
    JAVA_PATH=$(which java)
    log_info "Java executable: $JAVA_PATH"

    # Show JAVA_HOME
    log_info "JAVA_HOME: ${JAVA_HOME:-not set}"
else
    log_error "Java installation verification failed"
    log_info "Please restart your terminal and run: java -version"
fi

# Install Mason if not already installed (for Neovim)
log_info "Checking for Neovim installation..."
if command -v nvim &> /dev/null; then
    log_success "Neovim is installed"

    # Check if Mason is available
    log_info "Verifying Mason installation in Neovim..."
    if nvim --headless -c "lua if pcall(require, 'mason') then print('MASON_OK') else print('MASON_NOT_FOUND') end" -c "qa" 2>&1 | grep -q "MASON_OK"; then
        log_success "Mason is installed in Neovim"

        # Install sonarlint-language-server via Mason
        log_info "Installing sonarlint-language-server via Mason..."
        nvim --headless -c "lua require('mason.api.command').MasonInstall({'sonarlint-language-server'})" -c "sleep 30000m" -c "qa" 2>&1 &
        MASON_PID=$!

        log_info "Mason is installing sonarlint-language-server (PID: $MASON_PID)"
        log_info "This may take a few minutes..."

        # Wait for Mason installation
        wait $MASON_PID || log_warning "Mason installation may have issues, check :Mason in Neovim"

        log_success "SonarLint installation initiated via Mason"
    else
        log_warning "Mason not found in Neovim"
        log_info "SonarLint will be installed automatically when you open Neovim"
    fi
else
    log_warning "Neovim is not installed"
    log_info "Install Neovim first, then SonarLint will be installed automatically"
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
log_success "Installation Complete!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
log_info "Summary:"
echo "  ✓ Java (OpenJDK 21) installed via Homebrew"
echo "  ✓ JAVA_HOME configured: $BREW_PREFIX/opt/openjdk@21"
echo "  ✓ Java added to PATH in $SHELL_CONFIG"
echo "  ✓ SonarLint installation initiated"
echo ""
log_warning "IMPORTANT: Restart your terminal or run:"
echo "  source $SHELL_CONFIG"
echo ""
log_info "To verify the installation, run:"
echo "  java -version"
echo "  echo \$JAVA_HOME"
echo ""
log_info "In Neovim, check Mason status with:"
echo "  :Mason"
echo "  :LspInfo"
echo ""
log_info "Installation locations (all in Homebrew):"
echo "  Java: $BREW_PREFIX/opt/openjdk@21"
echo "  Mason tools: ~/.local/share/nvim/mason/"
echo ""
log_success "All done! 🎉"
