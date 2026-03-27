# FZF configuration
export FZF_DEFAULT_OPTS='
--bind ctrl-a:select-all,ctrl-d:deselect-all,tab:toggle+down,shift-tab:toggle+up
--height 50%
'

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --preview-window="border-sharp"
  --prompt="󰍉 "
  --marker="◆"
  --pointer="▸"
  --separator=""
  --scrollbar="🮉"
  --layout="reverse-list"
  --info="inline"'

# Colors sourced separately by the active theme
[ -f ~/.config/fzf/themes/amberglow.sh ] && source ~/.config/fzf/themes/amberglow.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
