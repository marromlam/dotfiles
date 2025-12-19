-- XML-specific options
vim.opt_local.wrap = true
vim.opt_local.breakindent = true
vim.opt_local.showbreak = string.rep(' ', 8) -- Make it so that long lines wrap smartly
vim.opt_local.linebreak = true

-- Formatter
vim.keymap.set(
  'n',
  '<leader>lf',
  ':%!xmlformat<CR>',
  { buffer = 0, desc = 'Format XML' }
)

-- Remap for dealing with word wrap
vim.keymap.set(
  'n',
  'k',
  "v:count == 0 ? 'gk' : 'k'",
  { expr = true, buffer = 0, desc = 'Move up (respect wrap)' }
)
vim.keymap.set(
  'n',
  'j',
  "v:count == 0 ? 'gj' : 'j'",
  { expr = true, buffer = 0, desc = 'Move down (respect wrap)' }
)

-- Helper function for MS Word reload
local function reload_word()
  vim.api.nvim_command('write')
  local bufname = vim.api.nvim_buf_get_name(0)
  require('docxedit').reload_docx(bufname)
  require('docxedit').watch_edit(bufname)
end

vim.keymap.set(
  { 'n', 'i' },
  '<leader>X',
  reload_word,
  { buffer = 0, desc = 'Reload MS Word' }
)
vim.keymap.set(
  { 'n', 'i' },
  '<s-cr>',
  reload_word,
  { buffer = 0, desc = 'Reload MS Word' }
)
