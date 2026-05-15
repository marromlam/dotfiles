# Local overrides
[[ -f "$HOME/.zshrc_local" ]] && source $HOME/.zshrc_local

# auto activate environment on .aa-env file
export DIRENV_LOG_FORMAT=""
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
