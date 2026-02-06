# zsh shell config file

[[ -f "$HOME/.zprofile" ]] && source "$HOME/.zprofile"
source $HOME/.config/zsh/conda.sh

# Use a minimal prompt in Cursor to avoid command detection issues
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  PROMPT='%n@%m:%~%# '
  RPROMPT=''
  return
fi

for rcfile in $HOME/.config/zsh/rc.d/*.zsh; do
  source "$rcfile"
done
