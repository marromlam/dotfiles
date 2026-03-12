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

# AI helper aliases - disable globbing for ? ?? ??? functions
alias '?'='noglob ?'
alias '??'='noglob ??'
alias '???'='noglob ???'

# bun completions
[ -s "/Users/marcos/.bun/_bun" ] && source "/Users/marcos/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# BEGIN_FZF_THEME: carbon-mist
source ~/.config/fzf/themes/carbon-mist.sh
# END_FZF_THEME: carbon-mist

# vim: fdm=marker ft=zsh
