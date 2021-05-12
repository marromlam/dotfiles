# # first remove links
# rm $HOME/.linuxbrew/lib/libstdc++.so.6
# rm $HOME/.linuxbrew/lib/libgcc_s.so.1
#
# # link them to system
# ln -s /usr/lib64/libstdc++.so.6 $HOME/.linuxbrew/lib/
# ln -s /usr/lib64/libgcc_s.so.1  $HOME/.linuxbrew/lib/ 

rm $HOME/.linuxbrew/lib/libstdc++.so.6
rm $HOME/.linuxbrew/lib/libgcc_s.so.1
ln -s /home3/marcos.romero/.linuxbrew/Cellar/gcc@9/9.3.0_2/lib/gcc/9/libstdc++.so.6 $HOME/.linuxbrew/lib/
ln -s /home3/marcos.romero/.linuxbrew/Cellar/gcc@9/9.3.0_2/lib/gcc/9/libgcc_s.so.1  $HOME/.linuxbrew/lib/ 
