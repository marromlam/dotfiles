if
  not mrl
  or not mrl.ui
  or not mrl.ui.statusline
  or not mrl.ui.statusline.enable
then
  return
end

-- Wait for icons to be available
if not mrl.ui.icons then
  vim.schedule(function()
    if mrl and mrl.ui and mrl.ui.icons then
      dofile(vim.fn.expand('<sfile>:p'))
    end
  end)
  return
end

mrl.ui.statusline = {}

-- LSP clients are collapsed by default: show only 🧩 <count>.
local state = { lsp_clients_visible = false }

local str = require('custom.strings')

local section, spacer, display = str.section, str.spacer, str.display
local icons, lsp, highlight, decorations =
  mrl.ui.icons, mrl.ui.lsp, mrl.highlight, mrl.ui.decorations
local api, fn, fs, fmt, strwidth =
  vim.api, vim.fn, vim.fs, string.format, vim.api.nvim_strwidth
local P, falsy = mrl.ui.palette, mrl.falsy

local sep = package.config:sub(1, 1)
local space = ' '
-------------------------------------------------------------------------------
--  Colors
-------------------------------------------------------------------------------

local function with_win_id(hl)
  return function(id) return hl .. id end
end

local stl_winhl = {
  filename = { hl = with_win_id('StFilename') },
  directory = { hl = with_win_id('StDirectory') },
  parent = { hl = with_win_id('StParentDirectory') },
  readonly = { hl = with_win_id('StError') },
  env = { hl = with_win_id('StEnv') },
}

local identifiers = {
  buftypes = {
    terminal = '',
    quickfix = '',
  },
  filetypes = mrl.p_table({
    ['fzf'] = '󱁴', -- '',
    ['log'] = '',
    ['org'] = '',
    ['orgagenda'] = '',
    ['mail'] = '',
    ['dbui'] = '',
    ['DiffviewFiles'] = '',
    ['tsplayground'] = '󰔱',
    ['Trouble'] = '',
    ['NeogitStatus'] = '', -- '',
    ['fugitive.*'] = '', -- ' ',
    ['norg'] = '',
    ['help'] = '',
    ['octo'] = '',
    ['undotree'] = '󰔱',
    ['NvimTree'] = '󰔱',
    ['neo-tree'] = '󰔱',
    ['neotest.*'] = '',
    ['dapui_.*'] = '',
    ['dap-repl'] = '',
    ['toggleterm'] = '',
    ['Avante.*'] = icons.misc.chat,
  }),
  names = mrl.p_table({
    ['fzf'] = 'FZF',
    ['orgagenda'] = 'Org',
    ['mail'] = 'Mail',
    ['dbui'] = 'Dadbod UI',
    ['tsplayground'] = 'Treesitter',
    ['NeogitStatus'] = 'Neogit Status',
    ['Neogit.*'] = 'Neogit',
    ['fugitive.*'] = 'Git ',
    ['Trouble'] = 'Lsp Trouble',
    ['gitcommit'] = 'Git commit',
    ['help'] = 'help',
    ['undotree'] = 'UndoTree',
    ['NvimTree'] = 'Nvim Tree',
    ['dap-repl'] = 'Debugger REPL',
    ['Diffview.*'] = 'Diff view',
    ['neotest.*'] = 'Testing',
    ['Avante.*'] = 'avante',

    ['log'] = function(fname, _) return fmt('Log(%s)', fs.basename(fname)) end,

    ['dapui_.*'] = function(fname) return fname end,

    ['neo-tree'] = function(fname, _)
      local parts = vim.split(fname, ' ')
      return fmt('Explorer(%s)', parts[2])
    end,
  }),
}

--- @param buf number
--- @param opts { default: boolean }
--- @return string, string?
local function get_buffer_icon(buf, opts)
  local path = api.nvim_buf_get_name(buf)
  if fn.isdirectory(path) == 1 then return '', nil end
  -- Use mini.icons if available (mocks nvim-web-devicons API)
  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if not ok then return '', nil end
  local name, ext = fn.fnamemodify(path, ':t'), fn.fnamemodify(path, ':e')
  return devicons.get_icon(name, ext, opts)
end

local function adopt_window_highlights()
  local curr_winhl = vim.opt_local.winhighlight:get()
  if falsy(curr_winhl) or not curr_winhl.StatusLine then return end

  for _, part in pairs(stl_winhl) do
    local name = part.hl(api.nvim_get_current_win())
    local hl = highlight.get(name)
    if not falsy(hl) then return end
    highlight.set(name, {
      inherit = part.fallback,
      bg = { from = curr_winhl.StatusLine, attr = 'bg' },
    })
  end
end

local function filetype(ctx)
  local ft, bt =
    identifiers.filetypes[ctx.filetype], identifiers.buftypes[ctx.buftype]
  if ft then return ft end
  if bt then return bt end
  return get_buffer_icon(ctx.bufnum, { default = true })
end

-- Terminal buffer labeling ----------------------------------------------------
-- For plain :terminal buffers we want to show the actual running process,
-- not just $SHELL. For Sidekick's tmux-backed terminals, show the active tmux
-- pane's current command.
local function trim(s)
  if type(s) ~= 'string' then return '' end
  return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function sysline(cmd)
  local ok, out = pcall(fn.systemlist, cmd)
  if not ok or not out or not out[1] then return '' end
  return trim(out[1])
end

local function tmux_server_args_from_pid(pid)
  local args = trim(sysline({ 'ps', '-o', 'args=', '-p', tostring(pid) }))
  if args == '' then return {} end
  local server_args = {}
  local sock = args:match('%-S%s+(%S+)')
  local label = args:match('%-L%s+(%S+)')
  if sock then
    server_args[#server_args + 1] = '-S'
    server_args[#server_args + 1] = sock
  elseif label then
    server_args[#server_args + 1] = '-L'
    server_args[#server_args + 1] = label
  end
  return server_args
end

local function tmux_pane_current_command(tmux_args, client_pid)
  tmux_args = tmux_args or {}
  local cmd_base = vim.list_extend({ 'tmux' }, tmux_args)

  -- Match the tmux client that is running inside this terminal by PID.
  local clients = fn.systemlist(vim.list_extend(vim.deepcopy(cmd_base), {
    'list-clients',
    '-F',
    '#{client_pid}\t#{client_name}',
  }))
  if type(clients) ~= 'table' then return '' end

  local name
  for _, line in ipairs(clients) do
    local cpid, cname = line:match('^(%d+)\t([^\t]*)$')
    if cpid and tonumber(cpid) == client_pid then
      name = cname
      break
    end
  end
  -- If we couldn't match by PID, but there is exactly one client, use it.
  if not name and #clients == 1 then
    local _, cname = clients[1]:match('^(%d+)\t([^\t]*)$')
    name = cname
  end
  if not name or name == '' then return '' end

  return sysline(vim.list_extend(vim.deepcopy(cmd_base), {
    'display-message',
    '-p',
    '-t',
    name,
    '#{pane_current_command}',
  }))
end

local function terminal_display_name(buf)
  local cached = vim.b[buf].mrl_term_display
  local now = (vim.uv and vim.uv.now and vim.uv.now()) or 0
  if
    type(cached) == 'table'
    and type(cached.value) == 'string'
    and type(cached.ts) == 'number'
    and now > 0
    and (now - cached.ts) < 1000
  then
    return cached.value
  end

  local job = vim.b[buf].terminal_job_id or vim.bo[buf].channel
  local pid = 0
  do
    local jid = tonumber(job)
    if jid and jid > 0 then
      -- NOTE: jobpid() throws E900 for invalid job ids. Never let statusline error.
      local ok, p = pcall(fn.jobpid, jid)
      if ok and type(p) == 'number' and p > 0 then pid = p end
    end
  end

  local comm = (pid > 0)
      and sysline({ 'ps', '-o', 'comm=', '-p', tostring(pid) })
    or ''

  local value = comm ~= '' and comm or fn.fnamemodify(vim.env.SHELL or '', ':t')

  local is_tmux = (type(value) == 'string' and value:match('^tmux') ~= nil)
  if is_tmux and pid and pid > 0 then
    -- Normalize tmux display name; we will replace with pane command when possible.
    value = 'tmux'
    local tmux_args = tmux_server_args_from_pid(pid)
    local pane_cmd = tmux_pane_current_command(tmux_args, pid)
    if pane_cmd ~= '' then value = pane_cmd end
  end

  vim.b[buf].mrl_term_display = { value = value, ts = now }
  return value
end

--- This function allow me to specify titles for special case buffers
--- like the preview window or a quickfix window
--- CREDIT: https://vi.stackexchange.com/a/18090
local function special_buffers(ctx)
  if ctx.preview then return 'preview' end
  if ctx.buftype == 'quickfix' then return 'Quickfix List' end
  if ctx.filetype == 'AvanteInput' then return 'Avante' end
  if ctx.filetype == 'AvanteSelectedFiles' then return 'Avante' end
  if ctx.filetype == 'Avante' then return 'Avante' end
  -- Many terminal providers (toggleterm, sidekick, etc) set a non-empty filetype,
  -- but they still use `buftype=terminal`. Always use our terminal label.
  if ctx.buftype == 'terminal' then
    return ('Terminal(%s)'):format(terminal_display_name(ctx.bufnum))
  end
  if fn.getloclist(0, { filewinid = 0 }).filewinid > 0 then
    return 'Location List'
  end
  return nil
end

---Only append the path separator if the path is not empty
local function with_sep(path)
  return (not falsy(path) and path:sub(-1) ~= sep) and path .. sep or path
end

--- Replace the directory path with an identifier if it matches a commonly
--- visited directory of mine such as my projects directory or my work directory
--- since almost all my project directories are nested underneath one of these
--- paths this should match often and reduce the unnecessary boilerplate in my
--- path as I know where these directories are generally
---@param directory string
---@return string directory
---@return string custom_dir
local function dir_env(directory)
  if not directory then return '', '' end
  local paths = {
    [vim.g.dotfiles] = '$DOTFILES',
    [vim.g.projects_directory .. '/personal/dotfiles'] = '$DOTFILES',
    [vim.g.work_directory] = '$WORK',
    ['~/Workspaces/work/'] = '$WORK',
    ['/home/marcos/Workspaces/work/'] = '$WORK',
    [vim.env.VIMRUNTIME] = '$VIMRUNTIME',
    [vim.g.projects_directory] = '$PROJECTS',
    ['/home/marcos/Projects/'] = '$WORKSPACES',
    ['/home/marcos/Projects/personal/dotfiles/'] = '$DOTFILES',
    ['~/Projects/personal/dotfiles/'] = '$DOTFILES',
    ['/Users/marcos/Library/Mobile Documents/iCloud~md~obsidian'] = '$OBSIDIAN',
    ['~/Library/Mobile Documents/iCloud~md~obsidian'] = '$OBSIDIAN',
    [vim.env.HOME] = '~',
  }
  local result, env, prev_match = directory, '', ''
  for dir, alias in pairs(paths) do
    local match, count = fs.normalize(directory)
      :gsub(vim.pesc(with_sep(dir)), '')
    if count == 1 and #dir > #prev_match then
      result, env, prev_match = match, alias, dir
    end
  end
  return result, env
end

--- @param ctx StatuslineContext
--- @return {env: string?, dir: string?, parent: string?, fname: string}
local function filename(ctx)
  local buf, ft = ctx.bufnum, ctx.filetype -- luacheck: ignore
  local special_buf = special_buffers(ctx)
  if special_buf then return { fname = special_buf } end

  local path = api.nvim_buf_get_name(buf)
  if falsy(path) then return { fname = '' } end

  local parts = vim.split(path, sep)
  local fname = table.remove(parts)

  local name = identifiers.names[ft]
  if name then
    return { fname = vim.is_callable(name) and name(fname, buf) or name }
  end

  local parent = table.remove(parts)
  fname = fn.isdirectory(fname) == 1 and fname .. sep or fname
  if falsy(parent) then return { fname = fname } end

  local dir = with_sep(table.concat(parts, sep))
  local new_dir, env = dir_env(dir)
  local max_dir_width = math.floor(vim.o.columns / 3)
  if strwidth(env .. new_dir) > max_dir_width then
    new_dir = fn.pathshorten(new_dir)
  end

  return {
    env = with_sep(env),
    dir = with_sep(new_dir),
    parent = with_sep(parent),
    fname = fname,
  }
end

-- Create the various segments of the current filename
local function stl_file(ctx)
  local ft_icon, icon_highlight = filetype(ctx)
  local file_opts = { {}, before = '', after = ' ', priority = 0 }
  local parent_opts = { {}, before = '', after = '', priority = 2 }
  local dir_opts = { {}, before = '', after = '', priority = 3 }
  local env_opts = { {}, before = '', after = '', priority = 4 }

  local p = filename(ctx)

  -- Depending on which filename segments are empty we select a section to add the file icon to
  local env_empty, dir_empty, parent_empty =
    falsy(p.env), falsy(p.dir), falsy(p.parent)
  local to_update = (env_empty and dir_empty and parent_empty) and file_opts
    or (env_empty and dir_empty) and parent_opts
    or env_empty and dir_opts
    or env_opts

  table.insert(to_update[1], { ' ' .. ft_icon .. ' ', 'StTitle' })
  table.insert(env_opts[1], { p.env or '', 'StEnv' })
  table.insert(dir_opts[1], { p.dir or '', 'StDirectory' })
  table.insert(file_opts[1], { p.fname or '', 'StFilename' })
  table.insert(parent_opts[1], { p.parent or '', 'StParent' })
  return {
    env = env_opts,
    file = file_opts,
    dir = dir_opts,
    parent = parent_opts,
  }
end

--- Get navic breadcrumb for statusline
--- @param ctx StatuslineContext
--- @return table?
local function get_navic_breadcrumb(ctx)
  local ok, navic_module = pcall(require, 'custom.navic')
  if not ok then return nil end

  -- Check availability for the buffer we're rendering
  if not navic_module.is_available(ctx.bufnum) then return nil end

  -- navic.get_location() uses current buffer context, so call without bufnr
  -- In statusline render, we're rendering for ctx.bufnum, so we need to be in
  -- that context
  -- But since navic.get_location() doesn't take bufnr, we'll call it directly
  local ok_navic, navic = pcall(require, 'nvim-navic')
  if not ok_navic then return nil end

  local location = navic.get_location()
  if not location or location == '' then return nil end

  -- Extract text identifiers from navic's formatted string
  -- Format: %#NavicIconsFunction#󰊕 %*%#NavicText#test_linear_fit%*
  -- Extract content between # and %*, filter to keep only text identifiers
  local parts = {}
  for content in location:gmatch('%%#[^#]*#([^%%]*)%%%*') do
    if content and content ~= '' then
      local text = content:match('^%s*(.-)%s*$')
      -- Keep only identifier-like text (alphanumeric + underscore, length > 1)
      -- This filters out single-character icons
      if text and text ~= '' and text:match('^[%w_]+$') and #text > 1 then
        table.insert(parts, text)
      end
    end
  end

  if #parts == 0 then return nil end

  -- Join with separator
  local breadcrumb_text = table.concat(parts, ' › ')

  return {
    {
      { '::', 'StFaded' },
      { breadcrumb_text, 'StFaded' },
      { space, 'StSeparator' },
    },
    priority = 4,
  }
end

local function diagnostic_info(context)
  local diagnostics = vim.diagnostic.get(context.bufnum)
  local severities = vim.diagnostic.severity
  local lsp_icons = mrl.ui.icons.lsp
  if vim.tbl_isempty(diagnostics) then
    return {
      error = { count = 0, icon = lsp_icons.error },
      warn = { count = 0, icon = lsp_icons.warn },
      info = { count = 0, icon = lsp_icons.info },
      hint = { count = 0, icon = lsp_icons.hint },
    }
  end

  local result = {
    error = { count = 0, icon = lsp_icons.error },
    warn = { count = 0, icon = lsp_icons.warn },
    info = { count = 0, icon = lsp_icons.info },
    hint = { count = 0, icon = lsp_icons.hint },
  }
  for _, item in ipairs(diagnostics) do
    local severity = severities[item.severity]:lower()
    result[severity].count = result[severity].count + 1
  end
  return result
end

local function debugger()
  return not package.loaded.dap and '' or require('dap').status()
end

--------------------------------------------------------------------------------
-- Last search count {{{
--------------------------------------------------------------------------------

local function search_count()
  local ok, result = pcall(fn.searchcount, { recompute = 1 })
  if not ok then return '' end
  if vim.tbl_isempty(result) then return '' end
  if result.incomplete == 1 then -- timed out
    return ' ?/?? '
  elseif result.incomplete == 2 then -- max count exceeded
    if result.total > result.maxcount and result.current > result.maxcount then
      return fmt(' >%d/>%d ', result.current, result.total)
    elseif result.total > result.maxcount then
      return fmt(' %d/>%d ', result.current, result.total)
    end
  end
  return fmt(' %d/%d ', result.current, result.total)
end

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  LSP Clients
--------------------------------------------------------------------------------

local LSP_COMPONENT_ID = 2000

function mrl.ui.statusline.lsp_client_click()
  state.lsp_clients_visible = not state.lsp_clients_visible
  vim.cmd('redrawstatus')
end

---@param ctx StatuslineContext
---@return boolean, string[]
local function stl_lsp_clients(ctx)
  local clients = vim.lsp.get_clients({ bufnr = ctx.bufnum }) or {}
  if #clients == 0 then return false, {} end

  local has_copilot = false
  local names = {}

  for _, client in ipairs(clients) do
    local name = client.name or ''
    -- Copilot should be displayed independently from other LSPs.
    if name == 'copilot' or name:match('copilot') then
      has_copilot = true
    else
      table.insert(names, name)
    end
  end

  table.sort(names)
  return has_copilot, names
end

--------------------------------------------------------------------------------
--  Git components {{{
--------------------------------------------------------------------------------

---@param interval number
---@param task function
local function run_task_on_interval(interval, task)
  local pending_job
  local timer = vim.uv.new_timer()
  if not timer then return end
  local function callback()
    if pending_job then fn.jobstop(pending_job) end
    pending_job = task()
  end
  local fail = timer:start(0, interval, vim.schedule_wrap(callback))
  if fail ~= 0 then
    vim.schedule(
      function() vim.notify('Failed to start git update job: ' .. fail) end
    )
  end
end

--- Check if in a git repository
---@param win_id number?
---@return boolean
local function is_git_repo(win_id)
  win_id = win_id or api.nvim_get_current_win()
  local cwd = fn.getcwd(win_id)
  return cwd and vim.uv.fs_stat(cwd .. '/.git') ~= nil
end

-- Use git and the native job API to first get the head of the repo
-- check the state of the repo head against the origin copy we have
-- the result format is in the format: `1       0`
-- the first value commits ahead by and the second is commits behind by
local function update_git_status()
  if not is_git_repo() then return end
  local result = {}
  fn.jobstart('git rev-list --count --left-right @{upstream}...HEAD', {
    stdout_buffered = true,
    on_stdout = function(_, data)
      for _, item in ipairs(data) do
        if item and item ~= '' then table.insert(result, item) end
      end
    end,
    on_exit = function(_, code)
      if code == 0 and result[1] then
        local parts = vim.split(result[1], '\t')
        if #parts == 2 then
          vim.g.git_statusline_updates = {
            behind = parts[1],
            ahead = parts[2],
          }
        end
      end
    end,
  })
end

--- starts a timer to check for the whether
--- we are currently ahead or behind upstream
local function git_updates() run_task_on_interval(10000, update_git_status) end

-- }}}
--------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--  Utility functions
----------------------------------------------------------------------------------------------------

local function is_plain(ctx)
  local decor = decorations.get({
    ft = ctx.filetype,
    bt = ctx.buftype,
    setting = 'statusline',
  })
  local is_plain_ft, is_plain_bt = decor.ft == 'minimal', decor.bt == 'minimal'
  return is_plain_ft or is_plain_bt or ctx.preview
end

local function is_modified(ctx, icon)
  return ctx.filetype == 'help' and '' or ctx.modified and (icon or '✎') or ''
end

local function is_readonly(ctx, icon)
  return ctx.readonly and ' ' .. (icon or '') or ''
end

--------------------------------------------------------------------------------
--  RENDER
--------------------------------------------------------------------------------

function mrl.ui.statusline.render()
  local curwin = api.nvim_get_current_win()
  local curbuf = api.nvim_win_get_buf(curwin)

  local available_space = vim.o.columns

  local ctx = {
    bufnum = curbuf,
    win = curwin,
    bufname = api.nvim_buf_get_name(curbuf),
    preview = vim.wo[curwin].previewwindow,
    readonly = vim.bo[curbuf].readonly,
    filetype = vim.bo[curbuf].ft,
    buftype = vim.bo[curbuf].bt,
    modified = vim.bo[curbuf].modified,
    fileformat = vim.bo[curbuf].fileformat,
    shiftwidth = vim.bo[curbuf].shiftwidth,
    expandtab = vim.bo[curbuf].expandtab,
    winhl = vim.wo[curwin].winhl:match('StatusLine') ~= nil,
  }
  ----------------------------------------------------------------------------//
  -- Modifiers
  ----------------------------------------------------------------------------//

  local plain = is_plain(ctx)
  local file_modified = is_modified(ctx, icons.misc.pencil)
  local focused = vim.g.vim_in_focus ~= false

  ----------------------------------------------------------------------------//
  -- Setup
  ----------------------------------------------------------------------------//

  local l1 = section:new({
    {
      -- { '  ' .. vim.g.dev_environ .. '▐', 'StDevEnv' },
      { '' .. vim.g.dev_environ .. '', 'StDevEnv' },
    },
    priority = 1,
    cond = true,
  })

  -- Filename components
  local path = stl_file(ctx)
  local readonly_component =
    { { { is_readonly(ctx), 'StFaded' } }, priority = 1 }
  -- }}}
  --
  --
  ----------------------------------------------------------------------------//
  -- show a minimal statusline with only the mode and file component
  ----------------------------------------------------------------------------//
  if plain or not focused then
    local l2 = section:new(
      readonly_component,
      path.env,
      path.dir,
      path.parent,
      path.file
    )
    return display({ l1 + l2 }, available_space)
  end
  -----------------------------------------------------------------------------//
  -- Variables
  -----------------------------------------------------------------------------//

  local lnum, col = unpack(api.nvim_win_get_cursor(curwin))
  col = col + 1 -- this should be 1-indexed, but isn't by default
  local line_count = api.nvim_buf_line_count(ctx.bufnum)

  --- @type {head: string?, added: integer?, changed: integer?, removed: integer?}
  local status = vim.b[curbuf].gitsigns_status_dict or {}
  local updates = vim.g.git_statusline_updates or {}
  local ahead = updates.ahead and tonumber(updates.ahead) or 0
  local behind = updates.behind and tonumber(updates.behind) or 0

  local lazy_ok, lazy = pcall(require, 'lazy.status')
  local pending_updates = lazy_ok and lazy.updates() or nil
  local has_pending_updates = lazy_ok and lazy.has_updates() or false
  -----------------------------------------------------------------------------//
  -- LSP
  -----------------------------------------------------------------------------//
  local diagnostics = diagnostic_info(ctx)
  local has_copilot, lsp_client_names = stl_lsp_clients(ctx)
  -- Count excludes Copilot (it has its own icon).
  local lsp_client_count = #lsp_client_names
  local lsp_clients = {
    {
      {
        { space, 'StSeparator' },
        has_copilot and { icons.misc.copilot .. space .. space, 'StTitle' }
          or nil,
        { icons.misc.puzzle, 'StTitle' },
        { space, 'StSeparator' },
        { tostring(lsp_client_count), 'StFaded' },
        -- Give Copilot its own breathing room.
        -- has_copilot and { ' ', 'StSeparator' } or { space, 'StSeparator' },
        -- Space before the next right-side segment (git/debugger/etc).
        { space, 'StSeparator' },
      },
      priority = 2,
      id = LSP_COMPONENT_ID,
      click = 'v:lua.mrl.ui.statusline.lsp_client_click',
    },
  }
  if state.lsp_clients_visible and lsp_client_count > 0 then
    table.insert(lsp_clients, {
      {
        { space, 'StSeparator' },
        { table.concat(lsp_client_names, ', '), 'StFaded' },
      },
      -- Lowest priority: keep the count visible if space is tight.
      priority = 9,
    })
  end
  -----------------------------------------------------------------------------//
  -- Left section
  -----------------------------------------------------------------------------//
  local l2 = section:new(
    {
      { { ' ' .. file_modified, 'StFaded' }, { space, 'StSeparator' } },
      cond = ctx.modified,
      priority = 1,
    },
    {
      { { search_count(), 'StSearchCount' } },
      cond = vim.v.hlsearch > 0,
      priority = 1,
    },
    path.env,
    path.dir,
    path.parent,
    path.file,
    get_navic_breadcrumb(ctx),
    {
      {
        { space, 'StSeparator' },
        { diagnostics.warn.icon, 'StWarn' },
        { space, 'StSeparator' },
        { diagnostics.warn.count .. ' ', 'StWarn' },
      },
      cond = diagnostics.warn.count,
      priority = 3,
    },
    {
      {
        { space, 'StSeparator' },
        { diagnostics.error.icon, 'StError' },
        { space, 'StSeparator' },
        { diagnostics.error.count .. ' ', 'StError' },
      },
      cond = diagnostics.error.count,
      priority = 1,
    },
    {
      {
        { space, 'StSeparator' },
        { diagnostics.info.icon, 'StInfo' },
        { space, 'StSeparator' },
        { diagnostics.info.count .. ' ', 'StInfo' },
      },
      cond = diagnostics.info.count,
      priority = 3,
    },
    {
      { { icons.misc.shaded_lock, 'StFaded' } },
      cond = vim.b[ctx.bufnum].formatting_disabled == true
        or vim.g.formatting_disabled == true,
      priority = 5,
    },
    {
      { { space, 'StSeparator' } },
      cond = true,
      priority = 1,
    }
  )
  -----------------------------------------------------------------------------
  -- Middle section {{{
  -----------------------------------------------------------------------------

  local m1 = section:new({
    {
      { vim.g.macro_recording, 'StWarn' },
    },
    priority = 1,
  })

  -- }}}
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Right section
  -----------------------------------------------------------------------------

  local r1 = section:new(
    {
      -- empty space
      { { space, 'StSeparator' } },
      priority = 3,
      cond = true,
    },
    -- neovim package updates
    {
      {
        { space, 'StSeparator' },
        { pending_updates, 'StTitle' },
        { space, 'StSeparator' },
      },
      priority = 3,
      cond = has_pending_updates,
    },
    -- LSP Clients
    unpack(lsp_clients)
  )

  local r2 = section:new(
    {
      {
        { icons.misc.bug },
        { space, 'StSeparator' },
        { debugger(), 'StFaded' },
      },
      priority = 4,
      cond = debugger(),
    },
    -- Git status {{{
    {
      {
        { icons.git.branch, 'StTitle' },
        { space, 'StSeparator' },
        { status.head, 'StBranch' },
        { space, 'StSeparator' },
      },
      priority = 1,
      cond = not falsy(status.head),
    },
    {
      {
        { icons.git.mod, 'StGitModified' },
        { space, 'StGitModified' },
        { status.changed, 'StTitle' },
        { space, 'StSeparator' },
      },
      priority = 5,
      cond = not falsy(status.changed),
    },
    {
      {
        { icons.git.remove, 'StGitDelete' },
        { space, 'StGitDelete' },
        { status.removed, 'StTitle' },
        { space, 'StSeparator' },
      },
      priority = 5,
      cond = not falsy(status.removed),
    },
    {
      {
        { icons.git.add, 'StGitAdd' },
        { space, 'StGitAdd' },
        { status.added, 'StTitle' },
        { space, 'StSeparator' },
      },
      priority = 5,
      cond = not falsy(status.added),
    },
    {
      {
        { icons.misc.up, 'StGitAdd' },
        { space, 'StSeparator' },
        { ahead, 'StTitle' },
      },
      cond = ahead,
      before = '',
      priority = 5,
    },
    {
      {
        { icons.misc.down, 'StGitDelete' },
        { space, 'StSeparator' },
        { behind, 'StTitle' },
      },
      after = ' ',
      cond = behind,
      priority = 5,
    },
    -- }}}
    -- Current position in buffer and percentage {{{
    {
      {
        { space, 'StSeparator' },
        { lnum .. ':' .. col, 'StTitle' },
        { space, 'StSeparator' },
        { fmt('%d', 100 * lnum / line_count) .. '%', 'StFaded' },
        { space, 'StSeparator' },
      },
      priority = 2,
    },
    -- }}}
    -- (Unexpected) Indentation {{{
    {
      {
        { ctx.expandtab and icons.misc.indent or icons.misc.tab, 'StTitle' },
        { space, 'StSeparator' },
        { ctx.shiftwidth, 'StTitle' },
        { space, 'StSeparator' },
      },
      cond = ctx.shiftwidth > 2 or not ctx.expandtab,
      priority = 6,
    }
    -- }}}
    -- Space after {{{
    -- { { { space, 'StSeparator' } }, priority = 1 }
    -- }}}
  )
  -- removes 5 columns to add some padding
  return display({ l1 + l2, m1, r1 + r2 }, available_space - 5)
end

-- :h qf.vim, disable qf statusline
vim.g.qf_disable_statusline = 1

-- set the statusline
vim.o.statusline = '%{%v:lua.mrl.ui.statusline.render()%}'

-- Helper to safely call augroup
local function augroup(name, ...)
  local args = { ... }
  if mrl and mrl.augroup then
    return mrl.augroup(name, unpack(args))
  else
    vim.schedule(function()
      if mrl and mrl.augroup then mrl.augroup(name, unpack(args)) end
    end)
  end
end

augroup('CustomStatusline', {
  event = 'FocusGained',
  command = function() vim.g.vim_in_focus = true end,
}, {
  event = 'FocusLost',
  command = function() vim.g.vim_in_focus = false end,
}, {
  event = 'WinEnter',
  command = adopt_window_highlights,
}, {
  event = 'BufReadPre',
  once = true,
  command = git_updates,
}, {
  event = 'User',
  pattern = {
    'NeogitPushComplete',
    'NeogitCommitComplete',
    'NeogitStatusRefresh',
  },
  command = update_git_status,
})

-- vim: fdm=marker
