#!/usr/bin/env bash

set -euo pipefail

FORCE_INSTALL=0
MACHINE_OVERRIDE=""

if [[ "${1:-}" == "--force" ]]; then
	FORCE_INSTALL=1
	shift
fi

if [[ -n "${1:-}" ]]; then
	MACHINE_OVERRIDE="$1"
fi

machine_from_file() {
	if [[ -f "$HOME/.machine" ]]; then
		cat "$HOME/.machine"
	else
		echo ""
	fi
}

MACHINE="${MACHINE_OVERRIDE:-$(machine_from_file)}"
if [[ -z "$MACHINE" ]]; then
	echo "No machine identifier found. Create ~/.machine or pass one as an argument."
	exit 1
fi

OS_NAME="$(uname -s)"
ARCH_NAME="$(uname -m)"

if [[ "$OS_NAME" == "Darwin" ]]; then
	if [[ "$ARCH_NAME" == "arm64" ]]; then
		HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"
	else
		HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/usr/local/homebrew}"
	fi
else
	HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}"
fi

ensure_prefix_dir() {
	if [[ -d "$HOMEBREW_PREFIX" ]]; then
		return
	fi

	if [[ -w "$(dirname "$HOMEBREW_PREFIX")" ]]; then
		mkdir -p "$HOMEBREW_PREFIX"
	else
		sudo mkdir -p "$HOMEBREW_PREFIX"
		sudo chown -R "$(whoami)" "$HOMEBREW_PREFIX"
	fi
}

install_homebrew_macos() {
	if [[ "$FORCE_INSTALL" -eq 1 ]] && [[ -d "$HOMEBREW_PREFIX" ]]; then
		echo "Removing existing Homebrew at $HOMEBREW_PREFIX..."
		sudo rm -rf "$HOMEBREW_PREFIX"
	fi

	if [[ ! -d "$HOMEBREW_PREFIX" ]]; then
		[[ ! -x git ]] && xcode-select --install || echo "cmd-line tools installed"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	else
		echo "Homebrew already installed. Skipping."
	fi
}

install_homebrew_linux() {
	if [[ "$FORCE_INSTALL" -eq 1 ]] && [[ -d "$HOMEBREW_PREFIX" ]]; then
		echo "Removing existing Homebrew at $HOMEBREW_PREFIX..."
		sudo rm -rf "$HOMEBREW_PREFIX"
	fi

	if [[ -d "$HOMEBREW_PREFIX/bin" ]]; then
		return
	fi

	ensure_prefix_dir

	if [[ -w "$HOMEBREW_PREFIX" ]]; then
		git clone --depth 1 https://github.com/Homebrew/brew "$HOMEBREW_PREFIX/Homebrew"
	else
		sudo git clone --depth 1 https://github.com/Homebrew/brew "$HOMEBREW_PREFIX/Homebrew"
		sudo chown -R "$(whoami)" "$HOMEBREW_PREFIX"
	fi

	mkdir -p "$HOMEBREW_PREFIX/bin"
	ln -s "$HOMEBREW_PREFIX/Homebrew/bin/brew" "$HOMEBREW_PREFIX/bin/brew"
}

bootstrap_homebrew() {
	if [[ "$OS_NAME" == "Darwin" ]]; then
		install_homebrew_macos
	else
		install_homebrew_linux
	fi

	eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
	export XDG_DATA_DIRS="$HOMEBREW_PREFIX/share:${XDG_DATA_DIRS:-}"
}

brew_tap_once() {
	local tap="$1"
	if brew tap | grep -qx "$tap"; then
		return
	fi
	brew tap "$tap"
}

brew_install_once() {
	local pkg="$1"
	if brew list --formula "$pkg" >/dev/null 2>&1; then
		return
	fi
	if brew install "$pkg"; then
		return
	fi
	echo "brew install failed for ${pkg}; attempting reinstall..."
	if brew reinstall "$pkg"; then
		return
	fi
	echo "brew reinstall failed for ${pkg}; continuing."
}

brew_install_cask_once() {
	local pkg="$1"
	if brew list --cask "$pkg" >/dev/null 2>&1; then
		return
	fi
	if brew install --cask "$pkg"; then
		return
	fi
	echo "brew install --cask failed for ${pkg}; attempting reinstall..."
	if brew reinstall --cask "$pkg"; then
		return
	fi
	echo "brew reinstall --cask failed for ${pkg}; continuing."
}

install_kitty_linux() {
	# Skip on macOS (installed via cask) and WSL (use Windows-side kitty)
	if [[ "$OS_NAME" == "Darwin" ]] || [[ "$MACHINE" == "x64-wsl" ]]; then
		return
	fi

	if [[ "$FORCE_INSTALL" -eq 1 ]]; then
		rm -rf "$HOMEBREW_PREFIX/Cellar/kitty" "$HOMEBREW_PREFIX/bin/kitty"
	fi

	if [[ -d "$HOMEBREW_PREFIX/Cellar/kitty" ]]; then
		echo "kitty is already installed"
		return
	fi

	local version="0.43.1"
	mkdir -p "$HOMEBREW_PREFIX/Cellar/kitty"
	pushd "$HOMEBREW_PREFIX/Cellar/kitty" >/dev/null
	wget "https://github.com/kovidgoyal/kitty/releases/download/v${version}/kitty-${version}-x86_64.txz" -O kitty.txz
	tar xf kitty.txz -C "$HOMEBREW_PREFIX/Cellar/kitty"
	ln -sf "$HOMEBREW_PREFIX/Cellar/kitty/bin/kitty" "$HOMEBREW_PREFIX/bin/kitty"
	rm -f kitty.txz
	popd >/dev/null
}

install_pdfcat() {
	brew_tap_once "marromlam/pdfcat"
	brew_install_once "marromlam/pdfcat/pdfcat"
}

install_rust() {
	brew_install_once "rust-analyzer"

	if command -v rustup >/dev/null 2>&1; then
		rustup component add rustfmt clippy rust-src
		return
	fi

	if command -v rustup-init >/dev/null 2>&1; then
		rustup-init -y
	else
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	fi

	if command -v rustup >/dev/null 2>&1; then
		rustup component add rustfmt clippy rust-src
	fi
}

install_ish_packages() {
	echo "iSH detected. Installing packages via apk..."
	apk update
	apk add bash curl tar shadow git neovim tmux fzf ripgrep jq
}

if [[ "$MACHINE" == "x32-linux" ]]; then
	install_ish_packages
	exit 0
fi

bootstrap_homebrew

# shellcheck source=install/install_sonarqube.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/install_sonarqube.sh"

TAPS_COMMON=(
	"browsh-org/homebrew-browsh"
	"koekeishiya/formulae"
	"Rigellute/tap"
	"Schniz/tap"
	"rlue/utils"
	"epk/epk"
	"marromlam/custom"
)

TAPS_MAC=(
	"iina/homebrew-mpv-iina"
	"iina/mpv-iina"
	"jayadamsmorgan/yatoro"
)

BREW_MAC=(
	"bat"
	"calcurse"
	"git"
	"git-delta"
	"browsh"
	"fpp"
	"fzf"
	"ripgrep"
	"ydiff"
	"gnu-sed"
	"neovim"
	"lazygit"
	"jq"
	"yq"
	"btop"
	"tmux"
	"tree"
	"wget"
	"stow"
	"eza"
	"otree"
	"coreutils"
	"gd"
	"asdf"
	"node"
	"yarn"
	"gcc"
	"texlive"
	"pandoc"
	"lua"
	"ncurses"
	"pkg-config"
	"pkgconf"
	"readline"
	"rlue/utils/timer"
	"mupdf-tools"
	"ffmpeg"
	"docker"
	"colima"
	"lazydocker"
	"cmake"
	"fswatch"
	"p7zip"
	"sevenzip"
	"tailscale"
	"timg"
	"ykman"
	"yt-dlp"
	"marromlam/custom/xmlformat"
)

BREW_LINUX=(
	"ruby"
	"glibc"
	"bottom"
	"lazydocker"
	"browsh"
	"fpp"
	"fzf"
	"git"
	"imagemagick"
	"gnu-sed"
	"lazygit"
	"git-delta"
	"ncurses"
	"neovim"
	"node"
	"pandoc"
	"pkg-config"
	"python"
	"readline"
	"ripgrep"
	"rlue/utils/timer"
	"asdf"
	"stow"
	"tmux"
	"tree"
	"vifm"
	"wget"
	"yarn"
	"mupdf-tools"
	"ffmpeg"
	"shfmt"
	"lsd"
	"exa"
	"gcc"
	"sshfs"
	"zsh-syntax-highlighting"
	"zsh-autosuggestions"
	"bat"
	"calcurse"
	"eza"
	"jq"
	"marromlam/custom/xmlformat"
)

CASK_MAC_ONLY=(
	"iina"
	"transmission"
	"kitty"
	"orion"
	"obsidian"
	"rectangle"
	"amethyst"
	"hammerspoon"
	"grandperspective"
	"keycastr"
	"ghostty"
	"appcleaner"
	"chatgpt"
	"claude-code"
	"codex"
	"copilot-cli"
	"whatsapp"
	"domzilla-caffeine"
	"font-hasklug-nerd-font"
	"font-jetbrains-mono"
	"font-victor-mono"
	"font-iosevka"
	"font-sf-mono-nerd-font"
	"font-fira-code-nerd-font"
	"font-hack-nerd-font"
	"font-symbols-only-nerd-font"
	"font-sf-pro"
)

for tap in "${TAPS_COMMON[@]}"; do
	brew_tap_once "$tap"
done

if [[ "$OS_NAME" == "Darwin" ]]; then
	for tap in "${TAPS_MAC[@]}"; do
		brew_tap_once "$tap"
	done
	ALL_BREWS=("${BREW_MAC[@]}")
else
	ALL_BREWS=("${BREW_LINUX[@]}")
fi

SEEN_BREWS=()
for pkg in "${ALL_BREWS[@]}"; do
	already=0
	for seen in "${SEEN_BREWS[@]:-}"; do
		if [[ "$seen" == "$pkg" ]]; then
			already=1
			break
		fi
	done
	if [[ "$already" -eq 0 ]]; then
		SEEN_BREWS+=("$pkg")
		brew_install_once "$pkg"
	fi
done

if [[ "$OS_NAME" == "Darwin" ]]; then
	for cask in "${CASK_MAC_ONLY[@]}"; do
		brew_install_cask_once "$cask"
	done
else
	install_kitty_linux
fi

install_pdfcat
install_rust
install_sonarqube
brew_install_once "pixi"

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -x "$DOTFILES_ROOT/install/install_zsh.sh" ]]; then
	bash "$DOTFILES_ROOT/install/install_zsh.sh"
elif [[ -x "${HOME}/tmp/install_zsh.sh" ]]; then
	bash "${HOME}/tmp/install_zsh.sh"
fi

brew update
brew upgrade
brew cleanup
