# joins paths together wiht colons
join() { a=("${@}"); local IFS=":"; echo "${a[*]}"; }
# removes duplicate paths
dedup() { echo -n $1 | awk -v RS=: -v ORS=: '!arr[$0]++'; }


function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }


# ZSH only and most performant way to check existence of an executable
# https://www.topbug.net/blog/2016/10/11/speed-test-check-the-existence-of-a-command-in-bash-and-zsh/
exists() { (( $+commands[$1] )); }


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

# open a port where jupyter can run kernels
launch_jupyter(){
  jupyter notebook --no-browser --port=8$1 &
}

# kill jupyter sessions
alias kill_jupyter="kill $(netstat -tulpn 2>&1 | pgrep jupyter)"

# }}}

# vim: fdm=marker ft=bash
