# Plugins
[[ -o interactive ]] || return

zmodload zsh/datetime

# Create a hash table for globally stashing variables without polluting main scope
typeset -A __DOTS

[[ -o interactive ]] && command -v pixi >/dev/null && eval "$(pixi completion --shell zsh)" || true

# zsh suggestions
[[ -f $HOME/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source $HOME/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f $HOME/.local/share/zsh/plugins/alias-tips/alias-tips.plugin.zsh ]] && source $HOME/.local/share/zsh/plugins/alias-tips/alias-tips.plugin.zsh
[[ -f $HOME/.local/share/zsh/plugins/fzf-marks/fzf-marks.plugin.zsh ]] && source $HOME/.local/share/zsh/plugins/fzf-marks/fzf-marks.plugin.zsh
if command -v terminal-notifier >/dev/null || command -v notify-send >/dev/null; then
  source $HOME/.local/share/zsh/plugins/zsh-auto-notify/auto-notify.plugin.zsh
fi
if [[ -f $HOME/.local/share/zsh/plugins/zsh-autopair/zsh-autopair.plugin.zsh ]]; then
  if [[ -t 0 && -t 1 ]]; then
    source $HOME/.local/share/zsh/plugins/zsh-autopair/zsh-autopair.plugin.zsh
  fi
fi
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=241'
# ZSH_AUTOSUGGEST_USE_ASYNC=1
CASE_SENSITIVE="false"
setopt MENU_COMPLETE
setopt no_list_ambiguous


# syntax highlighting
if [[ -f $HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  _load_zsh_syntax_highlighting() {
    source $HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    add-zsh-hook -d precmd _load_zsh_syntax_highlighting
  }
  add-zsh-hook precmd _load_zsh_syntax_highlighting
fi
