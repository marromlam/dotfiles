# Use a minimal prompt in Cursor to avoid command detection issues
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  PROMPT='%n@%m:%~%# '
  RPROMPT=''
  return
fi

# Zsh profiling (enable with ZSH_PROFILE=1)
if [[ -n "${ZSH_PROFILE:-}" ]]; then
  zmodload zsh/zprof
fi
