return {
  'folke/which-key.nvim',
  keys = { '<leader>', '<localleader>' },
  cmd = 'WhichKey',
  config = function()
    local wk = require('which-key')
    wk.setup({
      win = { border = false },
      layout = { align = 'center' },
      -- preset = 'modern',
    })
  end,
}
