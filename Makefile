# This file install all shit
#${TMUX_SHARE}/plugins/tpm/scripts/install_plugins.sh


FC=${HOME}/.dotfiles
TMUX_SHARE=${HOME}/.local/share/tmux

all: brew macos kitty nvim vim tmux fzf-marks private zsh-plugins

macos:
	${FC}/extra/macos/macos_settings.sh
	# now we change the keymaps
	bash extra/keyboard.sh

install:
	stow --ignore ".DS_Store" --target="${HOME}" --dir="${FC}" files
	rm -rf ~/Downloads; ln -sf "${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Downloads" ~/Downloads

projects:
	mkdir -p "${HOME}/Projects/icloud"
	stow --ignore ".DS_Store" --target="${HOME}/Projects/icloud" --dir="${HOME}/Library/Mobile Documents/com~apple~CloudDocs/" Projects

brew:
	brew bundle --file="${FC}/homebrew/Brewfile"
	python3 -m pip install pynvim neovim-remote mcphub[all] --upgrade
	npm install -g mcp-hub@latest

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
	    rm -rf ${HOME}/.local/share/nvim; \
	fi
	#bash ${FC}/extra/ccls_patch.sh; cd ${FC};
	python3 -m pip install --upgrade pynvim \
	python3 -m pip install --upgrade neovim-remote \
	#nvim +PlugInstall +qall
	nvim +PackerSync \


kitty:
	rm /Applications/kitty.app/Contents/Resources/kitty.icns; \
	cp ${FC}/assets/Gin.icns /Applications/kitty.app/Contents/Resources/kitty.icns; \
	if [ ! -f "${HOME}/Library/Keychains/kitty.keychain-db" ]; then \
	    security create-keychain -P kitty.keychain; \
	fi; \
	mkdir -p "${HOME}/.config/kitty/kittens"; \
	wget -O ~/.config/kitty/kittens/password.py https://github.com/marromlam/kitty-password/raw/main/password.py

vim:
	if [ ! -d "${FC}/files/.config/vim" ]; then \
	    git clone -b main git@github.com:marromlam/vim-gasm.git "${FC}/files/.config/vim"; \
	else \
	    rm -rf ${FC}/files/.config/vim/autoload; \
	    rm -rf ${FC}/files/.config/vim/plugin; \
	    rm -rf ${FC}/files/.config/coc; \
	    rm -rf ${HOME}/.local/share/vim; \
	fi
	bash ${FC}/extra/ccls_patch.sh; cd ${FC};
	python3 -m pip install --upgrade pynvim
	vim +PlugInstall +qall
	ln -sf ${FC}/files/.config/vim ~/.vim
	ln -sf ${FC}/files/.config/vim/init.vim ~/.vimrc

fzf-marks:
	if [ ! -d ~/fzf-marks ]; then \
	    git clone https://github.com/urbainvaes/fzf-marks.git ~/fzf-marks; \
	fi

private:
	# this uses a private repository where I store some other snippets
	if [ ! -d "${FC}/private" ]; then \
	    git clone git@github.com:marromlam/.dotfiles.git "${FC}/private"; \
	else \
	    cd  "${FC}/private"; \
	    git pull; \
	    cd "${FC}"; \
	fi
	stow --ignore ".DS_Store" --target="${HOME}" --dir="${FC}/private" files
	chmod 600 ${HOME}/.ssh/*

zsh-plugins:
	git clone https://github.com/djui/alias-tips.git ${HOMEBREW_PREFIX}/Cellar/alias-tips; \
	mkdir -p ${HOMEBREW_PREFIX}/share/zsh-alias-tips; \
	ln -sf ${HOMEBREW_PREFIX}/Cellar/alias-tips/alias-tips.plugin.zsh ${HOMEBREW_PREFIX}/share/zsh-alias-tips
	

.PHONY: all install brew macos kitty nvim vim tmux fzf-marks private zsh-plugins
