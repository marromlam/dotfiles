# first remove links
rm $HOME/.linuxbrew/lib/libstdc++.so.6
rm $HOME/.linuxbrew/lib/libgcc_s.so.1

# link them to system
ln -s /usr/lib64/libstdc++.so.6 $HOME/.linuxbrew/lib/
ln -s /usr/lib64/libgcc_s.so.1  $HOME/.linuxbrew/lib/ 
