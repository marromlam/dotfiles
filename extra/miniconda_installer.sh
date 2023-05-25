rm -rf ~/conda3

# for each OS, download the latest version of the bash installer
#
wget -O ~/miniconda-latest.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
# https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
# https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
bash ~/miniconda-latest.sh -b -p $HOME/conda3
rm -rf ~/miniconda-latest.sh


# vim: ft=bash
