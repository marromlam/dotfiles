-- CUSTOM QUICKFIX WINDOW

vim.opt_local.wrap = false
vim.opt_local.number = false
vim.opt_local.signcolumn = 'yes'
vim.opt_local.buflisted = false
vim.opt_local.winfixheight = true

vim.keymap.set(
  'n',
  'dd',
  mrl.list.qf.delete,
  { buffer = 0, desc = '[qf] delete current quickfix entry' }
)
vim.keymap.set(
  'v',
  'd',
  mrl.list.qf.delete,
  { buffer = 0, desc = '[qf] delete selected quickfix entry' }
)
vim.keymap.set(
  'n',
  'H',
  ':colder<CR>',
  { buffer = 0, desc = '[qf] older quickfix list' }
)
vim.keymap.set(
  'n',
  'L',
  ':cnewer<CR>',
  { buffer = 0, desc = '[qf] newer quickfix list' }
)

-- force quickfix to open beneath all other splits
vim.cmd.wincmd('J')
mrl.adjust_split_height(3, 10)
