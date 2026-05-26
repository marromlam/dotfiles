-- Dracula Pro color scheme for Neovim
-- The classic Dracula Pro theme with purple tones and precise contrast
-- Author: Dracula Pro
-- Version: 1.0.0

vim.cmd('hi clear')
if vim.fn.exists('syntax_on') then vim.cmd('syntax reset') end

vim.o.termguicolors = true
vim.g.colors_name = 'dracula-pro'

require('dracula-pro').load()
