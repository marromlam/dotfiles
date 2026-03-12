# FZF configuration
export FZF_DEFAULT_OPTS='
--bind ctrl-a:select-all,ctrl-d:deselect-all,tab:toggle+down,shift-tab:toggle+up
--height 50%
'

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:-1,fg+:3,bg:-1,bg+:0
  --color=hl:5,hl+:5,info:4,marker:6
  --color=prompt:4,spinner:6,pointer:3,header:1
  --color=gutter:-1,border:-1,label:0,query:#d9d9d9
  --preview-window="border-sharp"
  --prompt="󰍉 "
  --marker="◆"
  --pointer="▸"
  --separator=""
  --scrollbar="🮉"
  --layout="reverse-list"
  --info="inline"'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
