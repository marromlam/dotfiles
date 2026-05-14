-- Optimized: Cache severity constants and icons lookup
local S = vim.diagnostic.severity
local icons = require('tools').ui.icons.lsp

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
  },
})
