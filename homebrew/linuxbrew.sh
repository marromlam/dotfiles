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

# name for the homebrew environment
export HOMEBREW=$HOME/.linuxbrew

# since cURL and git are too old, let's ignore them
export HOMEBREW_NO_ENV_FILTERING=1

# speed up a bit
export HOMEBREW_MAKE_JOBS=8

# first start by cloning linuxbrew
if [[ -d "$HOMEBREW" ]]; then
  eval $($HOMEBREW/bin/brew shellenv)
else
  git clone https://github.com/Homebrew/brew $HOMEBREW/Homebrew
  mkdir $HOMEBREW/bin
  ln -s $HOMEBREW/Homebrew/bin/brew $HOMEBREW/bin
  eval $($HOMEBREW/bin/brew shellenv)
fi



# PARTY STARTS ! --------------------------------------------------------------
#    Since we want llvm 12 to work, we need to demangle library versions since
#    system ones are way older than what is required. We start force-bottling
#    gcc@9. What we really want here is basically some o the libraries in gcc@9
#    folder. The following dependencies are being installed:
#    zlib (P), binutils (B), linux-headers (P), glibc (B), m4 (P), gmp (P), 
#    isl@0.18 (P), mpfr (P), libmpc (P), gcc@5 (P) and isl (P)
brew install gcc@9 --force-bottle
#    We are linking those to lib in homebrew
rm $HOMEBREW/lib/libstdc++.so.6
rm $HOMEBREW/lib/libgcc_s.so.1
ln -s $HOMEBREW/Cellar/gcc@9/9.3.0_2/lib/gcc/9/libstdc++.so.6 $HOMEBREW/lib/
ln -s $HOMEBREW/Cellar/gcc@9/9.3.0_2/lib/gcc/9/libgcc_s.so.1  $HOMEBREW/lib/ 
#    we link syste,m libraries to gcc@5
rm $HOMEBREW/Cellar/gcc@5/5.5.0_6/lib/libstdc++.so.6
rm $HOMEBREW/Cellar/gcc@5/5.5.0_6/lib/libgcc_s.so.1
# ln -s /usr/lib64/libstdc++.so.6 $HOMEBREW/Cellar/gcc@5/5.5.0_6/lib
# ln -s /usr/lib64/libgcc_s.so.1 $HOMEBREW/Cellar/gcc@5/5.5.0_6/lib
# WARNING: When gcc@9 updates, those linked paths will be wrong!



# PYTHON and GCC --------------------------------------------------------------
#    Now python@3.9 should install building from source seamlessly. This command
#    is installing:
#    pkg-config (B), gdbm (B), mpdecimal (P), openssl@1.1 (B), gpatch (P), 
#    ncurses (B), readline (P), sqlite (P), xz (P), bzip2 (P), expat (P), 
#    libffi (P) and unzip (P)
brew install python@3.9
#    Let's go now with the hard one, compile gcc! No, you probably would win
#    nothing if doing so. Let's force bottle (since in this old systems brew
#    seems to have problems identifying the machine -- it's linux bro!).
#    The following dependencies are going to be installed:
#    TODO: fill me please!
brew install gcc --force-bottle


# NEOVIM and family -----------------------------------------------------------
#    Neovim has several requirements which will be auto-triggered by brew, but
#    it also depends on other packages which here are installed manually. This
#    should create the right atmosphere to run nvim married with dotfiles. This
#    command is installing:
#    llvm (P), 
#    cmake (P), lua (P), luarocks (P), gettext (B), unibilium (P),
#    libtermkey (P), libvterm (P), luajit-openresty (P), luv (P), msgpack (P), 
#    gperf (P), bison (B), krb5 (B), libtirpc (P) and libnsl (P)

brew install node yarn ccls neovim



# SHELL -----------------------------------------------------------------------
#    The zsh shell is much fancier if we use a couple of modules. They are 
#    installed just now
#    berkeley-db (P), perl (B) and texinfo (B), docbook (P), docbook-xsl (p),
#    gnu-getopt (P), libgpg-error (B), libgcrypt (P), libxslt (P), xmlto (P) 
#    and dbus (B)
brew install zsh zsh-autosuggestions starship
#    Fast finding is too important, so...
#    pcre2 (P)
brew install fzf ripgrep



# TOOLS -----------------------------------------------------------------------
#    Let's install some stuff that is *not* avaliable in homebrew
#    First, kitty terminal
if [[ -d "$HOMEBREW/Cellar/kitty" ]]; then
  echo "kitty is already installed"
else
  wget https://github.com/kovidgoyal/kitty/releases/download/v0.20.3/kitty-0.20.3-x86_64.txz -O kitty.txz
  mkdir $HOMEBREW/Cellar/kitty
  tar xf kitty.txz -C $HOMEBREW/Cellar/kitty
  ln -s $HOMEBREW/Cellar/kitty/bin/kitty $HOMEBREW/bin
  rm kitty.txz
fi
#   Second, lemonade clipboard utility
if [[ -d "$HOMEBREW/Cellar/lemonade" ]]; then
  echo "Lemonade is already installed"
else
  wget https://github.com/lemonade-command/lemonade/releases/download/v1.1.1/lemonade_linux_amd64.tar.gz -O lemonade.tar.gz
  mkdir $HOMEBREW/Cellar/lemonade
  tar xf lemonade.tar.gz -C $HOMEBREW/Cellar/lemonade
  rm $HOMEBREW/bin/lemonade
  ln -s $HOMEBREW/Cellar/lemonade/lemonade $HOMEBREW/bin
  rm lemonade.tar.gz
fi
#   3. termpdf, utility to show pdf files in terminal using kitty
if [[ -d "$HOMEBREW/Cellar/termpdf.py" ]]; then
  echo "termpdf is already installed"
else
  mkdir $HOMEBREW/Cellar/termpdf.py
  git clone https://github.com/dsanson/termpdf.py.git $HOMEBREW/Cellar/termpdf.py
  cd $HOMEBREW/Cellar/termpdf.py
  $HOMEBREW/bin/python3 -m pip install -r requirements.txt
  $HOMEBREW/bin/python3 -m pip install -e ../termpdf.py
  rm $HOMEBREW/bin/lemonade
  ln -s $HOMEBREW/Cellar/termpdf.py/termpdf.py $HOMEBREW/bin
fi


