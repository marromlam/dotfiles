pushd $HOMEBREW_PREFIX/Cellar

wget https://www.lua.org/ftp/lua-5.1.5.tar.gz
rm -rf lua-5.1.5
tar xzf lua-5.1.5.tar.gz
rm -f lua-5.1.5.tar.gz

cd lua-5.1.5
make macosx
rm -rf $HOMEBREW_PREFIX/Cellar/lua/5.1.5
mkdir $HOMEBREW_PREFIX/Cellar/lua/5.1.5
make INSTALL_TOP=$HOMEBREW_PREFIX/Cellar/lua/5.1.5 install

ln -sf $HOMEBREW_PREFIX/Cellar/lua/5.1.5/bin/lua $HOMEBREW_PREFIX/bin/lua5.1
rm -rf lua-5.1.5

popd
