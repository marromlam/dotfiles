-- Minimal init for running tests with mini.test.
-- Does NOT load the full lazy.nvim stack — only bootstraps mini.test itself.

local tmp = vim.fn.fnamemodify('/tmp/nvim-test', ':p')
vim.env.XDG_CONFIG_HOME = tmp .. '/config'
vim.env.XDG_DATA_HOME = tmp .. '/data'
vim.env.XDG_STATE_HOME = tmp .. '/state'
vim.env.XDG_CACHE_HOME = tmp .. '/cache'

-- Bootstrap mini.test into a dedicated data dir
local mini_test_path = tmp .. '/data/mini-test/mini.test'
if not vim.loop.fs_stat(mini_test_path) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/echasnovski/mini.test',
    mini_test_path,
  })
end

-- Add mini.test to runtimepath
vim.opt.rtp:prepend(mini_test_path)

-- Add the nvim config root so tests can `require('tools')`, `require('highlight')`, etc.
local config_root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h')
vim.opt.rtp:prepend(config_root)

-- Stub out vim.notify to avoid noise during unit tests
vim.notify = function() end

-- Set up MiniTest global so test files can reference MiniTest.* at file scope
require('mini.test').setup()
