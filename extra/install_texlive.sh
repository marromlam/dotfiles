#!/usr/bin/env bash
# This is the fancy installer for texlive under linuxbrew, since the formule
# is broken. Since 2021 texlive has more dependencies than the 2020, and given
# we in almost all situations wont need the 2021 version, I will just install
# the latest 2020 version
#
# WARNING: 2021 actually has some big differences wrt. 2021 for some includes
#          in tables/figures. Some 2020 code will fail on 2021. There is an
#          easy fix for this.

# create a install fonder on Cellar {{{

mkdir -p $HOMEBREW_PREFIX/Cellar/texlive/
cd $HOMEBREW_PREFIX/Cellar/texlive/
wget https://www.texlive.info/tlnet-archive/2020/07/15/tlnet/install-tl-unx.tar.gz
tar xf install-tl-unx.tar.gz

rm -rf 20200715
mv {install-tl-,}20200715
rm -f install-tl-unx.tar.gz*

# }}}

# write a profile file {{{

cat > texlive.profile <<EOF

selected_scheme scheme-small
TEXDIR $HOMEBREW_PREFIX/Cellar/texlive/20200715/texlive
TEXMFCONFIG \$TEXMFSYSCONFIG
TEXMFHOME \$TEXMFLOCAL
TEXMFLOCAL $HOMEBREW_PREFIX/Cellar/texlive/20200715/texlive/texmf-local
TEXMFSYSCONFIG $HOMEBREW_PREFIX/Cellar/texlive/20200715/texlive/texmf-sysconfig
TEXMFSYSVAR $HOMEBREW_PREFIX/Cellar/texlive/20200715/texlive/texmf-sysvar
TEXMFVAR \$TEXMFSYSVAR
binary_x86_64-linux 1
instopt_adjustpath 1
instopt_adjustrepo 1
instopt_letter 0
instopt_portable 0
instopt_write18_restricted 1
tlpdbopt_autobackup 1
tlpdbopt_backupdir tlpkg/backups
tlpdbopt_create_formats 1
tlpdbopt_desktop_integration 1
tlpdbopt_file_assocs 1
tlpdbopt_generate_updmap 0
tlpdbopt_install_docfiles 1
tlpdbopt_install_srcfiles 1
tlpdbopt_post_code 1
tlpdbopt_sys_bin $HOMEBREW_PREFIX/Cellar/texlive/20200715/bin
tlpdbopt_sys_info $HOMEBREW_PREFIX/Cellar/texlive/20200715/share/info
tlpdbopt_sys_man $HOMEBREW_PREFIX/Cellar/texlive/20200715/share/man
tlpdbopt_w32_multi_user 1

EOF

# }}}

# run the installation {{{

cd 20200715

# install! (usually it will take some time ~ 3h)
./install-tl -profile ../texlive.profile -repository ftp://tug.org/historic/systems/texlive/2020/tlnet-final

# }}}

# create homebrew links {{{
#
#
# }}}

# vim: fdm=marker
