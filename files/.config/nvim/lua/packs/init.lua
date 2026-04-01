-- packs/init.lua

-- plenary.nvim: no setup needed

-- fold-cycle
require('fold-cycle').setup({})
vim.keymap.set('n', '<BS>', function() require('fold-cycle').open() end, {
  desc = 'fold-cycle: toggle',
})

-- debugprint
require('debugprint').setup({ keymaps = {} })
vim.keymap.set('n', '<leader>dp', function()
  return require('debugprint').debugprint({ variable = true })
end, { desc = 'debugprint: cursor', expr = true })
vim.keymap.set('n', '<leader>do', function()
  return require('debugprint').debugprint({ motion = true })
end, { desc = 'debugprint: operator', expr = true })
vim.keymap.set('n', '<leader>dC', '<Cmd>DeleteDebugPrints<CR>', {
  desc = 'debugprint: clear all',
})

-- sailor.vim: loaded on VimEnter, no explicit setup needed

-- file-line: activated by the gF key, no setup needed

-- vim-dirdiff: loaded on :DirDiff command, no setup needed

-- vim-sleuth: loaded on BufReadPre, no setup needed

-- vim-surround: loaded on BufReadPre, no setup needed

-- vim-repeat: loaded on '.', no setup needed
