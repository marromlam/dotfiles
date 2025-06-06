-- add formatter
vim.keymap.set('n', '<leader>lf', ':%!xmlformat<CR>')
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.showbreak = string.rep(' ', 8) -- Make it so that long lines wrap smartly
vim.opt.linebreak = true

-- Remap for dealing with word wrap
vim.keymap.set(
  'n',
  'k',
  "v:count == 0 ? 'gk' : 'k'",
  { expr = true, silent = true }
)
vim.keymap.set(
  'n',
  'j',
  "v:count == 0 ? 'gj' : 'j'",
  { expr = true, silent = true }
)

vim.keymap.set({ 'n', 'i' }, '<leader>X', function()
  vim.api.nvim_command('write')

  local bufname = vim.api.nvim_buf_get_name(0)
  require('docxedit').reload_docx(bufname)
  require('docxedit').watch_edit(bufname)
end, { desc = 'Reload MS Word' })

vim.keymap.set({ 'n', 'i' }, '<s-cr>', function()
  vim.api.nvim_command('write')

  local bufname = vim.api.nvim_buf_get_name(0)
  require('docxedit').reload_docx(bufname)
  require('docxedit').watch_edit(bufname)
end, { desc = 'Reload MS Word' })
