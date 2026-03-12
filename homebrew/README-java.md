# Java Setup for SonarLint

This directory contains a setup script for installing Java (OpenJDK) which is required for the Neovim SonarLint/SonarQube plugin.

## Quick Start

```bash
# From the dotfiles directory
./homebrew/install-java-sonarqube.sh
```

## What It Does

1. ✅ Installs OpenJDK via Homebrew (if not already installed)
2. ✅ Checks if OpenJDK is in your PATH
3. ✅ Optionally creates system symlink for Java (requires sudo)
4. ✅ Verifies Java installation
5. ✅ Checks for sonarlint-language-server in Mason

## Manual Installation

If you prefer to install manually:

```bash
# Install OpenJDK
brew install openjdk

# The PATH is automatically configured in files/.config/zsh/macos.sh
# Just restart your terminal or source your .zshrc
source ~/.zshrc

# Verify
java -version
```

## Neovim Configuration

The SonarQube plugin is automatically enabled when:
- Java is available in PATH
- You open a Python file
- Mason has installed `sonarlint-language-server`

Check status in Neovim:
```vim
:checkhealth
:LspInfo
```

## Troubleshooting

**"Unable to locate a Java Runtime"**
- Run the installation script: `./homebrew/install-java-sonarqube.sh`
- Restart your terminal
- Verify: `java -version`

**SonarLint not starting in Neovim**
- Check Java: `java -version`
- Check Mason: `:Mason` and look for `sonarlint-language-server`
- Check logs: `:LspLog`

**Plugin not loading**
- The plugin uses a `cond` function to only load when Java is available
- If Java is installed but the plugin doesn't load, restart Neovim
