-- packs/repl.lua

require('kitty-repl').setup()
vim.keymap.set('n', '<leader>;r', ':KittyREPLRun<cr>', { desc = 'repl: run' })
vim.keymap.set('x', '<leader>;s', ':KittyREPLSend<cr>', { desc = 'repl: send' })
vim.keymap.set('n', '<leader>;s', ':KittyREPLSend<cr>', { desc = 'repl: send' })
vim.keymap.set('n', '<S-CR>', ':KittyREPLSend<cr>', { desc = 'repl: send' })
vim.keymap.set('n', '<leader>;c', ':KittyREPLClear<cr>', { desc = 'repl: clear' })
vim.keymap.set('n', '<leader>;k', ':KittyREPLKill<cr>', { desc = 'repl: kill' })
vim.keymap.set('n', '<leader>;l', ':KittyREPLRunAgain<cr>', { desc = 'repl: run again' })
vim.keymap.set('n', '<leader>;w', ':KittyREPLStart<cr>', { desc = 'repl: start' })
vim.keymap.set('n', '<leader>;a', function()
  require('kitty-repl').repl_run_repl()
end, { desc = 'repl: run comments' })
