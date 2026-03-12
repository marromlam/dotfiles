# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a comprehensive dotfiles repository that manages configuration across multiple machines (macOS, Linux, WSL2). It uses **dotbot** for symlink management and **Homebrew** for package installation. The core philosophy centers around Neovim as the primary editor, with tmux, fzf, ripgrep, and wezterm as essential supporting tools.

## Machine Identification System

The repository supports different machine types via a machine identifier stored in `~/.machine`:
- `arm64-darwin`: M1/M2/M3 Macs
- `x64-darwin`: Intel Macs
- `x64-linux`: Linux machines
- `x64-wsl`: WSL2 setup
- `x64-nodos`: IGFAE/CERN machines
- `x64-codespaces`: GitHub Codespaces
- `arm64-linux`: Raspberry Pi 4
- `x32-linux`: iSH app

This identifier determines which configuration files and packages are installed.

## Installation Commands

### Initial Setup

```bash
# Standard installation (downloads and runs install.sh from GitHub)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/marromlam/dotfiles/main/install.sh)" -f -f
```

For WSL2, run these commands first:
```bash
sudo sed -i -E 's/nameserver [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/nameserver 8.8.8.8/' /etc/resolv.conf
sudo apt update && sudo apt install curl -y
```

### Dotbot Installation (from local repo)

```bash
# Main dotbot installer
./install

# This runs: dotbot/bin/dotbot -d . -c install.conf.yaml
```

### Using the Makefile (legacy)

```bash
# Install all components
make all

# Individual components
make brew        # Install Homebrew packages
make nvim        # Setup Neovim
make tmux        # Setup tmux plugins
make install     # Create symlinks using stow
make private     # Clone and link private dotfiles
make zsh-plugins # Install zsh plugins
```

## Repository Structure

### Core Configuration Directories

- **`files/.config/`** - Main config directory that gets symlinked to `~/.config/`
  - `nvim/` - Neovim configuration (Lua-based, uses lazy.nvim plugin manager)
  - `tmux/` - tmux configuration and scripts
  - `zsh/` - ZSH configuration, aliases, functions, prompts
  - `kitty/`, `wezterm/` - Terminal emulator configs
  - `yabai/`, `skhd/`, `sketchybar/` - macOS window manager and bar
  - `lazygit/`, `lazydocker/` - TUI configurations
  - `bat/`, `btop/`, `fzf/`, etc. - CLI tool configs

- **`scripts/`** - Executable utility scripts added to PATH
- **`homebrew/`** - Homebrew bundle files (`Brewfile`, `BrewfileLinux`)
- **`extra/`** - Installation and setup scripts
  - `macos/` - macOS-specific settings
  - `windows/` - Windows/WSL-specific scripts
  - `keyboard.sh` - Keyboard configuration
  - `dotfiles.sh` - Dotfiles clone/setup script

- **`dotbot/`** - Dotbot submodule for symlink management
- **`install.conf.yaml`** - Dotbot configuration defining symlinks and shell commands

### Key Files

- `install` - Wrapper script that runs dotbot
- `install.sh` - Main installation script (downloads dependencies, clones repo)
- `Makefile` - Legacy installation targets
- `.gitconfig`, `.gitmessage`, `.zshrc`, `.bashrc` - Shell and git configs

## Neovim Architecture

The Neovim configuration is located in `files/.config/nvim/` and follows a modular structure:

### Core Files
- `init.lua` - Entry point, loads all modules, defines global namespace `_G.mrl`
- `lua/lazyloader.lua` - Plugin manager configuration (uses lazy.nvim)
- `lua/options.lua` - Vim options/settings
- `lua/keymaps.lua` - Global keybindings
- `lua/highlight.lua` - Custom highlights
- `lua/tools.lua` - Helper utilities (loaded before plugins)

### Plugin Organization (`lua/custom/plugins/`)

Plugins are split into focused modules:
- `colorscheme.lua` - Color schemes
- `lsp.lua` - LSP configuration (nvim-lspconfig, mason)
- `completion.lua` - Autocompletion setup
- `copilot.lua` - GitHub Copilot integration
- `fzf.lua` - Fuzzy finder (fzf-lua)
- `git.lua` - Git integration (gitsigns, fugitive)
- `noice.lua` - UI improvements for cmdline/messages
- `mini.lua` - mini.nvim suite plugins
- `folke.lua` - Folke plugins (todo-comments, trouble, etc.)
- `ui.lua` - UI enhancements (bufferline, indent-blankline)
- `format.lua` - Code formatting
- `linting.lua` - Linting configuration
- `debug.lua` - DAP debugging setup
- `dadbod.lua` - Database interface
- `navigation.lua` - File/code navigation
- `neotree.lua` - File tree explorer
- `tpope.lua` - Tim Pope's plugins

### Plugin Manager

Uses **lazy.nvim** for plugin management:
```bash
# Inside Neovim
:Lazy          # Open lazy.nvim UI
:Lazy sync     # Update plugins
:Lazy clean    # Remove unused plugins
```

### Custom Namespace

`_G.mrl` is a global table for helper functions and settings:
- `mrl.ui.statusline.enable` - Controls statusline
- `mrl.ui.statuscolumn.enable` - Controls status column
- `mrl.mappings` - Helper functions for keybindings

## Tmux Configuration

Located in `files/.config/tmux/`:
- `tmux.conf` - Main config file
- `theme.conf` - Visual theme settings
- `plugins/` - TPM plugin directory

Plugin installation:
```bash
# Install TPM and plugins
make tmux

# Or manually inside tmux: prefix + I (capital i)
```

## ZSH Configuration

ZSH config is split across multiple files in `files/.config/zsh/`:
- `common.sh` - Common shell settings
- `aliases.sh` - Alias definitions
- `ufunctions.sh` - Utility functions
- `prompt.sh` - Custom prompt configuration
- `tmux_aliases.sh` - tmux-specific aliases
- `conda.sh` - Conda environment setup
- `macos.sh`, `linux.sh`, `windows.sh` - OS-specific settings
- `plugins/` - ZSH plugin git submodules
- `funcs/` - Additional function definitions

## Common Development Tasks

### Testing Neovim Configuration

```bash
# Open Neovim
nvim

# Check plugin status
nvim +Lazy

# Check LSP status
nvim +LspInfo

# Check health
nvim +checkhealth
```

### Updating Dotfiles

```bash
# Pull latest changes
git pull

# Update submodules
git submodule update --init --recursive

# Re-run dotbot to update symlinks
./install
```

### Installing New Homebrew Packages

1. Add package to `homebrew/Brewfile` (or `homebrew/BrewfileLinux`)
2. Run: `brew bundle --file=~/Projects/personal/dotfiles/homebrew/Brewfile`

### Working with Private Dotfiles

The repository references a private dotfiles repo for sensitive configs (SSH keys, etc.):
```bash
make private  # Clones ~/Projects/personal/private-dotfiles and symlinks files
```

## Important Paths

- Dotfiles repo: `~/Projects/personal/dotfiles` (also stored in `vim.g.dotfiles`)
- Projects: `~/Projects/personal/` and `~/Projects/work/`
- Workspaces: `~/Workspaces/` (newer convention, see `init.lua:14`)
- Obsidian vault: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Marcos`
- Scripts: Scripts in `scripts/` are available in PATH

## Python/Conda Setup

The repo includes conda management in `.config/zsh/conda.sh`:
- `CONDA_AUTO_ACTIVATE_BASE=false` - Doesn't auto-activate base
- Python packages listed in `requirements.txt` include:
  - `pynvim`, `neovim-remote` - For Neovim integration
  - `mcphub[all]` - MCP hub

## Special Notes

- Uses `stow` for legacy symlink management (being replaced by dotbot)
- Private repository for sensitive files: `git@github.com:marromlam/.dotfiles.git`
- Neovim config was forked from kickstart.nvim but heavily customized
- Window management on macOS uses yabai + skhd + sketchybar (commented out in newer Brewfiles)
- The config assumes Nerd Fonts are installed (currently uses Fira Code)
