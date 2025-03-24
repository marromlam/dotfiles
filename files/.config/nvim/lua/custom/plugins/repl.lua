return {
  'marromlam/kitty-repl.nvim',
  dev = true,
  disable = false,
  keys = {
    { '<leader>;r', ':KittyREPLRun<cr>', 'repl: run' },
    { '<leader>;s', ':KittyREPLSend<cr>', 'repl: run' },
    { '<leader>;s', ':KittyREPLSend<cr>', 'repl: run' },
    { '<S-CR>', ':KittyREPLSend<cr>', 'repl: run' },
    { '<leader>;c', ':KittyREPLClear<cr>', 'repl: run' },
    { '<leader>;k', ':KittyREPLKill<cr>', 'repl: run' },
    { '<leader>;l', ':KittyREPLRunAgain<cr>', 'repl: run' },
    { '<leader>;w', ':KittyREPLStart<cr>', 'repl: run' },
    {
      '<leader>;a',
      ':lua require("kitty-repl").repl_run_repl()<cr>',
      'repl: run comments',
    },
  },
  config = function()
    require('kitty-repl').setup()
    vim.keymap.set('n', '<leader>;r', ':KittyREPLRun<cr>', {})
    vim.keymap.set('x', '<leader>;s', ':KittyREPLSend<cr>', {})
    vim.keymap.set('n', '<leader>;s', ':KittyREPLSend<cr>', {})
    vim.keymap.set('n', '<S-CR>', ':KittyREPLSend<cr>', {})
    vim.keymap.set('n', '<leader>;c', ':KittyREPLClear<cr>', {})
    vim.keymap.set('n', '<leader>;k', ':KittyREPLKill<cr>', {})
    vim.keymap.set('n', '<leader>;l', ':KittyREPLRunAgain<cr>', {})
    vim.keymap.set('n', '<leader>;w', ':KittyREPLStart<cr>', {})
  end,
}
