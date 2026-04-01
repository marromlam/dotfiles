-- packs/colorscheme.lua

local is_dev = vim.fn.isdirectory(
  '/Users/marcos/Workspaces/personal/theme-builder'
) == 1

if not is_dev then
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
else
  -- BEGIN_NEOVIM_THEME
  vim.cmd.colorscheme('amberglow')
  -- END_NEOVIM_THEME
end
