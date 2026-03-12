# Aliases and helpers
source $HOME/.config/zsh/aliases.sh
source $HOME/.config/zsh/utils.sh

# common settings for bash and zsh
source $HOME/.config/zsh/common.sh
source $HOME/.config/zsh/tmux_aliases.sh
source $HOME/.config/zsh/scripts/fzf.sh
source $HOME/.config/zsh/scripts/docker.sh

reload_zsh() {
  for f in $HOME/.config/zsh/rc.d/*.zsh; do
    [[ -f "$f" ]] && source "$f"
  done
}
