if not mrl then return end

-- Wait for icons to be available
if not mrl.ui or not mrl.ui.icons or not mrl.ui.icons.lsp then
  vim.schedule(function()
    if mrl and mrl.ui and mrl.ui.icons and mrl.ui.icons.lsp then
      -- Re-source this file
      dofile(vim.fn.expand('<sfile>:p'))
    end
  end)
  return
end

-- Optimized: Cache severity constants and icons lookup
local S = vim.diagnostic.severity
local icons = mrl.ui.icons.lsp

-- Diagnostics configuration (optimized for startup time)
vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  signs = {
    severity = { min = S.WARN },
    text = {
      [S.WARN] = icons.warn,
      [S.INFO] = icons.info,
      [S.HINT] = icons.hint,
      [S.ERROR] = icons.error,
    },
    linehl = {
      [S.WARN] = 'DiagnosticSignWarnLine',
      [S.INFO] = 'DiagnosticSignInfoLine',
      [S.HINT] = 'DiagnosticSignHintLine',
      [S.ERROR] = 'DiagnosticSignErrorLine',
    },
  },
})
