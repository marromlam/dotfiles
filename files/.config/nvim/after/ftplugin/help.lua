-- CUSTOM HELP WINDOW
--
-- References:
-- https://vim.fandom.com/wiki/Learn_to_use_help

vim.opt_local.list = false
vim.opt_local.wrap = false
vim.opt_local.spell = true
vim.opt_local.textwidth = 78

local opts = { buffer = 0 }

-- if this a vim help file create mappings to make navigation easier otherwise
-- enable preferred editing settings
if
  vim.startswith(vim.fn.expand('%'), vim.env.VIMRUNTIME) or vim.bo.readonly
then
  vim.opt_local.spell = false
  vim.api.nvim_create_autocmd(
    'BufWinEnter',
    { buffer = 0, command = 'wincmd L | vertical resize 80' }
  )
  map('n', '<CR>', '<C-]>', opts)
  map('n', '<BS>', '<C-T>', opts)
else
  map('n', '<leader>ml', 'maGovim:tw=78:ts=8:noet:ft=help:norl:<esc>`a', opts)
end
