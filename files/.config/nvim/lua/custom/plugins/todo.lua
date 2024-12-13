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
    dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/todo-comments.nvim' },
    cmd = { 'Trouble' },
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble<CR>',
        desc = 'Open/close trouble list',
      },
      {
        '<leader>xw',
        '<cmd>TroubleToggle workspace_diagnostics<CR>',
        desc = 'Open trouble workspace diagnostics',
      },
      {
        '<leader>xd',
        '<cmd>TroubleToggle document_diagnostics<CR>',
        desc = 'Open trouble document diagnostics',
      },
      {
        '<leader>xq',
        '<cmd>TroubleToggle quickfix<CR>',
        desc = 'Open trouble quickfix list',
      },
      {
        '<leader>xl',
        '<cmd>TroubleToggle loclist<CR>',
        desc = 'Open trouble location list',
      },
      { '<leader>xt', '<cmd>TodoTrouble<CR>', desc = 'Open todos in trouble' },
    },
  },
}
