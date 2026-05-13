vim.opt_local.wrap = true
vim.opt_local.textwidth = 80
vim.opt_local.colorcolumn = '80'

-- Simulate 80-col display by resizing the current window.
-- Accounts for sign column (2) + line numbers (up to 4 digits = 4) + 1 separator = 7
local padding = vim.opt_local.number:get() and 7 or 2
vim.api.nvim_win_set_width(0, 80 + padding)
