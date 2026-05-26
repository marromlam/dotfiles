-- Amberglow color scheme for Neovim
-- A warm, retro-inspired dark theme based on the gruvbox colorscheme by ellisonleao/gruvbox.nvim.
-- Author: ellisonleao (original gruvbox), Amberglow adaptation
-- Version: 1.0.0

vim.cmd('hi clear')
if vim.fn.exists('syntax_on') then vim.cmd('syntax reset') end

vim.o.termguicolors = true
vim.g.colors_name = 'amberglow'

require('amberglow').load()
