# Aliases loader
for f in $HOME/.config/zsh/aliases.d/*.sh; do
  [[ -f "$f" ]] && source "$f"
done
