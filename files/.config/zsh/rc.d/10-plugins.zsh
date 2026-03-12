# Plugins
[[ -o interactive ]] || return

zmodload zsh/datetime
autoload -Uz add-zsh-hook

# Create a hash table for globally stashing variables without polluting main scope
typeset -A __DOTS

# pixi completions — cache + defer to first precmd to not block startup
# Version check is throttled: only run pixi --version once per day via zstat
if command -v pixi >/dev/null; then
  _pixi_cache="$HOME/.cache/zsh/pixi-completion.zsh"
  if [[ ! -f $_pixi_cache ]]; then
    # No cache at all — generate it now
    mkdir -p "${_pixi_cache:h}"
    pixi completion --shell zsh >| "$_pixi_cache"
    NO_COLOR=1 pixi --version >| "$_pixi_cache.version"
  else
    # Cache exists — re-check version at most once per day
    zmodload -F zsh/stat b:zstat 2>/dev/null
    typeset -A _pixi_st
    if ! { zstat -H _pixi_st "$_pixi_cache.version" 2>/dev/null && (( EPOCHSECONDS - _pixi_st[mtime] < 86400 )) }; then
      _pixi_ver="$(NO_COLOR=1 pixi --version 2>/dev/null)"
      if [[ "$_pixi_ver" != "$(<"$_pixi_cache.version")" ]]; then
        pixi completion --shell zsh >| "$_pixi_cache"
      fi
      print -r -- "$_pixi_ver" >| "$_pixi_cache.version"
      unset _pixi_ver
    fi
    unset _pixi_st
  fi
  _load_pixi_completions() {
    source "$_pixi_cache"
    unset _pixi_cache
    add-zsh-hook -d precmd _load_pixi_completions
  }
  add-zsh-hook precmd _load_pixi_completions
fi

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
CASE_SENSITIVE="false"
setopt MENU_COMPLETE
setopt no_list_ambiguous

# syntax highlighting — deferred to first precmd to not block startup
if [[ -f $HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  _load_zsh_syntax_highlighting() {
    source $HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    add-zsh-hook -d precmd _load_zsh_syntax_highlighting
  }
  add-zsh-hook precmd _load_zsh_syntax_highlighting
fi
