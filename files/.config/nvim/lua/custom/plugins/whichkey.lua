return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    local wk = require('which-key')
    wk.setup({
      win = { border = false },
      layout = { align = 'center' },
      -- preset = 'modern',
    })

    wk.add({
      { ']', group = 'next' },
      { '[', group = 'prev' },
      { 'gc', group = 'comment' },
      { 'gb', group = 'bufferline' },
      { '<leader>a', group = 'projectionist' },
      { '<leader>c', group = 'code-action' },
      { '<leader>d', group = 'debugprint' },
      { '<leader>m', group = 'marks' },
      { '<leader>f', group = 'picker' },
      { '<leader>h', group = 'git-action' },
      { '<leader>n', group = 'new' },
      { '<leader>j', group = 'jump' },
      { '<leader>p', group = 'packages' },
      { '<leader>q', group = 'quit' },
      { '<leader>l', group = 'list' },
      { '<leader>i', group = 'iswap' },
      { '<leader>e', group = 'edit' },
      { '<leader>r', group = 'lsp-refactor' },
      { '<leader>o', group = 'only' },
      { '<leader>t', group = 'tab' },
      { '<leader>s', group = 'source/swap' },
      { '<leader>y', group = 'yank' },
      { '<leader>O', group = 'options' },
      { '<localleader>', group = 'local leader' },
      { '<localleader>d', group = 'dap' },
      { '<localleader>g', group = 'git' },
      { '<localleader>o', group = 'neorg' },
      { '<localleader>t', group = 'neotest' },
      { '<localleader>w', group = 'window' },
    })

    -- wk.add({
    --   [']'] = { name = '+next' },
    -- ['['] = { name = '+prev' },
    --   g = {
    --     c = { name = '+comment' },
    --     b = { name = '+bufferline' },
    --   },
    -- ['<leader>'] = {
    --   a = { name = '+projectionist' },
    --   c = { name = '+code-action' },
    --   f = { name = '+picker' },
    --   h = { name = '+git-action' },
    --   n = { name = '+new' },
    --   j = { name = '+jump' },
    --   p = { name = '+packages' },
    --   q = { name = '+quit' },
    --   l = { name = '+list' },
    --   i = { name = '+iswap' },
    --   e = { name = '+edit' },
    --   r = { name = '+lsp-refactor' },
    --   o = { name = '+only' },
    --   t = { name = '+tab' },
    --   s = { name = '+source/swap' },
    --   y = { name = '+yank' },
    --   O = { name = '+options' },
    -- },
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
