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
vim.g.use_cmp = false

local namespace = {
  ui = {
    winbar = { enable = false },
    statuscolumn = { enable = true },
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
require('highlight')
require('custom.ui')
require('custom.strings')
require('lazyloader')
require('external_grep')

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- COLORSCHEME and extra temporal highlights {{{
--------------------------------------------------------------------------------
vim.o.background = 'dark' -- or "light"
vim.opt.termguicolors = true
vim.cmd([[colorscheme gruvbox]])
-- vim.cmd([[colorscheme horizon]])
-- vim.cmd([[colorscheme rose-pine]])
-- vim.cmd([[colorscheme github_dark]])
-- vim.cmd([[colorscheme github_dark_default]])

vim.cmd([[
hi Match ctermbg=162
sig define highlightline linehl=Match
au TextChanged,TextChangedI,TextChangedP,BufWinEnter,BufWritePost,FileWritePost * if expand("%:p") != "" | exe("call map(range(1,1000), {i->execute('sig unplace 999 file='.expand('%:p'))})") | call map(getline(1, '$'), {idx, val -> execute('if val =~ "^\\s*##" | exe "sig place 999 line=".expand(idx+1)." name=highlightline file=".expand("%:p") | endif')}) | endif
]])

vim.cmd([[
autocmd! FileType fzf tnoremap <buffer> <esc> <c-c>
autocmd! FileType fzf tnoremap <buffer> <esc><esc> <c-c>
FzfLua register_ui_select
set colorcolumn=81
]])

vim.cmd([[
function! GoToColumnInFile (fileInfoString)
  let fileInfo = split(a:fileInfoString, ":")
  let column = 0
  normal! gF
  if len(fileInfo) > 2
    let column = fileInfo[2]
    execute 'normal! ' . column . '|'
  endif
endfunction
nnoremap <leader>gF :call GoToColumnInFile(expand("<cWORD>"))<CR>
]])

-- enable if neovim >= 0.12
if vim.fn.has('nvim-0.12') == 1 then
  vim.cmd([[
  set diffopt+=inline:char
  ]])
end

-- old stuff
-- vim.cmd [[
--   vmap <leader>sk ::w !kitty @ --to=tcp:localhost:$KITTY_PORT send-text --match=num:1 --stdin<CR><CR>
--   autocmd TermOpen * setlocal nonumber norelativenumber
--   autocmd TermOpen * setlocal scl=no
--
--   if has('nvim') && executable('nvr')
--     " pip3 install neovim-remote
--     let $GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
--     let $EDITOR='nvr --nostart --remote-tab-wait +"set bufhidden=delete"'
--   endif
--   nnoremap S :keeppatterns substitute/\s*\%#\s*/\r/e <bar> normal! ==<CR>
--   set path+=**,.,,
-- ]]

-- cfilter plugin allows filtering down an existing quickfix list
-- vim.cmd.packadd('cfilter')

-- }}}
--------------------------------------------------------------------------------

-- vim: ts=2 sts=2 sw=2 et fdm=marker
