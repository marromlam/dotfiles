return {
  "marromlam/kitty-repl.nvim",
  disable = false,
  config = function()
    require("kitty-repl").setup()
    vim.keymap.set("n", "<leader>;r", ":KittyREPLRun<cr>", {})
    vim.keymap.set("x", "<leader>;s", ":KittyREPLSend<cr>", {})
    vim.keymap.set("n", "<leader>;s", ":KittyREPLSend<cr>", {})
    vim.keymap.set("n", "<S-CR>", ":KittyREPLSend<cr>", {})
    vim.keymap.set("n", "<leader>;c", ":KittyREPLClear<cr>", {})
    vim.keymap.set("n", "<leader>;k", ":KittyREPLKill<cr>", {})
    vim.keymap.set("n", "<leader>;l", ":KittyREPLRunAgain<cr>", {})
    vim.keymap.set("n", "<leader>;w", ":KittyREPLStart<cr>", {})
  end,
}
