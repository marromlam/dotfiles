# Zsh Configuration

This directory is the ZDOTDIR for Zsh. Startup files live here and are loaded in the usual Zsh order.

## Entry Points

- `.zshenv` is sourced by every Zsh invocation. It chains to `~/.config/zsh/zshenv` for shared environment and PATH setup.
- `.zprofile` is sourced by login shells. It loads Homebrew environment and initializes completion cache.
- `.zshrc` is the interactive shell entry point. It sources all files in `rc.d/`.

## rc.d Layout

Files in `rc.d/` are loaded in lexical order:

- `00-cursor.zsh` minimal prompt for Cursor / VS Code
- `00-debug.zsh` optional profiling via `ZSH_PROFILE=1`
- `05-env.zsh` conda and virtualenv helpers
- `10-plugins.zsh` plugins and completion setup
- `20-history.zsh` history and shell options
- `30-os.zsh` OS-specific config and prompt
- `40-fzf.zsh` fzf defaults
- `50-keybindings.zsh` keybindings
- `60-sources.zsh` aliases and helper scripts
- `90-local.zsh` local overrides and direnv hook

## Plugins

Plugins are installed to:

- `~/.local/share/zsh/plugins`

The installer is:

- `~/Projects/personal/dotfiles/install/install_zsh.sh`

It deletes existing plugin directories and clones fresh copies for idempotent installs.

## Homebrew Environment

Homebrew shell environment is loaded from `.zprofile`:

- `/opt/homebrew/bin/brew` on Apple Silicon
- `/usr/local/bin/brew` on Intel macOS
- `/home/linuxbrew/.linuxbrew/bin/brew` on Linux

## Completion Caching

Completion init uses a cached compdump at:

- `~/.cache/zsh/zcompdump`

If `compdef` is missing in non-login shells, completion is initialized on-demand.

## Profiling

To profile startup time:

1. Set `ZSH_PROFILE=1`
2. Run: `zsh -i -c 'zprof'`

## WSL Network Setup

WSL DNS fix is handled by:

- `~/.config/zsh/wsl_network_setup.sh`

This is invoked from `install.sh` during WSL setup.
