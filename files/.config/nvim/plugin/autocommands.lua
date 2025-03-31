if not mrl then return end

local fn, api, v, env, cmd, fmt =
  vim.fn, vim.api, vim.v, vim.env, vim.cmd, string.format

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup(
    'kickstart-highlight-yank',
    { clear = true }
  ),
  callback = function() vim.highlight.on_yank() end,
})

local function stop_hl()
  if v.hlsearch == 0 or api.nvim_get_mode().mode ~= 'n' then return end
  vim.api.nvim_feedkeys(vim.keycode('<Plug>(StopHL)'), 'm', false)
end

local function hl_search()
  local col = api.nvim_win_get_cursor(0)[2]
  local curr_line = api.nvim_get_current_line()
  local ok, match = pcall(fn.matchstrpos, curr_line, fn.getreg('/'), 0)
  if not ok then return end
  local _, p_start, p_end = unpack(match)
  -- if the cursor is in a search result, leave highlighting on
  if col < p_start or col > p_end then stop_hl() end
end

mrl.augroup('VimrcIncSearchHighlight', {
  event = { 'CursorMoved' },
  command = function() hl_search() end,
}, {
  event = { 'InsertEnter' },
  command = function() stop_hl() end,
}, {
  event = { 'OptionSet' },
  pattern = { 'hlsearch' },
  command = function()
    vim.schedule(function() cmd.redrawstatus() end)
  end,
}, {
  event = 'RecordingEnter',
  command = function() vim.o.hlsearch = false end,
}, {
  event = 'RecordingLeave',
  command = function() vim.o.hlsearch = true end,
})

-- Search highlighting {{{

----------------------------------------------------------------------------------------------------
-- HLSEARCH
----------------------------------------------------------------------------------------------------
-- In order to get hlsearch working the way I like i.e. on when using /,?,N,n,*,#, etc. and off when
-- When I'm not using them, I need to set the following:
-- The mappings below are essentially faked user input this is because in order to automatically turn off
-- the search highlight just changing the value of 'hlsearch' inside a function does not work
-- read `:h nohlsearch`. So to have this workaround I check that the current mouse position is not a search
-- result, if it is we leave highlighting on, otherwise I turn it off on cursor moved by faking my input
-- using the expr mappings below.
--
-- This is based on the implementation discussed here:
-- https://github.com/neovim/neovim/issues/5581

vim.keymap.set(
  { 'n', 'v', 'o', 'i', 'c' },
  '<Plug>(StopHL)',
  'execute("nohlsearch")[-1]',
  { expr = true }
)

local function stop_hl()
  if v.hlsearch == 0 or api.nvim_get_mode().mode ~= 'n' then return end
  api.nvim_feedkeys(vim.keycode('<Plug>(StopHL)'), 'm', false)
end

local function hl_search()
  local col = api.nvim_win_get_cursor(0)[2]
  local curr_line = api.nvim_get_current_line()
  local ok, match = pcall(fn.matchstrpos, curr_line, fn.getreg('/'), 0)
  if not ok then return end
  local _, p_start, p_end = unpack(match)
  -- if the cursor is in a search result, leave highlighting on
  if col < p_start or col > p_end then stop_hl() end
end

mrl.augroup('VimrcIncSearchHighlight', {
  event = { 'CursorMoved' },
  command = function() hl_search() end,
}, {
  event = { 'InsertEnter' },
  command = function() stop_hl() end,
}, {
  event = { 'OptionSet' },
  pattern = { 'hlsearch' },
  command = function()
    vim.schedule(function() cmd.redrawstatus() end)
  end,
}, {
  event = 'RecordingEnter',
  command = function() vim.o.hlsearch = false end,
}, {
  event = 'RecordingLeave',
  command = function() vim.o.hlsearch = true end,
})

-- }}}

-- Recording macro {{{

vim.api.nvim_create_autocmd('RecordingEnter', {
  pattern = '*',
  callback = function()
    vim.g.macro_recording = 'macro @' .. vim.fn.reg_recording()
    vim.cmd('redrawstatus')
  end,
})

-- Autocmd to track the end of macro recording
vim.api.nvim_create_autocmd('RecordingLeave', {
  pattern = '*',
  callback = function()
    vim.g.macro_recording = ''
    vim.cmd('redrawstatus')
  end,
})

-- }}}

mrl.augroup('UpdateVim', {
  event = { 'FocusLost' },
  pattern = { '*' },
  command = 'silent! wall',
}, {
  event = { 'VimResized' },
  pattern = { '*' },
  command = 'wincmd =', -- Make windows equal size when vim resizes
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = vim.api.nvim_create_augroup('AutoCreateDir', { clear = true }),
  callback = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = vim.api.nvim_create_augroup('CheckAutoReload', { clear = true }),
  callback = function()
    if vim.o.buftype ~= 'nofile' then vim.cmd('checktime') end
  end,
})

-- Formatting {{{

vim.api.nvim_create_user_command('Format', function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line =
      vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ['end'] = { args.line2, end_line:len() },
    }
  end
  require('conform').format({
    async = true,
    lsp_format = 'fallback',
    range = range,
  })
end, { range = true })

vim.api.nvim_create_user_command(
  'FormatDisable',
  function(args) vim.g.disable_autoformat = true end,
  {
    desc = 'Disable autoformat-on-save',
  }
)

vim.api.nvim_create_user_command(
  'FormatEnable',
  function() vim.g.disable_autoformat = false end,
  {
    desc = 'Re-enable autoformat-on-save',
  }
)

-- }}}

-- LSP inline diagnostics {{{
--
-- local function best_diagnostic(diagnostics)
--   if vim.tbl_isempty(diagnostics) then
--     return
--   end
--
--   local best = nil
--   local line_diagnostics = {}
--   local line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
--
--   for k, v in pairs(diagnostics) do
--     if v.lnum == line_nr then
--       line_diagnostics[k] = v
--     end
--   end
--
--   for _, diagnostic in ipairs(line_diagnostics) do
--     if best == nil then
--       best = diagnostic
--     elseif diagnostic.severity < best.severity then
--       best = diagnostic
--     end
--   end
--
--   return best
-- end
--
-- local function current_line_diagnostics()
--   local bufnr = 0
--   local line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
--   local opts = { ["lnum"] = line_nr }
--
--   return vim.diagnostic.get(bufnr, opts)
-- end
--
-- local signs = {
--   Error = " ",
--   Warn = " ",
--   Hint = " ",
--   Info = " ",
-- }
--
-- local virt_handler = vim.diagnostic.handlers.virtual_text
-- local ns = vim.api.nvim_create_namespace "current_line_virt"
-- local severity = vim.diagnostic.severity
-- local virt_options = {
--   prefix = "",
--   format = function(diagnostic)
--     local message = vim.split(diagnostic.message, "\n")[1]
--
--     if diagnostic.severity == severity.ERROR then
--       return signs.Error .. message
--     elseif diagnostic.severity == severity.INFO then
--       return signs.Info .. message
--     elseif diagnostic.severity == severity.WARN then
--       return signs.Warn .. message
--     elseif diagnostic.severity == severity.HINT then
--       return signs.Hint .. message
--     else
--       return message
--     end
--   end,
-- }
--
-- vim.diagnostic.handlers.current_line_virt = {
--   show = function(_, bufnr, diagnostics, _)
--     local diagnostic = best_diagnostic(diagnostics)
--     if not diagnostic then
--       return
--     end
--
--     local filtered_diagnostics = { diagnostic }
--
--     pcall(
--       virt_handler.show,
--       ns,
--       bufnr,
--       filtered_diagnostics,
--       { virtual_text = virt_options }
--     )
--   end,
--   hide = function(_, bufnr)
--     bufnr = bufnr or vim.api.nvim_get_current_buf()
--     virt_handler.hide(ns, bufnr)
--   end,
-- }
--
-- vim.diagnostic.config {
--   float = { source = "always" },
--   signs = false,
--   virtual_text = false,
--   severity_sort = true,
--   current_line_virt = true,
-- }
--
-- vim.api.nvim_create_augroup("lsp_diagnostic_current_line", {
--   clear = true,
-- })
--
--
-- vim.api.nvim_clear_autocmds {
--   buffer = bufnr,
--   group = "lsp_diagnostic_current_line",
-- }
--
-- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
--   group = "lsp_diagnostic_current_line",
--   buffer = bufnr,
--   callback = function()
--     vim.diagnostic.handlers.current_line_virt.show(
--       nil,
--       0,
--       current_line_diagnostics(),
--       nil
--     )
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("CursorMoved", {
--   group = "lsp_diagnostic_current_line",
--   buffer = bufnr,
--   callback = function()
--     vim.diagnostic.handlers.current_line_virt.hide(nil, nil)
--   end,
-- })

-- }}}

-- }}}
