return {
  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
    config = function(_, opts)
      local todo_comments = require('todo-comments')
      vim.keymap.set(
        'n',
        ']t',
        function() todo_comments.jump_next() end,
        { desc = 'Next todo comment' }
      )
      vim.keymap.set(
        'n',
        '[t',
        function() todo_comments.jump_prev() end,
        { desc = 'Previous todo comment' }
      )
      todo_comments.setup(opts)
    end,
  },
  {
    'folke/trouble.nvim',
    dependencies = { 'folke/todo-comments.nvim' },
    cmd = { 'Trouble' },
    opts = {},
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'trouble: workspace diagnostics',
      },
      {
        '<leader>xd',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'trouble: document diagnostics',
      },
      {
        '<leader>xq',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'trouble: quickfix list',
      },
      {
        '<leader>xl',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'trouble: location list',
      },
      {
        '<leader>xs',
        '<cmd>Trouble symbols toggle<cr>',
        desc = 'trouble: document symbols',
      },
      { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'trouble: todos' },
    },
  },
}
