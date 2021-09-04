# This file install all shit
#${TMUX_SHARE}/plugins/tpm/scripts/install_plugins.sh


FC=${HOME}/fictional-couscous
TMUX_SHARE=${HOME}/.config/tmux

all: brew macos kitty nvim vim tmux fzf-marks private

macos:
	${FC}/extra/macos_settings.sh

install:
	stow --ignore ".DS_Store" --target="${HOME}" --dir="${FC}" files

brew:
	brew bundle --file="${FC}/homebrew/Brewfile"

tmux:
	if [ ! -d "${TMUX_SHARE}/plugins/tpm" ]; then \
	  git clone https://github.com/tmux-plugins/tpm "${TMUX_SHARE}/plugins/tpm"; \
	fi
	tmux start-server
	tmux new-session -d
	${TMUX_SHARE}/plugins/tpm/scripts/install_plugins.sh
	tmux kill-server

nvim:
	if [ ! -d "${FC}/files/.config/nvim" ]; then \
	  git clone -b luavim git@github.com:marromlam/vim-gasm.git "${FC}/files/.config/nvim"; \
	else \
	  rm -rf ${FC}/files/.config/nvim/autoload; \
	  rm -rf ${FC}/files/.config/nvim/plugin; \
	  rm -rf ${FC}/files/.config/coc; \
	  rm -rf ${HOME}/.local/share/nvim; \
	fi
	#bash ${FC}/extra/ccls_patch.sh; cd ${FC};
	python3 -m pip install --upgrade pynvim
	#nvim +PlugInstall +qall
	nvim +PackerSync

kitty:
	cp -r ${FC}/extra/pylib2kitty/* /Applications/kitty.app/Contents/Resources/Python/lib/python3.9/; \
	cp -r ${FC}/extra/pylib2kitty/* /Applications/kitty.app/Contents/Resources/python3.9/; \
	rm /Applications/kitty.app/Contents/Resources/kitty.icns; \
  cp ${FC}/assets/Gin.icns /Applications/kitty.app/Contents/Resources/kitty.icns;

vim:
	ln -sf ${FC}/files/.config/nvim ~/.vim
	ln -sf ${FC}/files/.config/nvim/init.vim ~/.vimrc

fzf-marks:
	if [ ! -d ~/fzf-marks ]; then \
	  git clone https://github.com/urbainvaes/fzf-marks.git ~/fzf-marks; \
	fi

private:
	# this uses a private repository where I store somoe other snippets
	if [ ! -d "${FC}/files/private" ]; then \
	  git clone git@github.com:marromlam/.dotfiles.git "${FC}/private"; \
	else \
    cd  "${FC}/files/private"; \
	  git pull; \
		cd "${FC}"; \
	fi
	stow --ignore ".DS_Store" --target="${HOME}" --dir="${FC}" private


.PHONY: all install brew macos kitty nvim vim tmux fzf-marks private
