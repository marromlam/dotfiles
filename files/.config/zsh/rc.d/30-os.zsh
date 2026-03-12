# OS-dependent config
case `uname` in
  Darwin)
    source "$HOME/.config/zsh/macos.sh"
    source "$HOME/.config/zsh/prompt.sh"
    ;;
  Linux)
    source "$HOME/.config/zsh/linux.sh"
    source "$HOME/.config/zsh/prompt.sh"
    [[ ! -f /etc/resolv.conf ]] && echo nameserver 8.8.8.8 | sudo tee /etc/resolv.conf
    ;;
esac

# test if ~/.wsl exists and source zsh/windows.sh if it does
if [[ -f ~/.wsl ]]; then
  source "$HOME/.config/zsh/windows.sh"
fi

# Host-based prompt tweaks
HOST_SHORT=${HOST%%.*}

