# joins paths together wiht colons
join() { a=("${@}"); local IFS=":"; echo "${a[*]}"; }
# removes duplicate paths
dedup() { echo -n $1 | awk -v RS=: -v ORS=: '!arr[$0]++'; }


function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }


# ZSH only and most performant way to check existence of an executable
# https://www.topbug.net/blog/2016/10/11/speed-test-check-the-existence-of-a-command-in-bash-and-zsh/
exists() { (( $+commands[$1] )); }


function blindworm() {
  source $HOME/conda3/bin/activate
  conda activate $1
}


# ssh functions {{{
# Try to create a custom ssh function with socket for the clipboard and some
# tmux things. I thik they wont work but...

function sshx (){
  ssh -t $1 "export IS_TMUX=${IS_TMUX}; zsh"
}

#_dt_term_socket_ssh() {
#    ssh -oControlPath=$1 -O exit DUMMY_HOST
#}
#function sshx {
#  #local t=$(mktemp -u --tmpdir=$HOME ssh.sock.XXXXXXXXXX)
#  local t=$(mktemp -u -d "/Users/marcos/ssh.sock.XXXXXXXXXX")
#  local f="~/clip"
#  ssh -f -oControlMaster=yes -oControlPath=$t $@ tail\ -f\ /dev/null || return 1
#  ssh -S$t DUMMY_HOST "bash -c 'if ! [ -p $f ]; then mkfifo $f; fi'" \
#      || { _dt_term_socket_ssh $t; return 1; }
#  (
#  set -e
#  set -o pipefail
#  while [ 1 ]; do
#      ssh -S$t DUMMY_HOST "cat $f" | xclip -selection clipboard
#  done &
#  )
#  ssh -S$t DUMMY_HOST \
#      || { _dt_term_socket_ssh $t; return 1; }
#  ssh -S$t DUMMY_HOST "rm $f"
#  _dt_term_socket_ssh $t
#}

# }}}


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

# Atom functions {{{
# these functions are from old times when I was not a vimmer :')
# I do not have Atom anymore, but just in case I will keep them

# open a port where jupyter can run kernels
launch_jupyter(){
  jupyter notebook --no-browser --port=8$1 &
}

# kill jupyter sessions
alias kill_jupyter="kill $(netstat -tulpn 2>&1 | pgrep jupyter)"

# }}}

# vim: fdm=marker ft=zsh
