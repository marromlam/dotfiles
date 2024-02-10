# Vi-mode {{{

# https://superuser.com/questions/151803/how-do-i-customize-zshs-vim-mode
# http://pawelgoscicki.com/archives/2012/09/vi-mode-indicator-in-zsh-prompt/
vim_ins_mode=""
vim_cmd_mode="%F{green} %f"
vim_mode=$vim_ins_mode

function zle-keymap-select {
  vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
  set-prompt
  zle && zle reset-prompt
}
zle -N zle-keymap-select

function zle-line-finish {
  vim_mode=$vim_ins_mode
}
zle -N zle-line-finish

# When you C-c in CMD mode and you'd be prompted with CMD mode indicator,
# while in fact you would be in INS mode Fixed by catching SIGINT (C-c),
# set vim_mode to INS and then repropagate the SIGINT,
# so if anything else depends on it, we will not break it
function TRAPINT() {
  vim_mode=$vim_ins_mode
  return $(( 128 + $1 ))
}

# }}}

# Version control {{{
# vcs_info is a zsh native module for getting git info into your
# prompt. It's not as fast as using git directly in some cases
# but easy and well documented.
# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html
# %c - git staged
# %u - git untracked
# %b - git branch
# %r - git repo
autoload -Uz vcs_info

# Using named colors means that the prompt automatically adapts to how these
# are set by the current terminal theme
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "%F{green} ●%f"
zstyle ':vcs_info:*' unstagedstr "%F{red} ●%f"
zstyle ':vcs_info:*' use-simple true
zstyle ':vcs_info:git+set-message:*' hooks git-untracked git-stash
zstyle ':vcs_info:git*:*' actionformats '(%B%F{red}%b|%a%c%u%%b%f) '
zstyle ':vcs_info:git:*' formats "%F{249}(%f%F{blue}%{$__DOTS[ITALIC_ON]%}%b%{$__DOTS[ITALIC_OFF]%}%f%F{249})%f%c%u"

__in_git() {
    [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == "true" ]]
}

# TODO: these functions should not be run outside of a git repository
# this function adds a hook to the git vcs_info backend that depending
# they can also be quite slow...
# on the output of the git command adds an indicator to the the vcs info
# use --directory and --no-empty-directory to speed up command
# https://stackoverflow.com/questions/11122410/fastest-way-to-get-git-status-in-bash
function +vi-git-untracked() {
  emulate -L zsh
  if __in_git; then
    if [[ -n $(git ls-files --directory --no-empty-directory --exclude-standard --others 2> /dev/null) ]]; then
      hook_com[unstaged]+="%F{blue} ●%f"
    fi
  fi
}

function +vi-git-stash() {
  emulate -L zsh
  if __in_git; then
    if [[ -n $(git rev-list --walk-reflogs --count refs/stash 2> /dev/null) ]]; then
      hook_com[unstaged]+=" %F{yellow} ●%f "
    fi
  fi
}

# Add the zsh directory to the autoload dirs
fpath+=$HOME/.dotfiles/zsh/zshfunctions

autoload -Uz _fill_line && _fill_line

# }}}

# Prompt {{{
# Sets PROMPT and RPROMPT.
#
# %F...%f - - foreground color
# toggle color based on success %F{%(?.green.red)}
# %F{a_color} - color specifier
# %B..%b - bold
# %* - reset highlight
# %j - background jobs
#
# Requires: prompt_percent and no_prompt_subst.
function set-prompt() {
  emulate -L zsh
  # directory(branch)                     10:51
  # ❯  █
  #
  # icon options =  ❯   
  #
  # Top left:     directory(gitbranch) ● ●
  # Top right:    Time
  # Bottom left:  ➜
  # Bottom right: empty
  local dots_prompt_icon="%F{green}➜ %f"
  local dots_prompt_failure_icon="%F{red}✘ %f"
  local execution_time="%F{yellow}%{$__DOTS[ITALIC_ON]%}${cmd_exec_time}%{$__DOTS[ITALIC_OFF]%}%f "

  # local current_eviron="%F{red}% ⏣ ◣♯⚕i⚯ 🮤 	🭑  	🭔 ⚎ ⚈ ♨ ♞ 🬅 🬖 ❖ $(get_env)"
  local current_eviron=" $(get_env)"
  local placeholder="(%F{red}%{$__DOTS[ITALIC_ON]%}…%{$__DOTS[ITALIC_OFF]%}%f)"
  local top_left="%B%F{blue}%1~%f%b${_git_status_prompt:-$placeholder}"
  local top_right="${vim_mode}${current_eviron}${execution_time}%F{240}%*%f"
  local bottom_left="%(1j.%F{cyan}%j✦%f .)%(?.${dots_prompt_icon}.${dots_prompt_failure_icon})"

  PROMPT="$(_fill_line "$top_left" "$top_right")"$'\n'$bottom_left
}

# Correction prompt
export SPROMPT="correct %F{red}'%R'%f to %F{red}'%r'%f [%B%Uy%u%bes, %B%Un%u%bo, %B%Ue%u%bdit, %B%Ua%u%bbort]? "

setopt noprompt{bang,subst} prompt{cr,percent,sp}
#-------------------------------------------------------------------------------
#           Execution time
#-------------------------------------------------------------------------------
# Inspired by https://github.com/sindresorhus/pure/blob/81dd496eb380aa051494f93fd99322ec796ec4c2/pure.zsh#L47
#
# Turns seconds into human readable time.
# 165392 => 1d 21h 56m 32s
# https://github.com/sindresorhus/pretty-time-zsh
__human_time_to_var() {
  local human total_seconds=$1 var=$2
  local days=$(( total_seconds / 60 / 60 / 24 ))
  local hours=$(( total_seconds / 60 / 60 % 24 ))
  local minutes=$(( total_seconds / 60 % 60 ))
  local seconds=$(( total_seconds % 60 ))
  (( days > 0 )) && human+="${days}d "
  (( hours > 0 )) && human+="${hours}h "
  (( minutes > 0 )) && human+="${minutes}m "
  human+="${seconds}s"

  # Store human readable time in a variable as specified by the caller
  typeset -g "${var}"="${human}"
}

# Stores (into cmd_exec_time) the execution
# time of the last command if set threshold was exceeded.
__check_cmd_exec_time() {
  integer elapsed
  (( elapsed = EPOCHSECONDS - ${cmd_timestamp:-$EPOCHSECONDS} ))
  typeset -g cmd_exec_time=
  (( elapsed > 1 )) && {
    __human_time_to_var $elapsed "cmd_exec_time"
  }
}

__timings_preexec() {
  emulate -L zsh
  typeset -g cmd_timestamp=$EPOCHSECONDS
}

__timings_precmd() {
  __check_cmd_exec_time
  unset cmd_timestamp
}

# Extracted from the last working dir plugin in oh-my-zsh
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/last-working-dir/last-working-dir.plugin.zsh
#
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

#-------------------------------------------------------------------------------
#           Hooks
#-------------------------------------------------------------------------------
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
#
# *fd - file descriptor
#
# https://www.zsh.org/mla/users/2018/msg00424.html
# https://github.com/sorin-ionescu/prezto/pull/1805/files#diff-6a24e7644c4c0969110e86872283ec82L79
# https://github.com/zsh-users/zsh-autosuggestions/pull/338/files
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
# https://unix.stackexchange.com/questions/360600/reload-zsh-when-resizing-terminator-window
#
# Resource: [TRAP functions]
# http://zsh.sourceforge.net/Doc/Release/Functions.html#Trap-Functions
function TRAPWINCH () {
  # clear
  set-prompt
  zle && zle reset-prompt
}

add-zsh-hook precmd () {
  __timings_precmd
  # start async job to populate git info
  __async_vcs_start
  set-prompt
}

add-zsh-hook chpwd () {
  # clear current vcs_info
  _git_status_prompt=""
  __auto-ls-after-cd
  chpwd_last_working_dir
}


add-zsh-hook preexec () {
  __timings_preexec
}

# }}}
