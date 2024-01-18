# fictional couscous

Most of my machine configuration is handled with my fictional couscous!

<img width="1680" alt="Screenshot 2023-11-07 at 10 55 09" src="https://github.com/marromlam/dotfiles/assets/41004396/7686b940-8004-42b6-bb28-92c5173882b6">
<img width="1680" alt="Screenshot 2023-11-07 at 11 01 43" src="https://github.com/marromlam/dotfiles/assets/41004396/feb8d9c7-2fbb-4a75-8b5c-a934fbb293ba">

I use different machines for different purposes, and I have set a
identificator for each of them. This identificator is based on the
architecture of the machine, and the OS. The following are the
identificators I use:

- `arm64-darwin`: for my M1 mac
- `arm64-linux`: for my Raspberry Pi 4
- `x64-darwin`: for my Intel mac
- `x64-linux`: for my linux machines
- `x64-nodos`: for IGFAE/CERN machines
- `x64-codespaces`: used for all my codespaces
- `x64-wsl`: used for my WSL2 setup
- `x32-linux`: mainly used for iSH app

This information **must** be set in the `~/.machine` file. This file is
automatically created by the `install.sh` script, but you can create it
manually if you want. The file should contain only the identificator of the
machine, and nothing else.

## Core ideas

Neovim is my main editor, and everything is circling around it. Here is a list
of the tools I use:

| Dependency         | Description                                 |
| ------------------ | ------------------------------------------- |
| Neovim             | Best editor on Earth                        |
| Nerd font          | Currently I use Fira Code                   |
| Fuzzy Finder (fzf) | Search utility                              |
| ripgrep            | Search                                      |
| tmux               | Terminal multiplexer                        |
| wezterm            | The terminal emulator that works everywhere |

I was mostly a Unix user till very recencly where I was forced to use Windows
and WSL. I used to use kitty as my main terminal, but I swiched to Wezterm
because it is the only one available on all platforms.

## Makefile

It still exists a Makefile to install this configuration, but I am currently
using dotbot to manage my dotfiles.

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/marromlam/dotfiles/main/install.sh)" -f -f
```

In WSL you need to run the following commands first:

```bash
sudo sed -i -E 's/nameserver [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/nameserver 8.8.8.8/' /etc/resolv.conf
sudo apt update && sudo apt install curl -y
```

## Contributions

This files should be used as a template to create your own configuration. I do
not recommend you to make install all my dotfiles since you will not leverage
the most part of them. Instead, try to copy what you need and create your own
repo. But, if you find there is some plugin or configuration that I could take
advantage of, please do not hesitate to create a pull request!
