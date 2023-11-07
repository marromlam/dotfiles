rm /Applications/kitty.app/Contents/Resources/kitty.icns; \
cp $HOME/.dotfiles/assets/Gin.icns /Applications/kitty.app/Contents/Resources/kitty.icns; \

if [ ! -f "${HOME}/Library/Keychains/kitty.keychain-db" ]; then
  security create-keychain -P kitty.keychain
fi

mkdir -p "${HOME}/.config/kitty/kittens"
wget -O ~/.config/kitty/kittens/password.py https://github.com/marromlam/kitty-password/raw/main/password.py
