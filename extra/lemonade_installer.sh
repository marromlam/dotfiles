# Get machine
machine=`$HOME/fictional-couscous/scripts/machine.sh`

# These are urls to lemonade
mac_url="https://github.com/lemonade-command/lemonade/releases/download/v1.1.1/lemonade_darwin_amd64.tar.gz"
linux_url="https://github.com/lemonade-command/lemonade/releases/download/v1.1.1/lemonade_linux_amd64.tar.gz"

# Download and untar lemonade
if [ machine=='Mac' ]; then
  wget -q $mac_url
  tar xf lemonade_darwin_amd64.tar.gz
  rm -rf lemonade_darwin_amd64.tar.gz
else
  wget -q $linux_url 
  tar -xf lemonade_linux_amd64.tar.gz
  rm -rf lemonade_linux_amd64.tar.gz
fi

# Install lemonade into homebrew
mkdir -p $HOMEBREW/Cellar/lemonade
mv lemonade $HOMEBREW/Cellar/lemonade 
rm $HOMEBREW/bin/lemonade
ln -s $HOMEBREW/Cellar/lemonade/lemonade $HOMEBREW/bin/lemonade
