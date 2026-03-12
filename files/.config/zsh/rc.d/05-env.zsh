# Conda and virtualenv settings

# disables prompt mangling in virtual_env/bin/activate

# get current environment name

# Lazy-load conda on first use
load_conda() {
  source $HOME/.config/zsh/conda.sh
  unset -f conda
  unset -f load_conda
}
conda() {
  load_conda
  conda "$@"
}
