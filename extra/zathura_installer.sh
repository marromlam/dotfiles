brew tap zegervdv/zathura
brew install girara --HEAD
brew uninstall zathura-pdf-poppler
brew uninstall zathura
brew install zathura --HEAD --with-synctex
brew install zathura-pdf-poppler
mkdir -p $(brew --prefix zathura)/lib/zathura
ln -s $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib
