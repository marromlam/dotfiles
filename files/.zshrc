# zsh shell config file — everything except login-only setup (.zprofile) and
# vars needed by every invocation, even scripts (.zshenv) lives here.
#
# Sections, top to bottom: conda · direnv · vscode bypass · profiling ·
# completions · plugins · history · OS config + prompt · WSL · fzf ·
# keybindings · utilities · jupyter · AI helpers (?/??/???) · env vars + PATH ·
# aliases (git/nav/misc) · tmux/zellij · fzf helpers · docker helpers ·
# local/private overrides · debug · AI noglob aliases · bun · theme markers
# Folds match these sections (zsh/vim: fdm=marker) — za to toggle one, zR to
# open all, zM to close all.

[[ -o login ]] || { [[ -f "$HOME/.zprofile" ]] && source "$HOME/.zprofile"; }

# --- conda (activate) --- {{{
# Install happens once, out-of-band, via install/install_conda.sh — this is
# just the lazy activation shim so a plain shell startup never touches conda.
CONDA_INSTALL_DIR="/opt/conda"
conda() {
  if [[ ! -x "${CONDA_INSTALL_DIR}/bin/conda" ]]; then
    echo "conda not installed — run install/install_conda.sh" >&2
    return 1
  fi
  eval "$(${CONDA_INSTALL_DIR}/bin/conda shell.zsh hook)"
  conda "$@"
}
# }}}

# --- direnv & vscode bypass --- {{{
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Minimal prompt in Cursor/VS Code's terminal, skip everything below
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  PROMPT='%n@%m:%~%# '
  RPROMPT=''
  return
fi
# }}}

# --- profiling (ZSH_PROFILE=1) --- {{{
[[ -n "${ZSH_PROFILE:-}" ]] && zmodload zsh/zprof
# }}}

# --- completions --- {{{
[[ -o interactive ]] || return

# Regenerate zcompdump at most once a day (login shells only)
zcompdump_refresh() {
  [[ -o login ]] || return
  local dump="$HOME/.cache/zsh/zcompdump" stamp="$HOME/.cache/zsh/.zcompdump_refresh"
  zmodload -F zsh/stat b:zstat 2>/dev/null || return
  local -A st
  if zstat -H st "$stamp" 2>/dev/null; then
    (( EPOCHSECONDS - st[mtime] < 86400 )) && return
  fi
  if zstat -H st "$dump" 2>/dev/null; then
    (( EPOCHSECONDS - st[mtime] > 604800 )) && rm -f "$dump"
  fi
  mkdir -p "$HOME/.cache/zsh"
  touch "$stamp"
}
zcompdump_refresh

[[ -d "$HOME/.cache/zsh" ]] || mkdir -p "$HOME/.cache/zsh"
autoload -Uz compinit
compinit -d "$HOME/.cache/zsh/zcompdump" -C
[[ -f $HOME/.local/share/zsh/plugins/zsh-completions/zsh-completions.plugin.zsh ]] && source $HOME/.local/share/zsh/plugins/zsh-completions/zsh-completions.plugin.zsh

zstyle ':completion:*' menu yes select
zstyle ':completion:*' rehash true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $HOME/.cache/zsh
zstyle ':completion:*' format '%F{240}%d%f'
zstyle ':completion:*' list-dirs-first true
ls_colors="di=1;34:ln=36:so=35:pi=33:ex=32:bd=40;33:cd=40;33:su=37;41:sg=30;43:tw=30;42:ow=34;42"
zstyle ':completion:*:default' list-colors "${(s.:.)ls_colors}"
# }}}

# --- plugins --- {{{
zmodload zsh/datetime
autoload -Uz add-zsh-hook
typeset -A __DOTS # scratch space for deferred-load state, avoids polluting scope

# pixi completions — cached, version re-checked at most daily, load deferred
# to first precmd so it never blocks startup
if command -v pixi >/dev/null; then
  _pixi_cache="$HOME/.cache/zsh/pixi-completion.zsh"
  if [[ ! -f $_pixi_cache ]]; then
    mkdir -p "${_pixi_cache:h}"
    pixi completion --shell zsh >| "$_pixi_cache"
    NO_COLOR=1 pixi --version >| "$_pixi_cache.version"
  else
    zmodload -F zsh/stat b:zstat 2>/dev/null
    typeset -A _pixi_st
    if ! { zstat -H _pixi_st "$_pixi_cache.version" 2>/dev/null && (( EPOCHSECONDS - _pixi_st[mtime] < 86400 )) }; then
      _pixi_ver="$(NO_COLOR=1 pixi --version 2>/dev/null)"
      [[ "$_pixi_ver" != "$(<"$_pixi_cache.version")" ]] && pixi completion --shell zsh >| "$_pixi_cache"
      print -r -- "$_pixi_ver" >| "$_pixi_cache.version"
      unset _pixi_ver
    fi
    unset _pixi_st
  fi
  _load_pixi_completions() {
    [[ -f "$HOME/.cache/zsh/pixi-completion.zsh" ]] && source "$HOME/.cache/zsh/pixi-completion.zsh"
    add-zsh-hook -d precmd _load_pixi_completions
  }
  add-zsh-hook precmd _load_pixi_completions
  unset _pixi_cache
fi

[[ -f $HOME/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source $HOME/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f $HOME/.local/share/zsh/plugins/alias-tips/alias-tips.plugin.zsh ]] && source $HOME/.local/share/zsh/plugins/alias-tips/alias-tips.plugin.zsh
[[ -f $HOME/.local/share/zsh/plugins/fzf-marks/fzf-marks.plugin.zsh ]] && source $HOME/.local/share/zsh/plugins/fzf-marks/fzf-marks.plugin.zsh
if command -v terminal-notifier >/dev/null || command -v notify-send >/dev/null; then
  source $HOME/.local/share/zsh/plugins/zsh-auto-notify/auto-notify.plugin.zsh
fi
if [[ -f $HOME/.local/share/zsh/plugins/zsh-autopair/zsh-autopair.plugin.zsh && -t 0 && -t 1 ]]; then
  source $HOME/.local/share/zsh/plugins/zsh-autopair/zsh-autopair.plugin.zsh
fi
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=241'
CASE_SENSITIVE="false"
setopt MENU_COMPLETE
setopt no_list_ambiguous

# syntax highlighting — deferred to first precmd, it's the slowest plugin
__DOTS[zsh_syntax_highlighting]="$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
if [[ -f "${__DOTS[zsh_syntax_highlighting]}" ]]; then
  _load_zsh_syntax_highlighting() {
    source "${__DOTS[zsh_syntax_highlighting]}"
    add-zsh-hook -d precmd _load_zsh_syntax_highlighting
  }
  add-zsh-hook precmd _load_zsh_syntax_highlighting
fi
# }}}

# --- history & shell options --- {{{
setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_ALL_DUPS HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS HIST_VERIFY SHARE_HISTORY APPEND_HISTORY
setopt AUTO_CD RM_STAR_WAIT CORRECT COMPLETE_ALIASES AUTOPARAMSLASH
setopt NO_BEEP NO_BG_NICE NO_HUP CASE_GLOB INTERACTIVE_COMMENTS EXTENDED_GLOB
HISTORY_IGNORE="(*password*|*token*|*secret*|*apikey*|*api_key*)"
# }}}

# --- OS-specific config + prompt --- {{{
# $OSTYPE is a zsh builtin, unlike `uname`, it doesn't fork a subprocess.
case $OSTYPE in
  darwin*)
    export BASH_SILENCE_DEPRECATION_WARNING=1
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_AUTO_UPDATING=0
    export HOMEBREW_UPDATE_PREINSTALL=0
    ulimit -S -n 2048
    # Needed for Neovim's SonarLint plugin
    [[ -d "/opt/homebrew/opt/openjdk/bin" ]] && export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
    ;;
  linux*)
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_AUTO_UPDATING=0
    export HOMEBREW_UPDATE_PREINSTALL=0
    [[ ! -f /etc/resolv.conf ]] && echo nameserver 8.8.8.8 | sudo tee /etc/resolv.conf
    ;;
esac

if [[ $OSTYPE == darwin* || $OSTYPE == linux* ]]; then
  setopt PROMPT_SUBST

  # Sets PROMPT/RPROMPT. get_env() (defined further down) fills the env segment.
  function set-prompt() {
    emulate -L zsh
    local status_icon="%(?.%F{green};%f.%F{red};%f)"
    local current_env="$(get_env)"
    local time_now="%F{240}%*%f"
    PROMPT="%B%F{blue}%1~%f%b %F{yellow}${current_env}%f ${status_icon} "
    RPROMPT="${time_now}"
  }
  export SPROMPT="correct %F{red}'%R'%f to %F{red}'%r'%f [%B%Uy%u%bes, %B%Un%u%bo, %B%Ue%u%bdit, %B%Ua%u%bbort]? "
  setopt noprompt{bang,subst} prompt{cr,percent,sp}

  # Last-working-dir jump on shell start (from oh-my-zsh), skipped inside tmux
  typeset -g ZSH_LAST_WORKING_DIRECTORY
  chpwd_last_working_dir() {
    [[ "$ZSH_SUBSHELL" = 0 ]] && pwd >| "$HOME/.last_working_dir"
  }
  lwd() {
    [[ -r "$HOME/.last_working_dir" ]] && cd "$(cat "$HOME/.last_working_dir")"
  }
  if [[ -z $TMUX && ( -z "$ZSH_LAST_WORKING_DIRECTORY" || "$PWD" == "$HOME" ) ]]; then
    lwd 2>/dev/null && ZSH_LAST_WORKING_DIRECTORY=1
  fi

  function __auto-ls-after-cd() {
    emulate -L zsh
    # Only for a user-typed `cd`, not one triggered indirectly by a function
    [[ "$ZSH_EVAL_CONTEXT" = "toplevel:shfunc" ]] && ls -a
  }
  function TRAPWINCH() { set-prompt; zle && zle reset-prompt } # redraw on terminal resize

  add-zsh-hook precmd set-prompt
  add-zsh-hook chpwd () { __auto-ls-after-cd; chpwd_last_working_dir }
  add-zsh-hook preexec () { :; }
fi
# }}}

# --- WSL --- {{{
if [[ -f ~/.wsl ]]; then
  alias wpwd="echo $PWD | tr '/' '\\\\'"
  alias winword='"/mnt/c/Program Files/Microsoft Office/root/Office16/WINWORD.EXE"'
  export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
  export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
  export PATH="$PATH:/mnt/c/WINDOWS/system32"
  export PATH="$PATH:/mnt/c/WINDOWS"
  export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"

  docker-service() {
    DOCKER_DISTRO="Ubuntu-24.04"
    DOCKER_DIR=/mnt/wsl/shared-docker
    export DOCKER_SOCK="$DOCKER_DIR/docker.sock"
    export DOCKER_HOST="unix://$DOCKER_SOCK"
    if [ ! -S "$DOCKER_SOCK" ]; then
      mkdir -pm o=,ug=rwx "$DOCKER_DIR"
      chgrp docker "$DOCKER_DIR"
      /mnt/c/Windows/System32/wsl.exe -d $DOCKER_DISTRO sh -c "nohup sudo -b dockerd < /dev/null > $DOCKER_DIR/dockerd.log 2>&1"
    fi
  }

  [[ -f $HOME/.vcxsrv ]] && export DISPLAY="$(cat $HOME/.vcxsrv)"
  get-vcxsrv-display() {
    IP4_ADDRESS=$(powershell.exe Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Wi-Fi | grep IPAddress | awk '{print $3}')
    rm -rf $HOME/.vcxsrv
    echo "${IP4_ADDRESS}" >$HOME/.vcxsrv
    dos2unix $HOME/.vcxsrv &>/dev/null
    sed -i 's/$/:0/g' ~/.vcxsrv
    dos2unix $HOME/.vcxsrv &>/dev/null
  }

  # Some Windows-side dotfiles/apps must be **copied**, not symlinked, in
  sync-windows-config() {
    LINUX_CONFIG=~/Workspaces/personal/dotfiles/files/.config
    WINDOWS_CONFIG=/mnt/c/Users/marcos.romero/.config
    mkdir -p $WINDOWS_CONFIG
    chmod -R 777 $WINDOWS_CONFIG
    WINDOWS_APPLICATIONS=/mnt/c/Users/marcos.romero/Applications/
    mkdir -p $WINDOWS_APPLICATIONS
    chmod -R 777 $WINDOWS_APPLICATIONS
    ln -sf /mnt/c/Users/marcos.romero/Downloads $HOME/Downloads
    ln -sf /mnt/c/Users/marcos.romero/Documents $HOME/Documents
    ln -sf /mnt/c/Users/marcos.romero/Desktop $HOME/Desktop
    ln -sf /mnt/c/Users/marcos.romero/Applications $HOME/Applications
  }
fi
# }}}

HOST_SHORT=${HOST%%.*}

# --- fzf --- {{{
export FZF_DEFAULT_OPTS='
--bind ctrl-a:select-all,ctrl-d:deselect-all,tab:toggle+down,shift-tab:toggle+up
--height 50%
'
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --preview-window="border-sharp"
  --prompt="󰍉 "
  --marker="◆"
  --pointer="▸"
  --separator=""
  --scrollbar="🮉"
  --layout="reverse-list"
  --info="inline"'
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --history=$HOME/.fzf_history"
# color theme is owned by the BEGIN_FZF_THEME block at the bottom of this file
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# }}}

# --- keybindings --- {{{
bindkey -e # emacs (bindkey -v for vi mode)

path_list() { echo $PATH | tr ':' '\n' }

reload_zsh() {
  source "$HOME/.zshenv"
  source "$HOME/.zshrc"
}
# }}}

# --- generic utilities (no side effects) --- {{{
# Version string -> comparable integer, e.g. 1.2.3 -> 1002003
function version() {
  echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'
}
# Check if command exists (faster than `command -v` in zsh)
# https://www.topbug.net/blog/2016/10/11/speed-test-check-the-existence-of-a-command-in-bash-and-zsh
exists() {
  (( $+commands[$1] ))
}
# Get machine type: Mac, Linux, Cygwin, MinGw, or UNKNOWN:<uname>
function get_machine() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
  esac
  echo ${machine}
}
# }}}

# --- Jupyter --- {{{
launch_jupyter() { jupyter notebook --no-browser --port=8$1 & }
kill_jupyter() { pkill -f "jupyter-notebook" 2>/dev/null || pkill -f jupyter }
# }}}

# --- AI assistants: ? copilot, ?? claude (terse), ??? claude (verbose) --- {{{
'?' () {
  if [ $# -eq 0 ]; then
    echo "Usage: ? <question>"; echo "Example: ? how to commit"; return 1
  fi
  command -v copilot >/dev/null 2>&1 || { echo "? : copilot not found in PATH" >&2; return 1; }
  local query="$*"
  copilot -p "$query" 2>/dev/null | sed -E '
      /^(Sure|Here|Certainly|Of course|To|You can|Simply)/d;
      /^$/d; s/^[[:space:]]+//; s/[[:space:]]+$//
    ' | head -5
}
'??' () {
  if [ $# -eq 0 ]; then
    echo "Usage: ?? <question>"; echo "Example: ?? how to commit"; return 1
  fi
  command -v claude >/dev/null 2>&1 || { echo "?? : claude not found in PATH" >&2; return 1; }
  local query="$*"
  claude --print \
    --append-system-prompt "Be extremely concise. If it's a command question, respond with ONLY the command(s), no explanation unless asked. If it's a concept question, respond in 1-2 sentences max." \
    "$query" 2>/dev/null | sed -E '
      /^(Sure|Here|Certainly|Of course|Here is|Here are)/d;
      /^$/d; s/^[[:space:]]+//; s/[[:space:]]+$//; /^```/d
    ' | head -10
}
'???' () {
  if [ $# -eq 0 ]; then
    echo "Usage: ??? <question>"; echo "Example: ??? explain how git rebase works"; return 1
  fi
  command -v claude >/dev/null 2>&1 || { echo "??? : claude not found in PATH" >&2; return 1; }
  claude --print "$*"
}

# Env segment shown in the prompt (used by set-prompt above)
get_env() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "('$(basename "$VIRTUAL_ENV")') "
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    echo "${CONDA_DEFAULT_ENV}"
  else
    echo "syst"
  fi
}
# }}}

# --- env vars + PATH --- {{{
export PYTHONPATH="$HOME/.config/kitty/mplbackend":$PYTHONPATH # matplotlib+kitty
export TEXINPUTS=".:~/beamer-compostela:"
export LG_CONFIG_FILE=$HOME/.config/lazygit/config.yml
export BROWSER="$HOMEBREW_PREFIX/bin/browsh"
export DISPLAY=:0
command -v bat >/dev/null || export BAT_THEME="base16"

export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_TMUX=0 # don't open a separate tmux split

# PATH: SYS_PATHS prepended, USER_PATHS appended, only if the dir exists.
# (N-/) glob quals filter to existing dirs; typeset -U dedups `path` (tied to
# $PATH) on assignment — no forked subshell/awk needed for either step.
SYS_PATHS=(
  "$HOME/.local/share/nvim/mason/bin"
  "$HOME/go/bin"
  "$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin"
  "$HOMEBREW_PREFIX/sbin"
  "$HOMEBREW_PREFIX/bin"
)
USER_PATHS=(
  "$HOME/.cargo/env"
  "$HOME/.dotfiles/scripts"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
)
SYS_PATHS=(${^SYS_PATHS}(N-/))
USER_PATHS=(${^USER_PATHS}(N-/))
typeset -U path
path=($SYS_PATHS $path $USER_PATHS)
# }}}

# --- aliases: git --- {{{
# source: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh#L53
# NOTE: single-quoted on purpose so `$(...)` expands at alias-run time, not now
alias g="git"
alias gss="git status -s"
alias gst="git status"
alias gc='git commit -v'
alias gd='git diff'
alias gco="git checkout"
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gbD='git branch -D'
alias gbl='git blame -b -w'
alias gbr='git branch --remote'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'
alias gm='git merge'
alias gma='git merge --abort'
alias gmom='git merge origin/$(git_main_branch)'
alias gp='git push'
alias gbda='git branch --no-color --merged | command grep -vE "^(\+|\*|\s*($(git_main_branch)|development|develop|devel|dev)\s*$)" | command xargs -n 1 git branch -d'
alias gpristine='git reset --hard && git clean -dffx'
alias gcl='git clone --recurse-submodules'
alias gl='git pull'
alias glum='git pull upstream $(git_main_branch)'
alias grhh='git reset --hard'
alias grbi='git rebase -i'
alias grbm='git rebase $(git_main_branch)'
alias gcb='git checkout -b'
alias gcm='git checkout $(git_main_branch)'
alias gcd="git checkout development"
alias gstp="git stash pop"
alias gsts="git stash show -p"

function grename() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 old_branch new_branch"; return 1
  fi
  git branch -m "$1" "$2"
  git push origin :"$1" && git push --set-upstream origin "$2"
}
function gdnolock() {
  git diff "$@" ":(exclude)package-lock.json" ":(exclude)*.lock"
}
function git_main_branch() {
  local branch
  for branch in main trunk; do
    command git show-ref -q --verify refs/heads/$branch && { echo $branch; return; }
  done
  echo master
}
function cs-list() {
  gh codespace list | awk 'NR > 0 {print $1"@"$5}'
}
function cs-ssh() {
  if [ $# -eq 1 ]; then
    gh codespace ssh -c $1
  else
    CODESPACE=$(gh codespace list | awk 'NR > 0 {print $1"@"$5}' | fzf | awk -F@ '{print $1}')
    gh codespace ssh -c $CODESPACE
  fi
}
select_partition() {
  PARTITION=$(lsblk -o NAME,SIZE,TYPE,MOUNTPOINT -n | awk '$3 == "part" {gsub(/[├└]─/, "", $1); print $1}' | fzf --height 50% --reverse --prompt="Select a partition to mount: " --header="NAME SIZE TYPE")
  if [ -n "$PARTITION" ]; then
    echo "Selected partition: $PARTITION"
    sudo mount /dev/$PARTITION /mnt/
  else
    echo "No partition selected."
  fi
}
dcu() { docker compose up -d }
dcd() { docker compose down }
repo() {
  # Lists up to 2 dirs deep under $HOME/Workspaces; adjust */ depth to taste
  local srchDir=$HOME/Workspaces/*/*/
  [ "$1" = false ] && cd "$(ls -d $srchDir | fzf)" || local qTerm="${@}"
  cd "$(ls -d $srchDir | fzf -q "$qTerm")"
}
ocurrences() { rg -o "$@" | wc -l }
# }}}

# --- aliases: navigation --- {{{
alias ...="cd ../../.."
alias ....="cd ../../../.."
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index
alias digls="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias mvim="nvim -u NONE"
alias nv="nvim"
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias :q='exit'
alias :w='echo "not in vim :)"'
alias cal='cal -m'
# Use neovim-remote if nvim is called from inside a running nvim instance
[[ -n "$NVIM_LISTEN_ADDRESS" ]] && alias nvim=nvr -cc split --remote-wait +'set bufhidden=wipe'
alias restart="exec $SHELL"
alias src='restart'
alias dnd='do-not-disturb toggle'
alias md="mkdir -p"
batdiff() { git diff --name-only --relative --diff-filter=d | xargs bat --diff }
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
alias bathelp='bat --plain --language=help'
help() { "$@" --help 2>&1 | bathelp }
# }}}

# --- aliases: misc --- {{{
if [[ "$OSTYPE" == darwin* ]]; then
  alias clc="clear && printf '\e[3J'"
else
  alias clc="LD_LIBRARY_PATH='' /bin/clear && printf '\e[3J'"
fi
alias ls='eza --icons=auto'
alias ll="eza -lr --icons=auto"
alias zshrc='${=EDITOR} $HOME/.zshrc'
alias grep='grep --color'
alias x="exit"
alias del="rm -rf"
alias dots="cd $DOTFILES"
alias coding="cd $PROJECTS_DIR"
[ $SSH_TTY ] || alias ssh='ssh -R 50000:${KITTY_LISTEN_ON#*:}'
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
which kitty >/dev/null && alias icat="kitty +kitten icat"
# }}}

# --- tmux / zellij session management --- {{{
function t() { # create/attach a tmux session named after $PWD
  SESSION_NAME=$(basename $PWD | tr -d .)
  if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    echo "switching to session $SESSION_NAME"
  else
    echo "creating and switching to session $SESSION_NAME"
    tmux new-session -s $SESSION_NAME -d
  fi
  if [ -z "$TMUX" ]; then tmux attach-session -t $SESSION_NAME; else tmux switch -t $SESSION_NAME; fi
}
function z() { # create/attach a zellij session named after $PWD
  SESSION_NAME=$(basename $PWD | tr -d .)
  if [ -z "$ZELLIJ" ]; then
    zellij attach -c $SESSION_NAME
  else
    zellij pipe -p sessionizer -n sessionizer-new --args cwd="$PWD",name="$SESSION_NAME"
  fi
}
tm() { # fzf tmux picker: no arg = pick/create via fzf, arg = attach/create by name
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1")
    return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) && \
    tmux $change -t "$session" || echo "No sessions found."
}
alias 'tl'="tmux list-sessions -F '#{s/ [a-f0-9][a-f0-9][a-f0-9][a-f0-9]$//:session_name}' 2>/dev/null || echo 'no sessions'"
alias td="tmux detach"
alias tkss="killall tmux"
alias tkill="tmux kill-session -t"
# }}}

# --- fzf-driven git/file helpers --- {{{
fshow() { # git commit browser
  git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
    --bind "ctrl-m:execute:
  (grep -o '[a-f0-9]\{7\}' | head -1 |
  xargs -I % sh -c 'git show --color=always % | bat -R') << 'FZF-EOF'
  {}
  FZF-EOF"
}
cdf() { # cd to the dir of an fzf-picked file
  local file dir
  file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir" || exit
}
fbr() { # checkout a branch (local or remote) via fzf, last 30 by commit date
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" | fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout "$(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
}
vmod() { ${EDITOR:-vim} "$(git status -s | fzf -m)" } # edit modified files via fzf
fe() { # open fzf-picked file(s) with $EDITOR, with a bat preview
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0 --preview\
  'bat --theme="OneHalfDark" --color "always" {}' --preview-window=right:60% ))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}
fstash() { # git stash browser: enter=show, ctrl-d=diff, ctrl-b=branch it
  local out q k sha
  while out=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
    fzf --ansi --no-sort --query="$q" --print-query --expect=ctrl-d,ctrl-b);
  do
    mapfile -t out <<< "$out"
    q="${out[0]}"; k="${out[1]}"; sha="${out[-1]}"; sha="${sha%% *}"
    [[ -z "$sha" ]] && continue
    if [[ "$k" == 'ctrl-d' ]]; then
      git diff "$sha"
    elif [[ "$k" == 'ctrl-b' ]]; then
      git stash branch "stash-$sha" "$sha"; break
    else
      git stash show -p "$sha"
    fi
  done
}
# }}}

# --- fzf-driven docker helpers --- {{{
# source: https://calbertts.medium.com/docker-and-fuzzy-finder-fzf
runc() { # run a new container, picking image/options/command/volume via fzf
  export FZF_DEFAULT_OPTS='--height 90% --reverse --border'
  local image=$(docker images --format '{{.Repository}}:{{.Tag}}' | fzf-tmux --reverse --multi)
  if [[ $image != '' ]]; then
    echo -e "\n  \033[1mDocker image:\033[0m" $image
    read -e -p $'  \e[1mOptions: \e[0m' -i "-it --rm" options
    printf "  \033[1mChoose the command: \033[0m"
    local cmd=$(echo -e "/bin/bash\nsh" | fzf-tmux --reverse --multi)
    [[ $cmd == '' ]] && read -e -p $'  \e[1mCustom command: \e[0m' cmd
    echo -e "  \033[1mCommand: \033[0m" $cmd
    export FZF_DEFAULT_COMMAND='find ./ -type d -maxdepth 1 -exec basename {} \;'
    printf "  \033[1mChoose the volume: \033[0m"
    local volume=$(fzf-tmux --reverse --multi)
    local curDir=${PWD##*/}
    if [[ $volume == '.' ]]; then
      volume="`pwd`:/$curDir -w /$curDir"
    else
      volume="`pwd`/$volume:/$volume -w /$volume"
    fi
    export FZF_DEFAULT_COMMAND="" FZF_DEFAULT_OPTS=""
    history -s runc
    history -s docker run $options -v $volume $image $cmd
    docker run $options -v $volume $image $cmd
  fi
}
runinc() { # exec into a running container, picked via fzf
  export FZF_DEFAULT_OPTS='--height 90% --reverse --border'
  local container=$(docker ps --format '{{.Names}} => {{.Image}}' | fzf-tmux --reverse --multi | awk -F '\\=>' '{print $1}')
  if [[ $container != '' ]]; then
    echo -e "\n  \033[1mDocker container:\033[0m" $container
    read -e -p $'  \e[1mOptions: \e[0m' -i "-it" options
    if [[ $@ == '' ]]; then read -e -p $'  \e[1mCommand: \e[0m' cmd; else cmd="$@"; fi
    history -s runinc "$@"
    history -s docker exec $options $container $cmd
    docker exec $options $container $cmd
  fi
  export FZF_DEFAULT_OPTS=""
}
stopc() { # stop and/or remove a container, picked via fzf
  export FZF_DEFAULT_OPTS='--height 90% --reverse --border'
  local container=$(docker ps --format '{{.Names}} => {{.Image}}' | fzf-tmux --reverse --multi | awk -F '\\=>' '{print $1}')
  if [[ $container != '' ]]; then
    printf "  \033[1mRemove?: \033[0m"
    local cmd=$(echo -e "No\nYes" | fzf-tmux --reverse --multi)
    if [[ $cmd != '' ]]; then
      history -s stopc; history -s docker stop $container
      docker stop $container > /dev/null
      if [[ $cmd != 'No' ]]; then
        history -s stopc; history -s docker rm $container
        docker rm $container > /dev/null
      fi
    fi
  fi
  export FZF_DEFAULT_OPTS=""
}
showipc() { # print a container's IP, picked via fzf
  export FZF_DEFAULT_OPTS='--height 90% --reverse --border'
  local container=$(docker ps -a --format '{{.Names}} => {{.Image}}' | fzf-tmux --reverse --multi | awk -F '\\=>' '{print $1}')
  if [[ $container != '' ]]; then
    local network=$(docker inspect $container -f '{{.NetworkSettings.Networks}}' | awk -F 'map\\[|:' '{print $2}')
    history -s showipc
    history -s docker inspect -f "{{.NetworkSettings.Networks.${network}.IPAddress}}" $container
    echo -e "  \033[1mIP Address:\033[0m" $(docker inspect -f "{{.NetworkSettings.Networks.${network}.IPAddress}}" $container)
  fi
}
alias docker-cleanup='docker system prune -a --volumes'
# }}}

# --- local / private overrides --- {{{
[[ -f "$HOME/.zshrc_local" ]] && source $HOME/.zshrc_local
export DIRENV_LOG_FORMAT=""
[[ -f "$HOME/.config/zsh/private.zsh" ]] && source "$HOME/.config/zsh/private.zsh"
# }}}

# --- debug (ZSH_DEBUG=1) --- {{{
[[ -n "${ZSH_DEBUG:-}" ]] && set -o xtrace
# }}}

# AI helper aliases - disable globbing for ? ?? ??? functions
alias '?'='noglob ?'
alias '??'='noglob ??'
alias '???'='noglob ???'

# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
path=("$BUN_INSTALL/bin" $path) # via `path` array (tied+deduped, see typeset -U above)

# BEGIN_FZF_THEME: carbon-mist
source ~/.config/fzf/themes/carbon-mist.sh
# END_FZF_THEME: carbon-mist

alias curl='noglob curl'

# BEGIN_EZA_THEME
export EZA_COLORS=$(tr '\n' ':' < ~/.config/eza/themes/dracula-pro.yaml)
# END_EZA_THEME

# vim: foldmethod=marker ft=zsh
