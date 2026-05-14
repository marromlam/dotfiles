# zsh shell config file

[[ -f "$HOME/.zprofile" ]] && source "$HOME/.zprofile"

# Ensure lazy conda wrapper exists even after manual rc reloads.
if ! typeset -f conda >/dev/null 2>&1; then
  load_conda() {
    source "$HOME/.config/zsh/conda.sh"
    unset -f load_conda
  }
  conda() {
    load_conda
    conda "$@"
  }
fi

for rcfile in $HOME/.config/zsh/rc.d/*.zsh; do
  source "$rcfile"
done
