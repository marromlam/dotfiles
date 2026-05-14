#!/usr/bin/env zsh

CONDA_PREFIX="/opt/conda"
export CONDA_ORIGIN="/opt/conda"

__bootstrap_conda() {
	local conda_os=""
	local conda_arch=""
	local conda_url=""
	local conda_installer="${HOME}/miniconda.sh"

	case "${OSTYPE}" in
	linux-gnu* | freebsd*)
		conda_os="Linux"
		;;
	darwin*)
		conda_os="MacOSX"
		;;
	*)
		echo "Unsupported OS for conda bootstrap: ${OSTYPE}" >&2
		return 1
		;;
	esac

	case "$(uname -m)" in
	x86_64 | amd64)
		conda_arch="x86_64"
		;;
	arm64 | aarch64)
		conda_arch="arm64"
		;;
	*)
		echo "Unsupported architecture for conda bootstrap: $(uname -m)" >&2
		return 1
		;;
	esac

	conda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-${conda_os}-${conda_arch}.sh"

	if command -v wget >/dev/null 2>&1; then
		wget "${conda_url}" -O "${conda_installer}"
	elif command -v curl >/dev/null 2>&1; then
		curl -fsSL "${conda_url}" -o "${conda_installer}"
	else
		echo "Neither wget nor curl is available to download Miniconda." >&2
		return 1
	fi

	sudo mkdir -p /opt
	sudo chown -R "$(whoami)" /opt

	bash "${conda_installer}" -b -p "${CONDA_ORIGIN}"
	rm -f "${conda_installer}"

	eval "$(${CONDA_PREFIX}/bin/conda shell.zsh hook)"
	conda config --append channels conda-forge
}

conda() {
	if [[ ! -x "${CONDA_PREFIX}/bin/conda" ]]; then
		__bootstrap_conda || return 1
	fi

	eval "$(${CONDA_PREFIX}/bin/conda shell.zsh hook)"
	unset -f __bootstrap_conda
	conda "$@"
}

# vim: ft=zsh
