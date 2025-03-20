return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    local wk = require('which-key')
    wk.setup({
      win = { border = false },
      layout = { align = 'center' },
    })

    -- wk.add({
    --   [']'] = { name = '+next' },
    -- ['['] = { name = '+prev' },
    --   g = {
    --     c = { name = '+comment' },
    --     b = { name = '+bufferline' },
    --   },
    --   ['<leader>'] = {
    --     a = { name = '+projectionist' },
    --     c = { name = '+code-action' },
    --     f = { name = '+picker' },
    --     h = { name = '+git-action' },
    --     n = { name = '+new' },
    --     j = { name = '+jump' },
    --     p = { name = '+packages' },
    --     q = { name = '+quit' },
    --     l = { name = '+list' },
    --     i = { name = '+iswap' },
    --     e = { name = '+edit' },
    --     r = { name = '+lsp-refactor' },
    --     o = { name = '+only' },
    --     t = { name = '+tab' },
    --     s = { name = '+source/swap' },
    --     y = { name = '+yank' },
    --     O = { name = '+options' },
    --   },
    --   ['<localleader>'] = {
    --     name = 'local leader',
    --     d = { name = '+dap' },
    --     g = { name = '+git' },
    --     o = { name = '+neorg' },
    --     t = { name = '+neotest' },
    --     w = { name = '+window' },
    --   },
    -- })
  end,
}
