-- packs/debug.lua

-- Keymaps (registered immediately so they work as soon as the pack loads)
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, {
  desc = 'Debug: Start/Continue',
})
vim.keymap.set('n', '<F1>', function() require('dap').step_into() end, {
  desc = 'Debug: Step Into',
})
vim.keymap.set('n', '<F2>', function() require('dap').step_over() end, {
  desc = 'Debug: Step Over',
})
vim.keymap.set('n', '<F3>', function() require('dap').step_out() end, {
  desc = 'Debug: Step Out',
})
vim.keymap.set('n', '<leader>B', function() require('dap').toggle_breakpoint() end, {
  desc = 'Debug: Toggle Breakpoint',
})
vim.keymap.set('n', '<F7>', function() require('dapui').toggle() end, {
  desc = 'Debug: See last session result.',
})

-- Full setup deferred until BufReadPre (heavy plugins)
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlDebug', { clear = true }),
  callback = function()
    local dap = require('dap')
    local dapui = require('dapui')

    require('mason-nvim-dap').setup({
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'debugpy',
      },
    })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup({
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '',
          play = '',
          step_into = '󱆭',
          step_over = '',
          step_out = '󰙣',
          step_back = '󱆮',
          run_last = '󰙡',
          terminate = '',
          disconnect = '',
        },
      },
    })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup()
  end,
})

-- rest-nvim is disabled (cond = false)
-- if false then
--   require('rest-nvim').setup()
-- end
