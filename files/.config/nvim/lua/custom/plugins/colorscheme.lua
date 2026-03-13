-- DONE
local is_dev = vim.fn.isdirectory(
  '/Users/marcos/Workspaces/personal/theme-builder'
) == 1

return {

  {
    'vague2k/vague.nvim',
    lazy = false,
    enabled = not is_dev,
    cond = not is_dev,
    priority = 1000,
    config = function()
      require('vague').setup({
        transparent = false,
        style = {
          boolean = 'none',
          number = 'none',
          float = 'none',
          error = 'none',
          comments = 'italic',
          conditionals = 'none',
          functions = 'none',
          headings = 'bold',
          operators = 'none',
          strings = 'none',
          variables = 'none',
          keywords = 'italic',
        },
      })

      vim.cmd('colorscheme vague')
    end,
  },
  {
    'marromlam/theme-builder.nvim',
    lazy = false,
    dev = true,
    enabled = is_dev,
    cond = is_dev,
    dir = '/Users/marcos/Workspaces/personal/theme-builder/generated/amberglow/nvim',
    priority = 1000,
    config = function() vim.cmd.colorscheme('amberglow') end,
  },
}
