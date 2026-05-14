local augroup = require('tools').augroup

local fn, api, v, cmd = vim.fn, vim.api, vim.v, vim.cmd

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
  local group =
    api.nvim_create_augroup('DisableIndentGuidesInTerminal', { clear = true })

  local function disable(buf)
    if not api.nvim_buf_is_valid(buf) then return end
    vim.b[buf].miniindentscope_disable = true
    vim.b[buf].ibl_disable = true
    vim.b[buf].indent_blankline_enabled = false
  end

  api.nvim_create_autocmd('TermOpen', {
    group = group,
    callback = function(args) disable(args.buf) end,
  })

  api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = { 'toggleterm', 'terminal' },
    callback = function(args) disable(args.buf) end,
  })
end

-- Ensure all terminal windows use the main Normal background (including plugin-created ones).
do
  local group =
    api.nvim_create_augroup('TerminalNormalBackground', { clear = true })

  local function apply_terminal_winhighlight(buf)
    if not api.nvim_buf_is_valid(buf) then return end
    local bt, ft = vim.bo[buf].buftype, vim.bo[buf].filetype
    if bt ~= 'terminal' and ft ~= 'toggleterm' and ft ~= 'terminal' then
      return
    end

    local win = api.nvim_get_current_win()
    if not api.nvim_win_is_valid(win) then return end

    api.nvim_win_call(
      win,
      function()
        vim.opt_local.winhighlight:append({
          Normal = 'Normal',
          NormalNC = 'NormalNC',
          NormalFloat = 'Normal',
        })
      end
    )
  end

  api.nvim_create_autocmd(
    { 'TermOpen', 'BufWinEnter', 'BufEnter', 'WinEnter' },
    {
      group = group,
      callback = function(args)
        vim.schedule(function() apply_terminal_winhighlight(args.buf) end)
      end,
    }
  )

  api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = { 'toggleterm', 'terminal' },
    callback = function(args)
      vim.schedule(function() apply_terminal_winhighlight(args.buf) end)
    end,
  })
end

-- Highlight when yanking (copying) text
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
  vim.cmd('nohlsearch')
end

local function hl_search()
  local col = api.nvim_win_get_cursor(0)[2]
  local curr_line = api.nvim_get_current_line()
  local ok, match = pcall(fn.matchstrpos, curr_line, fn.getreg('/'), 0)
  if not ok then return end
  local _, p_start, p_end = unpack(match)
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
  command = function()
    vim.o.hlsearch = false
    vim.g.macro_recording = 'macro @' .. vim.fn.reg_recording()
    vim.cmd('redrawstatus')
  end,
}, {
  event = 'RecordingLeave',
  command = function()
    vim.o.hlsearch = true
    vim.g.macro_recording = ''
    vim.cmd('redrawstatus')
  end,
})

augroup('UpdateVim', {
  event = { 'FocusLost' },
  pattern = { '*' },
  command = 'silent! wall',
}, {
  event = { 'VimResized' },
  pattern = { '*' },
  command = 'wincmd =',
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
      pcall(cmd.bdelete, { 0, bang = true })
    end
  end

  api.nvim_create_autocmd('QuickFixCmdPost', {
    group = group,
    pattern = '*grep*',
    command = 'cwindow',
  })

  api.nvim_create_autocmd('FileType', {
    group = group,
    callback = function(args)
      local buf = args.buf
      local ft = vim.bo[buf].filetype or ''
      local bt = vim.bo[buf].buftype or ''
      local is_unmapped = fn.hasmapto('q', 'n') == 0
      local eligible = is_unmapped
        or vim.wo.previewwindow
        or ft_matches(ft)
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

  api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = function()
      if fn.winnr('$') == 1 and vim.bo.buftype == 'quickfix' then
        api.nvim_buf_delete(0, { force = true })
      end
    end,
  })

  api.nvim_create_autocmd('QuitPre', {
    group = group,
    nested = true,
    callback = function()
      if vim.bo.filetype ~= 'qf' then
        cmd.lclose({ mods = { silent = true } })
      end
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

    local allow_prefixes = {
      vim.g.personal_directory,
      vim.g.work_directory,
      vim.g.dotfiles,
      vim.g.vim_dir,
      vim.env.HOME,
    }
    for _, p in ipairs(allow_prefixes) do
      if p and startswith(path, p) then
        if p ~= vim.env.HOME then return false end
      end
    end

    if vim.env.VIMRUNTIME and startswith(path, vim.env.VIMRUNTIME) then
      return true
    end

    for _, dir in ipairs(vim.split(vim.o.runtimepath, ',', { plain = true })) do
      if dir ~= '' and startswith(path, dir) then
        if vim.g.vim_dir and startswith(path, vim.g.vim_dir) then
          return false
        end
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

  local function is_floating_win() return fn.win_gettype() == 'popup' end

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

-- Auto create dir when saving a file
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

-- Cursorline only in active window
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

-- Disable statuscolumn/signcolumn/foldcolumn in floating windows and tool panels.
do
  local group =
    vim.api.nvim_create_augroup('DisableColumnsInFloats', { clear = true })

  local no_number_filetypes = {
    'lazy',
    'mason',
    'noice',
    'notify',
    'trouble',
    'aerial',
    'dap-repl',
    'dapui_console',
    'dapui_watches',
    'dapui_stacks',
    'dapui_breakpoints',
    'dapui_scopes',
  }

  local function disable_decoration_columns(win)
    vim.wo[win].statuscolumn = ''
    vim.wo[win].signcolumn = 'no'
    vim.wo[win].foldcolumn = '0'
  end

  vim.api.nvim_create_autocmd('WinEnter', {
    group = group,
    callback = function()
      local win = vim.api.nvim_get_current_win()
      if vim.api.nvim_win_get_config(win).relative ~= '' then
        disable_decoration_columns(win)
      end
    end,
  })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = no_number_filetypes,
    callback = function()
      vim.opt_local.statuscolumn = ''
      vim.opt_local.signcolumn = 'no'
      vim.opt_local.foldcolumn = '0'
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
    end,
  })
end

-- Window dimming: Dim inactive windows for better focus
do
  local group = vim.api.nvim_create_augroup('WindowDimming', { clear = true })

  vim.api.nvim_create_autocmd('WinLeave', {
    group = group,
    callback = function()
      local win_config = vim.api.nvim_win_get_config(0)
      if win_config.relative == '' then
        vim.cmd([[setlocal winhl=CursorLine:CursorLineNC]])
      end
    end,
  })

  vim.api.nvim_create_autocmd('WinEnter', {
    group = group,
    callback = function() vim.cmd([[setlocal winhl=]]) end,
  })
end

-- -----------------------------------------------------------------------------
-- Sidebar panels: strip line numbers and remap highlights to panel groups
-- -----------------------------------------------------------------------------

do
  local sidebar_fts = {
    'undotree',
    'diff',
    'Outline',
    'dbui',
    'neotest-summary',
    'fugitive',
    'AvanteSidebar',
    'AvanteInput',
    'Avante',
    'AvanteSelectedFiles',
  }

  local function on_sidebar_enter()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.winhighlight:append({
      Normal = 'PanelDarkBackground',
      EndOfBuffer = 'PanelDarkBackground',
      SignColumn = 'PanelDarkBackground',
      WinSeparator = 'PanelWinSeparator',
    })
  end

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup(
      'SidebarPanelHighlights',
      { clear = true }
    ),
    pattern = sidebar_fts,
    callback = on_sidebar_enter,
  })
end
