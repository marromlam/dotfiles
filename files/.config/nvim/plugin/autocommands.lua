if not mrl then return end

-- Helper to safely call augroup, deferring if not available yet
local function augroup(name, ...)
  local args = { ... }
  if mrl and mrl.augroup then
    return mrl.augroup(name, unpack(args))
  else
    -- Defer until augroup is available
    vim.schedule(function()
      if mrl and mrl.augroup then mrl.augroup(name, unpack(args)) end
    end)
  end
end

local fn, api, v, env, cmd, fmt =
  vim.fn, vim.api, vim.v, vim.env, vim.cmd, string.format

-- -----------------------------------------------------------------------------
-- Performance-sensitive: avoid heavy Vimscript in init.lua
-- -----------------------------------------------------------------------------

-- Highlight lines starting with '##' (headings) using a lightweight sign group.
-- This replaces the old Vimscript that unplaced/placed signs across 1000 ids.
do
  local group = api.nvim_create_augroup('HeadingLineSign', { clear = true })
  local sign_name = 'highlightline'
  local sign_group = 'headingline'
  local debounce_ms = 120
  local pending = {} ---@type table<integer, uv_timer_t?>

  -- Define sign once (safe to call multiple times).
  pcall(fn.sign_define, sign_name, { linehl = 'Match' })

  local function update(bufnr)
    if not api.nvim_buf_is_valid(bufnr) then return end
    if vim.bo[bufnr].buftype ~= '' then return end

    local ft = vim.bo[bufnr].filetype
    if ft ~= 'markdown' and ft ~= 'org' and ft ~= 'norg' then return end

    pcall(fn.sign_unplace, sign_group, { buffer = bufnr })

    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, line in ipairs(lines) do
      if line:match('^%s*##') then
        -- id=0 lets Vim allocate IDs; placing is scoped to sign_group+buffer.
        pcall(fn.sign_place, 0, sign_group, sign_name, bufnr, {
          lnum = i,
          priority = 10,
        })
      end
    end
  end

  local function schedule(bufnr)
    if pending[bufnr] then
      pending[bufnr]:stop()
      pending[bufnr]:close()
      pending[bufnr] = nil
    end
    pending[bufnr] = vim.defer_fn(function()
      pending[bufnr] = nil
      update(bufnr)
    end, debounce_ms)
  end

  api.nvim_create_autocmd(
    { 'BufWinEnter', 'TextChanged', 'TextChangedI', 'TextChangedP' },
    {
      group = group,
      callback = function(args) schedule(args.buf) end,
    }
  )
end

-- Better terminal UX inside fzf-lua: allow Esc to abort.
api.nvim_create_autocmd('FileType', {
  group = api.nvim_create_augroup('FzfTerminalMappings', { clear = true }),
  pattern = 'fzf',
  callback = function(args)
    vim.keymap.set('t', '<esc>', '<c-c>', { buffer = args.buf, silent = true })
    vim.keymap.set('t', '<esc><esc>', '<c-c>', {
      buffer = args.buf,
      silent = true,
    })
  end,
})

-- Disable indent guides in terminal buffers (mini.indentscope / indent-blankline / etc).
do
  local group = api.nvim_create_augroup('DisableIndentGuidesInTerminal', { clear = true })

  local function disable(buf)
    if not api.nvim_buf_is_valid(buf) then return end
    -- Common plugin conventions:
    vim.b[buf].miniindentscope_disable = true
    vim.b[buf].ibl_disable = true
    vim.b[buf].indent_blankline_enabled = false
  end

  api.nvim_create_autocmd('TermOpen', {
    group = group,
    callback = function(args) disable(args.buf) end,
  })

  -- Some terminal plugins use a FileType instead of buftype checks.
  api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = { 'toggleterm', 'terminal' },
    callback = function(args) disable(args.buf) end,
  })
end

-- Ensure all terminal windows use the main Normal background (including plugin-created ones).
do
  local group = api.nvim_create_augroup('TerminalNormalBackground', { clear = true })

  local function apply_terminal_winhighlight(buf)
    if not api.nvim_buf_is_valid(buf) then return end
    local bt, ft = vim.bo[buf].buftype, vim.bo[buf].filetype
    if bt ~= 'terminal' and ft ~= 'toggleterm' and ft ~= 'terminal' then return end

    local win = api.nvim_get_current_win()
    if not api.nvim_win_is_valid(win) then return end

    api.nvim_win_call(win, function()
      vim.opt_local.winhighlight:append({
        -- Force terminal windows to inherit the main editor background.
        Normal = 'Normal',
        NormalNC = 'NormalNC',
        -- For floating terminal windows, ensure the float "Normal" maps to Normal too.
        NormalFloat = 'Normal',
      })
    end)
  end

  api.nvim_create_autocmd({ 'TermOpen', 'BufWinEnter' }, {
    group = group,
    callback = function(args) apply_terminal_winhighlight(args.buf) end,
  })

  api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = { 'toggleterm', 'terminal' },
    callback = function(args) apply_terminal_winhighlight(args.buf) end,
  })
end

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

augroup('VimrcIncSearchHighlight', {
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

augroup('VimrcIncSearchHighlight', {
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

augroup('UpdateVim', {
  event = { 'FocusLost' },
  pattern = { '*' },
  command = 'silent! wall',
}, {
  event = { 'VimResized' },
  pattern = { '*' },
  command = 'wincmd =', -- Make windows equal size when vim resizes
})

-- -----------------------------------------------------------------------------
-- SmartClose: treat tool buffers like panels
-- -----------------------------------------------------------------------------

do
  local group = api.nvim_create_augroup('SmartClose', { clear = true })

  local smart_close_filetypes = {
    ['qf'] = true,
    ['help'] = true,
    ['checkhealth'] = true,
    ['startuptime'] = true,
    ['log'] = true,
    ['query'] = true,
    ['dbui'] = true,
    ['dbout'] = true,
    ['lspinfo'] = true,
    ['tsplayground'] = true,
    ['diff'] = true,
    ['noice'] = true,
  }

  local smart_close_filetype_patterns = {
    '^git.*',
    '^Neogit.*',
    '^neotest.*',
    '^fugitive.*',
    '^copilot.*',
    '^Diffview.*',
  }

  local smart_close_buftypes = {
    ['nofile'] = true,
    ['quickfix'] = true,
  }

  local function ft_matches(ft)
    if smart_close_filetypes[ft] then return true end
    for _, pat in ipairs(smart_close_filetype_patterns) do
      if ft:match(pat) then return true end
    end
    return false
  end

  local function smart_close()
    if fn.winnr('$') ~= 1 then
      api.nvim_win_close(0, true)
    else
      -- If it's the last window, delete the buffer instead.
      pcall(cmd.bdelete, { 0, bang = true })
    end
  end

  -- Auto open quickfix after grep-like commands.
  api.nvim_create_autocmd('QuickFixCmdPost', {
    group = group,
    pattern = '*grep*',
    command = 'cwindow',
  })

  -- Close certain filetypes by pressing q.
  api.nvim_create_autocmd('FileType', {
    group = group,
    callback = function(args)
      local buf = args.buf
      local ft = vim.bo[buf].filetype or ''
      local bt = vim.bo[buf].buftype or ''
      local is_unmapped = fn.hasmapto('q', 'n') == 0
      local eligible = is_unmapped or vim.wo.previewwindow or ft_matches(ft)
        or smart_close_buftypes[bt]

      if eligible then
        vim.keymap.set('n', 'q', smart_close, {
          buffer = buf,
          nowait = true,
          silent = true,
        })
      end
    end,
  })

  -- Close quickfix buffer if it's the only remaining window.
  api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = function()
      if fn.winnr('$') == 1 and vim.bo.buftype == 'quickfix' then
        api.nvim_buf_delete(0, { force = true })
      end
    end,
  })

  -- Close location list when quitting a window.
  api.nvim_create_autocmd('QuitPre', {
    group = group,
    nested = true,
    callback = function()
      if vim.bo.filetype ~= 'qf' then cmd.lclose({ mods = { silent = true } }) end
    end,
  })
end

-- -----------------------------------------------------------------------------
-- Formatting guardrail: disable formatting in third-party/runtime code
-- -----------------------------------------------------------------------------

do
  local group = api.nvim_create_augroup('FormattingGuardrail', { clear = true })

  local function startswith(s, prefix)
    return type(s) == 'string'
      and type(prefix) == 'string'
      and prefix ~= ''
      and s:sub(1, #prefix) == prefix
  end

  local function should_disable_formatting(bufnr)
    if not api.nvim_buf_is_valid(bufnr) then return false end
    if vim.bo[bufnr].buftype ~= '' then return false end
    if not vim.bo[bufnr].modifiable then return false end
    if vim.bo[bufnr].filetype == '' then return false end

    local path = api.nvim_buf_get_name(bufnr)
    if path == '' then return false end

    -- Always allow formatting in your own code/config.
    local allow_prefixes = {
      vim.g.personal_directory,
      vim.g.work_directory,
      vim.g.dotfiles,
      vim.g.vim_dir,
      vim.env.HOME,
    }
    for _, p in ipairs(allow_prefixes) do
      if p and startswith(path, p) then
        -- Don't blanket-allow HOME; only use it to prevent disabling on empty vars.
        -- If you want stricter behavior, remove HOME from this list.
        if p ~= vim.env.HOME then return false end
      end
    end

    -- Disable formatting in runtime/plugin directories.
    if vim.env.VIMRUNTIME and startswith(path, vim.env.VIMRUNTIME) then return true end

    for _, dir in ipairs(vim.split(vim.o.runtimepath, ',', { plain = true })) do
      if dir ~= '' and startswith(path, dir) then
        -- Never disable in your actual config path.
        if vim.g.vim_dir and startswith(path, vim.g.vim_dir) then return false end
        return true
      end
    end

    return false
  end

  api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = function(args)
      vim.b[args.buf].formatting_disabled = should_disable_formatting(args.buf)
    end,
  })
end

-- -----------------------------------------------------------------------------
-- Trailing whitespace highlight (different in insert vs normal)
-- -----------------------------------------------------------------------------

do
  local group = api.nvim_create_augroup('WhitespaceMatch', { clear = true })

  local function is_floating_win()
    return fn.win_gettype() == 'popup'
  end

  local function is_invalid_buf(bufnr)
    return vim.bo[bufnr].filetype == ''
      or vim.bo[bufnr].buftype ~= ''
      or not vim.bo[bufnr].modifiable
  end

  local function ensure_hl()
    pcall(api.nvim_set_hl, 0, 'ExtraWhitespace', { fg = 'red' })
  end

  local function toggle_trailing(mode)
    local bufnr = api.nvim_get_current_buf()
    if is_invalid_buf(bufnr) or is_floating_win() then return end

    ensure_hl()

    local pattern = mode == 'i' and [[\s\+\%#\@<!$]] or [[\s\+$]]
    if vim.w.whitespace_match_number then
      pcall(fn.matchdelete, vim.w.whitespace_match_number)
      vim.w.whitespace_match_number =
        fn.matchadd('ExtraWhitespace', pattern, 10)
    else
      vim.w.whitespace_match_number = fn.matchadd('ExtraWhitespace', pattern)
    end
  end

  api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = ensure_hl,
  })

  api.nvim_create_autocmd({ 'BufEnter', 'FileType', 'InsertLeave' }, {
    group = group,
    callback = function() toggle_trailing('n') end,
  })

  api.nvim_create_autocmd('InsertEnter', {
    group = group,
    callback = function() toggle_trailing('i') end,
  })
end

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

-- Cursorline only in active window (Folke's pattern)
vim.api.nvim_create_autocmd({ 'InsertLeave', 'WinEnter' }, {
  callback = function()
    if vim.w.auto_cursorline then
      vim.wo.cursorline = true
      vim.w.auto_cursorline = nil
    end
  end,
})
vim.api.nvim_create_autocmd({ 'InsertEnter', 'WinLeave' }, {
  callback = function()
    if vim.wo.cursorline then
      vim.w.auto_cursorline = true
      vim.wo.cursorline = false
    end
  end,
})

-- Copy pyrightconfig.json to git repo root
local function copy_pyrightconfig()
  local buf_path = api.nvim_buf_get_name(api.nvim_get_current_buf())
  if buf_path == '' then return end

  -- Find git root using vim.fs.find (more efficient)
  local git_root_file = vim.fs.find('.git', {
    path = vim.fs.dirname(buf_path),
    upward = true,
  })[1]

  -- If no .git found, skip
  if not git_root_file then return end

  local git_root = vim.fs.dirname(git_root_file)

  -- Source and destination paths
  local source = vim.g.vim_dir .. '/../pyright/pyrightconfig.json'
  local dest = git_root .. '/pyrightconfig.json'

  -- Check if source exists
  if fn.filereadable(source) ~= 1 then return end

  -- Copy file if destination doesn't exist or is different
  local should_copy = false
  if fn.filereadable(dest) ~= 1 then
    should_copy = true
  else
    -- Compare file contents (simple check)
    local source_content = fn.readfile(source)
    local dest_content = fn.readfile(dest)
    if
      table.concat(source_content, '\n') ~= table.concat(dest_content, '\n')
    then
      should_copy = true
    end
  end

  if should_copy then fn.writefile(fn.readfile(source), dest) end
end

augroup('CopyPyrightConfig', {
  event = { 'BufEnter' },
  pattern = { '*.py' },
  command = function()
    -- Only run once per buffer to avoid excessive copying
    if vim.b.pyrightconfig_copied then return end
    vim.b.pyrightconfig_copied = true
    copy_pyrightconfig()
  end,
})

-- }}
