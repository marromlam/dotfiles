#!/usr/bin/env bash

# install rust
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# sources of the standard library.
# rustup component add rust-src

# rust analyzer
# rustup +nightly component add rust-analyzer-preview

# rustup compoent clippy

# brew install rust   # only one version of rust
# brew install rustup # several versions fo rust
brew install rust-analyzer
rustup-init

rustup component add rustfmt
rustup component add clippy
rustup component add rust-src
# rustup component add rust-analysis-preview
# rustup component add rust-analysis-preview-ui
# rustup component add rust-analysis-preview-clippy

# vim:foldmethod=marker
