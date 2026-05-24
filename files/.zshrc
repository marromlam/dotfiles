# zsh shell config file

# Source .zprofile for non-login interactive shells (login shells source it automatically)
[[ -o login ]] || { [[ -f "$HOME/.zprofile" ]] && source "$HOME/.zprofile"; }
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


# vim: fdm=marker ft=zsh






















































# BEGIN_EZA_THEME
export EZA_COLORS=$(tr '\n' ':' < ~/.config/eza/themes/amberglow.yaml)
# END_EZA_THEME

# Added by Antigravity
export PATH="/Users/marcos/.antigravity/antigravity/bin:$PATH"
