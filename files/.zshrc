
# Eval Homebrew {{{

# Get machine operative system
export MACHINEOS=`$HOME/.dotfiles/scripts/machine.sh`
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

# Set OS-dependent stuff
if [[ "$MACHINEOS" == "Mac" ]]; then
  # homebrew path
  if [[ "$(uname -m)" == "x86_64" ]]; then
    # intel / rosseta
    export HOMEBREW_PREFIX="/usr/local"
  else
    # running on Apple Sillicon
    export HOMEBREW_PREFIX="/opt/homebrew"
  fi
else
  # linuxbrew path
  export HOMEBREW_PREFIX="$HOME/.linuxbrew"
fi
eval $($HOMEBREW_PREFIX/bin/brew shellenv)
export XDG_DATA_DIRS="$HOMEBREW_PREFIX/share:$XDG_DATA_DIRS"

# export languages
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# source basuc functions
source $DOTFILES/zsh/ufunctions.sh
#
# set prompt-stuyle for zsh {{{

CONDA_AUTO_ACTIVATE_BASE=false
CONDA_ALWAYS_YES=true

export VIRTUAL_ENV_DISABLE_PROMPT=0
#conda config --set changeps1 False

# get virtualenv
function get_env {
 if [ $VIRTUAL_ENV ]; then
   echo "via ('`basename $VIRTUAL_ENV`') "
 elif [ $CONDA_DEFAULT_ENV ]; then
   echo "via ${CONDA_DEFAULT_ENV}"
 else
   echo "syst"
 fi
}


# disables prompt mangling in virtual_env/bin/activate
export VIRTUAL_ENV_DISABLE_PROMPT=1
# }}}


# Use Powerlevel10k if zsh is new enough, else use starship {{{

# MIN_ZSH_VERSION=5.1.0
# THE_ZSH_VERSION=`echo $ZSH_VERSION`
# if [ $(version $THE_ZSH_VERSION) -ge $(version $MIN_ZSH_VERSION) ]; then
#   # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
#   # Initialization code that may require console input (password prompts, [y/n]
#   # confirmations, etc.) must go above this block; everything else may go below.
#   source $HOMEBREW/opt/powerlevel10k/powerlevel10k.zsh-theme
#   if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#     source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#   fi
#   # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#   [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# else
#   function whoismyhost (){
#     a="$(ip route get 1 | awk '{print $NF;exit}')"
#     b=`echo "$a" | sed 's/^.*\.\([^.]*\)$/\1/'`
#     #echo $a
#     #echo $b
#     if [[ $a == 172.16.57.* ]]; then
#       echo "gpu"$b
#     elif [[ $a == 172.16.58.1 ]]; then
#       echo "master"
#     elif [[ $a == 193.144.80.1 ]]; then
#       echo "pool"
#     else
#       echo "nodo0"$b
#     fi
#   }
#   export CURRENT_HOST="$(whoismyhost)"
# fi

# }}}


zmodload zsh/datetime

# Create a hash table for globally stashing variables without polluting main
# scope with a bunch of identifiers.
typeset -A __DOTS

__DOTS[ITALIC_ON]=$'\e[3m'
__DOTS[ITALIC_OFF]=$'\e[23m'


PLUGIN_DIR=$DOTFILES/zsh/plugins

# Init completions
autoload -Uz compinit
compinit

# Plugins {{{
# These should be source *BEFORE* setting up hooks

# zsh suggestions
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=241'
ZSH_AUTOSUGGEST_USE_ASYNC=1
CASE_SENSITIVE="false"
setopt MENU_COMPLETE
setopt no_list_ambiguous
#zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==34=34}:${(s.:.)LS_COLORS}")';
ls_colors="di=1;34:ln=36:so=35:pi=33:ex=32:bd=40;33:cd=40;33:su=37;41:sg=30;43:tw=30;42:ow=34;42"
zstyle ':completion:*:default' list-colors "${(s.:.)ls_colors}"
zstyle ':completion:*' menu yes select

# syntax highlighting
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# source $HOMEBREW_PREFIX/share/zsh-completions/zsh-completions.zsh

source $HOMEBREW_PREFIX/share/zsh-alias-tips/alias-tips.plugin.zsh

autoload zmv # builtin zsh rename command

# }}}

# zsh completions {{{

# Completion for kitty
if [[ "$TERM" == "xterm-kitty" ]]; then
  kitty + complete setup zsh | source /dev/stdin
fi

# Colorize completions using default `ls` colors.
zstyle ':completion:*' list-colors ''

# Enable keyboard navigation of completions in menu
# (not just tab/shift-tab but cursor keys as well):
zstyle ':completion:*' menu select

# persistent reshahing i.e puts new executables in the $path
# if no command is set typing in a line will cd by default
zstyle ':completion:*' rehash true

# Allow completion of ..<Tab> to ../ and beyond.
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(..) ]] && reply=(..)'

# Categorize completion suggestions with headings:
zstyle ':completion:*' group-name ''
# Style the group names
zstyle ':completion:*' format %F{yellow}%B%U%{$__DOTS[ITALIC_ON]%}%d%{$__DOTS[ITALIC_OFF]%}%b%u%f

# Added by running `compinstall`
zstyle ':completion:*' expand suffix
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-suffixes true
# End of lines added by compinstall

# Make completion:
# (stolen from Wincent)
# - Try exact (case-sensitive) match first.
# - Then fall back to case-insensitive.
# - Accept abbreviations after . or _ or - (ie. f.b -> foo.bar).
# - Substring complete (ie. bar -> foobar).
zstyle ':completion:*' matcher-list '' '+m:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}' '+m:{_-}={-_}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# }}}

# set some history options {{{
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=999999999
export SAVEHIST=999999999
setopt SHARE_HISTORY # Share your history across all your terminal windows
setopt APPEND_HISTORY

setopt AUTO_CD
setopt RM_STAR_WAIT
setopt CORRECT # command auto-correction
setopt COMPLETE_ALIASES
setopt AUTOPARAMSLASH # tab completing directory appends a slash

# }}}

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
fpath+=$DOTFILES/zsh/zshfunctions

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

  local current_eviron="%F{red}% -<$(get_env)>-"
  local placeholder="(%F{blue}%{$__DOTS[ITALIC_ON]%}…%{$__DOTS[ITALIC_OFF]%}%f)"
  local top_left="%B%F{10}%1~%f%b${current_eviron}${_git_status_prompt:-$placeholder}"
  local top_right="${vim_mode}${execution_time}%F{240}%*%f"
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
#-------------------------------------------------------------------------------
#   LOCAL SCRIPTS
#-------------------------------------------------------------------------------
# source all zsh and sh files
for script in $DOTFILES/zsh/scripts/*; do
  source $script
done

# }}}

# os-dependent config {{{

case `uname` in
  Darwin)
    source "$DOTFILES/zsh/macos.sh"
    ;;
  Linux)
    source "$DOTFILES/zsh/linux.sh"
    ;;
esac

# }}}

# source my aliases
source $DOTFILES/zsh/aliases.sh



# fuzzy finder configuration {{{

# export FZF_DEFAULT_OPTS='--height 40% --border --preview="cat {}" --preview-window=right:60%:wrap'

#export FZF_PREVIEW_COMMAND='bat {}'
#export FZF_DEFAULT_OPTS="
#  --color=dark
#  --color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
#  --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
#  --bind ctrl-a:select-all,ctrl-d:deselect-all,tab:toggle+up,shift-tab:toggle+down
#"
# Fzf completions
#source "/usr/local/opt/fzf/shell/completion.bash"
#source "/usr/local/opt/fzf/shell/key-bindings.bash"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Ripgrep configuration file
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/rc

# }}}


# pyenv stuff {{{

#   eval "$(pyenv init -)"
#   if which pyenv-virtualenv-init > /dev/null; then 
#     eval "$(pyenv virtualenv-init -)"
#   fi

# }}}

# autoinit {{{

# if [[ -n $ZSH_INIT_COMMAND ]]; then
#   echo "Running: $ZSH_INIT_COMMAND"
#   eval "$ZSH_INIT_COMMAND"
# fi

# }}}

if exists hub; then
  eval "$(hub alias -s)" # Aliases 'hub' to git
fi

if [[ ! "$(exists nvr)" && "$(exists pip3)" ]]; then
  pip3 install neovim-remote
fi

if exists thefuck; then
  eval $(thefuck --alias)
fi

if exists zoxide; then
  eval "$(zoxide init zsh)"
fi


# zsh keybindings {{{

bindkey -v # enables vi mode, using -e = emacs

export KEYTIMEOUT=1
bindkey ‘^R’ history-incremental-search-backward
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^U' autosuggest-accept

# }}}

# finishing {{{

# common settings for bash and zsh
source $DOTFILES/zsh/common.sh

# Set editor
# export EDITOR='nvim'

# source $HOME/.sh_profile

# source local config file, if exists
[[ -f "$HOME/.zshrc_local" ]] && source $HOME/.zshrc_local

# check whether tmux is running or not, and export variable
if [ -n "$TMUX" ]; then
  export IS_TMUX=1
else
  if [ -z ${IS_TMUX+x} ]; then
    export IS_TMUX=0
  fi
fi

# }}}


# vim: fdm=marker ft=zsh
