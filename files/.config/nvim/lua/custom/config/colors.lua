function mrl.get_hi(name, id)
  id = id or 0
  local hi = vim.api.nvim_get_hl(0, { name = name })
  -- hi is a table with bg and fg keys. for those we want to return the hex
  -- value with ('#%06x'):format(num)
  for k, v in pairs(hi) do
    if type(v) == 'number' then hi[k] = ('#%06x'):format(v) end
  end
  return hi
end

-- vim.api.nvim_create_user_command("Format", function()
--   -- check if null-ls exists
--   local check, nullls = pcall(require, "null-ls")
--   -- check if a formatting source of null-ls is registered
--   --  wait 2 sec to get the server started
--   vim.wait(2000, function()
--     return check
--       and nullls.is_registered({ method = nullls.methods.FORMATTING })
--   end, 1)
--
--   if check and nullls.is_registered({ method = nullls.methods.FORMATTING }) then
--     vim.lsp.buf.format()
--   else
--     vim.cmd([[normal gg=G<C-o>]])
--   end
-- end, {})
--
-- vim.keymap.set(
--   { "n" },
--   "<leader>lf",
--   "<cmd>Format<CR>",
--   { silent = true, desc = "lsp-format current buffer" }
-- )

-- vim.api.nvim_set_hl(0, 'LineNr', {
--   fg = mrl.get_hi('Comment').fg,
--   bg = mrl.get_hi('Normal').bg,
-- })
-- vim.api.nvim_set_hl(0, 'LineNrAbove', {
--   fg = mrl.get_hi('Comment').fg,
--   bg = mrl.get_hi('Normal').bg,
-- })
-- vim.api.nvim_set_hl(0, 'NotifyBackground', {
--   fg = mrl.get_hi('Comment').fg,
--   bg = mrl.get_hi('Normal').bg,
-- })
-- vim.api.nvim_set_hl(0, 'LineNrBelow', {
--   fg = mrl.get_hi('Comment').fg,
--   bg = mrl.get_hi('Normal').bg,
-- })

-- vim.api.nvim_set_hl(0, 'GitSignsAdd', {
--   fg = mrl.get_hi('GitSignsAdd').fg,
--   bg = mrl.get_hi('Normal').bg,
-- })
-- vim.api.nvim_set_hl(0, 'GitSignsChange', {
--   fg = mrl.get_hi('GitSignsChange').fg,
--   bg = mrl.get_hi('Normal').bg,
-- })
-- vim.api.nvim_set_hl(0, 'GitSignsDelete', {
--   fg = mrl.get_hi('GitSignsDelete').fg,
--   bg = mrl.get_hi('Normal').bg,
-- })
-- vim.api.nvim_set_hl(0, 'GitSignsUntracked', {
--   fg = mrl.get_hi('GitSignsUntracked').fg,
--   bg = mrl.get_hi('Normal').bg,
-- })

-- general color for text in status line
vim.api.nvim_set_hl(0, 'Statusline', {
  -- fg = mrl.get_hi('Statusline').fg,
  fg = '#00ff00',
  bg = '#213352',
  -- bg = mrl.get_hi('Normal').bg,
})
vim.api.nvim_set_hl(0, 'CustomStatusline', {
  -- fg = mrl.get_hi('Statusline').fg,
  fg = '#00ff00',
  bg = '#213352',
  -- bg = mrl.get_hi('Normal').bg,
})
vim.api.nvim_set_hl(0, 'StatusLine', {
  -- fg = mrl.get_hi('Statusline').fg,
  fg = '#00ff00',
  bg = '#213352',
  -- bg = mrl.get_hi('Normal').bg,
})
vim.api.nvim_set_hl(0, 'StCustomError', {
  -- fg = mrl.get_hi('Statusline').fg,
  fg = '#ff0000',
  bg = '#213352',
  -- bg = mrl.get_hi('Normal').bg,
})

vim.api.nvim_set_hl(0, 'StTitle', {
  -- fg = mrl.get_hi('Statusline').fg,
  fg = '#00ff00',
  bg = '#213352',
  -- bg = mrl.get_hi('Normal').bg,
})

vim.api.nvim_set_hl(0, 'StatuslineGitSignsAdd', {
  -- fg = mrl.get_hi('DiffAdd').fg,
  fg = '#00ffaa',
  bg = mrl.get_hi('Statusline').bg,
})

vim.api.nvim_set_hl(0, 'StatuslineGitSignsDelete', {
  -- fg = mrl.get_hi('WarningMsg').fg,
  fg = '#ff0000',
  bg = mrl.get_hi('StatusLine').bg,
})

vim.api.nvim_set_hl(0, 'StatuslineSearch', {
  fg = mrl.get_hi('Search').fg,
  bg = mrl.get_hi('Search').bg,
})

vim.api.nvim_set_hl(0, 'StatuslineRed', {
  fg = mrl.get_hi('GitSignsDelete').fg,
  bg = mrl.get_hi('Statusline').bg,
})

vim.api.nvim_set_hl(0, 'StBranch', {
  fg = '#ffaa00',
  -- bg = mrl.get_hi('GruvboxRedSign').fg,
})
vim.api.nvim_set_hl(0, 'StWarn', {
  fg = '#ffaa00',
  -- bg = mrl.get_hi('GruvboxRedSign').fg,
})

vim.api.nvim_set_hl(0, 'StBranch', {
  fg = mrl.get_hi('StatuslineRed').fg,
  -- bg = mrl.get_hi('GruvboxRedSign').fg,
})

vim.api.nvim_set_hl(0, 'StatuslineParentDirectory', {
  fg = mrl.get_hi('IncSearch').bg,
  bg = mrl.get_hi('Statusline').bg,
  bold = true,
})
vim.api.nvim_set_hl(0, 'StatuslineEnv', {
  fg = mrl.get_hi('GitSignsDelete').fg,
  bg = mrl.get_hi('Statusline').bg,
  bold = true,
  italic = true,
})
vim.api.nvim_set_hl(0, 'StatuslineDirectory', {
  fg = mrl.get_hi('Comment').fg,
  bg = mrl.get_hi('Statusline').bg,
  bold = false,
  italic = true,
})
vim.api.nvim_set_hl(0, 'StatuslineDirectoryInactive', {
  fg = mrl.get_hi('Comment').fg,
  bg = mrl.get_hi('Statusline').bg,
  bold = false,
  italic = false,
})
vim.api.nvim_set_hl(0, 'StatuslineFilename', {
  fg = mrl.get_hi('Normal').fg,
  bg = mrl.get_hi('Statusline').bg,
  bold = true,
  italic = false,
})
vim.api.nvim_set_hl(0, 'WinSeparator', {
  fg = mrl.get_hi('Statusline').fg,
  bg = mrl.get_hi('Normal').bg,
  bold = false,
})






-- Diagnostic symbols: remove background
vim.api.nvim_set_hl(0, 'DiagnosticSignWarnLine',
  { bg = mrl.get_hi('SignColumn').bg, fg = mrl.get_hi('GitSignsDelete').fg })
vim.api.nvim_set_hl(0, 'DiagnosticSignWarn', { bg = mrl.get_hi('SignColumn').bg, fg = mrl.get_hi('DiagnosticWarn').fg })
-- vim.api.nvim_set_hl(0, 'DiagnosticSignErrorLine', { bg = mrl.get_hi('SignColumn').bg })
vim.api.nvim_set_hl(0, 'DiagnosticSignError', { bg = mrl.get_hi('SignColumn').bg, fg = mrl.get_hi('GitSignsDelete').fg })
-- vim.api.nvim_set_hl(0, 'DiagnosticSignHintLine', { bg = mrl.get_hi('SignColumn').bg })
vim.api.nvim_set_hl(0, 'DiagnosticSignHint', { bg = mrl.get_hi('SignColumn').bg, fg = mrl.get_hi('MoreMsg').fg })
-- vim.api.nvim_set_hl(0, 'DiagnosticSignInfoLine', { bg = mrl.get_hi('SignColumn').bg })
vim.api.nvim_set_hl(0, 'DiagnosticSignInfo', { bg = mrl.get_hi('SignColumn').bg, fg = mrl.get_hi('MoreMsg').fg })
