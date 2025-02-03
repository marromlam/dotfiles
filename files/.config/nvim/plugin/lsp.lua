if not mrl then return end

local lsp, fs, fn, api, fmt = vim.lsp, vim.fs, vim.fn, vim.api, string.format
local diagnostic = vim.diagnostic
local L, S = vim.lsp.log_levels, vim.diagnostic.severity
local M = vim.lsp.protocol.Metho


local icons = mrl.ui.icons.lsp
local border = mrl.ui.current.border

-- Diagnostics
-------------------------------------------------------------------------------
diagnostic.config({
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
  virtual_text = false and {
    severity = { min = S.WARN },
    spacing = 1,
    prefix = function(d)
      local level = diagnostic.severity[d.severity]
      return icons[level:lower()]
    end,
  },
  float = {
    -- max_width = max_width,
    -- max_height = max_height,
    border = border,
    title = { { '  ', 'DiagnosticFloatTitleIcon' }, { 'Problems  ', 'DiagnosticFloatTitle' } },
    focusable = true,
    scope = 'cursor',
    source = 'if_many',
    prefix = function(diag)
      local level = diagnostic.severity[diag.severity]
      local prefix = fmt('%s ', icons[level:lower()])
      return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
    end,
  },
})
