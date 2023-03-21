set -e
FC=${HOME}/.private
HTTPS_OR_SSH=${HOME}/.ssh_keys_present

if test "$1" = "-f"; then
  rm -rf $HTTPS_OR_SSH
  rm -rf $FC
fi

echo "================================================================================"
echo "Installing ssh keys"
echo "--------------------------------------------------------------------------------";

if test -f "$HTTPS_OR_SSH"; then
  echo "$HTTPS_OR_SSH exists. Ready to proceed."
  exit 0
else
  echo "$HTTPS_OR_SSH does not exist. Installing dotfile."
fi

if [ ! -d "${FC}" ]; then
  echo "Make sure you have an access token for your repo."
  echo "https://github.com/settings/tokens"
  git clone https://github.com/marromlam/private-dotfiles.git "${FC}"
else
  cd "${FC}"
  git pull
fi

cd "${FC}"
stow --ignore ".DS_Store" --target="${HOME}" --dir="${FC}" files
chmod 600 ${HOME}/.ssh/*

touch $HTTPS_OR_SSH

echo "--------------------------------------------------------------------------------";
echo "Done "
echo "================================================================================"

exit 0

vim: ft=bash
