# Carbon Mist - fzf Theme
# Carbon Mist theme based on a soft retro ANSI palette.
# Author: Marcos Romero Lamas
# Version: 1.0.0

# fzf color scheme configuration
# Uses ANSI color codes: -1 (default), 0-15 (ANSI colors), or hex colors

export FZF_DEFAULT_OPTS="\
--bind ctrl-a:select-all,ctrl-d:deselect-all,tab:toggle+down,shift-tab:toggle+up \
--height 50% \
--color=fg:#C4C8C6,fg+:#C4C8C6,bg:#1D1F21,bg+:#353A44 \
--color=hl:#F0C674,hl+:#F0C674,info:#8ABEB7,marker:#B6BD68 \
--color=prompt:#666666,spinner:#B6BD68,pointer:#F0C674,header:#666666 \
--color=gutter:#1D1F21,border:#666666,label:#C4C8C6,query:#C4C8C6 \
--preview-window='border-sharp' \
--prompt='󰍉 ' \
--marker='◆' \
--pointer='▸' \
--separator='' \
--scrollbar='🮉' \
--layout='reverse-list' \
--info='inline'"
