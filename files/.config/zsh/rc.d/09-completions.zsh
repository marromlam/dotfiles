# Completions
[[ -o interactive ]] || return

zcompdump_refresh() {
  local dump="$HOME/.cache/zsh/zcompdump"
  local stamp="$HOME/.cache/zsh/.zcompdump_refresh"
  [[ -o login ]] || return
  if [[ -f $stamp ]]; then
    local now=$(date +%s)
    local mtime=$(stat -f %m $stamp 2>/dev/null || echo 0)
    (( now - mtime < 86400 )) && return
  fi
  if [[ -f $dump ]]; then
    local now=$(date +%s)
    local mtime=$(stat -f %m $dump 2>/dev/null || echo 0)
    if (( now - mtime > 604800 )); then
      rm -f $dump
    fi
  fi
  mkdir -p "$HOME/.cache/zsh"
  date +%s > "$stamp"
}

zcompdump_refresh

mkdir -p "$HOME/.cache/zsh"
autoload -Uz compinit
compinit -d "$HOME/.cache/zsh/zcompdump" -C

[[ -f $HOME/.local/share/zsh/plugins/zsh-completions/zsh-completions.plugin.zsh ]] && source $HOME/.local/share/zsh/plugins/zsh-completions/zsh-completions.plugin.zsh

zstyle ':completion:*' menu yes select
zstyle ':completion:*' rehash true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $HOME/.cache/zsh
zstyle ':completion:*' format '%F{240}%d%f'
zstyle ':completion:*' list-dirs-first true

ls_colors="di=1;34:ln=36:so=35:pi=33:ex=32:bd=40;33:cd=40;33:su=37;41:sg=30;43:tw=30;42:ow=34;42"
zstyle ':completion:*:default' list-colors "${(s.:.)ls_colors}"
