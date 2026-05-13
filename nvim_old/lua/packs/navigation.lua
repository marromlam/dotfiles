-- packs/navigation.lua

-- oil.nvim
require('oil').setup({
  default_file_explorer = true,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
  },
  keymaps = {
    ['<C-h>'] = false, -- don't shadow split navigation
    ['<C-l>'] = false,
  },
})
vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'oil: open parent directory' })

-- grapple.nvim
require('grapple').setup({
  scope = 'git',
})
vim.keymap.set('n', '<leader>m', '<cmd>Grapple tag<cr>', { desc = 'grapple: tag file' })
vim.keymap.set('n', '<leader><leader>', '<cmd>Grapple toggle_tags<cr>', { desc = 'grapple: open tags' })
vim.keymap.set('n', '<leader>1', '<cmd>Grapple select index=1<cr>', { desc = 'grapple: select 1' })
vim.keymap.set('n', '<leader>2', '<cmd>Grapple select index=2<cr>', { desc = 'grapple: select 2' })
vim.keymap.set('n', '<leader>3', '<cmd>Grapple select index=3<cr>', { desc = 'grapple: select 3' })
vim.keymap.set('n', '<leader>4', '<cmd>Grapple select index=4<cr>', { desc = 'grapple: select 4' })
vim.keymap.set('n', '<leader>5', '<cmd>Grapple select index=5<cr>', { desc = 'grapple: select 5' })
vim.keymap.set('n', '[g', '<cmd>Grapple cycle_tags prev<cr>', { desc = 'grapple: prev tag' })
vim.keymap.set('n', ']g', '<cmd>Grapple cycle_tags next<cr>', { desc = 'grapple: next tag' })
