-- Carbon Mist color scheme for Neovim
-- Carbon Mist theme based on a soft retro ANSI palette.
-- Author: Marcos Romero Lamas
-- Version: 1.0.0

vim.cmd('hi clear')
if vim.fn.exists('syntax_on') then vim.cmd('syntax reset') end

vim.o.termguicolors = true
vim.g.colors_name = 'carbon-mist'

require('carbon-mist').load()
