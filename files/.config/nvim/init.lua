-- Init lua

vim.g.os = vim.loop.os_uname().sysname
vim.g.open_command = vim.g.os == 'Darwin' and 'open' or 'xdg-open'

vim.g.dotfiles = vim.env.DOTFILES or vim.fn.expand('~/.dotfiles')
vim.g.vim_dir = vim.g.dotfiles .. '/.config/nvim'

vim.g.projects_directory = vim.fn.expand('~/Projects')
vim.g.personal_directory = vim.g.projects_directory .. '/personal'
vim.g.work_directory = vim.g.projects_directory .. '/work'

vim.g.icloud = vim.fn.expand('~') .. '/Library/Mobile Documents'
vim.g.obsidian = vim.g.icloud .. '/iCloud~md~obsidian/Documents'

-- Leader bindings
vim.g.mapleader = ' '       -- Remap leader key
vim.g.maplocalleader = '\\' -- Local leader is <Space>


--------------------------------------------------------------------------------
-- Global namespace {{{
--------------------------------------------------------------------------------

local namespace = {
  ui = {
    winbar = { enable = false },
    statuscolumn = { enable = true },
    statusline = { enable = true },
  },
  -- some vim mappings require a mixture of commandline commands and function calls
  -- this table is place to store lua functions to be called in those mappings
  mappings = { enable = true },
}

-- This table is a globally accessible store to facilitating accessing
-- helper functions and variables throughout my config
_G.mrl = mrl or namespace
_G.map = vim.keymap.set
_G.P = vim.print

-- If opening from inside neovim terminal, skip
if vim.env.NVIM then
  return require('lazy').setup({ { 'willothy/flatten.nvim', config = true } })
end

-- }}}
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Load modules {{{
--------------------------------------------------------------------------------

require('tools') -- has to be loaded before plugins
-- require('remaps')
require('keymaps')
require('tools')
-- require('autocommands')
require('custom.globals')
require('options')
require('highlight')
require('custom.ui')
require('custom.strings')
require('lazyloader')
-- require('custom.ui')
require('external_grep')

vim.keymap.set(
  'n',
  '<space>ls',
  '<cmd>lua vim.lsp.diagnostic.get_line_diagnostics()<CR>',
  { noremap = true, silent = true }
)

-- }}}
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Colorscheme and extra temporal highlights {{{
--------------------------------------------------------------------------------

vim.o.background = 'dark' -- or "light"
vim.cmd([[colorscheme gruvbox]])
-- vim.cmd([[colorscheme horizon]])
-- vim.cmd([[colorscheme rose-pine]])
-- vim.cmd([[colorscheme github_dark]])

vim.cmd([[

hi Match ctermbg=162
sig define highlightline linehl=Match
au TextChanged,TextChangedI,TextChangedP,BufWinEnter,BufWritePost,FileWritePost * if expand("%:p") != "" | exe("call map(range(1,1000), {i->execute('sig unplace 999 file='.expand('%:p'))})") | call map(getline(1, '$'), {idx, val -> execute('if val =~ "^\\s*##" | exe "sig place 999 line=".expand(idx+1)." name=highlightline file=".expand("%:p") | endif')}) | endif
]])


vim.cmd([[
autocmd! FileType fzf tnoremap <buffer> <esc> <c-c>
autocmd! FileType fzf tnoremap <buffer> <esc><esc> <c-c>
" let &colorcolumn = join(range(81,999), ',')
set colorcolumn=81
]])


-- }}}
--------------------------------------------------------------------------------


-- vim: ts=2 sts=2 sw=2 et fdm=marker
