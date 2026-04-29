-- packs/colorscheme.lua
local home_dir = os.getenv('HOME')

local is_dev = vim.fn.isdirectory(
  home_dir .. '/Workspaces/personal/themes'
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
  vim.cmd.colorscheme('dracula_pro')
  -- END_NEOVIM_THEME
end
