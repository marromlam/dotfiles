# couscous

<div align=center>
  <a href="../../commits/main">
    <img alt="Last commit" src="https://img.shields.io/github/last-commit/marromlam/dotfiles?style=for-the-badge&color=f2cdcd&labelColor=363a4f"/>
  </a>
  <img alt="Repo size" src="https://img.shields.io/github/repo-size/marromlam/dotfiles?style=for-the-badge&color=eba0ac&labelColor=363a4f"/>
</div>

<div align=center>
  <img alt="macOS" src="https://img.shields.io/badge/MacOS-f0f0f0?logo=apple&logoColor=black&style=for-the-badge"/>
  <img alt="Linux" src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black"/>
</div>

## Introduction

Most of my machine configuration lives here.

<img width="1680" alt="Screenshot 2023-11-07 at 10 55 09" src="https://github.com/marromlam/dotfiles/assets/41004396/7686b940-8004-42b6-bb28-92c5173882b6">
<img width="1680" alt="Screenshot 2023-11-07 at 11 01 43" src="https://github.com/marromlam/dotfiles/assets/41004396/feb8d9c7-2fbb-4a75-8b5c-a934fbb293ba">

Each machine is identified by a string stored in `~/.machine`:

| Identifier       | Machine                    |
| ---------------- | -------------------------- |
| `arm64-darwin`   | M-series Mac               |
| `x64-darwin`     | Intel Mac                  |
| `x64-linux`      | Linux                      |
| `x64-wsl`        | WSL2                       |
| `x64-nodos`      | IGFAE/CERN machines        |
| `x64-codespaces` | GitHub Codespaces          |
| `arm64-linux`    | Raspberry Pi 4             |
| `x32-linux`      | iSH app                    |

The install script creates this file automatically, or you can write it manually.

## Core tools

Neovim is the primary editor; everything else orbits it.

| Tool               | Role                            |
| ------------------ | ------------------------------- |
| Neovim             | Editor                          |
| Nerd Font          | Currently Fira Code             |
| fzf                | Fuzzy finder                    |
| ripgrep            | Search                          |
| tmux               | Terminal multiplexer            |
| kitty / wezterm    | Terminal emulators              |

## Installation

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/marromlam/dotfiles/main/install.sh)" -f -f
```

On WSL, run these first:

```bash
sudo sed -i -E 's/nameserver [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/nameserver 8.8.8.8/' /etc/resolv.conf
sudo apt update && sudo apt install curl -y
```

The installer:
1. Bootstraps Homebrew (or uses `apk` on iSH)
2. Installs packages via `install/install_dependencies.sh`
3. Clones this repo to `~/Projects/personal/dotfiles`
4. Creates symlinks via GNU Stow (`make install`)

After the initial install, individual steps can be re-run with `make`:

```
make brew     # reinstall/update Homebrew packages
make install  # re-apply symlinks
make setup    # run post-install setup
```

## macOS window manager (Amethyst + Hammerspoon)

- Installed via Brewfile (`amethyst`, `hammerspoon`)
- Configs are symlinked: `~/.amethyst.yml` and `~/.hammerspoon/`
- Required: `System Settings > Privacy & Security > Accessibility` — enable both apps
- If switching from another tiler (yabai/skhd), disable the old one first

## Contributing

Use this as a template — don't install it wholesale. Pick what's useful and build your own config. If you spot something worth sharing back, pull requests are welcome.
