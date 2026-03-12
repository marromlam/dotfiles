#!/usr/bin/env bash
#
# Install Java (OpenJDK) for Neovim SonarLint/SonarQube plugin
#
# This script:
# 1. Installs OpenJDK via Homebrew
# 2. Creates the required macOS system symlink
# 3. Verifies the installation
# 4. Optionally installs sonarlint-language-server via Mason

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Java Installation for SonarLint${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${YELLOW}Warning: This script is designed for macOS.${NC}"
    echo -e "${YELLOW}On Linux, install Java via your package manager:${NC}"
    echo -e "  Ubuntu/Debian: sudo apt install openjdk-17-jdk"
    echo -e "  Fedora/RHEL:   sudo dnf install java-17-openjdk"
    echo -e "  Arch:          sudo pacman -S jdk-openjdk"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Error: Homebrew is not installed.${NC}"
    echo -e "Install Homebrew first: https://brew.sh"
    exit 1
fi

# Step 1: Install OpenJDK
echo -e "${BLUE}Step 1: Installing OpenJDK...${NC}"
if brew list openjdk &>/dev/null; then
    echo -e "${GREEN}✓ OpenJDK is already installed${NC}"
else
    echo "Installing openjdk..."
    brew install openjdk
    echo -e "${GREEN}✓ OpenJDK installed${NC}"
fi
echo ""

# Step 2: Add OpenJDK to PATH
echo -e "${BLUE}Step 2: Configuring PATH...${NC}"
OPENJDK_BIN="$(brew --prefix)/opt/openjdk/bin"

# Check if openjdk/bin is in PATH
if [[ ":$PATH:" == *":$OPENJDK_BIN:"* ]]; then
    echo -e "${GREEN}✓ OpenJDK is already in PATH${NC}"
else
    echo -e "${YELLOW}⚠ OpenJDK not in PATH${NC}"
    echo ""
    echo "Add this to your ~/.zshrc or ~/.bashrc:"
    echo -e "  ${BLUE}export PATH=\"$(brew --prefix)/opt/openjdk/bin:\$PATH\"${NC}"
    echo ""
    echo "Or run this command:"
    echo -e "  ${BLUE}echo 'export PATH=\"$(brew --prefix)/opt/openjdk/bin:\$PATH\"' >> ~/.zshrc${NC}"
    echo ""
fi
echo ""

# Step 3: Create system symlink (optional, for system-wide Java)
echo -e "${BLUE}Step 3: Creating macOS system symlink (optional)...${NC}"
OPENJDK_PATH="$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk"
JAVA_LINK="/Library/Java/JavaVirtualMachines/openjdk.jdk"

if [[ -L "$JAVA_LINK" ]] || [[ -d "$JAVA_LINK" ]]; then
    echo -e "${GREEN}✓ Java symlink already exists${NC}"
else
    echo "This step is optional but recommended for system-wide Java access."
    read -p "Create system symlink? (requires sudo) [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo ln -sfn "$OPENJDK_PATH" "$JAVA_LINK"
        echo -e "${GREEN}✓ Symlink created${NC}"
    else
        echo -e "${YELLOW}⊘ Skipped (Neovim will still work with PATH setup)${NC}"
    fi
fi
echo ""

# Step 4: Verify installation
echo -e "${BLUE}Step 4: Verifying installation...${NC}"
# Try brew-installed java first
JAVA_CMD="$(brew --prefix)/opt/openjdk/bin/java"
if [[ -x "$JAVA_CMD" ]]; then
    JAVA_VERSION=$("$JAVA_CMD" -version 2>&1 | head -n 1)
    echo -e "${GREEN}✓ Java is available: $JAVA_VERSION${NC}"
elif command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    echo -e "${GREEN}✓ Java is available: $JAVA_VERSION${NC}"
else
    echo -e "${RED}✗ Java command not found${NC}"
    echo -e "Please add OpenJDK to your PATH and restart your terminal."
    exit 1
fi
echo ""

# Step 5: Check Mason and SonarLint
echo -e "${BLUE}Step 5: Checking Neovim Mason setup...${NC}"
MASON_BIN="$HOME/.local/share/nvim/mason/bin/sonarlint-language-server"

if [[ -f "$MASON_BIN" ]]; then
    echo -e "${GREEN}✓ sonarlint-language-server is already installed${NC}"
else
    echo -e "${YELLOW}⚠ sonarlint-language-server not found${NC}"
    echo ""
    echo -e "To install it, open Neovim and run:"
    echo -e "  ${BLUE}:MasonInstall sonarlint-language-server${NC}"
    echo ""
    echo -e "Or it will be auto-installed when you open a Python file."
fi
echo ""

# Step 6: Final instructions
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. ${BLUE}Add OpenJDK to PATH${NC} (see instructions above if not done)"
echo -e "  2. ${BLUE}Restart your terminal${NC} (or run: source ~/.zshrc)"
echo -e "  3. ${BLUE}Restart Neovim${NC}"
echo -e "  4. ${BLUE}Open a Python file${NC} - SonarLint should now work!"
echo ""
echo -e "To verify Java:"
echo -e "  ${BLUE}$(brew --prefix)/opt/openjdk/bin/java -version${NC}"
echo -e "  ${BLUE}java -version${NC} (after PATH is set)"
echo ""
echo -e "To check SonarLint in Neovim:"
echo -e "  ${BLUE}:checkhealth${NC}"
echo -e "  ${BLUE}:LspInfo${NC} (when a Python file is open)"
echo ""
