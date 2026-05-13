-- packs/testing.lua

---@diagnostic disable: missing-fields
local function neotest() return require('neotest') end
local function open() neotest().output.open({ enter = true, short = false }) end
local function run_file() neotest().run.run(vim.fn.expand('%')) end
local function run_file_sync()
  neotest().run.run({ vim.fn.expand('%'), concurrent = false })
end
local function nearest() neotest().run.run() end
local function next_failed() neotest().jump.prev({ status = 'failed' }) end
local function prev_failed() neotest().jump.next({ status = 'failed' }) end
local function toggle_summary() neotest().summary.toggle() end
local function cancel() neotest().run.stop({ interactive = true }) end

-- Keymaps registered immediately
vim.keymap.set('n', '<localleader>ts', toggle_summary, { desc = 'neotest: toggle summary' })
vim.keymap.set('n', '<localleader>to', open, { desc = 'neotest: output' })
vim.keymap.set('n', '<localleader>tn', nearest, { desc = 'neotest: run' })
vim.keymap.set('n', '<localleader>tf', run_file, { desc = 'neotest: run file' })
vim.keymap.set('n', '<localleader>tF', run_file_sync, { desc = 'neotest: run file synchronously' })
vim.keymap.set('n', '<localleader>tc', cancel, { desc = 'neotest: cancel' })
vim.keymap.set('n', '[n', next_failed, { desc = 'jump to next failed test' })
vim.keymap.set('n', ']n', prev_failed, { desc = 'jump to previous failed test' })

-- Neotest setup on BufReadPre (heavy plugin)
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlNeotest', { clear = true }),
  callback = function()
    local namespace = vim.api.nvim_create_namespace('neotest')
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          local value = diagnostic.message
            :gsub('\n', ' ')
            :gsub('\t', ' ')
            :gsub('%s+', ' ')
            :gsub('^%s+', '')
          return value
        end,
      },
    }, namespace)

    require('neotest').setup({
      discovery = { enabled = true },
      diagnostic = { enabled = true },
      floating = { border = 'rounded' },
      quickfix = { enabled = false, open = true },
      adapters = {
        require('neotest-plenary'),
        require('neotest-python'),
      },
    })
  end,
})
