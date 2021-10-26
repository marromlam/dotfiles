echo " "
echo "           _     <-. ('-')_            ('-')     <-.('-')    ('-')  ('-')  _     .->   "
echo "   <-.    (_)       \( OO) )     .->   (OO )_.->  __( OO) <-.(OO )  ( OO).-/ ('('-')/')"
echo " ,--. )   ,-('-'),--./ ,--/ ,--.(,--.  (_| \_)--.'-'---.\ ,------,)(,------.,-'( OO).',"
echo " |  ('-') | ( OO)|   \ |  | |  | |('-')\  '.'  / | .-. (/ |   /'. ' |  .---'|  |\  |  |"
echo " |  |OO ) |  |  )|  . '|  |)|  | |(OO ) \    .') | '-' '.)|  |_.' |(|  '--. |  | '.|  |"
echo "(|  '__ |(|  |_/ |  |\    | |  | | |  \ .'    \  | /''.  ||  .   .' |  .--' |  |.'.|  |"
echo " |     |' |  |'->|  | \   | \  '-'(_ .'/  .'.  \ | '--'  /|  |\  \  |  '---.|   ,'.   |"
echo " '-----'  '--'   '--'  '--'  '-----'  '--'   '--''------' '--' '--' '------''--'   '--'"
echo " "
echo " This file is intended to properly install homebrew in the IGFAE cluster"
echo " which has software clearly outdated. I suggest carefully look at each"
echo " step of the installation and do not close your fucking eyes during the"
echo " nightmare process."
echo " "
echo " Marcosito wishes you good luck!"
echo " "
echo " "
echo " "


# Install homebrew repository {{{

# Name for the homebrew environment
export HOMEBREW=$HOME/.linuxbrew
# export HOMEBREW="/afs/cern.ch/work/m/mromerol/.linuxbrew"

# Since cURL and git are too old, let's ignore them
export HOMEBREW_NO_ENV_FILTERING=1

# We are going to run this script in mastercr1. This machine is not intended to
# run long compilations and large jobs. Thus we will only use one of its cores
# and the other people will not be affected by our installation.
export HOMEBREW_MAKE_JOBS=1

# First start by cloning linuxbrew, which should not give any error
if [[ -d "$HOMEBREW" ]]; then
  eval $($HOMEBREW/bin/brew shellenv)
else
  git clone https://github.com/Homebrew/brew $HOMEBREW/Homebrew
  mkdir $HOMEBREW/bin
  ln -s $HOMEBREW/Homebrew/bin/brew $HOMEBREW/bin
  eval $($HOMEBREW/bin/brew shellenv)
fi

# }}}


# Homebrew package installation {{{

brew test
cd $HOMEBREW/Homebrew/Library/Taps/homebrew/homebrew-core 
# git checkout e42a71c15314272000396a284f63b97b30f714b4 Formula
git checkout e153667b924f0bf4f21e7ee4c33efe10393aa2ee Formula
echo "=== CHECKOUT OLD HOMEBREW ==="
git diff "Formula/gcc@5"
# To install gcc@5 we first need to fix the formula for linux.
sed -i "19s/.*/    sha256 cellar: :any, x86_64_linux: \"cd94b6bc2189df7861c2c32c480f777984865dbab4107f493188feda5a05b80d\"/" $HOMEBREW/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/gcc@5.rb


brew install gcc@5
brew install stow
brew install git lazygit ydiff
brew install gcc@11 --force-bottle

# Install zsh plugins
brew install zsh-syntax-highlighting zsh-autosuggestions

# Install search utilities
brew install fzf ripgrep

# Install nvim and some useful packages
brew install yarn ccls neovim

# }}}


# Old configuration {{{

#    Since we want llvm 12 to work, we need to demangle library versions since
#    system ones are way older than what is required. We start force-bottling
#    gcc@9. What we really want here is basically some o the libraries in gcc@9
#    folder. The following dependencies are being installed:
#    zlib (P), binutils (B), linux-headers (P), glibc (B), m4 (P), gmp (P), 
#    isl@0.18 (P), mpfr (P), libmpc (P), gcc@5 (P) and isl (P)
# brew install gcc@9 --force-bottle

#    We are linking those to lib in homebrew
#rm $HOMEBREW/lib/libstdc++.so.6
#rm $HOMEBREW/lib/libgcc_s.so.1
#ln -s $HOMEBREW/Cellar/gcc@9/9.3.0_2/lib/gcc/9/libstdc++.so.6 $HOMEBREW/lib/
#ln -s $HOMEBREW/Cellar/gcc@9/9.3.0_2/lib/gcc/9/libgcc_s.so.1  $HOMEBREW/lib/ 
#    we link syste,m libraries to gcc@5
# rm $HOMEBREW/Cellar/gcc@5/5.5.0_6/lib/libstdc++.so.6
# rm $HOMEBREW/Cellar/gcc@5/5.5.0_6/lib/libgcc_s.so.1
# ln -s /usr/lib64/libstdc++.so.6 $HOMEBREW/Cellar/gcc@5/5.5.0_6/lib
# ln -s /usr/lib64/libgcc_s.so.1 $HOMEBREW/Cellar/gcc@5/5.5.0_6/lib
# WARNING: When gcc@9 updates, those linked paths will be wrong!

# }}}


# Install software that is not avaliable in homebrew {{{

# Kitty terminal
if [[ -d "$HOMEBREW/Cellar/kitty" ]]; then
  echo "kitty is already installed"
else
  wget https://github.com/kovidgoyal/kitty/releases/download/v0.20.3/kitty-0.20.3-x86_64.txz -O kitty.txz
  mkdir $HOMEBREW/Cellar/kitty
  tar xf kitty.txz -C $HOMEBREW/Cellar/kitty
  ln -sf $HOMEBREW/Cellar/kitty/bin/kitty $HOMEBREW/bin
  rm kitty.txz
fi

# Lemonade clipboard utility
if [[ -d "$HOMEBREW/Cellar/lemonade" ]]; then
  echo "Lemonade is already installed"
else
  wget https://github.com/lemonade-command/lemonade/releases/download/v1.1.1/lemonade_linux_amd64.tar.gz -O lemonade.tar.gz
  mkdir $HOMEBREW/Cellar/lemonade
  tar xf lemonade.tar.gz -C $HOMEBREW/Cellar/lemonade
  ln -sf $HOMEBREW/Cellar/lemonade/lemonade $HOMEBREW/bin
  rm lemonade.tar.gz
fi

# Termpdf, utility to show pdf files in terminal using kitty
if [[ -d "$HOMEBREW/Cellar/termpdf.py" ]]; then
  echo "termpdf is already installed"
else
  mkdir $HOMEBREW/Cellar/termpdf.py
  git clone https://github.com/dsanson/termpdf.py.git $HOMEBREW/Cellar/termpdf.py
  cd $HOMEBREW/Cellar/termpdf.py
  $HOMEBREW/bin/python3 -m pip install -r requirements.txt
  $HOMEBREW/bin/python3 -m pip install -e ../termpdf.py
  ln -sf $HOMEBREW/Cellar/termpdf.py/termpdf.py $HOMEBREW/bin
fi

# }}}


# vim:foldmethod=marker
