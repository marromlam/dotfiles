# This file install all shit
#${TMUX_SHARE}/plugins/tpm/scripts/install_plugins.sh



FC=${HOME}/fictional-couscous
TMUX_SHARE=${HOME}/.config/tmux

all: brew macos kitty neovim vim tmux fzf-marks

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

neovim:
	python3 -m pip install --upgrade pynvim
	nvim +PlugInstall +qall

kitty:
	cp -r ${FC}/extra/pylib2kitty/* /Applications/kitty.app/Contents/Resources/Python/lib/python3.8/

vim:
	ln -sf ${FC}/files/.config/nvim ~/.vim
	ln -sf ${FC}/files/.config/nvim/init.vim ~/.vimrc

fzf-marks:
	if [ ! -d ~/fzf-marks ]; then \
	  git clone https://github.com/urbainvaes/fzf-marks.git ~/fzf-marks; \
	fi

.PHONY: all install brew macos kitty neovim vim tmux fzf-marks
