#!/usr/bin/env bash

set -euo pipefail

CONDA_INSTALL_DIR="/opt/conda"

if [[ -x "${CONDA_INSTALL_DIR}/bin/conda" ]]; then
	echo "conda already installed at ${CONDA_INSTALL_DIR}. Skipping."
	exit 0
fi

case "${OSTYPE}" in
	linux-gnu* | freebsd*)
		conda_os="Linux"
		;;
	darwin*)
		conda_os="MacOSX"
		;;
	*)
		echo "Unsupported OS for conda bootstrap: ${OSTYPE}" >&2
		exit 1
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
		exit 1
		;;
esac

conda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-${conda_os}-${conda_arch}.sh"
conda_installer="${HOME}/miniconda.sh"

if command -v wget >/dev/null 2>&1; then
	wget "${conda_url}" -O "${conda_installer}"
elif command -v curl >/dev/null 2>&1; then
	curl -fsSL "${conda_url}" -o "${conda_installer}"
else
	echo "Neither wget nor curl is available to download Miniconda." >&2
	exit 1
fi

sudo mkdir -p /opt
sudo chown -R "$(whoami)" /opt

bash "${conda_installer}" -b -p "${CONDA_INSTALL_DIR}"
rm -f "${conda_installer}"

"${CONDA_INSTALL_DIR}/bin/conda" config --append channels conda-forge

echo "conda installed at ${CONDA_INSTALL_DIR}. Open a new shell and run 'conda' to activate it."
