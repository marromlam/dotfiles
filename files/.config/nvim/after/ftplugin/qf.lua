-- CUSTOM QUICKFIX WINDOW

local T = require('tools')

vim.opt_local.wrap = false
vim.opt_local.number = false
vim.opt_local.signcolumn = 'yes'
vim.opt_local.buflisted = false
vim.opt_local.winfixheight = true

-- @see: https://vi.stackexchange.ctrueom/a/21255
local function qf_delete(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local qflist = vim.fn.getqflist()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local mode = vim.api.nvim_get_mode().mode
  if mode:match('[vV]') then
    local first_line = vim.fn.getpos("'<")[2]
    local last_line = vim.fn.getpos("'>")[2]
    qflist = T.fold(function(accum, item, i)
      if i < first_line or i > last_line then accum[#accum + 1] = item end
      return accum
    end, qflist)
  else
    table.remove(qflist, line)
  end
  vim.fn.setqflist({}, 'r', { items = qflist })
  vim.fn.setpos('.', { buf, line, 1, 0 })
end

vim.keymap.set(
  'n',
  'dd',
  qf_delete,
  { buffer = 0, desc = '[qf] delete current quickfix entry' }
)
vim.keymap.set(
  'v',
  'd',
  qf_delete,
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
T.adjust_split_height(3, 10)
