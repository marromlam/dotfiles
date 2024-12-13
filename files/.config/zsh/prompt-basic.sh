#!/usr/bin/env bash


export CONDA_AUTO_ACTIVATE_BASE=false
export CONDA_ALWAYS_YES=true

# disables prompt mangling in virtual_env/bin/activate
export VIRTUAL_ENV_DISABLE_PROMPT=1

# get virtualenv
function current_environ {
 if [ $VIRTUAL_ENV ]; then
   echo "via ('`basename $VIRTUAL_ENV`') "
 fi
 if [ $CONDA_DEFAULT_ENV ]; then
   echo "via ${CONDA_DEFAULT_ENV}"
 fi
}




# change prompt
# setopt PROMPT_SUBST
export NEWLINE=$'\n'
# export PS1='${NEWLINE}%B[%2~ $(current_environ)@$(whoismyhost)] %(!.#.>) '
# export PS1="\u \w \$(git branch 2>/dev/null | sed -n "s/* \(.*\)/\1 /p")$ "
export PS1='$CURRENT_HOST `echo "${PWD%/*}" | sed -e "s;\(/.\)[^/]*;\1;g"`/${PWD##*/} $(git branch 2>/dev/null | sed -n "s/* \(.*\)/(\1) /p")» '
# export RPROMPT="%b%*


# vim:foldmethod=marker
