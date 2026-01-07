#!/bin/zsh

# ==============================================================================
# Utility Functions
# ==============================================================================

# Tree view with exclusions
# Courtesy of wes bos: https://gist.github.com/wesbos/1432b08749e3cd2aea22fcea2628e2ed
function _t() {
  # Defaults to 3 levels deep, do more with `t 5` or `t 1`
  # Pass additional args after
  local levels=${1:-3}; shift
  tree -I '.git|node_modules|bower_components|.DS_Store' --dirsfirst -L $levels -aC $@
}

# Use bat instead of cat if available
# https://github.com/sharkdp/bat#installation
cat() {
  if hash bat 2>/dev/null; then
    bat "$@"
  else
    command cat "$@"
  fi
}

# ==============================================================================
# Network & System Functions
# ==============================================================================

# Check what's listening on a port
# Courtesy of: https://github.com/jdsimcoe/dotfiles/blob/master/.zshrc
function port() {
  lsof -n -i ":$@" | grep LISTEN
}

# Display color palette
function colours() {
  for i in {0..255}; do
    printf "\x1b[38;5;${i}m colour${i}"
    if (( $i % 5 == 0 )); then
      printf "\n"
    else
      printf "\t"
    fi
  done
}

# ==============================================================================
# Git Helper Functions
# ==============================================================================

# Git diff excluding specific files
function gdmin() {
  local branchname=${1:-develop}
  local ignore=${2:-package\-lock.json}
  git diff $branchname -- ":(exclude)"$ignore
}

# Ignore changes to tracked files (useful for local configs)
function ignore() {
  git update-index --skip-worktree $1
}

# Stop ignoring changes to tracked files
function unignore() {
  git update-index --no-skip-worktree $1
}

# ==============================================================================
# Editor Functions
# ==============================================================================

# Quick vim/nvim
function v() {
  nvim "$@"
}

# ==============================================================================
# File System Functions
# ==============================================================================

# chmod a directory
function ch() {
  sudo chmod -R 777 "$@"
}

# chown a directory
function cho() {
  sudo chown -R www:www "$@"
}

# ==============================================================================
# Git Workflow Functions
# ==============================================================================

# Git clone
function clone() {
  git clone "$@"
}

# Quick git commit
function quickie() {
  git add .;git add -u :/;git commit -m "$@";
}

# Quick git commit and push
function quickpush() {
  git add .
  git commit -m "$@"
  echo "🍏 commit message: [$@]"
  git push
  echo 🚀  quick push success... or not.
}

# Git push from current branch
function push() {
  git push origin "$@"
}

# Git push setting upstream
function gpuo() {
  git push --set-upstream origin "$@"
}

# Git commit and push
function gcap() {
  git add .;git add -u :/;git commit -m "$@";git push
}

# Git pull with rebase
function gpr() {
  git pull --rebase "$@"
}

# Git commit/push and Heroku deploy
function gcph() {
  git add .;git add -u :/;git commit -m "$@";git push;git push heroku master
}

# Heroku commit/push/deploy
function gph() {
  git add .;git add -u :/;git commit -m "$@";git push heroku master
}

# ==============================================================================
# Package Management Functions
# ==============================================================================

# Install NPM module and save to devDependencies
function npmi() {
  npm install --save-dev "$@"
}

# ==============================================================================
# Zsh Widgets
# ==============================================================================

# Fancy Ctrl-Z: toggle foreground/background
fancy-ctrl-z() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# Toggle sudo on command line (Esc+Esc)
sudo-command-line() {
  [[ -z $BUFFER ]] && zle up-history
  if [[ $BUFFER == sudo\ * ]]; then
    LBUFFER="${LBUFFER#sudo }"
  elif [[ $BUFFER == $EDITOR\ * ]]; then
    LBUFFER="${LBUFFER#$EDITOR }"
    LBUFFER="sudoedit $LBUFFER"
  elif [[ $BUFFER == sudoedit\ * ]]; then
    LBUFFER="${LBUFFER#sudoedit }"
    LBUFFER="$EDITOR $LBUFFER"
  else
    LBUFFER="sudo $LBUFFER"
  fi
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line
