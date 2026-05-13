-- packs/todo.lua

-- todo-comments (on BufReadPre)
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlTodo', { clear = true }),
  callback = function()
    local todo_comments = require('todo-comments')
    vim.keymap.set('n', ']t', function() todo_comments.jump_next() end, {
      desc = 'Next todo comment',
    })
    vim.keymap.set('n', '[t', function() todo_comments.jump_prev() end, {
      desc = 'Previous todo comment',
    })
    todo_comments.setup({ signs = false })
  end,
})

-- trouble keymaps (registered immediately)
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', {
  desc = 'trouble: workspace diagnostics',
})
vim.keymap.set('n', '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', {
  desc = 'trouble: document diagnostics',
})
vim.keymap.set('n', '<leader>xq', '<cmd>Trouble qflist toggle<cr>', {
  desc = 'trouble: quickfix list',
})
vim.keymap.set('n', '<leader>xl', '<cmd>Trouble loclist toggle<cr>', {
  desc = 'trouble: location list',
})
vim.keymap.set('n', '<leader>xs', '<cmd>Trouble symbols toggle<cr>', {
  desc = 'trouble: document symbols',
})
vim.keymap.set('n', '<leader>xt', '<cmd>Trouble todo toggle<cr>', {
  desc = 'trouble: todos',
})

-- trouble setup (on command invocation; setup with empty opts)
vim.defer_fn(function()
  require('trouble').setup({})
end, 100)
