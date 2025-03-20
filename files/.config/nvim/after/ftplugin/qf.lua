-- CUSTOM QUICKFIX WINDOW

vim.opt_local.wrap = false
vim.opt_local.number = false
vim.opt_local.signcolumn = 'yes'
vim.opt_local.buflisted = false
vim.opt_local.winfixheight = true

map(
  'n',
  'dd',
  mrl.list.qf.delete,
  { desc = '[qf] delete current quickfix entry', buffer = 0 }
)
map(
  'v',
  'd',
  mrl.list.qf.delete,
  { desc = '[qf] delete selected quickfix entry', buffer = 0 }
)

map('n', 'H', ':colder<CR>', { buffer = 0 })
map('n', 'L', ':cnewer<CR>', { buffer = 0 })

-- force quickfix to open beneath all other splits
vim.cmd.wincmd('J')
mrl.adjust_split_height(3, 10)
