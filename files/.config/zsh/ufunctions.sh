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

# vim: fdm=marker ft=zsh
