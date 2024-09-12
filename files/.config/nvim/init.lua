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
vim.g.mapleader = ' ' -- Remap leader key
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

-- }}}

-- If opening from inside neovim terminal, skip {{{
if vim.env.NVIM then
  return require('lazy').setup({ { 'willothy/flatten.nvim', config = true } })
end
-- }}}
--------------------------------------------------------------------------------

-- Load modules
require('tools') -- has to be loaded before plugins
-- require('remaps')
require('keymaps')
require('autocommands')
require('custom.globals')
require('options')
require('lazyloader')
require('custom.ui')
require('external_grep')

vim.keymap.set(
  'n',
  '<space>ls',
  '<cmd>lua vim.lsp.diagnostic.get_line_diagnostics()<CR>',
  { noremap = true, silent = true }
)
-- local ns = require('lint').get_namespace('my_linter_name')
-- vim.diagnostic.config({ virtual_text = true }, ns)

--------------------------------------------------------------------------------
-- Extra hightlighting {{{
--------------------------------------------------------------------------------

function mrl.get_hi(name, id)
  id = id or 0
  local hi = vim.api.nvim_get_hl(0, { name = name })
  -- hi is a table with bg and fg keys. for those we want to return the hex
  -- value with ('#%06x'):format(num)
  for k, v in pairs(hi) do
    if type(v) == 'number' then hi[k] = ('#%06x'):format(v) end
  end
  return hi
end

-- vim.api.nvim_create_user_command("Format", function()
--   -- check if null-ls exists
--   local check, nullls = pcall(require, "null-ls")
--   -- check if a formatting source of null-ls is registered
--   --  wait 2 sec to get the server started
--   vim.wait(2000, function()
--     return check
--       and nullls.is_registered({ method = nullls.methods.FORMATTING })
--   end, 1)
--
--   if check and nullls.is_registered({ method = nullls.methods.FORMATTING }) then
--     vim.lsp.buf.format()
--   else
--     vim.cmd([[normal gg=G<C-o>]])
--   end
-- end, {})
--
-- vim.keymap.set(
--   { "n" },
--   "<leader>lf",
--   "<cmd>Format<CR>",
--   { silent = true, desc = "lsp-format current buffer" }
-- )

gruvbox = require('gruvbox')

vim.api.nvim_set_hl(0, 'LineNr', {
  fg = mrl.get_hi('Comment').fg,
  bg = mrl.get_hi('Normal').bg,
})
vim.api.nvim_set_hl(0, 'LineNrAbove', {
  fg = mrl.get_hi('Comment').fg,
  bg = mrl.get_hi('Normal').bg,
})
vim.api.nvim_set_hl(0, 'NotifyBackground', {
  fg = mrl.get_hi('Comment').fg,
  bg = mrl.get_hi('Normal').bg,
})
vim.api.nvim_set_hl(0, 'LineNrBelow', {
  fg = mrl.get_hi('Comment').fg,
  bg = mrl.get_hi('Normal').bg,
})

-- vim.api.nvim_set_hl(0, 'GitSignsAdd', {
--   fg = mrl.get_hi('GitSignsAdd').fg,
--   bg = mrl.get_hi('Normal').bg,
-- })
-- vim.api.nvim_set_hl(0, 'GitSignsChange', {
--   fg = mrl.get_hi('GitSignsChange').fg,
--   bg = mrl.get_hi('Normal').bg,
-- })
-- vim.api.nvim_set_hl(0, 'GitSignsDelete', {
--   fg = mrl.get_hi('GitSignsDelete').fg,
--   bg = mrl.get_hi('Normal').bg,
-- })
-- vim.api.nvim_set_hl(0, 'GitSignsUntracked', {
--   fg = mrl.get_hi('GitSignsUntracked').fg,
--   bg = mrl.get_hi('Normal').bg,
-- })

-- general color for text in status line
vim.api.nvim_set_hl(0, 'Statusline', {
  -- fg = mrl.get_hi('Statusline').fg,
  fg = '#00ff00',
  bg = '#213352',
  -- bg = mrl.get_hi('Normal').bg,
})
vim.api.nvim_set_hl(0, 'CustomStatusline', {
  -- fg = mrl.get_hi('Statusline').fg,
  fg = '#00ff00',
  bg = '#213352',
  -- bg = mrl.get_hi('Normal').bg,
})
vim.api.nvim_set_hl(0, 'StatusLine', {
  -- fg = mrl.get_hi('Statusline').fg,
  fg = '#00ff00',
  bg = '#213352',
  -- bg = mrl.get_hi('Normal').bg,
})
vim.api.nvim_set_hl(0, 'StCustomError', {
  -- fg = mrl.get_hi('Statusline').fg,
  fg = '#ff0000',
  bg = '#213352',
  -- bg = mrl.get_hi('Normal').bg,
})

vim.api.nvim_set_hl(0, 'StTitle', {
  -- fg = mrl.get_hi('Statusline').fg,
  fg = '#00ff00',
  bg = '#213352',
  -- bg = mrl.get_hi('Normal').bg,
})

vim.api.nvim_set_hl(0, 'StatuslineGitSignsAdd', {
  -- fg = mrl.get_hi('DiffAdd').fg,
  fg = '#00ffaa',
  bg = mrl.get_hi('Statusline').bg,
})

vim.api.nvim_set_hl(0, 'StatuslineGitSignsDelete', {
  -- fg = mrl.get_hi('WarningMsg').fg,
  fg = '#ff0000',
  bg = mrl.get_hi('StatusLine').bg,
})

vim.api.nvim_set_hl(0, 'StatuslineSearch', {
  fg = mrl.get_hi('Search').fg,
  bg = mrl.get_hi('Search').bg,
})

vim.api.nvim_set_hl(0, 'StatuslineRed', {
  fg = mrl.get_hi('GitSignsDelete').fg,
  bg = mrl.get_hi('Statusline').bg,
})

vim.api.nvim_set_hl(0, 'StBranch', {
  fg = '#ffaa00',
  -- bg = mrl.get_hi('GruvboxRedSign').fg,
})

vim.api.nvim_set_hl(0, 'StBranch', {
  fg = mrl.get_hi('StatuslineRed').fg,
  -- bg = mrl.get_hi('GruvboxRedSign').fg,
})

vim.api.nvim_set_hl(0, 'StatuslineParentDirectory', {
  fg = mrl.get_hi('IncSearch').bg,
  bg = mrl.get_hi('Statusline').bg,
  bold = true,
})
vim.api.nvim_set_hl(0, 'StatuslineEnv', {
  fg = mrl.get_hi('GitSignsDelete').fg,
  bg = mrl.get_hi('Statusline').bg,
  bold = true,
  italic = true,
})
vim.api.nvim_set_hl(0, 'StatuslineDirectory', {
  fg = mrl.get_hi('Comment').fg,
  bg = mrl.get_hi('Statusline').bg,
  bold = false,
  italic = true,
})
vim.api.nvim_set_hl(0, 'StatuslineDirectoryInactive', {
  fg = mrl.get_hi('Comment').fg,
  bg = mrl.get_hi('Statusline').bg,
  bold = false,
  italic = false,
})
vim.api.nvim_set_hl(0, 'StatuslineFilename', {
  fg = mrl.get_hi('Normal').fg,
  bg = mrl.get_hi('Statusline').bg,
  bold = true,
  italic = false,
})
vim.api.nvim_set_hl(0, 'WinSeparator', {
  fg = mrl.get_hi('Statusline').fg,
  bg = mrl.get_hi('Normal').bg,
  bold = false,
})

-- }}}
--------------------------------------------------------------------------------

vim.o.background = 'dark' -- or "light"
vim.cmd([[colorscheme gruvbox]])

vim.cmd([[

hi Match ctermbg=162
sig define highlightline linehl=Match
au TextChanged,TextChangedI,TextChangedP,BufWinEnter,BufWritePost,FileWritePost * if expand("%:p") != "" | exe("call map(range(1,1000), {i->execute('sig unplace 999 file='.expand('%:p'))})") | call map(getline(1, '$'), {idx, val -> execute('if val =~ "^\\s*##" | exe "sig place 999 line=".expand(idx+1)." name=highlightline file=".expand("%:p") | endif')}) | endif


]])

vim.cmd([[
autocmd! FileType fzf tnoremap <buffer> <esc> <c-c>
autocmd! FileType fzf tnoremap <buffer> <esc><esc> <c-c>
]])

-- vim: ts=2 sts=2 sw=2 et fdm=marker
