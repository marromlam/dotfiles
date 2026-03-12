# ==============================================================================
# Utility Functions
# ==============================================================================

# Join paths together with colons
join() {
  a=("${@}")
  local IFS=":"
  echo "${a[*]}"
}

# Remove duplicate paths
dedup() {
  echo -n $1 | awk -v RS=: -v ORS=: '!arr[$0]++'
}

# Version comparison function
function version() {
  echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'
}

# Check if command exists (zsh-optimized)
# https://www.topbug.net/blog/2016/10/11/speed-test-check-the-existence-of-a-command-in-bash-and-zsh/
exists() {
  (( $+commands[$1] ))
}

# Get machine type
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

# ==============================================================================
# Jupyter Functions
# ==============================================================================

# Open a port where jupyter can run kernels
launch_jupyter() {
  jupyter notebook --no-browser --port=8$1 &
}

# Kill jupyter sessions
alias kill_jupyter="kill $(netstat -tulpn 2>&1 | pgrep jupyter)"

# ==============================================================================
# AI Assistant Functions
# ==============================================================================

# GitHub Copilot quick helper - concise command suggestions
# Usage: ? how to commit
'?' () {
  if [ $# -eq 0 ]; then
    echo "Usage: ? <question>"
    echo "Example: ? how to commit"
    return 1
  fi
  
  local query="$*"
  
  # Use copilot in print mode for non-interactive output
  /opt/homebrew/bin/copilot -p "$query" 2>/dev/null | \
    # Remove common fluff
    sed -E '
      /^(Sure|Here|Certainly|Of course|To|You can|Simply)/d;
      /^$/d;
      s/^[[:space:]]+//;
      s/[[:space:]]+$//
    ' | \
    head -5
}

# Claude quick helper - concise answers
# Usage: ?? how to commit
'??' () {
  if [ $# -eq 0 ]; then
    echo "Usage: ?? <question>"
    echo "Example: ?? how to commit"
    return 1
  fi
  
  local query="$*"
  
  # Use claude in print mode with brevity system prompt
  /opt/homebrew/bin/claude \
    --print \
    --append-system-prompt "Be extremely concise. If it's a command question, respond with ONLY the command(s), no explanation unless asked. If it's a concept question, respond in 1-2 sentences max." \
    "$query" 2>/dev/null | \
    sed -E '
      /^(Sure|Here|Certainly|Of course|Here is|Here are)/d;
      /^$/d;
      s/^[[:space:]]+//;
      s/[[:space:]]+$//;
      /^```/d
    ' | \
    head -10
}

# Verbose version - get full explanation
# Usage: ??? explain git rebase
'???' () {
  if [ $# -eq 0 ]; then
    echo "Usage: ??? <question>"
    echo "Example: ??? explain how git rebase works"
    return 1
  fi
  
  local query="$*"
  /opt/homebrew/bin/claude --print "$query"
}

# vim: fdm=marker ft=zsh

# Get current environment name
get_env() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "('$(basename "$VIRTUAL_ENV")') "
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    echo "${CONDA_DEFAULT_ENV}"
  else
    echo "syst"
  fi
}
