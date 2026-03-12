# macOS now shows a deprecation warning about bash, remove it
export BASH_SILENCE_DEPRECATION_WARNING=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_AUTO_UPDATING=0
export HOMEBREW_UPDATE_PREINSTALL=0

ulimit -S -n 2048

# Add OpenJDK to PATH (required for Neovim SonarLint plugin)
if [[ -d "/opt/homebrew/opt/openjdk/bin" ]]; then
  export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
fi
