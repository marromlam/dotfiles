# fictional couscous

Most of my machine configuration is handled with my dotfiles.
Dotfiles, you know, fictional couscous...

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/marromlam/dotfiles/main/install.sh)" -f -f
```

I use different machines for different purposes, and I have set a
identificator for each of them. This identificator is based on the
architecture of the machine, and the OS. The following are the
identificators I use:

- arm64-darwin: for my M1 mac
- arm64-linux: for my Raspberry Pi 4
- x64-darwin: for my Intel mac
- x64-linux: for my linux machines
- x64-nodos: for IGFAE/CERN machines
- x64-codespaces: used for all my codespaces
- x64-wsl: used for my WSL2 setup
- x32-linux: mainly used for iSH app

This information **must** be set in the `~/.machine` file. This file is
automatically created by the `install.sh` script, but you can create it
manually if you want. The file should contain only the identificator of the
machine, and nothing else.

## Core ideas

Neovim is my editor. Everything is set to be comfortable to work with it. The
main parts of the code are:

| Dependency         | Description                     |
| ------------------ | ------------------------------- |
| Neovim             | Best editor on Earth            |
| Nerd font          | Currently I use Victor          |
| Fuzzy Finder (fzf) | Search utility                  |
| ripgrep            | Search, better than grep for me |
| tmux               | Terminal multiplexer            |

I do almost all my work sshing into different machines, with are all of them
linux based (they use basically SCL and CentOS).

## Makefile

blah blah blah

### macOS

All these files are intended to work in macOS and were tested in the latest
stable release of macOS Big Sur (on Intel Macs, 😥).
That's why I have a `mac macos` rule, which sets up almost my whole macOS
configuration in jus a sec.

### kitty

When you open a lot of nvim instances in different machines and attach to
several tmux instances, you will give proper value to a terminal which cares
about cpu cycles. Kitty is one of those terminals, plus has full image support.
It is a super-fast GPU-accelerated terminal emulator with a lot of
customizations, and a very helpful community.

Kitty lacks a good macOS icon. I made one for me, with my favourite cat, Gin.

#### juKitty

I develop a lot of python code, so you might recommend me to use Jupiter
notebooks. I argue that. In 2021 Easter, encouraded by my mate [Saul](https://github.com/saulsolino), I developed
juKitty. It is (we think) a very close approach to that the VSCode Python
extension does with line-by-line evaluation. It leverages kitty's image support
to plot images inline, plus it allows me to run the code in any of the machines
I have access to on the fly.

|             | local python kernel | remote python kernel |
| ----------- | ------------------- | -------------------- |
| local code  | yes                 | yes                  |
| remote code | yes                 | yes                  |

### neovim and vim

I mostly use neovim, but since I ssh to a lot of machines dayly, sometime I do
not have nvim installed / I don't have libraries installed in that machine to
allow me to easy install it. So, in this situations, I use vim. Most of the
stuff works right away, and things that don't are source-skipped with ifs in my
nvim dotfiles.

The neovim rule should install all plugins and python support, and the `vim` one
should create soft links to the former.

### tmux

I need persitent sessions! I love them.

## Contributions

This files should be used as a template to create your own configuration. I do
not recommend you to make install all my dotfiles since you will not leverage
the most part of them. Instead, try to copy what you need and create your own
repo. But, if you find there is some plugin or configuration that I could take
advantage of, please do not hessitate to create a pull request!.
