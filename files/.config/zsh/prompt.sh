setopt PROMPT_SUBST
# Add the zsh directory to the autoload dirs
fpath+=$HOME/.config/zsh/zshfunctions

# Prompt {{{
# Sets PROMPT and RPROMPT.
# %F...%f - - foreground color
# toggle color based on success %F{%(?.green.red)}
# %F{a_color} - color specifier
# %B..%b - bold
# %* - reset highlight
# %j - background jobs
# Requires: prompt_percent and no_prompt_subst.
function set-prompt() {
  emulate -L zsh
  local status_icon="%(?.%F{green};%f.%F{red};%f)"
  local current_env="$(get_env)"
  local time_now="%F{240}%*%f"
  PROMPT="%B%F{blue}%1~%f%b %F{yellow}${current_env}%f ${status_icon} "
  RPROMPT="${time_now}"
}

# Correction prompt
export SPROMPT="correct %F{red}'%R'%f to %F{red}'%r'%f [%B%Uy%u%bes, %B%Un%u%bo, %B%Ue%u%bdit, %B%Ua%u%bbort]? "

setopt noprompt{bang,subst} prompt{cr,percent,sp}
# Extracted from the last working dir plugin in oh-my-zsh
# Flag indicating if we've previously jumped to last directory
typeset -g ZSH_LAST_WORKING_DIRECTORY

# Updates the last directory once directory is changed
chpwd_last_working_dir() {
  if [ "$ZSH_SUBSHELL" = 0 ]; then
    local cache_file="$HOME/.last_working_dir"
    pwd >| "$cache_file"
  fi
}

# Changes directory to the last working directory
lwd() {
  local cache_file="$HOME/.last_working_dir"
  [[ -r "$cache_file" ]] && cd "$(cat "$cache_file")"
}

# Jump to last directory automatically unless:
# - this isn't the first time the plugin is loaded
# - it's not in $HOME directory
if ! [[ -n $TMUX ]] ; then
  if ! [[ -n "$ZSH_LAST_WORKING_DIRECTORY" ]] || ! [[ "$PWD" != "$HOME" ]]; then
    lwd 2>/dev/null && ZSH_LAST_WORKING_DIRECTORY=1 || true
  fi
fi

#           Hooks
autoload -Uz add-zsh-hook

function __auto-ls-after-cd() {
  emulate -L zsh
  # Only in response to a user-initiated `cd`, not indirectly (eg. via another
  # function).
  if [ "$ZSH_EVAL_CONTEXT" = "toplevel:shfunc" ]; then
    ls -a
  fi
}

# Async prompt in Zsh
# Rather than using zpty (a pseudo terminal) under the hood
# as is the case with zsh-async this method forks a process sends
# it the command to evaluate which is written to a file descriptor
# *fd - file descriptor
__async_vcs_start() {
  # Close the last file descriptor to invalidate old requests
  if [[ -n "$__prompt_async_fd" ]] && { true <&$__prompt_async_fd } 2>/dev/null; then
    exec {__prompt_async_fd}<&-
    zle -F $__prompt_async_fd
  fi
  # fork a process to fetch the vcs status and open a pipe to read from it
  exec {__prompt_async_fd}< <(
    __async_vcs_info $PWD
  )

  # When the fd is readable, call the response handler
  zle -F "$__prompt_async_fd" __async_vcs_info_done
}

__async_vcs_info() {
  cd -q "$1"
  vcs_info
  print ${vcs_info_msg_0_}
}

# Called when new data is ready to be read from the pipe
__async_vcs_info_done() {
  # Read everything from the fd
  _git_status_prompt="$(<&$1)"
  # check if vcs info is returned, if not set the prompt
  # to a non visible character to clear the placeholder
  # NOTE: -z returns true if a string value has a length of 0
  if [[ -z $_git_status_prompt ]]; then
    _git_status_prompt=" "
  fi
  # remove the handler and close the file descriptor
  zle -F "$1"
  exec {1}<&-
  # reset the prompt
  set-prompt
  zle && zle reset-prompt
}

# When the terminal is resized, the shell receives a SIGWINCH signal.
# So redraw the prompt in a trap.
# Resource: [TRAP functions]
function TRAPWINCH () {
  # clear
  set-prompt
  zle && zle reset-prompt
}

add-zsh-hook precmd set-prompt

add-zsh-hook chpwd () {
  __auto-ls-after-cd
  chpwd_last_working_dir
}


add-zsh-hook preexec () { :; }

# }}}
