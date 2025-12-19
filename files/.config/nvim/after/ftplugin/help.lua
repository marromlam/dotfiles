-- CUSTOM HELP WINDOW
--
-- References:
-- https://vim.fandom.com/wiki/Learn_to_use_help

vim.opt_local.list = false
vim.opt_local.wrap = false
vim.opt_local.spell = true
vim.opt_local.textwidth = 78

-- If this is a vim help file, create mappings to make navigation easier
-- Otherwise enable preferred editing settings
if
  vim.startswith(vim.fn.expand('%'), vim.env.VIMRUNTIME) or vim.bo.readonly
then
  vim.opt_local.spell = false
  vim.api.nvim_create_autocmd('BufWinEnter', {
    buffer = 0,
    command = 'wincmd L | vertical resize 80',
  })
  vim.keymap.set('n', '<CR>', '<C-]>', { buffer = 0, desc = 'Follow help tag' })
  vim.keymap.set(
    'n',
    '<BS>',
    '<C-T>',
    { buffer = 0, desc = 'Go back in help tag stack' }
  )
else
  vim.keymap.set(
    'n',
    '<leader>ml',
    'maGovim:tw=78:ts=8:noet:ft=help:norl:<esc>`a',
    { buffer = 0, desc = 'Add help modeline' }
  )
end
