-- Init lua

-- Enable vim.loader for faster startup (Folke's pattern)
if vim.loader then vim.loader.enable() end

vim.g.os = vim.loop.os_uname().sysname
vim.g.open_command = vim.g.os == 'Darwin' and 'open' or 'xdg-open'
vim.g.dev_environ = ''

vim.g.dotfiles = vim.env.DOTFILES or vim.fn.expand('~/.dotfiles')
vim.g.vim_dir = vim.g.dotfiles .. '/.config/nvim'

-- vim.g.projects_directory = vim.fn.expand('~/Projects')
vim.g.projects_directory = vim.fn.expand('~/Workspaces/')
vim.g.personal_directory = vim.g.projects_directory .. '/personal'
vim.g.work_directory = vim.g.projects_directory .. '/work'

vim.g.icloud = vim.fn.expand('~') .. '/Library/Mobile Documents'
vim.g.obsidian = vim.g.icloud .. '/iCloud~md~obsidian/Documents/Marcos'

-- Leader bindings
vim.g.mapleader = ' ' -- Remap leader key
vim.g.maplocalleader = '\\' -- Local leader is <Space>

--------------------------------------------------------------------------------
-- Global namespace {{{
--------------------------------------------------------------------------------

local namespace = {
  ui = {
    statuscolumn = {
      enable = true, -- Re-enabled with caching optimizations
      number_width = 3,
      hide_diag_on_cursorline = true,
    },
    statusline = { enable = true },
  },
  -- some vim mappings require a mixture of commandline commands and function
  -- calls this table is place to store lua functions to be called in those
  -- mappings
  mappings = { enable = true },
}

-- This table is a globally accessible store to facilitating accessing
-- helper functions and variables throughout my config
_G.mrl = mrl or namespace
_G.map = vim.keymap.set
_G.P = vim.print

-- If opening from inside neovim terminal buffer, skip full config
if vim.env.NVIM and vim.env.TERM_PROGRAM == 'nvim' then
  return require('lazy').setup({ { 'willothy/flatten.nvim', config = true } })
end

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Load modules {{{
--------------------------------------------------------------------------------

require('tools') -- has to be loaded before plugins
require('keymaps')
require('options')
require('highlight') -- needed by plugins for highlight tables
require('custom.ui') -- needed by lazyloader for icons
require('lazyloader')

-- Defer non-critical modules for faster startup
vim.defer_fn(function()
  require('custom.strings')
  require('external_grep')
end, 0)

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- }}}
--------------------------------------------------------------------------------

-- vim: ts=2 sts=2 sw=2 et fdm=marker
