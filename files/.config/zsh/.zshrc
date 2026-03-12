# zsh shell config file

[[ -f "$HOME/.zprofile" ]] && source "$HOME/.zprofile"
for rcfile in $HOME/.config/zsh/rc.d/*.zsh; do
  source "$rcfile"
done
