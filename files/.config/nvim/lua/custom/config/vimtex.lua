local M = {}

function M.config()
  vim.g.tex_flavor = 'latex'
  vim.g.vimtex_compiler_latexmk = { progname = 'nvr' }
  -- quickfix errors
  vim.g.vimtex_quickfix_open_on_warning = 0
  vim.g.vimtex_view_automatic = 0
  -- vim.g.vimtex_quickfix_mode = 2

  -- Config from castel.dev
  vim.cmd([[set conceallevel=1]])
  vim.g.tex_conceal = 'abdmg'
end

return M
