-- packs/obsidian.lua

-- Keymaps registered immediately (plugin loaded on demand via commands)
vim.keymap.set('n', '<leader>oo', ':ObsidianOpen<CR>', { desc = 'obsidian: open' })
vim.keymap.set('n', '<leader>on', ':ObsidianNew<CR>', { desc = 'obsidian: new' })
vim.keymap.set('n', '<leader>os', ':ObsidianSearch<CR>', { desc = 'obsidian: search' })
vim.keymap.set('n', '<leader>of', ':ObsidianQuickSwitch<CR>', { desc = 'obsidian: quick switch' })

-- Defer setup until actually used via command
vim.api.nvim_create_user_command('ObsidianSetup', function()
  require('obsidian').setup({
    ui = { enable = false },
    workspaces = {
      {
        name = 'personal',
        path = vim.g.obsidian,
      },
    },
  })
end, { desc = 'Setup obsidian.nvim' })

-- Auto-setup on first obsidian command invocation
vim.defer_fn(function()
  require('obsidian').setup({
    ui = { enable = false },
    workspaces = {
      {
        name = 'personal',
        path = vim.g.obsidian,
      },
    },
  })
end, 100)
