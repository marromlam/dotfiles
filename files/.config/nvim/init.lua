-- Init lua

-- Enable vim.loader for faster startup (Folke's pattern)
if vim.loader then vim.loader.enable() end

vim.g.os = vim.loop.os_uname().sysname
vim.g.open_command = vim.g.os == 'Darwin' and 'open' or 'xdg-open'
vim.g.dev_environ = ''

vim.g.dotfiles = vim.env.DOTFILES or vim.fn.expand('~/.dotfiles')
vim.g.vim_dir = vim.g.dotfiles .. '/.config/nvim'

-- vim.g.projects_directory = vim.fn.expand('~/Projects')
vim.g.projects_directory = vim.fn.expand('~/Workspaces/')
vim.g.personal_directory = vim.g.projects_directory .. 'personal/'
vim.g.work_directory = vim.g.projects_directory .. 'work/'

vim.g.icloud = vim.fn.expand('~') .. '/Library/Mobile Documents'
vim.g.obsidian = vim.g.icloud .. '/iCloud~md~obsidian/Documents/Marcos'

-- Leader bindings
vim.g.mapleader = ' ' -- Remap leader key
vim.g.maplocalleader = '\\' -- Local leader is <Space>

-- database
vim.g.db_ui_use_nerd_fonts = 1

-------------------------------------------------------------------------------
-- Tools {{{                                                     lua/tools.lua
-------------------------------------------------------------------------------

local fn, api, cmd, fmt = vim.fn, vim.api, vim.cmd, string.format

local T = {}
_G.T = T -- expose for ftplugins and after/ scripts

-- User commands
function T.command(name, rhs, opts)
  api.nvim_create_user_command(name, rhs, opts or {})
end

-- Autocommand group: T.augroup('Name', { event=..., pattern=..., command=fn }, ...)
do
  local autocmd_keys = {
    'event',
    'buffer',
    'pattern',
    'desc',
    'command',
    'group',
    'once',
    'nested',
  }
  function T.augroup(name, ...)
    local commands = { ... }
    assert(name ~= 'User', 'augroup name cannot be User')
    assert(#commands > 0, fmt('augroup %s needs at least one autocmd', name))
    local id = api.nvim_create_augroup(name, { clear = true })
    for _, autocmd in ipairs(commands) do
      local bad = {}
      for k in pairs(autocmd) do
        if not vim.tbl_contains(autocmd_keys, k) then bad[#bad + 1] = k end
      end
      if #bad > 0 then
        vim.schedule(
          function()
            vim.notify(
              'Unknown keys: ' .. table.concat(bad, ', '),
              vim.log.levels.ERROR,
              { title = fmt('Autocmd: %s', name) }
            )
          end
        )
      end
      local is_fn = type(autocmd.command) == 'function'
      api.nvim_create_autocmd(autocmd.event, {
        group = name,
        pattern = autocmd.pattern,
        desc = autocmd.desc,
        callback = is_fn and autocmd.command or nil,
        command = not is_fn and autocmd.command or nil,
        once = autocmd.once,
        nested = autocmd.nested,
        buffer = autocmd.buffer,
      })
    end
    return id
  end
end

-- Falsy check (nil, false, '', 0, {})
function T.falsy(item)
  if not item then return true end
  local t = type(item)
  if t == 'boolean' then return not item end
  if t == 'string' then return item == '' end
  if t == 'number' then return item <= 0 end
  if t == 'table' then return vim.tbl_isempty(item) end
  return false
end

function T.foreach(callback, list)
  for k, v in pairs(list) do
    callback(v, k)
  end
end

function T.fold(callback, list, accum)
  accum = accum or {}
  for k, v in pairs(list) do
    accum = callback(accum, v, k)
    assert(accum ~= nil, 'accumulator must be returned on each iteration')
  end
  return accum
end

function T.map(callback, list)
  return T.fold(function(acc, v, k)
    acc[#acc + 1] = callback(v, k, acc)
    return acc
  end, list, {})
end

-- Pattern-aware membership: T.any('foo.lua', {'%.lua$', '%.vim$'})
function T.any(target, list)
  for _, item in ipairs(list) do
    if target:match(item) then return true end
  end
  return false
end

function T.find(matcher, haystack)
  for _, needle in ipairs(haystack) do
    if matcher(needle) then return needle end
  end
end

function T.adjust_split_height(min, max)
  local lines = math.max(min, math.min(max, vim.fn.line('$')))
  vim.cmd('resize ' .. lines)
end

-- Table with pattern-fallback __index
function T.p_table(map)
  return setmetatable(map, {
    __index = function(tbl, key)
      if not key then return end
      for k, v in pairs(tbl) do
        if key:match(k) then return v end
      end
    end,
  })
end

-- pcall that notifies on error via vim.notify
function T.pcall(msg, func, ...)
  local args = { ... }
  if type(msg) == 'function' then
    local arg = func
    args, func, msg = { arg, unpack(args) }, msg, nil
  end
  return xpcall(func, function(err)
    msg = debug.traceback(
      msg and fmt('%s:\n%s\n%s', msg, vim.inspect(args), err) or err
    )
    vim.schedule(
      function() vim.notify(msg, vim.log.levels.ERROR, { title = 'ERROR' }) end
    )
  end, unpack(args))
end

-- Display-width-aware truncation
function T.truncate(str, max_len)
  assert(str and max_len, 'truncate: string and max_len required')
  return api.nvim_strwidth(str) > max_len and str:sub(1, max_len) .. '…'
    or str
end

-- Highlight group as hex strings
function T.get_hi(name)
  local hi = api.nvim_get_hl(0, { name = name })
  for k, v in pairs(hi) do
    if type(v) == 'number' then hi[k] = ('#%06x'):format(v) end
  end
  return hi
end

-- Brighten (+) or darken (-) a hex color by a percentage
function T.tint(color, percent)
  assert(color and percent, 'tint: color and percent required')
  local r = tonumber(color:sub(2, 3), 16)
  local g = tonumber(color:sub(4, 5), 16)
  local b = tonumber(color:sub(6, 7), 16)
  if not r or not g or not b then return 'NONE' end
  local function blend(c)
    return math.min(math.max(math.floor(c * (1 + percent)), 0), 255)
  end
  return fmt('#%02x%02x%02x', blend(r), blend(g), blend(b))
end

-- Blend two hex colors; alpha=0 → bg, alpha=1 → fg
function T.blend(bg, fg, alpha)
  assert(bg and fg and alpha ~= nil, 'blend: bg, fg, alpha required')
  if type(bg) ~= 'string' or type(fg) ~= 'string' then return 'NONE' end
  if not bg:match('^#%x%x%x%x%x%x$') or not fg:match('^#%x%x%x%x%x%x$') then
    return 'NONE'
  end
  alpha = math.min(math.max(alpha, 0), 1)
  local br, bg2, bb =
    tonumber(bg:sub(2, 3), 16),
    tonumber(bg:sub(4, 5), 16),
    tonumber(bg:sub(6, 7), 16)
  local fr, fg2, fb =
    tonumber(fg:sub(2, 3), 16),
    tonumber(fg:sub(4, 5), 16),
    tonumber(fg:sub(6, 7), 16)
  if not br or not bg2 or not bb or not fr or not fg2 or not fb then
    return 'NONE'
  end
  local function mix(b, f) return math.floor((1 - alpha) * b + alpha * f + 0.5) end
  return fmt('#%02x%02x%02x', mix(br, fr), mix(bg2, fg2), mix(bb, fb))
end

-- Icons {{{

local _icons = {
  separators = {
    left_thin_block = '▏',
    right_thin_block = '▕',
    vert_bottom_half_block = '▄',
    vert_top_half_block = '▀',
    right_block = '🮉',
    light_shade_block = '░',
    right_chubby_block = '▓',
  },
  scrollbar = '█',
  lsp = {
    error = '',
    warn = '',
    info = '󰋼',
    hint = '󰌵',
  },
  git = {
    add = '',
    mod = '',
    remove = '',
    ignore = '',
    rename = '',
    untracked = '',
    ignored = '',
    unstaged = '',
    staged = '',
    conflict = '',
    diff = '',
    repo = '',
    logo = '󰊢',
    branch = '',
  },
  documents = {
    file = '',
    files = '',
    folder = '',
    open_folder = '',
  },
  misc = {
    plus = '',
    ellipsis = '…',
    up = '⇡',
    down = '⇣',
    line = '',
    indent = 'Ξ',
    tab = '⇥',
    bug = '',
    question = '',
    bell = '󰂚',
    clock = '󰥔',
    cmd = '⌘',
    lock = '',
    shaded_lock = '',
    circle = '',
    project = '',
    dashboard = '',
    history = '󰄉',
    comment = '󰅺',
    robot = '󰚩',
    copilot = '',
    lightbulb = '󰌵',
    search = '󰍉',
    code = '',
    telescope = '',
    gear = '',
    chat = '󰭻',
    package = '',
    list = '',
    sign_in = '',
    check = '󰄬',
    fire = '󰈸',
    note = '󰎞',
    bookmark = '',
    pencil = '󰏫',
    tools = '',
    arrow_right = '',
    caret_right = '',
    chevron_right = '',
    double_chevron_right = '»',
    table = '󰓫',
    calendar = '󰃭',
    block = '▏',
    clippy = '󰅏',
    puzzle = '',
    settings = '⚙',
    key = '',
    config = '',
    box = '',
    moon = '󰤄',
    source = '󰈙',
    sleep = '󰒲',
    rocket = '',
    task = '󰐃',
    runtime = '',
  },
}

-- }}}

-- }}}
-------------------------------------------------------------------------------

-- Highlights {{{

local function _stl_hl()
  -- Undercurl for diagnostics (must set sp= for the curl colour)
  api.nvim_set_hl(
    0,
    'DiagnosticUnderlineError',
    { undercurl = true, sp = T.get_hi('DiagnosticError').fg }
  )
  api.nvim_set_hl(
    0,
    'DiagnosticUnderlineWarn',
    { undercurl = true, sp = T.get_hi('DiagnosticWarn').fg }
  )
  api.nvim_set_hl(
    0,
    'DiagnosticUnderlineInfo',
    { undercurl = true, sp = T.get_hi('DiagnosticInfo').fg }
  )
  api.nvim_set_hl(
    0,
    'DiagnosticUnderlineHint',
    { undercurl = true, sp = T.get_hi('DiagnosticHint').fg }
  )

  local stl_bg = T.get_hi('StatusLine').bg or 'NONE'
  local function stl(name, opts)
    opts.bg = opts.bg or stl_bg
    api.nvim_set_hl(0, name, opts)
  end
  stl('StSeparator', { fg = 'NONE', bg = 'NONE' })
  stl('StTitle', { fg = T.get_hi('Normal').fg })
  stl('StFaded', { fg = T.get_hi('Comment').fg })
  stl('StFilename', { fg = T.get_hi('Normal').fg, bold = true })
  stl('StDirectory', { fg = T.get_hi('Comment').fg, italic = true })
  stl('StParent', { fg = T.get_hi('DiagnosticWarn').fg, italic = true })
  stl(
    'StEnv',
    { fg = T.get_hi('DiagnosticError').fg, bold = true, italic = true }
  )
  stl('StBranch', { fg = T.get_hi('DiagnosticInfo').fg })
  stl('StGitAdd', { fg = T.get_hi('GitSignsAdd').fg })
  stl('StGitDelete', { fg = T.get_hi('GitSignsDelete').fg })
  stl('StGitModified', { fg = T.get_hi('DiagnosticWarn').fg })
  stl('StInfo', { fg = T.get_hi('DiagnosticInfo').fg })
  stl('StWarn', { fg = T.get_hi('DiagnosticWarn').fg })
  stl('StError', { fg = T.get_hi('DiagnosticError').fg })
  stl(
    'StDevEnv',
    { fg = T.get_hi('StatusLine').bg, bg = T.get_hi('Comment').fg }
  )
  api.nvim_set_hl(0, 'StSearchCount', {
    fg = T.get_hi('Normal').bg,
    bg = T.get_hi('Normal').fg,
  })
  api.nvim_set_hl(
    0,
    'CursorLineNr',
    { fg = T.get_hi('CursorLineNr').fg, bold = true }
  )
  api.nvim_set_hl(0, 'StatusColGitAdd', { fg = T.get_hi('GitSignsAdd').fg })
  api.nvim_set_hl(
    0,
    'StatusColGitChange',
    { fg = T.get_hi('GitSignsChange').fg }
  )
  api.nvim_set_hl(
    0,
    'StatusColGitDelete',
    { fg = T.get_hi('GitSignsDelete').fg }
  )
  api.nvim_set_hl(
    0,
    'StatusColGitUntracked',
    { fg = T.get_hi('DiagnosticWarn').fg }
  )
  api.nvim_set_hl(0, 'StatusColGitNone', { fg = T.get_hi('Comment').fg })
  -- Build a named palette from the ANSI 16-color terminal slots.
  -- Index semantics are fixed by convention; every colorscheme that sets terminal_colors honors them.
  local palette = {
    { 'black',         0  }, { 'red',           1  },
    { 'green',         2  }, { 'yellow',        3  },
    { 'blue',          4  }, { 'purple',        5  },
    { 'cyan',          6  }, { 'white',         7  },
    { 'bright_black',  8  }, { 'bright_red',    9  },
    { 'bright_green',  10 }, { 'bright_yellow', 11 },
    { 'bright_blue',   12 }, { 'bright_purple', 13 },
    { 'bright_cyan',   14 }, { 'bright_white',  15 },
  }
  for _, p in ipairs(palette) do
    local fg = vim.g['terminal_color_' .. p[2]]
    if fg then api.nvim_set_hl(0, p[1], { fg = fg }) end
  end
  -- Rainbow delimiters pull from the palette by hue name.
  local rd_map = {
    { 'RainbowDelimiterViolet', 'purple'       },
    { 'RainbowDelimiterBlue',   'blue'         },
    { 'RainbowDelimiterCyan',   'cyan'         },
    { 'RainbowDelimiterGreen',  'green'        },
    { 'RainbowDelimiterYellow', 'yellow'       },
    { 'RainbowDelimiterOrange', 'bright_yellow'},
    { 'RainbowDelimiterRed',    'red'          },
  }
  for _, pair in ipairs(rd_map) do
    api.nvim_set_hl(0, pair[1], { link = pair[2] })
  end
end

T.augroup('StlHighlights', {
  event = 'ColorScheme',
  command = _stl_hl,
}, {
  event = 'VimEnter',
  once = true,
  command = _stl_hl,
})

-- }}}

-- Statuscolumn {{{
do
  local function _hl(group, text)
    if not group or group == '' then return text end
    return ('%%#%s#%s%%*'):format(group, text)
  end

  local _fcs = vim.opt.fillchars:get()
  T.augroup('StatusColFillchars', {
    event = 'OptionSet',
    pattern = 'fillchars',
    command = function() _fcs = vim.opt.fillchars:get() end,
  })

  local function get_signs(buf, lnum0)
    return api.nvim_buf_get_extmarks(
      buf,
      -1,
      { lnum0, 0 },
      { lnum0, -1 },
      { details = true, type = 'sign' }
    )
  end

  local _git_hl = {
    Add = 'StatusColGitAdd',
    Change = 'StatusColGitChange',
    Changedelete = 'StatusColGitChange',
    Delete = 'StatusColGitDelete',
    Topdelete = 'StatusColGitDelete',
    Untracked = 'StatusColGitUntracked',
  }

  local _git_bar_thick = _icons.separators.right_block .. ' '
  local _git_bar_thin = _icons.separators.right_thin_block .. ' '

  local function git_col(signs)
    for _, m in ipairs(signs) do
      local hlg = (m[4] or {}).sign_hl_group or ''
      if hlg:match('^GitSigns') then
        for key, grp in pairs(_git_hl) do
          if hlg:match(key) then return _hl(grp, _git_bar_thick) end
        end
        return _hl('StatusColGitChange', _git_bar_thick)
      end
    end
    return _hl('StatusColGitNone', _git_bar_thin)
  end

  local function diag_col(signs, cursor_lnum, lnum)
    if lnum == cursor_lnum then return ' ' end
    -- Fold header: show fold icon in this cell instead of diagnostic sign.
    if fn.foldlevel(lnum) > fn.foldlevel(lnum - 1) then
      local icon = fn.foldclosed(lnum) == -1 and (_fcs.foldopen or '▾') or (_fcs.foldclose or '▸')
      return _hl('FoldColumn', icon)
    end
    local best_text, best_hl, best_sev = '', nil, 99
    for _, m in ipairs(signs) do
      local hlg = (m[4] or {}).sign_hl_group or ''
      if hlg:match('^DiagnosticSign') then
        local sev = hlg:match('Error') and 1 or hlg:match('Warn') and 2 or nil
        if sev and sev < best_sev then
          best_text = sev == 1 and _icons.lsp.error or _icons.lsp.warn
          best_hl, best_sev = hlg, sev
        end
      end
    end
    return best_text == '' and ' ' or _hl(best_hl, best_text)
  end

  local function render()
    local win = tonumber(vim.g.statusline_winid) or api.nvim_get_current_win()
    local buf = api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype ~= '' then return '' end

    local lnum, relnum, virtnum = vim.v.lnum, vim.v.relnum, vim.v.virtnum
    local cursor_lnum = api.nvim_win_get_cursor(win)[1]
    local w =
      math.max(api.nvim_strwidth(tostring(api.nvim_buf_line_count(buf))), 3)

    local num_str
    if virtnum ~= 0 then
      num_str = (' '):rep(w - 1) .. _icons.separators.light_shade_block
    else
      local n = tostring(
        (vim.wo[win].relativenumber and relnum ~= 0) and relnum or lnum
      )
      num_str = (' '):rep(w - #n) .. n
    end

    local lnum0 = lnum - 1
    local signs = get_signs(buf, lnum0)
    local is_cursor = (lnum == cursor_lnum and virtnum == 0)
    local num_hl = is_cursor and 'CursorLineNr' or 'LineNr'
    local parts = table.concat({
      diag_col(signs, cursor_lnum, lnum),
      _hl(num_hl, num_str),
      git_col(signs),
    })
    return is_cursor and ('%%#CursorLine#%s%%*'):format(parts) or parts
  end

  _G._stlcol = render
  vim.o.statuscolumn = '%{%v:lua._stlcol()%}'

  T.augroup('StatusColumn', {
    event = { 'BufEnter', 'FileType' },
    command = function()
      local win = api.nvim_get_current_win()
      local buf = api.nvim_win_get_buf(win)
      if
        vim.bo[buf].buftype == 'terminal'
        or (vim.wo[win].winhl or ''):match('FzfLua')
      then
        vim.wo[win].statuscolumn = ''
        vim.wo[win].signcolumn = 'no'
      end
    end,
  })
end
-- }}}

-- Options {{{
-- Suppress deprecation warnings from plugins (e.g. client.notify)
vim.deprecate = function() end

-- Make all keymaps silent by default (Folke's pattern)
local keymap_set = vim.keymap.set
vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  return keymap_set(mode, lhs, rhs, opts)
end

-- Disable unused providers (Folke's pattern)
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Message output on vim actions {{{
vim.opt.shortmess = {
  t = true, -- truncate file messages at start
  A = true, -- ignore annoying swap file messages
  o = true, -- file-read message overwrites previous
  O = true, -- file-read message overwrites previous
  T = true, -- truncate non-file messages in middle
  f = true, -- (file x of x) instead of just (x of x
  F = true, -- Don't give file info when editing, NOTE: this breaks autocommand messages
  s = true,
  c = true,
  W = true, -- Don't show [w] or written when writing
}
vim.o.background = 'dark' -- or "light"
-- }}}

-- Timings {{{
vim.opt.updatetime = 1000 -- Increased from 500 to reduce CursorHold frequency (improves scrolling perf)
vim.opt.timeout = true
vim.opt.timeoutlen = 500
-- }}}

-- Window splitting and buffers {{{

vim.opt.splitkeep = 'screen'
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.eadirection = 'hor'
-- exclude usetab pde we do not want to jump to buffers in already open tabs
--- do not use split or vsplit to ensure we don't open any new windows
vim.opt.switchbuf = 'useopen,uselast'
vim.opt.fillchars = {
  eob = ' ', -- suppress ~ at EndOfBuffer
  diff = '╱', -- alternatives = ⣿ ░ ─
  msgsep = ' ', -- alternatives: ‾ ─
  fold = ' ',
  foldopen = '▽', -- '▼'
  foldclose = '▷', -- '▶'
  foldsep = 's',
}

-- do not show tabline
vim.opt.showtabline = 0

vim.opt.nu = true
vim.opt.relativenumber = true

-- }}}

-- Diff {{{
-- Use in vertical diff mode, blank lines to keep sides aligned, Ignore
-- whitespace changes
vim.opt.diffopt = vim.opt.diffopt
  + {
    'vertical',
    'iwhite',
    'hiddenoff',
    'foldcolumn:0',
    'context:4',
    'algorithm:myers',
    'indent-heuristic',
    'linematch:60',
  }
if vim.fn.has('nvim-0.12') == 1 then
  vim.cmd([[
  set diffopt+=inline:char
  ]])
end
-- }}}

-- Format Options {{{

vim.opt.formatoptions = {
  ['1'] = true,
  ['2'] = true, -- Use indent from 2nd line of a paragraph
  q = true, -- continue comments with gq"
  c = true, -- Auto-wrap comments using textwidth
  r = true, -- Continue comments when pressing Enter
  n = true, -- Recognize numbered lists
  t = false, -- autowrap lines using text width value
  j = true, -- remove a comment leader when joining lines.
  -- Only break if the line was not longer than 'textwidth' when the insert
  -- started and only at a white character that has been entered during the
  -- current insert command.
  l = true,
  v = true,
}

-- }}}

-- Folds {{{
-- unfortunately folding in (n)vim is a mess, if you set the fold level to start
-- at X then it will auto fold anything at that level, all good so far. If you then
-- try to edit the content of your fold and the foldmethod=manual then it will
-- recompute the fold which when using nvim-ufo means it will be closed again...

vim.opt.foldlevelstart = 999

-- Grepprg
vim.opt.grepprg = [[rg --glob "!.git" --no-heading --vimgrep --follow $*]]
vim.opt.grepformat = vim.opt.grepformat ^ { '%f:%l:%c:%m' }

-- Display
vim.opt.conceallevel = 2
vim.opt.breakindent = true
vim.opt.breakindentopt = 'sbr'
vim.opt.linebreak = true -- lines wrap at words rather than random characters
-- If we render signs inside `statuscolumn`, disable the built-in signcolumn to
-- avoid duplicated icons.
vim.opt.signcolumn = 'no' -- statuscolumn.lua manages signs
vim.opt.ruler = false
vim.opt.cmdheight = 0
vim.opt.showbreak = [[↪ ]] -- Options include -> '…', '↳ ', '→','↪ '

-- List chars
vim.opt.list = true -- invisible chars
vim.opt.listchars = {
  eol = nil,
  extends = '…', -- Alternatives: … » ›
  precedes = '░', -- Alternatives: … « ‹
  tab = '» ',
  trail = '·',
  nbsp = '␣',
}

-- Indentation
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.wrapmargin = 8
vim.opt.textwidth = 80
vim.opt.autoindent = true
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.opt.pumheight = 15
vim.opt.confirm = true -- make vim prompt me to save before doing destructive things
vim.opt.completeopt = { 'menuone', 'noselect' }
vim.opt.hlsearch = true
vim.opt.autowriteall = true -- automatically :write before running commands and changing files
-- Defer clipboard setup to avoid startup cost from provider discovery.
vim.schedule(function() vim.opt.clipboard = { 'unnamedplus' } end)
vim.o.laststatus = 3
vim.o.termguicolors = true
vim.o.guifont = 'CartographCF Nerd Font Mono:h14,codicon'
vim.opt.inccommand = 'split'
vim.g.have_nerd_font = true

-- Emoji
vim.opt.emoji = false

-- Cursor
vim.opt.guicursor = {
  'n-v-c-sm:block-Cursor',
  'i-ci-ve:ver25-iCursor',
  'r-cr-o:hor20-Cursor',
  'a:blinkon0',
}
vim.opt.cursorline = true
vim.opt.cursorlineopt = { 'both', 'number' }

-- Title
vim.opt.title = true
vim.opt.titlelen = 70

-- Utilities
vim.opt.showmode = false
vim.opt.sessionoptions = {
  'globals',
  'buffers',
  'curdir',
  'winpos',
  'winsize',
  'help',
  'tabpages',
  'terminal',
}
vim.opt.viewoptions = { 'cursor', 'folds' } -- save/restore just these (with `:{mk,load}view`)
vim.opt.virtualedit = 'block' -- allow cursor to move where there is no text in visual block mode

-- Jumplist
vim.opt.jumpoptions = { 'stack' } -- make the jumplist behave like a browser stack

-- Backup and swaps
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('state') .. '/undo'
vim.opt.swapfile = false

-- Match and search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true -- Searches wrap around the end of the file
vim.opt.scrolloff = 9
vim.opt.sidescrolloff = 10
vim.opt.sidescroll = 1

-- }}}

-- Spelling {{{

vim.opt.spellsuggest:prepend({ 12 })
vim.opt.spelloptions:append({ 'camel', 'noplainbuffer' })
vim.opt.spellcapcheck = '' -- don't check for capital letters at start of sentence

-- }}}

-- Mouse {{{

vim.opt.mouse = 'a'
vim.opt.mousefocus = true
vim.opt.mousemoveevent = true
vim.opt.mousescroll = 'ver:1,hor:4'

-- }}}

-- Netrw {{{

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- }}}

-- vim.opt.isfname:append('@-@')

-- Diagnostics
local _S = vim.diagnostic.severity
vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = false,
  float = { border = 'rounded' },
  signs = {
    severity = { min = _S.WARN },
    text = {
      [_S.ERROR] = _icons.lsp.error,
      [_S.WARN] = _icons.lsp.warn,
      [_S.INFO] = _icons.lsp.info,
      [_S.HINT] = _icons.lsp.hint,
    },
  },
})

-- }}}

-- Filetypes {{{

vim.filetype.add({
  extension = {
    lock = 'yaml',
    scpt = 'applescript',
    applescript = 'applescript',
  },
  filename = {
    ['.psqlrc'] = 'conf',
    ['launch.json'] = 'jsonc',
    Podfile = 'ruby',
    Brewfile = 'ruby',
    Snakefile = 'snakemake',
  },
  pattern = {
    ['.*%.map'] = 'xml',
    ['.*%.cnk'] = 'xml',
    ['.*%.avsc'] = 'json',
    ['.*%.avro'] = 'json',
    ['.*%.conf'] = 'conf',
    ['.*%.theme'] = 'conf',
    ['.*%.gradle'] = 'groovy',
    ['^.env%..*'] = 'bash',
  },
})

-- }}}

-------------------------------------------------------------------------------
-- Plugin add {{{                                           lua/packloader.lua
-------------------------------------------------------------------------------

-- Dev plugins {{{
local _sailor_dev = '/Users/marcos/Workspaces/personal/sailor.vim'
if vim.uv.fs_stat(_sailor_dev) then
  vim.opt.runtimepath:prepend(_sailor_dev)
  vim.cmd('source ' .. _sailor_dev .. '/plugin/sailor.lua')
else
  vim.pack.add({ 'https://github.com/marromlam/sailor.vim' })
end
-- }}}

-- Rainbow delimiters config must be set before vim.pack.add loads the plugin
vim.g.rainbow_delimiters = {
  highlight = {
    'RainbowDelimiterRed',
    'RainbowDelimiterYellow',
    'RainbowDelimiterBlue',
    'RainbowDelimiterOrange',
    'RainbowDelimiterGreen',
    'RainbowDelimiterViolet',
    'RainbowDelimiterCyan',
  },
}

-- General plugins {{{
vim.pack.add({
  -- Colorschemes
  'https://github.com/folke/tokyonight.nvim',

  -- LSP
  -- 'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  -- 'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/j-hui/fidget.nvim',
  -- 'https://github.com/folke/lazydev.nvim',
  -- 'https://github.com/stevanmilic/nvim-lspimport',
  -- 'https://github.com/simrat39/symbols-outline.nvim',
  'https://github.com/rachartier/tiny-inline-diagnostic.nvim',
  'https://github.com/iamkarasik/sonarqube.nvim',
  'https://github.com/kosayoda/nvim-lightbulb',
  -- 'https://github.com/DNLHC/glance.nvim',
  'https://github.com/smjonas/inc-rename.nvim',

  -- Completion {{{
  'https://github.com/saghen/blink.lib',
  'https://github.com/saghen/blink.cmp',
  'https://github.com/rafamadriz/friendly-snippets',
  'https://github.com/onsails/lspkind.nvim',
  -- }}}
  -- 'https://github.com/MeanderingProgrammer/render-markdown.nvim',

  -- Treesitter
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
  -- 'https://github.com/JoosepAlviste/nvim-ts-context-commentstring',
  -- 'https://github.com/Wansmer/treesj',
  -- 'https://github.com/windwp/nvim-ts-autotag',

  -- Fuzzy finder
  'https://github.com/ibhagwan/fzf-lua',

  -- Git
  'https://github.com/lewis6991/gitsigns.nvim',
  -- 'https://github.com/ruifm/gitlinker.nvim',
  -- 'https://github.com/akinsho/git-conflict.nvim',
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/sindrets/diffview.nvim',
  -- 'https://github.com/isakbm/gitgraph.nvim',
  -- 'https://github.com/ThePrimeagen/git-worktree.nvim',

  -- UI
  -- 'https://github.com/akinsho/bufferline.nvim',
  'https://github.com/lukas-reineke/indent-blankline.nvim',
  'https://github.com/SmiteshP/nvim-navic',
  'https://github.com/nvim-tree/nvim-web-devicons',
  -- 'https://github.com/b0o/incline.nvim',
  -- 'https://github.com/uga-rosa/ccc.nvim',
  -- 'https://github.com/Wansmer/symbol-usage.nvim',
  'https://github.com/mbbill/undotree',
  -- 'https://github.com/nacro90/numb.nvim',
  'https://github.com/HiPhish/rainbow-delimiters.nvim',

  -- Noice
  -- 'https://github.com/folke/noice.nvim',
  -- 'https://github.com/MunifTanjim/nui.nvim',

  -- Format / Lint {{{
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/mfussenegger/nvim-lint',
  -- }}}

  -- Debug
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  -- 'https://github.com/jay-babu/mason-nvim-dap.nvim',
  -- 'https://github.com/leoluz/nvim-dap-go',

  -- Testing
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-neotest/neotest',
  -- 'https://github.com/rcarriga/neotest-plenary',
  'https://github.com/nvim-neotest/neotest-python',

  -- Navigation
  'https://github.com/stevearc/oil.nvim',
  -- 'https://github.com/cbochs/grapple.nvim',

  -- Terminal
  -- 'https://github.com/akinsho/toggleterm.nvim',

  -- Copilot / AI {{{
  'https://github.com/zbirenbaum/copilot.lua',
  'https://github.com/folke/sidekick.nvim',
  -- }}}

  -- Database
  -- 'https://github.com/tpope/vim-dadbod',
  -- 'https://github.com/kristijanhusak/vim-dadbod-ui',
  -- 'https://github.com/kristijanhusak/vim-dadbod-completion',

  -- Todo / Folke
  -- 'https://github.com/folke/todo-comments.nvim',
  -- 'https://github.com/folke/trouble.nvim',

  -- Whichkey
  'https://github.com/folke/which-key.nvim',

  -- Comment
  -- 'https://github.com/numToStr/Comment.nvim',

  -- Obsidian
  -- 'https://github.com/epwalsh/obsidian.nvim',

  -- REPL (loaded conditionally below)

  -- Remote / containers
  -- 'https://codeberg.org/esensar/nvim-dev-container',

  -- Filetype support {{{
  'https://github.com/hat0uma/csvview.nvim',
  -- }}}
})

-- }}}

-- }}}
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Plugin setup {{{
-------------------------------------------------------------------------------

-- Colorscheme {{{

require('tokyonight').setup({
  style = 'night', -- 'storm', 'moon', 'night', 'day'
  transparent = false,
  terminal_colors = true,
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    functions = {},
    variables = {},
  },
  sidebars = { 'qf', 'help', 'terminal' },
  day_brightness = 0.3,
})
vim.cmd('colorscheme tokyonight')

-- }}}

-- Treesitter {{{

-- context highlights (set before plugin loads so ColorScheme refreshes them)
T.augroup('TsContextHighlights', {
  event = 'ColorScheme',
  command = function()
    api.nvim_set_hl(0, 'TreesitterContext', { link = 'Normal' })
    api.nvim_set_hl(0, 'TreesitterContextSeparator', { link = 'Comment' })
    api.nvim_set_hl(0, 'TreesitterContextLineNumber', { link = 'LineNr' })
  end,
}, {
  event = 'VimEnter',
  once = true,
  command = function()
    api.nvim_set_hl(0, 'TreesitterContext', { link = 'Normal' })
    api.nvim_set_hl(0, 'TreesitterContextSeparator', { link = 'Comment' })
    api.nvim_set_hl(0, 'TreesitterContextLineNumber', { link = 'LineNr' })
  end,
})

vim.keymap.set(
  'n',
  '<leader>sc',
  '<cmd>TSContext toggle<CR>',
  { desc = 'toggle treesitter context' }
)

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlTreesitter', { clear = true }),
  callback = function()
    -- nvim-treesitter v1 (main branch) API
    require('nvim-treesitter').setup({
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'css',
        'diff',
        'dockerfile',
        'git_config',
        'git_rebase',
        'gitcommit',
        'gitignore',
        'go',
        'graphql',
        'html',
        'javascript',
        'json',
        'jsonc',
        'lua',
        'luadoc',
        'luap',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'regex',
        'rust',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'xml',
        'yaml',
      },
    })

    require('nvim-treesitter-textobjects').setup({
      select = {
        enable = true,
        lookahead = true,
        include_surrounding_whitespace = true,
        keymaps = {
          ['af'] = { query = '@function.outer', desc = 'ts: all function' },
          ['if'] = { query = '@function.inner', desc = 'ts: inner function' },
          ['ac'] = { query = '@class.outer', desc = 'ts: all class' },
          ['ic'] = { query = '@class.inner', desc = 'ts: inner class' },
          ['aC'] = {
            query = '@conditional.outer',
            desc = 'ts: all conditional',
          },
          ['iC'] = {
            query = '@conditional.inner',
            desc = 'ts: inner conditional',
          },
          ['aL'] = { query = '@assignment.lhs', desc = 'ts: assignment lhs' },
          ['aR'] = { query = '@assignment.rhs', desc = 'ts: assignment rhs' },
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          [']m'] = '@function.outer',
          [']M'] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[M'] = '@class.outer',
        },
      },
    })

    require('treesitter-context').setup({
      enable = false,
      max_lines = 3,
      multiline_threshold = 10,
      separator = '─',
      mode = 'cursor',
    })
  end,
})

-- Treesitter folds (opt-in per buffer; foldlevelstart=999 keeps them open)
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('MrlTsFolds', { clear = true }),
  callback = function(ev)
    local ok, parser = pcall(vim.treesitter.get_parser, ev.buf)
    if not ok or not parser then return end
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  end,
})

-- }}}

require('csvview').setup()

require('nvim-web-devicons').setup({ default = true })

require('nvim-navic').setup({
  lsp = { auto_attach = false },
  highlight = true,
  separator = ' › ',
  depth_limit = 5,
  depth_limit_indicator = '…',
  safe_output = true,
})

-- blink.cmp {{{

require('blink.cmp').setup({
  keymap = {
    preset = 'none',
    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-e>'] = { 'cancel', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<Tab>'] = {
      'select_next',
      'snippet_forward',
      function() return require('sidekick').nes_jump_or_apply() end,
      'fallback',
    },
    ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
    ['<Up>'] = { 'select_prev', 'fallback' },
    ['<Down>'] = { 'select_next', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback' },
    ['<C-n>'] = { 'select_next', 'fallback' },
    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
  },

  appearance = {
    nerd_font_variant = 'mono',
    use_nvim_cmp_as_default = true,
  },

  fuzzy = {
    frecency = { enabled = true },
    use_proximity = true,
    sorts = { 'score', 'sort_text' },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    per_filetype = {
      lua = { 'lsp', 'path', 'snippets', 'buffer' },
      python = { 'lsp', 'path', 'snippets', 'buffer' },
      gitcommit = { 'buffer' },
    },
    providers = {
      lsp = {
        name = 'LSP',
        module = 'blink.cmp.sources.lsp',
        min_keyword_length = 0,
        score_offset = 100,
        fallbacks = { 'snippets' },
      },
      path = {
        name = 'Path',
        module = 'blink.cmp.sources.path',
        score_offset = 3,
        opts = {
          trailing_slash = true,
          label_trailing_slash = false,
          get_cwd = function(context)
            return vim.fn.expand(('#%d:p:h'):format(context.bufnr))
          end,
        },
      },
      snippets = {
        name = 'Snippets',
        module = 'blink.cmp.sources.snippets',
        min_keyword_length = 2,
        score_offset = -3,
      },
      buffer = {
        name = 'Buffer',
        module = 'blink.cmp.sources.buffer',
        min_keyword_length = 5,
        max_items = 5,
      },
    },
  },

  signature = {
    enabled = true,
    window = { border = 'rounded' },
  },

  completion = {
    ghost_text = { enabled = true },
    trigger = {
      show_in_snippet = true,
      show_on_keyword = true,
      show_on_trigger_character = true,
      show_on_insert_on_trigger_character = true,
    },
    list = {
      max_items = 200,
      cycle = { from_bottom = true, from_top = true },
      selection = {
        preselect = true,
        auto_insert = function(ctx) return ctx.mode == 'cmdline' end,
      },
    },
    menu = {
      -- border = 'rounded',
      cmdline_position = function()
        if vim.g.ui_cmdline_pos ~= nil then
          local pos = vim.g.ui_cmdline_pos
          return { pos[1] - 1, pos[2] }
        end
        local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
        return { vim.o.lines - height, 0 }
      end,
      draw = {
        columns = {
          { 'kind_icon', 'label', gap = 1 },
          { 'kind' },
        },
        components = {
          kind_icon = {
            text = function(item)
              return (require('lspkind').symbol_map[item.kind] or '') .. ' '
            end,
            highlight = 'CmpItemKind',
          },
          label = {
            width = { fill = true, max = 60 },
            text = function(item)
              return item.label .. (item.label_detail or '')
            end,
            highlight = 'CmpItemAbbr',
          },
          kind = {
            width = { max = 20 },
            text = function(item) return item.kind end,
            highlight = 'CmpItemKind',
          },
        },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      update_delay_ms = 50,
      treesitter_highlighting = true,
      window = {
        border = 'rounded',
        winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None',
      },
    },
    accept = {
      auto_brackets = { enabled = true },
    },
  },
})

vim.api.nvim_set_hl(0, 'BlinkCmpDoc', { bg = '#2a2a2a' })
vim.api.nvim_set_hl(0, 'BlinkCmpDocBorder', { bg = '#2a2a2a', fg = '#2a2a2a' })
vim.api.nvim_set_hl(0, 'BlinkCmpDocSeparator', { fg = '#333333' })

-- }}}

-- Copilot {{{

require('copilot').setup({
  panel = {
    enabled = true,
    auto_refresh = false,
    keymap = {
      jump_prev = '[[',
      jump_next = ']]',
      accept = '<CR>',
      refresh = 'gr',
      open = '<M-CR>',
    },
    layout = {
      position = 'bottom',
      ratio = 0.4,
    },
  },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    hide_during_completion = true,
    debounce = 75,
    keymap = {
      accept = '<C-a>',
      accept_word = false,
      accept_line = false,
      next = '<M-]>',
      prev = '<M-[>',
      dismiss = '<C-]>',
    },
  },
  filetypes = {
    yaml = false,
    markdown = false,
    help = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    ['.'] = false,
  },
  copilot_node_command = 'node',
  server_opts_overrides = {},
})

-- }}}

-- Sidekick
vim.keymap.set(
  'n',
  '<leader>aa',
  function() require('sidekick.cli').toggle() end,
  {
    desc = 'Sidekick Toggle CLI',
  }
)
vim.keymap.set(
  'n',
  '<leader>as',
  function() require('sidekick.cli').select() end,
  {
    desc = 'Select CLI',
  }
)
vim.keymap.set(
  { 'x', 'n' },
  '<leader>at',
  function() require('sidekick.cli').send({ msg = '{this}' }) end,
  { desc = 'Send This' }
)
vim.keymap.set(
  'x',
  '<leader>av',
  function() require('sidekick.cli').send({ msg = '{selection}' }) end,
  { desc = 'Send Visual Selection' }
)
vim.keymap.set(
  { 'n', 'x' },
  '<leader>ap',
  function() require('sidekick.cli').prompt() end,
  { desc = 'Sidekick Select Prompt' }
)
vim.keymap.set(
  { 'n', 'x', 'i', 't' },
  '<c-.>',
  function() require('sidekick.cli').focus() end,
  { desc = 'Sidekick Switch Focus' }
)
vim.keymap.set(
  'n',
  '<leader>ac',
  function() require('sidekick.cli').toggle({ name = 'claude', focus = true }) end,
  { desc = 'Sidekick Toggle Claude' }
)

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    require('sidekick').setup({
      cli = {
        mux = {
          enabled = true,
          create = 'terminal',
          backend = 'tmux',
        },
        tools = {},
      },
    })
  end,
})

-- fzf-lua {{{

local has_bat = vim.fn.executable('bat') == 1
  or vim.fn.executable('batcat') == 1
local has_delta = vim.fn.executable('delta') == 1

local function open_files_in_cwd(cwd)
  if type(cwd) == 'string' and vim.fn.isdirectory(cwd) == 1 then
    require('fzf-lua').files({ cwd = cwd })
  else
    require('fzf-lua').files()
  end
end

require('fzf-lua').setup({
  winopts = {
    split = 'botright new',
    preview = {
      default = has_bat and 'bat' or 'builtin',
      scrollbar = 'float',
    },
  },
  fzf_opts = { ['--info'] = 'default' },
  files = {
    rg_opts = [[--color=never --files --hidden -g "!.git"]],
    fd_opts = [[--color=never --type f --type l --hidden --exclude .git]],
  },
  grep = {
    rg_opts = '--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden -e',
  },
  keymap = {
    builtin = {
      ['<c-e>'] = 'toggle-preview',
      ['<c-f>'] = 'preview-page-down',
      ['<c-b>'] = 'preview-page-up',
    },
    fzf = {
      ['esc'] = 'abort',
      ['ctrl-q'] = 'select-all+accept',
    },
  },
  git = {
    status = {
      preview_pager = has_delta and 'delta --width=$FZF_PREVIEW_COLUMNS' or nil,
    },
    commits = {
      preview_pager = has_delta and 'delta --width=$FZF_PREVIEW_COLUMNS' or nil,
    },
    bcommits = {
      preview_pager = has_delta and 'delta --width=$FZF_PREVIEW_COLUMNS' or nil,
    },
  },
})

vim.keymap.set(
  'n',
  '<c-p>',
  '<cmd>FzfLua git_files<cr>',
  { desc = 'fzf: git files' }
)
vim.keymap.set(
  'n',
  '<leader>ff',
  '<cmd>FzfLua files<cr>',
  { desc = 'fzf: git files' }
)
-- vim.keymap.set('n', '<leader>ff', function()
--   local ok = vim.fn.systemlist('git rev-parse --is-inside-work-tree 2>/dev/null')[1]
--   if ok == 'true' then require('fzf-lua').git_files({ show_untracked = true })
--   else require('fzf-lua').files() end
-- end, { desc = 'fzf: find files' })
vim.keymap.set(
  'n',
  '<leader>fa',
  '<cmd>FzfLua<cr>',
  { desc = 'fzf: all builtins' }
)
vim.keymap.set(
  'n',
  '<leader>fb',
  '<cmd>FzfLua grep_curbuf<cr>',
  { desc = 'fzf: current buffer' }
)
vim.keymap.set(
  'n',
  '<leader>fr',
  '<cmd>FzfLua resume<cr>',
  { desc = 'fzf: resume' }
)
vim.keymap.set(
  'n',
  '<leader>fo',
  '<cmd>FzfLua buffers<cr>',
  { desc = 'fzf: open buffers' }
)
vim.keymap.set(
  'n',
  '<leader>fh',
  '<cmd>FzfLua oldfiles<cr>',
  { desc = 'fzf: recent files' }
)
vim.keymap.set(
  'n',
  '<leader>fs',
  '<cmd>FzfLua live_grep<cr>',
  { desc = 'fzf: live grep' }
)
vim.keymap.set('n', '<leader>fw', function()
  local word = vim.fn.expand('<cword>')
  if word == '' then return end
  vim.cmd('silent grep! ' .. word)
end, { desc = 'grep word under cursor → qf' })
vim.keymap.set('n', '<leader>fW', function()
  local word = vim.fn.expand('<cWORD>')
  if word == '' then return end
  vim.cmd('silent grep! ' .. word)
end, { desc = 'grep WORD under cursor → qf' })
vim.keymap.set('n', '<leader>fS', function()
  local word = vim.fn.input('rg> ')
  if word == '' then return end
  vim.cmd('silent grep! ' .. word)
end, { desc = 'ripgrep prompt → qf' })
vim.keymap.set(
  'n',
  '<leader>f?',
  '<cmd>FzfLua help_tags<cr>',
  { desc = 'fzf: help' }
)
vim.keymap.set(
  'n',
  '<leader>fva',
  '<cmd>FzfLua autocmds<cr>',
  { desc = 'fzf: autocmds' }
)
vim.keymap.set(
  'n',
  '<leader>fvh',
  '<cmd>FzfLua highlights<cr>',
  { desc = 'fzf: highlights' }
)
vim.keymap.set(
  'n',
  '<leader>fvk',
  '<cmd>FzfLua keymaps<cr>',
  { desc = 'fzf: keymaps' }
)
vim.keymap.set(
  'n',
  '<leader>fle',
  '<cmd>FzfLua diagnostics_workspace<cr>',
  { desc = 'fzf: diagnostics' }
)
vim.keymap.set(
  'n',
  '<leader>fld',
  '<cmd>FzfLua lsp_document_symbols<cr>',
  { desc = 'fzf: document symbols' }
)
vim.keymap.set(
  'n',
  '<leader>fls',
  '<cmd>FzfLua lsp_live_workspace_symbols<cr>',
  { desc = 'fzf: workspace symbols' }
)
vim.keymap.set(
  'n',
  '<leader>fgb',
  '<cmd>FzfLua git_branches<cr>',
  { desc = 'fzf: git branches' }
)
vim.keymap.set(
  'n',
  '<leader>fgs',
  '<cmd>FzfLua git_status<cr>',
  { desc = 'fzf: git status' }
)
vim.keymap.set(
  'n',
  '<leader>fgc',
  '<cmd>FzfLua git_commits<cr>',
  { desc = 'fzf: git commits' }
)
vim.keymap.set(
  'n',
  '<leader>fgB',
  '<cmd>FzfLua git_bcommits<cr>',
  { desc = 'fzf: buffer commits' }
)
vim.keymap.set(
  'n',
  '<localleader>p',
  '<cmd>FzfLua registers<cr>',
  { desc = 'fzf: registers' }
)
vim.keymap.set(
  'n',
  '<leader>fd',
  function() open_files_in_cwd(vim.g.dotfiles) end,
  { desc = 'fzf: dotfiles' }
)
vim.keymap.set(
  'n',
  '<leader>fp',
  function() open_files_in_cwd(vim.g.projects_directory) end,
  { desc = 'fzf: projects' }
)
vim.keymap.set(
  'n',
  '<leader>fc',
  function() open_files_in_cwd(vim.g.vim_dir) end,
  { desc = 'fzf: nvim config' }
)
vim.keymap.set('n', '<leader>f.', function()
  local name = vim.api.nvim_buf_get_name(0)
  local dir = name ~= '' and vim.fn.fnamemodify(name, ':p:h') or vim.loop.cwd()
  open_files_in_cwd(dir)
end, { desc = 'fzf: current file dir' })

-- }}}

-- Gitsigns {{{

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlGitsigns', { clear = true }),
  callback = function()
    require('gitsigns').setup({
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '▎' },
        topdelete = { text = '▎' },
        changedelete = { text = '▎' },
        untracked = { text = '░' },
      },
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gs.nav_hunk('next')
          end
        end, { desc = 'Next git change' })
        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gs.nav_hunk('prev')
          end
        end, { desc = 'Prev git change' })

        -- Hunk actions
        map(
          'v',
          '<leader>hs',
          function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
          { desc = '[git] Stage hunk' }
        )
        map(
          'v',
          '<leader>hr',
          function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
          { desc = '[git] Reset hunk' }
        )
        map('n', '<leader>hs', gs.stage_hunk, { desc = '[git] Stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = '[git] Reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = '[git] Stage buffer' })
        map(
          'n',
          '<leader>hu',
          gs.undo_stage_hunk,
          { desc = '[git] Undo stage hunk' }
        )
        map('n', '<leader>hR', gs.reset_buffer, { desc = '[git] Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = '[git] Preview hunk' })
        map('n', '<leader>hb', gs.blame_line, { desc = '[git] Blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = '[git] Diff index' })
        map(
          'n',
          '<leader>hD',
          function() gs.diffthis('@') end,
          { desc = '[git] Diff last commit' }
        )

        -- Toggles
        map(
          'n',
          '<leader>tb',
          gs.toggle_current_line_blame,
          { desc = '[git] Toggle blame line' }
        )
        map(
          'n',
          '<leader>tD',
          gs.toggle_deleted,
          { desc = '[git] Toggle deleted' }
        )
      end,
    })
  end,
})

-- }}}

-- Fugitive {{{

vim.api.nvim_create_autocmd('DirChanged', {
  group = vim.api.nvim_create_augroup(
    'FugitiveWorktreeDetect',
    { clear = true }
  ),
  callback = function() vim.fn.FugitiveDetect(vim.fn.getcwd()) end,
})

vim.keymap.set('n', '<leader>gs', function()
  local cur_common = vim.fn.FugitiveCommonDir(vim.api.nvim_get_current_buf())
  if cur_common == '' then
    vim.cmd('tab Git')
    return
  end
  for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
    for _, winnr in ipairs(vim.api.nvim_tabpage_list_wins(tabnr)) do
      local buf = vim.api.nvim_win_get_buf(winnr)
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match('^fugitive://') then
        local tab_common = vim.fn.FugitiveCommonDir(buf)
        if tab_common ~= '' and tab_common == cur_common then
          vim.api.nvim_set_current_tabpage(tabnr)
          return
        end
      end
    end
  end
  vim.cmd('tab Git')
end, { desc = '[git] Status' })

vim.keymap.set(
  'n',
  '<leader>g-',
  function() require('gitsigns').blame_line() end,
  { desc = '[git] Blame line' }
)
vim.keymap.set(
  'n',
  '<leader>gB',
  '<cmd>Git blame<cr>',
  { desc = '[git] Blame' }
)
vim.keymap.set(
  'n',
  '<leader>gb',
  '<cmd>FzfLua git_branches<cr>',
  { desc = '[git] Checkout branch' }
)
vim.keymap.set(
  'n',
  '<leader>gc',
  '<cmd>FzfLua git_commits<cr>',
  { desc = '[git] Checkout commit' }
)
vim.keymap.set(
  'n',
  '<leader>gC',
  '<cmd>FzfLua git_bcommits<cr>',
  { desc = '[git] Checkout commit (current file)' }
)
vim.keymap.set(
  'n',
  '<leader>gf',
  '<cmd>Git fetch --all<cr>',
  { desc = '[git] Fetch all branches' }
)
vim.keymap.set(
  'n',
  '<leader>gj',
  function() require('gitsigns').next_hunk() end,
  { desc = '[git] Next hunk' }
)
vim.keymap.set(
  'n',
  '<leader>gk',
  function() require('gitsigns').prev_hunk() end,
  { desc = '[git] Prev hunk' }
)
vim.keymap.set(
  'n',
  '<leader>gh',
  '<cmd>diffget //2<cr>',
  { desc = '[git] Get diff from left' }
)
vim.keymap.set(
  'n',
  '<leader>gH',
  '<cmd>0Gclog<cr>',
  { desc = '[git] History for current file' }
)
vim.keymap.set(
  'n',
  '<leader>gl',
  '<cmd>diffget //3<cr>',
  { desc = '[git] Get diff from right' }
)
vim.keymap.set('n', '<leader>gP', '<cmd>Git push<cr>', { desc = '[git] Push' })
vim.keymap.set(
  'n',
  '<leader>gp',
  '<cmd>Git pull --rebase<cr>',
  { desc = '[git] Pull rebase' }
)
vim.keymap.set(
  'n',
  '<leader>gt',
  ':Git push -u origin ',
  { desc = '[git] Set target branch' }
)

-- }}}

-- Oil {{{

require('oil').setup({
  default_file_explorer = true,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
  },
  win_options = {
    wrap = false,
    signcolumn = 'no',
    cursorcolumn = false,
    foldcolumn = '0',
    spell = false,
    list = false,
    conceallevel = 3,
    concealcursor = 'nvic',
  },
  keymaps = {
    ['<C-h>'] = false, -- free up for tmux
    ['<C-l>'] = false, -- free up for tmux
  },
})

vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent directory' })

-- }}}

-- Mason {{{

require('mason').setup({
  ui = { border = 'rounded', width = 0.8, height = 0.8 },
})

require('mason-tool-installer').setup({
  ensure_installed = {
    -- LSP servers
    'lua-language-server',
    'basedpyright',
    'ruff',
    'typescript-language-server',
    'texlab',
    'vim-language-server',
    -- Formatters
    'stylua',
    'prettier',
    'prettierd',
    'black',
    'isort',
    'shfmt',
    -- Linters
    'eslint_d',
    'flake8',
    'mypy',
    'luacheck',
    'hadolint',
    'jsonlint',
    'vale',
    'tflint',
    -- Other
    'debugpy',
    'sonarlint-language-server',
  },
  auto_update = false,
  run_on_start = true,
})

-- }}}

-- LSP {{{

-- Rounded borders on all LSP floats
do
  local orig = vim.lsp.util.open_floating_preview
  ---@diagnostic disable-next-line: duplicate-set-field
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or 'rounded'
    local bufnr, winnr = orig(contents, syntax, opts, ...)
    if winnr and vim.api.nvim_win_is_valid(winnr) then
      vim.wo[winnr].statuscolumn = ''
      vim.wo[winnr].signcolumn = 'no'
      vim.wo[winnr].foldcolumn = '0'
      vim.wo[winnr].number = false
      vim.wo[winnr].relativenumber = false
      vim.wo[winnr].winhighlight =
        'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder'
      vim.wo[winnr].wrap = false
      vim.wo[winnr].colorcolumn = ''
    end
    return bufnr, winnr
  end
end

local function _with_border(handler)
  return function(err, result, ctx, config)
    config = vim.tbl_extend('force', config or {}, { border = 'rounded' })
    return handler(err, result, ctx, config)
  end
end
vim.lsp.handlers['textDocument/hover'] =
  _with_border(vim.lsp.handlers['textDocument/hover'])
vim.lsp.handlers['textDocument/signatureHelp'] =
  _with_border(vim.lsp.handlers['textDocument/signatureHelp'])

-- Capabilities (blink.cmp injects its extras)
local _lsp_caps = require('blink.cmp').get_lsp_capabilities(
  vim.lsp.protocol.make_client_capabilities()
)
_lsp_caps.workspace = _lsp_caps.workspace or {}
_lsp_caps.workspace.didChangeWatchedFiles = { dynamicRegistration = false }

-- Server configurations
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_dir = function(_, cb) cb(vim.fn.getcwd()) end,
  capabilities = _lsp_caps,
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file('', true),
      },
      diagnostics = { globals = { 'vim' } },
      completion = { callSnippet = 'Replace' },
    },
  },
})

vim.lsp.config('basedpyright', {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_dir = function(_, cb) cb(vim.fn.getcwd()) end,
  capabilities = _lsp_caps,
  on_attach = function(client, _)
    client.server_capabilities.diagnosticProvider = false -- ruff owns diagnostics
  end,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = 'off',
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
    basedpyright = { disableOrganizeImports = true },
  },
})

vim.lsp.config('ruff', {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_dir = function(_, cb) cb(vim.fn.getcwd()) end,
  capabilities = _lsp_caps,
})

vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_dir = function(_, cb) cb(vim.fn.getcwd()) end,
  capabilities = _lsp_caps,
})

vim.lsp.config('texlab', {
  cmd = { 'texlab' },
  filetypes = { 'tex', 'plaintex', 'bib' },
  root_dir = function(_, cb) cb(vim.fn.getcwd()) end,
  capabilities = _lsp_caps,
  settings = {
    texlab = {
      build = { onSave = true },
      chktex = { onOpenAndSave = true },
    },
  },
})

vim.lsp.config('vimls', {
  cmd = { 'vim-language-server', '--stdio' },
  filetypes = { 'vim' },
  root_dir = vim.fn.getcwd,
  capabilities = _lsp_caps,
  initializationOptions = { isNeovim = true },
})

vim.lsp.enable({
  'lua_ls',
  'basedpyright',
  'ruff',
  'ts_ls',
  'texlab',
  'vimls',
  'copilot',
})

-- Per-buffer keymaps on attach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('mrl_lsp_attach', { clear = true }),
  callback = function(event)
    if vim.b[event.buf].lsp_keymaps_attached then return end
    vim.b[event.buf].lsp_keymaps_attached = true
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentSymbolProvider then
      require('nvim-navic').attach(client, event.buf)
    end
    local map = function(keys, func, desc)
      vim.keymap.set(
        'n',
        keys,
        func,
        { buffer = event.buf, desc = 'LSP: ' .. desc }
      )
    end
    map('gh', vim.lsp.buf.hover, 'hover docs')
    local function scroll_hover(delta)
      local float = T.find(
        function(w) return vim.api.nvim_win_get_config(w).relative ~= '' end,
        vim.api.nvim_list_wins()
      )
      if float then
        vim.api.nvim_win_call(
          float,
          function() vim.api.nvim_feedkeys(delta, 'n', false) end
        )
      end
    end
    -- map('<C-f>', function() scroll_hover(vim.api.nvim_replace_termcodes('<C-f>', true, false, true)) end, 'scroll hover down')
    -- map('<C-b>', function() scroll_hover(vim.api.nvim_replace_termcodes('<C-b>', true, false, true)) end, 'scroll hover up')
    map('gd', vim.lsp.buf.definition, 'goto definition')
    map('gD', vim.lsp.buf.declaration, 'goto declaration')
    map('gr', vim.lsp.buf.references, 'references')
    map('gy', vim.lsp.buf.type_definition, 'type definition')
    map('gm', vim.lsp.buf.implementation, 'implementation')
    vim.keymap.set('n', '<leader>rn', function()
      return ':IncRename ' .. vim.fn.expand('<cword>')
    end, { expr = true, silent = false, buffer = event.buf, desc = 'rename' })
    map('<leader>ca', vim.lsp.buf.code_action, 'code action')
    map(
      '<leader>th',
      function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
      'toggle inlay hints'
    )
  end,
})

vim.api.nvim_create_autocmd('LspDetach', {
  group = vim.api.nvim_create_augroup('mrl_lsp_detach', { clear = true }),
  callback = function(event) vim.lsp.buf.clear_references() end,
})

-- }}}

-- Fidget {{{

require('fidget').setup({})

-- }}}

-- Tiny inline diagnostic {{{

vim.api.nvim_create_autocmd('LspAttach', {
  once = true,
  group = vim.api.nvim_create_augroup('MrlTinyInlineDiag', { clear = true }),
  callback = function()
    require('tiny-inline-diagnostic').setup({
      preset = 'simple',
      transparent_bg = false,
      hi = {
        error = 'DiagnosticError',
        warn = 'DiagnosticWarn',
        info = 'DiagnosticInfo',
        hint = 'DiagnosticHint',
        arrow = 'NonText',
        background = 'CursorLine',
        mixing_color = 'None',
      },
      options = {
        show_source = true,
        use_icons_from_diagnostic = false,
        add_messages = true,
        throttle = 100,
        softwrap = 30,
        multilines = { enabled = false, always_show = false },
        show_all_diags_on_cursorline = false,
        enable_on_insert = false,
        overflow = { mode = 'wrap', padding = 0 },
        virt_texts = { priority = 2048 },
        severity = {
          vim.diagnostic.severity.ERROR,
          vim.diagnostic.severity.WARN,
          vim.diagnostic.severity.INFO,
          vim.diagnostic.severity.HINT,
        },
      },
    })
  end,
})

-- }}}

-- Lightbulb {{{

vim.api.nvim_create_autocmd('LspAttach', {
  once = true,
  group = vim.api.nvim_create_augroup('MrlLightbulb', { clear = true }),
  callback = function()
    require('nvim-lightbulb').setup({
      autocmd = { enabled = true },
      sign = { enabled = false },
      virtual_text = {
        enabled = true,
        text = _icons.misc.lightbulb,
        hl = 'DiagnosticWarn',
      },
    })
  end,
})

-- }}}

-- Inc-rename {{{

require('inc_rename').setup({
  hl_group = 'Visual',
  preview_empty_name = true,
})

-- }}}

-- Undotree {{{

vim.g.undotree_TreeNodeShape = '◉'
vim.g.undotree_SetFocusWhenToggle = 1

vim.keymap.set('n', '<leader>u', '<Cmd>UndotreeToggle<CR>', { desc = 'undotree: toggle' })

-- }}}

-- Indent blankline {{{

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlIndentBlankline', { clear = true }),
  callback = function()
    require('ibl').setup({
      indent = { char = '┊' },
      scope = { enabled = false },
    })
  end,
})

-- }}}

-- Rainbow delimiters {{{

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlRainbowDelimiters', { clear = true }),
  callback = function()
    local ok, rainbow_delimiters = pcall(require, 'rainbow-delimiters')
    if not ok then return end
    local rd = vim.g.rainbow_delimiters or {}
    rd.strategy = { [''] = rainbow_delimiters.strategy['global'] }
    rd.query    = { [''] = 'rainbow-delimiters' }
    vim.g.rainbow_delimiters = rd
  end,
})

-- }}}

-- Debug {{{

vim.keymap.set('n', '<F5>',       function() require('dap').continue() end,          { desc = 'debug: continue' })
vim.keymap.set('n', '<F1>',       function() require('dap').step_into() end,         { desc = 'debug: step into' })
vim.keymap.set('n', '<F2>',       function() require('dap').step_over() end,         { desc = 'debug: step over' })
vim.keymap.set('n', '<F3>',       function() require('dap').step_out() end,          { desc = 'debug: step out' })
vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { desc = 'debug: toggle breakpoint' })
vim.keymap.set('n', '<F7>',       function() require('dapui').toggle() end,          { desc = 'debug: toggle UI' })

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlDebug', { clear = true }),
  callback = function()
    local dap = require('dap')
    local dapui = require('dapui')

    dap.adapters.python = {
      type = 'executable',
      command = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python',
      args = { '-m', 'debugpy.adapter' },
    }
    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        pythonPath = function()
          local venv = os.getenv('VIRTUAL_ENV') or os.getenv('CONDA_PREFIX')
          if venv then return venv .. '/bin/python' end
          return vim.fn.exepath('python3') or 'python'
        end,
      },
    }

    dapui.setup({
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '', play = '', step_into = '󱆭',
          step_over = '', step_out = '󰙣', run_last = '󰙡',
          terminate = '', disconnect = '',
        },
      },
    })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close
  end,
})

-- }}}

-- Testing {{{

local function nt() return require('neotest') end
vim.keymap.set('n', '<localleader>ts', function() nt().summary.toggle() end,                { desc = 'neotest: summary' })
vim.keymap.set('n', '<localleader>to', function() nt().output.open({ enter = true }) end,   { desc = 'neotest: output' })
vim.keymap.set('n', '<localleader>tn', function() nt().run.run() end,                       { desc = 'neotest: run nearest' })
vim.keymap.set('n', '<localleader>tf', function() nt().run.run(vim.fn.expand('%')) end,     { desc = 'neotest: run file' })
vim.keymap.set('n', '<localleader>tc', function() nt().run.stop() end,                      { desc = 'neotest: cancel' })
vim.keymap.set('n', '[n',              function() nt().jump.prev({ status = 'failed' }) end, { desc = 'prev failed test' })
vim.keymap.set('n', ']n',              function() nt().jump.next({ status = 'failed' }) end, { desc = 'next failed test' })

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlNeotest', { clear = true }),
  callback = function()
    vim.cmd.packadd('plenary.nvim')
    require('neotest').setup({
      discovery = { enabled = true },
      diagnostic = { enabled = true },
      floating = { border = 'rounded' },
      quickfix = { enabled = false },
      adapters = {
        require('neotest-python')({ runner = 'pytest' }),
      },
    })
  end,
})

-- }}}

-- Formatting {{{

local _conform = require('conform')

_conform.setup({
  notify_on_error = true,
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.g.formatting_disabled then return nil end
    if vim.b[bufnr] and vim.b[bufnr].formatting_disabled then return nil end
    local disable_filetypes =
      { c = true, cpp = true, xml = true, cnk = true, map = true }
    return {
      timeout_ms = 5000,
      lsp_format = disable_filetypes[vim.bo[bufnr].filetype] and 'never'
        or 'fallback',
    }
  end,
  default_format_opts = { lsp_format = 'fallback' },
  formatters_by_ft = {
    bash = { 'shfmt' },
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescriptreact = { 'prettier' },
    css = { 'prettier' },
    html = { 'prettier' },
    json = { 'prettier' },
    jsonc = { 'prettier' },
    yaml = { 'prettier' },
    markdown = { 'prettier' },
    graphql = { 'prettier' },
    lua = { 'stylua' },
    python = { 'isort', 'black' },
  },
  formatters = {
    shfmt = { prepend_args = { '-i', '2' } },
  },
})

T.command('Format', function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line =
      vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range =
      { start = { args.line1, 0 }, ['end'] = { args.line2, end_line:len() } }
  end
  _conform.format({ async = true, lsp_format = 'fallback', range = range })
end, { range = true })

T.command(
  'FormatDisable',
  function() vim.g.disable_autoformat = true end,
  { desc = 'Disable autoformat-on-save' }
)
T.command(
  'FormatEnable',
  function() vim.g.disable_autoformat = false end,
  { desc = 'Enable autoformat-on-save' }
)

-- }}}

-- Linting {{{

do
  local lint = require('lint')
  local _fn = vim.fn

  local function _exe(cmd)
    return type(cmd) == 'string' and cmd ~= '' and _fn.executable(cmd) == 1
  end

  local function _can_lint(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then return false end
    if vim.bo[bufnr].buftype ~= '' then return false end
    local ft = vim.bo[bufnr].filetype or ''
    if ft == '' or ft:match('^fugitive') or ft == 'diff' then return false end
    local names = lint.linters_by_ft[ft]
    if type(names) ~= 'table' or #names == 0 then return false end
    for _, name in ipairs(names) do
      local linter = lint.linters[name]
      local cmd = linter and (linter.cmd or linter.command)
      if _exe(cmd) then return true end
    end
    return false
  end

  lint.linters_by_ft = {
    javascript = { 'eslint_d' },
    typescript = { 'eslint_d' },
    javascriptreact = { 'eslint_d' },
    typescriptreact = { 'eslint_d' },
    python = { 'flake8', 'mypy' },
    lua = _exe('luacheck') and { 'luacheck' } or nil,
    dockerfile = { 'hadolint' },
    json = { 'jsonlint' },
    markdown = { 'vale' },
    rst = { 'vale' },
    text = { 'vale' },
    ruby = { 'ruby' },
    terraform = { 'tflint' },
  }

  -- Guard: ensure linter tables exist so nvim-lint doesn't error on missing tools
  lint.linters.flake8 = lint.linters.flake8 or {}
  lint.linters.mypy = lint.linters.mypy or {}
  lint.linters.eslint_d = lint.linters.eslint_d or {}
  lint.linters.luacheck = lint.linters.luacheck or {}

  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
    group = vim.api.nvim_create_augroup('MrlLint', { clear = true }),
    callback = function(args)
      if not _can_lint(args.buf) then return end
      pcall(lint.try_lint)
    end,
  })
end

vim.keymap.set(
  'n',
  '<leader>ll',
  function() require('lint').try_lint() end,
  { desc = 'lint current buffer' }
)

-- }}}
-- }}}
-------------------------------------------------------------------------------

-- SonarLint {{{

vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'python',
    'javascript',
    'typescript',
    'java',
    'go',
    'html',
    'xml',
  },
  once = true,
  group = vim.api.nvim_create_augroup('MrlSonarqube', { clear = true }),
  callback = function()
    if vim.fn.executable('java') ~= 1 then return end
    local ext = vim.fn.stdpath('data')
      .. '/mason/packages/sonarlint-language-server/extension'
    if vim.fn.isdirectory(ext) == 0 then return end
    local a = ext .. '/analyzers/'
    require('sonarqube').setup({
      lsp = {
        cmd = {
          vim.fn.exepath('java'),
          '-jar',
          ext .. '/server/sonarlint-ls.jar',
          '-stdio',
          '-analyzers',
          a .. 'sonargo.jar',
          a .. 'sonarhtml.jar',
          a .. 'sonariac.jar',
          a .. 'sonarjava.jar',
          a .. 'sonarjavasymbolicexecution.jar',
          a .. 'sonarjs.jar',
          a .. 'sonarphp.jar',
          a .. 'sonarpython.jar',
          a .. 'sonartext.jar',
          a .. 'sonarxml.jar',
        },
      },
      python = { enabled = true },
      javascript = { enabled = true },
      typescript = { enabled = true },
    })
  end,
})

-- }}}

-- Navic breadcrumb {{{

local function get_navic_breadcrumb(bufnr)
  local ok, navic = pcall(require, 'nvim-navic')
  if not ok then return nil end
  if not navic.is_available(bufnr) then return nil end
  local location = navic.get_location({}, bufnr)
  if not location or location == '' then return nil end
  local parts = {}
  for content in location:gmatch('%%#[^#]*#([^%%]*)%%%*') do
    local text = content:match('^%s*(.-)%s*$')
    if text and text ~= '' and text:match('^[%w_]+$') and #text > 1 then
      table.insert(parts, text)
    end
  end
  if #parts == 0 then return nil end
  return {
    {
      { ' :: ', 'StFaded' },
      { table.concat(parts, ' › '), 'StFaded' },
      { ' ', 'StSeparator' },
    },
    priority = 4,
  }
end

-- }}}

-------------------------------------------------------------------------------
-- Plugins                                                            plugins/
-------------------------------------------------------------------------------

-- Last place {{{

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'FileType' }, {
  group = vim.api.nvim_create_augroup('LastPlace', { clear = true }),
  callback = function()
    local ignore_buftype = { 'quickfix', 'nofile', 'help', 'terminal' }
    local ignore_filetype = { 'gitcommit', 'gitrebase', 'svn', 'hgcommit' }

    if vim.tbl_contains(ignore_buftype, vim.bo.buftype) then return end
    if vim.tbl_contains(ignore_filetype, vim.bo.filetype) then
      vim.cmd('normal! gg')
      return
    end

    if vim.fn.line('.') > 1 then return end

    local last_line = vim.fn.line([['"]])
    local buff_last_line = vim.fn.line('$')

    if last_line > 0 and last_line <= buff_last_line then
      local win_last_line = vim.fn.line('w$')
      local win_first_line = vim.fn.line('w0')
      if win_last_line == buff_last_line then
        vim.cmd('normal! g`"')
      elseif
        buff_last_line - last_line
        > ((win_last_line - win_first_line) / 2) - 1
      then
        vim.cmd('normal! g`"zz')
      else
        vim.cmd([[normal! G'"<c-e>]])
      end
    end
  end,
})

-- }}}

-- Project root {{{

local _root_names = {
  '.git',
  'Makefile',
  'go.mod',
  'go.sum',
  'package.json',
  'pyproject.toml',
  'requirements.txt',
  'Cargo.toml',
  'composer.json',
}
local _root_cache = {}
local _root_cache_max = 100

local function _get_lsp_root(buf)
  local clients = vim.lsp.get_clients({ bufnr = buf })
  if not next(clients) then return end
  for _, client in pairs(clients) do
    local filetypes = client.config.filetypes
    if filetypes and vim.tbl_contains(filetypes, vim.bo[buf].ft) then
      return client.config.root_dir, client.name
    end
  end
end

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('FindProjectRoot', { clear = true }),
  callback = function(args)
    local path = vim.api.nvim_buf_get_name(args.buf)
    if path == '' then return end
    path = vim.fs.dirname(path)

    local root = _root_cache[path]
    if not root then
      local root_file =
        vim.fs.find(_root_names, { path = path, upward = true })[1]
      root = vim.fs.dirname(root_file) or _get_lsp_root(args.buf)
    end
    if not root or not path then return end
    if vim.tbl_count(_root_cache) >= _root_cache_max then _root_cache = {} end
    _root_cache[path] = root
    if root == vim.fn.getcwd() then return end
    vim.fn.chdir(root)
  end,
})

-- }}}

-------------------------------------------------------------------------------
-- Autocommands {{{

-- Yank highlight
T.augroup('YankHighlight', {
  event = 'TextYankPost',
  desc = 'Highlight when yanking text',
  command = function() vim.highlight.on_yank() end,
})

-- Smart hlsearch: clear when cursor moves off the match
local function _stop_hl()
  if vim.v.hlsearch == 0 or api.nvim_get_mode().mode ~= 'n' then return end
  vim.cmd('nohlsearch')
end

local function _hl_search()
  local col = api.nvim_win_get_cursor(0)[2]
  local curr_line = api.nvim_get_current_line()
  local ok, match = pcall(fn.matchstrpos, curr_line, fn.getreg('/'), 0)
  if not ok then return end
  local _, p_start, p_end = unpack(match)
  if col < p_start or col > p_end then _stop_hl() end
end

T.augroup('IncSearchHighlight', {
  event = 'CursorMoved',
  command = _hl_search,
}, {
  event = 'InsertEnter',
  command = _stop_hl,
}, {
  event = 'OptionSet',
  pattern = 'hlsearch',
  command = function()
    vim.schedule(function() cmd.redrawstatus() end)
  end,
}, {
  event = 'RecordingEnter',
  command = function()
    vim.o.hlsearch = false
    vim.g.macro_recording = 'macro @' .. fn.reg_recording()
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

-- Equalise windows on resize
T.augroup('UpdateVim', {
  event = 'VimResized',
  pattern = '*',
  command = 'wincmd =',
})

-- Disable columns in floating windows and tool panels
do
  local _no_col_fts = {
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

  local function _no_cols(win)
    vim.wo[win].statuscolumn = ''
    vim.wo[win].signcolumn = 'no'
    vim.wo[win].foldcolumn = '0'
  end

  T.augroup('DisableColumnsInFloats', {
    event = 'WinEnter',
    command = function()
      local win = api.nvim_get_current_win()
      if api.nvim_win_get_config(win).relative ~= '' then _no_cols(win) end
    end,
  }, {
    event = 'FileType',
    pattern = _no_col_fts,
    command = function()
      local win = api.nvim_get_current_win()
      _no_cols(win)
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
    end,
  })
end

-- Sidebar panels: strip line numbers and remap highlights
T.augroup('SidebarPanelHighlights', {
  event = 'FileType',
  pattern = {
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
  },
  command = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.winhighlight:append({
      Normal = 'PanelDarkBackground',
      EndOfBuffer = 'PanelDarkBackground',
      SignColumn = 'PanelDarkBackground',
      WinSeparator = 'PanelWinSeparator',
    })
  end,
})

-- Cursorline only in the active window
T.augroup('AutoCursorline', {
  event = { 'InsertLeave', 'WinEnter' },
  command = function()
    if vim.w.auto_cursorline then
      vim.wo.cursorline = true
      vim.w.auto_cursorline = nil
    end
  end,
}, {
  event = { 'InsertEnter', 'WinLeave' },
  command = function()
    if vim.wo.cursorline then
      vim.w.auto_cursorline = true
      vim.wo.cursorline = false
    end
  end,
})

-- Auto-create parent dirs on save
T.augroup('AutoCreateDir', {
  event = 'BufWritePre',
  command = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    fn.mkdir(fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Reload file when it changes on disk
T.augroup('CheckAutoReload', {
  event = { 'FocusGained', 'TermClose', 'TermLeave' },
  command = function()
    if vim.o.buftype ~= 'nofile' then vim.cmd('checktime') end
  end,
})

-- Formatting guardrail: disable formatting in third-party/runtime code
do
  local function _startswith(s, prefix)
    return type(s) == 'string'
      and type(prefix) == 'string'
      and prefix ~= ''
      and s:sub(1, #prefix) == prefix
  end

  local function _should_disable(bufnr)
    if not api.nvim_buf_is_valid(bufnr) then return false end
    if vim.bo[bufnr].buftype ~= '' then return false end
    if not vim.bo[bufnr].modifiable then return false end
    if vim.bo[bufnr].filetype == '' then return false end
    local path = api.nvim_buf_get_name(bufnr)
    if path == '' then return false end

    local allow = {
      vim.g.personal_directory,
      vim.g.work_directory,
      vim.g.dotfiles,
      vim.g.vim_dir,
      vim.env.HOME,
    }
    for _, p in ipairs(allow) do
      if p and _startswith(path, p) then
        if p ~= vim.env.HOME then return false end
      end
    end

    if vim.env.VIMRUNTIME and _startswith(path, vim.env.VIMRUNTIME) then
      return true
    end

    for _, dir in ipairs(vim.split(vim.o.runtimepath, ',', { plain = true })) do
      if dir ~= '' and _startswith(path, dir) then
        if vim.g.vim_dir and _startswith(path, vim.g.vim_dir) then
          return false
        end
        return true
      end
    end
    return false
  end

  T.augroup('FormattingGuardrail', {
    event = 'BufEnter',
    command = function(args)
      vim.b[args.buf].formatting_disabled = _should_disable(args.buf)
    end,
  })
end

-- }}}

-------------------------------------------------------------------------------
-- Keymaps {{{                                                 lua/keymaps.lua
-------------------------------------------------------------------------------

-- Quickfix and Location List {{{

local list = { qf = {}, loc = {} }

local silence = { mods = { silent = true, emsg_silent = true } }

local function is_list_open(list_type)
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win[list_type] ~= 0 then return true end
  end
  return false
end

local function preserve_window(callback, ...)
  local win = vim.api.nvim_get_current_win()
  callback(...)
  if win ~= vim.api.nvim_get_current_win() then vim.cmd.wincmd('p') end
end

-- Auto-size the list window: clamp between 3 and 10 lines.
local function autosize_list(items)
  local h = math.max(3, math.min(#items, 10))
  vim.api.nvim_win_set_height(0, h)
end

function list.qf.toggle()
  if is_list_open('quickfix') then
    vim.cmd.cclose(silence)
  else
    local items = vim.fn.getqflist()
    if #items > 0 then
      preserve_window(function()
        vim.cmd.copen(silence)
        autosize_list(items)
      end)
    end
  end
end

function list.loc.toggle()
  if is_list_open('loclist') then
    vim.cmd.lclose(silence)
  else
    local items = vim.fn.getloclist(0)
    if #items > 0 then
      preserve_window(function()
        vim.cmd.lopen(silence)
        autosize_list(items)
      end)
    end
  end
end

function list.qf.delete(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local qflist = vim.fn.getqflist()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local mode = vim.api.nvim_get_mode().mode
  if mode:match('[vV]') then
    local first_line = vim.fn.getpos("'<")[2]
    local last_line = vim.fn.getpos("'>")[2]
    local filtered = {}
    for i, item in ipairs(qflist) do
      if i < first_line or i > last_line then filtered[#filtered + 1] = item end
    end
    qflist = filtered
  else
    table.remove(qflist, line)
  end
  vim.fn.setqflist({}, 'r', { items = qflist })
  vim.fn.setpos('.', { buf, line, 1, 0 })
end

-- }}}

-- Quickfix formatter {{{
do
  local home = vim.env.HOME
  local limit = 31
  local fname_fmt1 = '%-' .. limit .. 's'
  local fname_fmt2 = '…%.' .. (limit - 1) .. 's'
  local valid_fmt = '%s │%5d:%-3d│%s %s'
  local type_icons = {
    E = _icons.lsp.error .. ' ',
    W = _icons.lsp.warn .. ' ',
    I = _icons.lsp.info .. ' ',
    N = _icons.lsp.hint .. ' ',
  }

  function _G.qftf(info)
    local items
    local ret = {}
    if info.quickfix == 1 then
      items = vim.fn.getqflist({ id = info.id, items = 0 }).items
    else
      items = vim.fn.getloclist(info.winid, { id = info.id, items = 0 }).items
    end
    for i = info.start_idx, info.end_idx do
      local e = items[i]
      local str
      if e.valid == 1 then
        local fname = ''
        if e.bufnr > 0 then
          fname = vim.fn.bufname(e.bufnr)
          if fname == '' then
            fname = '[No Name]'
          else
            fname = fname:gsub('^' .. home, '~')
            fname = vim.fn.pathshorten(fname)
          end
          local w = vim.api.nvim_strwidth(fname)
          if w <= limit then
            fname = fname_fmt1:format(fname)
          else
            fname = fname_fmt2:format(fname:sub(1 - limit))
          end
        end
        local lnum = e.lnum > 99999 and -1 or e.lnum
        local col = e.col > 999 and -1 or e.col
        local qtype = type_icons[e.type:sub(1, 1):upper()]
          or (e.type ~= '' and ' ' .. e.type:sub(1, 1):upper() or '')
        str = valid_fmt:format(fname, lnum, col, qtype, e.text)
      else
        str = e.text
      end
      table.insert(ret, str)
    end
    return ret
  end
end

vim.o.qftf = '{info -> v:lua._G.qftf(info)}'
-- }}}

vim.keymap.set(
  'n',
  'g>',
  [[<cmd>set nomore<bar>40messages<bar>set more<CR>]],
  { desc = 'show message history' }
)
vim.keymap.set(
  'n',
  '<BS>',
  [[@=(foldlevel('.')?'za':"\<Space>")<CR>]],
  { desc = 'toggle fold under cursor' }
)
vim.keymap.set('n', '<localleader>z', [[zMzvzz]], { desc = 'center viewport' })
vim.keymap.set('n', 'zO', [[zCzO]])

-- Buffers
vim.keymap.set(
  'n',
  '<leader>on',
  [[<cmd>w <bar> %bd <bar> e#<CR>]],
  { desc = 'close all other buffers' }
)
vim.keymap.set(
  'n',
  '<localleader><tab>',
  [[:b <Tab>]],
  { silent = false, desc = 'open buffer list' }
)

-- Windows
vim.keymap.set(
  'n',
  '<localleader>wh',
  '<C-W>t <C-W>K',
  { desc = 'change horizontal splits to vertical' }
)
vim.keymap.set(
  'n',
  '<localleader>wv',
  '<C-W>t <C-W>H',
  { desc = 'change vertical splits to horizontal' }
)
vim.keymap.set(
  'n',
  '<C-w>f',
  '<C-w>vgf',
  { desc = 'open file in vertical split' }
)

-- New files
vim.keymap.set(
  'n',
  '<leader>nf',
  [[:e <C-R>=expand("%:p:h") . "/" <CR>]],
  { silent = false, desc = 'new file in same directory' }
)
vim.keymap.set(
  'n',
  '<leader>ns',
  [[:vsp <C-R>=expand("%:p:h") . "/" <CR>]],
  { silent = false, desc = 'vertical split new file in same directory' }
)

-- Save / quit
vim.keymap.set('n', '<c-s>', '<Cmd>silent! write ++p<CR>')
vim.keymap.set('n', 'qa', '<cmd>qa<CR>')

-- Quickfix / loclist nav
vim.keymap.set('n', ']q', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '[q', '<cmd>cprev<CR>zz')
vim.keymap.set('n', ']l', '<cmd>lnext<cr>zz')
vim.keymap.set('n', '[l', '<cmd>lprev<cr>zz')

-- Tab navigation
vim.keymap.set('n', '<leader>tn', '<cmd>tabedit %<CR>')
vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<CR>')
vim.keymap.set('n', '<leader>to', '<cmd>tabonly<cr>')
vim.keymap.set('n', '<leader>tm', '<cmd>tabmove<Space>')
vim.keymap.set('n', ']t', '<cmd>tabprev<CR>')
vim.keymap.set('n', '[t', '<cmd>tabnext<CR>')

-- Entire buffer text object
vim.keymap.set('x', 'ie', [[gg0oG$]])

-- Smart center
vim.keymap.set(
  'n',
  'zz',
  [[(winline() == (winheight(0) + 1)/ 2) ? 'zt' : (winline() == 1)? 'zb' : 'zz']],
  { expr = true }
)

-- Open common config files
vim.keymap.set(
  'n',
  '<leader>ev',
  [[<Cmd>edit $MYVIMRC<CR>]],
  { desc = 'open $VIMRC' }
)
vim.keymap.set(
  'n',
  '<leader>ez',
  '<Cmd>edit $ZDOTDIR/.zshrc<CR>',
  { desc = 'open zshrc' }
)
vim.keymap.set(
  'n',
  '<leader>et',
  '<Cmd>edit $XDG_CONFIG_HOME/tmux/tmux.conf<CR>',
  { desc = 'edit tmux.conf' }
)
vim.keymap.set(
  'n',
  '<leader>sv',
  [[<Cmd>source $MYVIMRC<cr> <bar> :lua vim.notify('Sourced init.vim')<cr>]],
  { desc = 'source $VIMRC' }
)

vim.keymap.set('n', '<leader>pU', function()
  -- Auto-accept the confirmation buffer that vim.pack.update opens
  vim.api.nvim_create_autocmd('BufAdd', {
    once = true,
    pattern = 'nvim-pack://confirm#*',
    callback = function(ev)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(ev.buf) then
          vim.api.nvim_buf_call(ev.buf, function() vim.cmd('write') end)
        end
      end)
    end,
  })
  vim.pack.update(nil, { summary = true })
end, { desc = 'pack: update all plugins (auto-accept)' })

-- Quote surrounds
vim.keymap.set(
  'n',
  [[<leader>"]],
  [[ciw"<c-r>""<esc>]],
  { desc = 'surround with double quotes' }
)
vim.keymap.set(
  'n',
  '<leader>`',
  [[ciw`<c-r>"`<esc>]],
  { desc = 'surround with backticks' }
)
vim.keymap.set(
  'n',
  "<leader>'",
  [[ciw'<c-r>"'<esc>]],
  { desc = 'surround with single quotes' }
)
vim.keymap.set(
  'n',
  '<leader>)',
  [[ciw(<c-r>")<esc>]],
  { desc = 'surround with parentheses' }
)
vim.keymap.set(
  'n',
  '<leader>}',
  [[ciw{<c-r>"}<esc>]],
  { desc = 'surround with curly braces' }
)

-- gx: open URL or github link
local function open(path)
  fn.jobstart({ vim.g.open_command, path }, { detach = true })
  vim.notify(fmt('Opening %s', path))
end

vim.keymap.set('n', 'gx', function()
  local file = fn.expand('<cfile>')
  if not file or fn.isdirectory(file) > 0 then return vim.cmd.edit(file) end
  if file:match('http[s]?://') then return open(file) end
  local link = file:match('[%a%d%-%.%_]*%/[%a%d%-%.%_]*')
  if link then return open(fmt('https://www.github.com/%s', link)) end
end)

vim.keymap.set('n', 'gf', '<Cmd>e <cfile><CR>')

-- Quickfix / loclist toggles
vim.keymap.set('n', '<C-q>', list.qf.toggle, { desc = 'toggle quickfix list' })
vim.keymap.set('n', '<C-;>', list.loc.toggle, { desc = 'toggle location list' })

-- Tab / shift-tab cycle completion menu (normal mode only — blink owns insert mode)
vim.keymap.set(
  'i',
  '<tab>',
  [[pumvisible() ? "\<C-n>" : "\<Tab>"]],
  { expr = true }
)
vim.keymap.set(
  'i',
  '<s-tab>',
  [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]],
  { expr = true }
)

-- Commands
cmd.cabbrev('options', 'vert options')

-- :Grep / :LGrep — rg into quickfix/loclist (for bulk ops; use live_grep for exploration)
T.command(
  'Grep',
  function(o) vim.cmd('silent grep! ' .. o.args) end,
  { nargs = '+', complete = 'file_in_path', bar = true }
)
T.command(
  'LGrep',
  function(o) vim.cmd('silent lgrep! ' .. o.args) end,
  { nargs = '+', complete = 'file_in_path', bar = true }
)

vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  group = vim.api.nvim_create_augroup('grep_qf', { clear = true }),
  pattern = { 'grep', 'grep!', 'Grep' },
  callback = function() list.qf.toggle() end,
})
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  group = vim.api.nvim_create_augroup('grep_lf', { clear = true }),
  pattern = { 'lgrep', 'lgrep!', 'LGrep' },
  callback = function() list.loc.toggle() end,
})

T.command(
  'ToggleBackground',
  function() vim.o.background = vim.o.background == 'dark' and 'light' or 'dark' end
)

T.command('Todo', [[noautocmd silent! grep! 'TODO\|FIXME\|BUG\|HACK' | copen]])

T.command(
  'MoveWrite',
  [[<line1>,<line2>write<bang> <args> | <line1>,<line2>delete _]],
  {
    nargs = 1,
    bang = true,
    range = true,
    complete = 'file',
  }
)

T.command(
  'MoveAppend',
  [[<line1>,<line2>write<bang> >> <args> | <line1>,<line2>delete _]],
  {
    nargs = 1,
    bang = true,
    range = true,
    complete = 'file',
  }
)

T.command(
  'Reverse',
  '<line1>,<line2>g/^/m<line1>-1',
  { range = '%', bar = true }
)

T.command('Exrc', function()
  local cwd = fn.getcwd()
  local p1 = ('%s/.nvim.lua'):format(cwd)
  local p2 = ('%s/.nvimrc'):format(cwd)
  local path = vim.loop.fs_stat(p1) and p1 or vim.loop.fs_stat(p2) and p2
  if not path then
    local fh, err = io.open(p1, 'w')
    if err then
      vim.notify(
        'Cannot create ' .. p1 .. ': ' .. err,
        vim.log.levels.ERROR,
        { title = 'Exrc' }
      )
      return
    end
    fh:close()
    path = p1
  end
  local ok, err = pcall(vim.cmd.edit, path)
  if not ok then
    vim.notify(err, vim.log.levels.ERROR, { title = 'Exrc Opener' })
  end
end)

T.command('ClearRegisters', function()
  local regs =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-'
  for r in regs:gmatch('.') do
    fn.setreg(r, {})
  end
end)

-- Toggle keymaps
vim.keymap.set(
  'n',
  '<leader>Ob',
  '<cmd>ToggleBackground<cr>',
  { desc = 'toggle background' }
)
vim.keymap.set('n', '<leader>Ow', function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify('wrap ' .. (vim.o.wrap and 'on' or 'off'))
end, { desc = 'toggle wrap' })
vim.keymap.set(
  'n',
  '<leader>Tc',
  '<Cmd>ClearRegisters<CR>',
  { desc = 'clear registers' }
)
vim.keymap.set(
  'n',
  '<leader>Tr',
  '<Cmd>Reverse<CR>',
  { desc = 'reverse buffer' }
)
vim.keymap.set('n', '<C-x>', '<Cmd>Todo<CR>', { desc = 'todo search' })

-- Editing
vim.keymap.set('n', 'U', 'gUiw`]', { desc = 'capitalize word' })
vim.keymap.set('v', '.', ':norm.<CR>')
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
vim.cmd(
  [[nnoremap S :keeppatterns substitute/\s*\%#\s*/\r/e <bar> normal! ==<CR>]]
)

-- Motion
vim.keymap.set({ 'n', 'v' }, 'j', 'gj', { desc = 'move down by display line' })
vim.keymap.set({ 'n', 'v' }, 'k', 'gk', { desc = 'move up by display line' })
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('n', "'", '`')

-- Clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]])
vim.keymap.set('n', '<leader>Y', [["+Y]])
vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]])

-- LSP / format
vim.keymap.set(
  'n',
  '<leader>lf',
  '<cmd>Format<CR>',
  { desc = 'format current buffer' }
)

-- Clear search highlight
vim.keymap.set('n', '<Esc>', function()
  vim.cmd('nohlsearch')
  vim.v.hlsearch = false
end, { desc = 'clear highlight' })

-- Diagnostics
vim.keymap.set(
  'n',
  '[d',
  vim.diagnostic.goto_prev,
  { desc = 'prev diagnostic' }
)
vim.keymap.set(
  'n',
  ']d',
  vim.diagnostic.goto_next,
  { desc = 'next diagnostic' }
)
vim.keymap.set(
  'n',
  '[D',
  function() vim.diagnostic.goto_prev({ count = 999999, wrap = false }) end,
  { desc = 'first diagnostic' }
)
vim.keymap.set(
  'n',
  ']D',
  function() vim.diagnostic.goto_next({ count = 999999, wrap = false }) end,
  { desc = 'last diagnostic' }
)
vim.keymap.set(
  'n',
  '<leader>se',
  vim.diagnostic.open_float,
  { desc = 'show diagnostic float' }
)
vim.keymap.set(
  'n',
  '<leader>ls',
  vim.diagnostic.open_float,
  { desc = 'show diagnostic float' }
)

-- Terminal
vim.keymap.set(
  't',
  '<Esc><Esc>',
  '<C-\\><C-n>',
  { desc = 'exit terminal mode' }
)

-- Buffer navigation
vim.keymap.set('n', '<S-l>', ':bnext<CR>', { noremap = true, silent = true })
vim.keymap.set(
  'n',
  '<S-h>',
  ':bprevious<CR>',
  { noremap = true, silent = true }
)
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { noremap = true, silent = true })
vim.keymap.set(
  'n',
  '<S-Tab>',
  ':bprevious<CR>',
  { noremap = true, silent = true }
)

-- Splits
vim.keymap.set('n', '<leader>|', '<cmd>vsp<CR>', { desc = 'vertical split' })
vim.keymap.set('n', '<leader>-', '<cmd>sp<CR>', { desc = 'horizontal split' })

-- Resize with arrows
vim.keymap.set('n', '<Up>', ':resize -2<CR>', { silent = true })
vim.keymap.set('n', '<Down>', ':resize +2<CR>', { silent = true })
vim.keymap.set('n', '<Left>', ':vertical resize -2<CR>', { silent = true })
vim.keymap.set('n', '<Right>', ':vertical resize +2<CR>', { silent = true })

-- Visual indent / paste
vim.keymap.set('x', '<', '<gv', { desc = 'indent left' })
vim.keymap.set('x', '>', '>gv', { desc = 'indent right' })
vim.keymap.set('x', 'p', 'pgvy')
vim.keymap.set(
  'v',
  'p',
  '"_dP',
  { desc = 'paste without overwriting clipboard' }
)

-- Buffer management
vim.keymap.set('n', '<leader>bo', '<Cmd>:only<CR>', { desc = 'buffer only' })
vim.keymap.set(
  'n',
  '<leader>bD',
  '<Cmd>:bd!<CR>',
  { desc = 'force delete buffer' }
)
vim.keymap.set(
  'n',
  '<leader>z',
  '<cmd>%bdelete<CR>',
  { desc = 'close all buffers' }
)
vim.keymap.set(
  'n',
  '<leader>Z',
  '<cmd>%bdelete!<CR>',
  { desc = 'force close all buffers' }
)
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'quit' })
vim.keymap.set('n', '<leader>Q', '<cmd>q!<CR>', { desc = 'force quit' })

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Statusline {{{
--------------------------------------------------------------------------------

do
  -- ── Rendering primitives ─────────────────────────────────────────────

  local CLICK_END = '%X'

  local function sl_separator()
    return { component = '%=', length = 0, priority = 0 }
  end

  local function sl_get_click_start(func_name, id)
    if not id then
      vim.schedule(
        function()
          vim.notify_once(
            fmt('An ID is needed to enable click handler %s', func_name),
            vim.log.levels.ERROR,
            { title = 'Statusline' }
          )
        end
      )
      return ''
    end
    return ('%%%d@%s@'):format(id, func_name)
  end

  local function sl_normalize_chunks(chunks)
    if type(chunks) ~= 'table' then return end
    if vim.islist(chunks) then return chunks end
    local keys = {}
    for k in pairs(chunks) do
      if type(k) == 'number' and k >= 1 and math.floor(k) == k then
        keys[#keys + 1] = k
      end
    end
    if #keys == 0 then return end
    table.sort(keys)
    local dense = {}
    for _, k in ipairs(keys) do
      local v = chunks[k]
      if v ~= nil then dense[#dense + 1] = v end
    end
    return dense
  end

  local function sl_truncate_string(str, max_size)
    if not max_size or api.nvim_strwidth(str) < max_size then return str end
    local match, count = str:gsub('([\'"]).*%1', '%1…%1')
    return count > 0 and match or str:sub(1, max_size - 1) .. '…'
  end

  local function sl_chunks_to_string(chunks)
    chunks = sl_normalize_chunks(chunks)
    if not chunks then return '' end
    local strings = {}
    for _, item in ipairs(chunks) do
      local text, hl = unpack(item)
      if not T.falsy(text) then
        if type(text) ~= 'string' then text = tostring(text) end
        if item.max_size then text = sl_truncate_string(text, item.max_size) end
        text = text:gsub('%%', '%%%1')
        strings[#strings + 1] = not T.falsy(hl)
            and ('%%#%s#%s%%*'):format(hl, text)
          or text
      end
    end
    return table.concat(strings, '')
  end

  local function sl_component(opts)
    assert(opts, 'component options are required')
    if opts.cond ~= nil and T.falsy(opts.cond) then return end
    local item = sl_normalize_chunks(opts[1])
    if not item then
      error(
        fmt(
          'component options are required but got %s instead',
          vim.inspect(opts[1])
        )
      )
    end
    if not opts.priority then opts.priority = 10 end
    local item_str = sl_chunks_to_string(item)
    if #item_str == 0 then return end
    local click_start = opts.click
        and sl_get_click_start(opts.click, tostring(opts.id))
      or ''
    local click_end = opts.click and CLICK_END or ''
    local component_str = click_start .. item_str .. click_end
    return {
      component = component_str,
      length = api.nvim_eval_statusline(component_str, { maxwidth = 0 }).width,
      priority = opts.priority,
    }
  end

  local function sl_sum_lengths(list)
    return T.fold(
      function(acc, item) return acc + (item.length or 0) end,
      list,
      0
    )
  end

  local function sl_is_lowest(item, lowest)
    if not lowest or not lowest.length then return true end
    if not item.priority or not item.length then return false end
    if item.priority == lowest.priority then
      return item.length > lowest.length
    end
    return item.priority > lowest.priority
  end

  local function sl_prioritize(statusline, space, length)
    length = length or sl_sum_lengths(statusline)
    if length <= space then return statusline end
    local lowest, idx_rm
    for idx, c in ipairs(statusline) do
      if sl_is_lowest(c, lowest) then
        lowest, idx_rm = c, idx
      end
    end
    table.remove(statusline, idx_rm)
    return sl_prioritize(statusline, space, length - lowest.length)
  end

  local section = {}
  function section:new(...)
    local o = { ... }
    self.__index = self
    self.__add = function(l, r)
      local rt = { unpack(l) }
      for _, v in ipairs(r) do
        rt[#rt + 1] = v
      end
      return rt
    end
    return setmetatable(o, self)
  end

  local function display(sections, available_space)
    local components = T.fold(function(acc, sec, count)
      if #sec == 0 then
        table.insert(acc, sl_separator())
        return acc
      end
      T.foreach(function(args, index)
        if not args then return end
        local ok, str = T.pcall('Error creating component', sl_component, args)
        if not ok then return end
        table.insert(acc, str)
        if #sec == index and count ~= #sections then
          table.insert(acc, sl_separator())
        end
      end, sec)
      return acc
    end, sections)
    local items = available_space and sl_prioritize(components, available_space)
      or components
    local strs = vim.tbl_map(function(item) return item.component end, items)
    return table.concat(strs)
  end

  -- ── Minimal-mode detection ────────────────────────────────────────────

  local _minimal_ft = T.p_table({
    ['startuptime'] = true,
    ['checkhealth'] = true,
    ['log'] = true,
    ['help'] = true,
    ['^copilot.*'] = true,
    ['dbout'] = true,
    ['dbui'] = true,
    ['minimap'] = true,
    ['Trouble'] = true,
    ['tsplayground'] = true,
    ['list'] = true,
    ['netrw'] = true,
    ['NvimTree'] = true,
    ['neo-tree'] = true,
    ['undotree'] = true,
    ['dap-repl'] = true,
    ['neotest.*'] = true,
    ['DiffviewFiles'] = true,
    ['toggleterm'] = true,
    ['org'] = true,
    ['norg'] = true,
    ['markdown'] = true,
    ['gitcommit'] = true,
    ['fzf'] = true,
    ['fzf-lua'] = true,
    ['noice'] = true,
  })
  local _minimal_bt =
    { quickfix = true, nofile = true, nowrite = true, terminal = true }

  local function is_plain(ctx)
    if ctx.filetype == 'fzf' then return false end
    return (
      _minimal_ft[ctx.filetype]
      or _minimal_bt[ctx.buftype]
      or ctx.preview
    ) == true
  end

  -- ── State & helpers ───────────────────────────────────────────────────

  _G.Stl = {}
  local _stl_state = { lsp_clients_visible = false }
  local LSP_COMPONENT_ID = 2000
  local space = ' '
  local _sep = package.config:sub(1, 1)

  local _stl_ft_icon = T.p_table({
    ['fzf'] = '󱁴',
    ['fzf-lua'] = '󱁴',
    ['log'] = '',
    ['org'] = '',
    ['mail'] = '',
    ['dbui'] = '',
    ['DiffviewFiles'] = '',
    ['Trouble'] = '',
    ['norg'] = '',
    ['help'] = '',
    ['undotree'] = '󰔱',
    ['NvimTree'] = '󰔱',
    ['neo-tree'] = '󰔱',
    ['neotest.*'] = '',
    ['dapui_.*'] = '',
    ['dap-repl'] = '',
    ['toggleterm'] = '',
    ['Avante.*'] = _icons.misc.chat,
  })

  local _stl_names = T.p_table({
    ['fzf'] = 'FZF',
    ['fzf-lua'] = 'FZF',
    ['orgagenda'] = 'Org',
    ['mail'] = 'Mail',
    ['dbui'] = 'Dadbod UI',
    ['tsplayground'] = 'Treesitter',
    ['Trouble'] = 'Lsp Trouble',
    ['gitcommit'] = 'Git commit',
    ['help'] = 'help',
    ['undotree'] = 'UndoTree',
    ['NvimTree'] = 'Nvim Tree',
    ['dap-repl'] = 'Debugger REPL',
    ['Diffview.*'] = 'Diff view',
    ['neotest.*'] = 'Testing',
    ['Avante.*'] = 'avante',
    ['log'] = function(fname) return fmt('Log(%s)', vim.fs.basename(fname)) end,
    ['dapui_.*'] = function(fname) return fname end,
    ['neo-tree'] = function(fname)
      local parts = vim.split(fname, ' ')
      return fmt('Explorer(%s)', parts[2])
    end,
  })

  -- ── Terminal display name (cached 1 s) ────────────────────────────────

  local function _trim(s)
    return type(s) == 'string' and (s:gsub('^%s+', ''):gsub('%s+$', '')) or ''
  end
  local function _sysline(c)
    local ok, out = pcall(fn.systemlist, c)
    return (ok and out and out[1]) and _trim(out[1]) or ''
  end

  local function _tmux_server_args(pid)
    local args = _trim(_sysline({ 'ps', '-o', 'args=', '-p', tostring(pid) }))
    local result = {}
    local sock, label = args:match('%-S%s+(%S+)'), args:match('%-L%s+(%S+)')
    if sock then
      result[#result + 1] = '-S'
      result[#result + 1] = sock
    elseif label then
      result[#result + 1] = '-L'
      result[#result + 1] = label
    end
    return result
  end

  local function _tmux_pane_cmd(tmux_args, client_pid)
    tmux_args = tmux_args or {}
    local base = vim.list_extend({ 'tmux' }, tmux_args)
    local clients = fn.systemlist(vim.list_extend(vim.deepcopy(base), {
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
    if not name and #clients == 1 then
      local _, cname = clients[1]:match('^(%d+)\t([^\t]*)$')
      name = cname
    end
    if not name or name == '' then return '' end
    return _sysline(vim.list_extend(vim.deepcopy(base), {
      'display-message',
      '-p',
      '-t',
      name,
      '#{pane_current_command}',
    }))
  end

  local function _term_display_name(buf)
    local cached = vim.b[buf].mrl_term_display
    local now = (vim.uv and vim.uv.now and vim.uv.now()) or 0
    if
      type(cached) == 'table'
      and type(cached.value) == 'string'
      and now > 0
      and (now - (cached.ts or 0)) < 1000
    then
      return cached.value
    end
    local job = vim.b[buf].terminal_job_id or vim.bo[buf].channel
    local pid = 0
    local jid = tonumber(job)
    if jid and jid > 0 then
      local ok, p = pcall(fn.jobpid, jid)
      if ok and type(p) == 'number' and p > 0 then pid = p end
    end
    local comm = pid > 0
        and _sysline({ 'ps', '-o', 'comm=', '-p', tostring(pid) })
      or ''
    local value = comm ~= '' and comm
      or fn.fnamemodify(vim.env.SHELL or '', ':t')
    if type(value) == 'string' and value:match('^tmux') and pid > 0 then
      value = 'tmux'
      local pane = _tmux_pane_cmd(_tmux_server_args(pid), pid)
      if pane ~= '' then value = pane end
    end
    vim.b[buf].mrl_term_display = { value = value, ts = now }
    return value
  end

  -- ── Special buffer label ──────────────────────────────────────────────

  local function _special_buf(ctx)
    if ctx.preview then return 'preview' end
    if ctx.buftype == 'quickfix' then return 'Quickfix List' end
    if ctx.filetype == 'fzf' or (ctx.bufname and ctx.bufname:match('^fzf')) then
      return 'FZF'
    end
    if
      ctx.filetype == 'AvanteInput'
      or ctx.filetype == 'AvanteSelectedFiles'
      or ctx.filetype == 'Avante'
    then
      return 'Avante'
    end
    if ctx.buftype == 'terminal' then
      return ('Terminal(%s)'):format(_term_display_name(ctx.bufnum))
    end
    if fn.getloclist(0, { filewinid = 0 }).filewinid > 0 then
      return 'Location List'
    end
    return nil
  end

  -- ── Filename decomposition ────────────────────────────────────────────

  local function _with_sep(path)
    return (not T.falsy(path) and path:sub(-1) ~= _sep) and path .. _sep or path
  end

  local function _dir_env(directory)
    if not directory then return '', '' end
    local paths = {
      [vim.g.dotfiles] = '$DOTFILES',
      [vim.g.personal_directory .. 'dotfiles'] = '$DOTFILES',
      [vim.g.work_directory] = '$WORK',
      [vim.env.VIMRUNTIME] = '$VIMRUNTIME',
      [vim.g.projects_directory] = '$WORKSPACES',
      [vim.g.obsidian] = '$OBSIDIAN',
      [vim.env.HOME] = '~',
    }
    local result, env, prev = directory, '', ''
    for dir, alias in pairs(paths) do
      if dir then
        local match, count =
          vim.fs.normalize(directory):gsub(vim.pesc(_with_sep(dir)), '')
        if count == 1 and #dir > #prev then
          result, env, prev = match, alias, dir
        end
      end
    end
    return result, env
  end

  local function _get_ft_icon(buf)
    local path = api.nvim_buf_get_name(buf)
    if fn.isdirectory(path) == 1 then return '', nil end
    local ok, devicons = pcall(require, 'nvim-web-devicons')
    if not ok then return '', nil end
    local name, ext = fn.fnamemodify(path, ':t'), fn.fnamemodify(path, ':e')
    return devicons.get_icon(name, ext, { default = true })
  end

  local _bt_icon = { terminal = '', quickfix = '󰁨' }

  local function _filetype_icon(ctx)
    return _stl_ft_icon[ctx.filetype]
      or _bt_icon[ctx.buftype]
      or _get_ft_icon(ctx.bufnum)
  end

  local function _filename(ctx)
    local special = _special_buf(ctx)
    if special then return { fname = special } end
    local path = api.nvim_buf_get_name(ctx.bufnum)
    if T.falsy(path) then return { fname = '' } end
    local parts = vim.split(path, _sep)
    local fname = table.remove(parts)
    local name = _stl_names[ctx.filetype]
    if name then
      return {
        fname = vim.is_callable(name) and name(fname, ctx.bufnum) or name,
      }
    end
    local parent = table.remove(parts)
    fname = fn.isdirectory(fname) == 1 and fname .. _sep or fname
    if T.falsy(parent) then return { fname = fname } end
    local dir = _with_sep(table.concat(parts, _sep))
    local new_dir, env = _dir_env(dir)
    local max_dir_width = math.floor(vim.o.columns / 3)
    if api.nvim_strwidth(env .. new_dir) > max_dir_width then
      new_dir = fn.pathshorten(new_dir)
    end
    return {
      env = _with_sep(env),
      dir = _with_sep(new_dir),
      parent = _with_sep(parent),
      fname = fname,
    }
  end

  local function _stl_file(ctx)
    local ft_icon = _filetype_icon(ctx)
    local file_opts = { {}, before = '', after = ' ', priority = 0 }
    local parent_opts = { {}, before = '', after = '', priority = 2 }
    local dir_opts = { {}, before = '', after = '', priority = 3 }
    local env_opts = { {}, before = '', after = '', priority = 4 }
    local p = _filename(ctx)
    local env_empty, dir_empty, parent_empty =
      T.falsy(p.env), T.falsy(p.dir), T.falsy(p.parent)
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

  -- ── Diagnostics ───────────────────────────────────────────────────────

  local _diag_cache = {}

  local function _refresh_diag(buf)
    local sev = vim.diagnostic.severity
    local icons = _icons.lsp
    local result = {
      error = { count = 0, icon = icons.error },
      warn  = { count = 0, icon = icons.warn  },
      info  = { count = 0, icon = icons.info  },
      hint  = { count = 0, icon = icons.hint  },
    }
    for _, item in ipairs(vim.diagnostic.get(buf)) do
      local s = sev[item.severity]:lower()
      result[s].count = result[s].count + 1
    end
    _diag_cache[buf] = result
  end

  local _diag_zero = {
    error = { count = 0 }, warn = { count = 0 },
    info  = { count = 0 }, hint = { count = 0 },
  }

  local function _diagnostics(buf)
    return _diag_cache[buf] or _diag_zero
  end

  -- ── Search count ──────────────────────────────────────────────────────

  local function _search_count()
    local ok, r = pcall(fn.searchcount, { recompute = 1 })
    if not ok or vim.tbl_isempty(r) then return '' end
    if r.incomplete == 1 then return ' ?/?? ' end
    if r.incomplete == 2 then
      if r.total > r.maxcount and r.current > r.maxcount then
        return fmt(' >%d/>%d ', r.current, r.total)
      elseif r.total > r.maxcount then
        return fmt(' %d/>%d ', r.current, r.total)
      end
    end
    return fmt(' %d/%d ', r.current, r.total)
  end

  -- ── LSP clients ───────────────────────────────────────────────────────

  function Stl.lsp_client_click()
    _stl_state.lsp_clients_visible = not _stl_state.lsp_clients_visible
    vim.cmd('redrawstatus')
  end

  local _lsp_cache = {}

  local function _refresh_lsp(buf)
    local clients = vim.lsp.get_clients({ bufnr = buf }) or {}
    if #clients == 0 then _lsp_cache[buf] = { false, {} }; return end
    local has_copilot, names = false, {}
    for _, c in ipairs(clients) do
      local name = c.name or ''
      if name == 'copilot' or name:match('copilot') then
        has_copilot = true
      else
        table.insert(names, name)
      end
    end
    table.sort(names)
    _lsp_cache[buf] = { has_copilot, names }
  end

  local function _lsp_clients(ctx)
    local cached = _lsp_cache[ctx.bufnum]
    if cached then return cached[1], cached[2] end
    return false, {}
  end

  -- ── Git update timer ──────────────────────────────────────────────────

  local function _update_git_status()
    local cwd = fn.getcwd()
    if not (cwd and vim.uv.fs_stat(cwd .. '/.git')) then return end
    local result = {}
    fn.jobstart('git rev-list --count --left-right @{upstream}...HEAD', {
      stdout_buffered = true,
      on_stdout = function(_, data)
        for _, item in ipairs(data) do
          if item and item ~= '' then result[#result + 1] = item end
        end
      end,
      on_exit = function(_, code)
        if code == 0 and result[1] then
          local parts = vim.split(result[1], '\t')
          if #parts == 2 then
            vim.g.git_statusline_updates =
              { behind = parts[1], ahead = parts[2] }
          end
        end
      end,
    })
  end

  local function _git_updates()
    local timer = vim.uv.new_timer()
    if not timer then return end
    local pending
    local fail = timer:start(
      0,
      10000,
      vim.schedule_wrap(function()
        if pending then fn.jobstop(pending) end
        pending = _update_git_status()
      end)
    )
    if fail ~= 0 then
      vim.schedule(
        function()
          vim.notify(
            'Failed to start git update timer: ' .. fail,
            vim.log.levels.WARN
          )
        end
      )
    end
  end

  -- Render {{{

  function Stl.render()
    local curwin = api.nvim_get_current_win()
    local curbuf = api.nvim_win_get_buf(curwin)
    local available = vim.o.columns

    local ctx = {
      bufnum = curbuf,
      win = curwin,
      bufname = api.nvim_buf_get_name(curbuf),
      preview = vim.wo[curwin].previewwindow,
      readonly = vim.bo[curbuf].readonly,
      filetype = vim.bo[curbuf].ft,
      buftype = vim.bo[curbuf].bt,
      modified = vim.bo[curbuf].modified,
      shiftwidth = vim.bo[curbuf].shiftwidth,
      expandtab = vim.bo[curbuf].expandtab,
    }

    local plain = is_plain(ctx)
    local focused = vim.g.vim_in_focus ~= false
    local path = _stl_file(ctx)

    local l1 = section:new({
      { { '' .. vim.g.dev_environ .. '', 'StDevEnv' } },
      priority = 1,
      cond = true,
    })

    if plain or not focused then
      local l2 = section:new(
        { { { ctx.readonly and ' ' or '', 'StFaded' } }, priority = 1 },
        path.env,
        path.dir,
        path.parent,
        path.file
      )
      return display({ l1 + l2 }, available)
    end

    local lnum, col = unpack(api.nvim_win_get_cursor(curwin))
    col = col + 1
    local line_count = api.nvim_buf_line_count(curbuf)
    local status = vim.b[curbuf].gitsigns_status_dict or {}
    local updates = vim.g.git_statusline_updates or {}
    local ahead = updates.ahead and tonumber(updates.ahead) or 0
    local behind = updates.behind and tonumber(updates.behind) or 0
    local diag = _diagnostics(curbuf)
    local has_copilot, lsp_names = _lsp_clients(ctx)
    local lsp_count = #lsp_names

    local lsp_components = {
      {
        {
          { space, 'StSeparator' },
          has_copilot and { _icons.misc.copilot .. space, 'StTitle' } or nil,
          { space, 'StSeparator' },
          { _icons.misc.puzzle, 'StTitle' },
          { space, 'StSeparator' },
          { tostring(lsp_count), 'StFaded' },
          { space, 'StSeparator' },
        },
        priority = 2,
        id = LSP_COMPONENT_ID,
        click = 'v:lua.Stl.lsp_client_click',
      },
    }
    if _stl_state.lsp_clients_visible and lsp_count > 0 then
      table.insert(lsp_components, {
        {
          { space, 'StSeparator' },
          { table.concat(lsp_names, ', '), 'StFaded' },
        },
        priority = 9,
      })
    end

    -- Left
    local l2 = section:new(
      {
        { { ' ' .. _icons.misc.pencil, 'StFaded' }, { space, 'StSeparator' } },
        cond = ctx.modified,
        priority = 1,
      },
      {
        { { _search_count(), 'StSearchCount' } },
        cond = vim.v.hlsearch > 0,
        priority = 1,
      },
      path.env,
      path.dir,
      path.parent,
      path.file,
      -- get_navic_breadcrumb(ctx.bufnum),
      {
        {
          { space, 'StSeparator' },
        },
        cond = true,
        priority = 1,
      },
      {
        {
          { diag.warn.icon, 'StWarn' },
          { space, 'StSeparator' },
          { diag.warn.count .. ' ', 'StWarn' },
        },
        cond = diag.warn.count > 0,
        priority = 3,
      },
      {
        {
          { diag.error.icon, 'StError' },
          { space, 'StSeparator' },
          { diag.error.count .. ' ', 'StError' },
        },
        cond = diag.error.count > 0,
        priority = 1,
      },
      {
        {
          { diag.info.icon, 'StInfo' },
          { space, 'StSeparator' },
          { diag.info.count .. ' ', 'StInfo' },
        },
        cond = diag.info.count > 0,
        priority = 3,
      },
      {
        { { _icons.misc.shaded_lock, 'StFaded' } },
        cond = vim.b[ctx.bufnum].formatting_disabled == true
          or vim.g.formatting_disabled == true,
        priority = 5,
      },
      { { { space, 'StSeparator' } }, cond = true, priority = 1 }
    )

    -- Middle (macro recording)
    local m1 = section:new({
      { { vim.g.macro_recording or '', 'StWarn' } },
      priority = 1,
    })

    -- Right
    local r1 = section:new(
      { { { space, 'StSeparator' } }, priority = 3, cond = true },
      unpack(lsp_components)
    )

    local r2 = section:new({
      {
        { _icons.git.branch, 'StTitle' },
        { space, 'StSeparator' },
        { status.head, 'StBranch' },
        { space, 'StSeparator' },
      },
      priority = 1,
      cond = not T.falsy(status.head),
    }, {
      {
        { _icons.git.mod, 'StGitModified' },
        { space, 'StGitModified' },
        { status.changed, 'StTitle' },
        { space, 'StSeparator' },
      },
      priority = 5,
      cond = not T.falsy(status.changed),
    }, {
      {
        { _icons.git.remove, 'StGitDelete' },
        { space, 'StGitDelete' },
        { status.removed, 'StTitle' },
        { space, 'StSeparator' },
      },
      priority = 5,
      cond = not T.falsy(status.removed),
    }, {
      {
        { _icons.git.add, 'StGitAdd' },
        { space, 'StGitAdd' },
        { status.added, 'StTitle' },
        { space, 'StSeparator' },
      },
      priority = 5,
      cond = not T.falsy(status.added),
    }, {
      {
        { _icons.misc.up, 'StGitAdd' },
        { space, 'StSeparator' },
        { ahead, 'StTitle' },
      },
      cond = ahead > 0,
      before = '',
      priority = 5,
    }, {
      {
        { _icons.misc.down, 'StGitDelete' },
        { space, 'StSeparator' },
        { behind, 'StTitle' },
      },
      cond = behind > 0,
      after = ' ',
      priority = 5,
    }, {
      {
        { space, 'StSeparator' },
        { lnum .. ':' .. col, 'StTitle' },
        { space, 'StSeparator' },
        { fmt('%d', 100 * lnum / line_count) .. '%', 'StFaded' },
        { space, 'StSeparator' },
      },
      priority = 2,
    }, {
      {
        { ctx.expandtab and _icons.misc.indent or _icons.misc.tab, 'StTitle' },
        { space, 'StSeparator' },
        { ctx.shiftwidth, 'StTitle' },
        { space, 'StSeparator' },
      },
      cond = ctx.shiftwidth > 2 or not ctx.expandtab,
      priority = 6,
    })

    return display({ l1 + l2, m1, r1 + r2 }, available - 5)
  end

  -- }}}

  -- Wire up {{{

  vim.g.qf_disable_statusline = 1
  vim.o.statusline = '%{%v:lua.Stl.render()%}'

  T.augroup('CustomStatusline', {
    event = 'FocusGained',
    command = function() vim.g.vim_in_focus = true end,
  }, {
    event = 'FocusLost',
    command = function() vim.g.vim_in_focus = false end,
  }, {
    event = 'BufReadPre',
    once = true,
    command = _git_updates,
  }, {
    event = 'DiagnosticChanged',
    command = function(ev) _refresh_diag(ev.buf); vim.cmd('redrawstatus') end,
  }, {
    event = { 'LspAttach', 'LspDetach' },
    command = function(ev) _refresh_lsp(ev.buf); vim.cmd('redrawstatus') end,
  }, {
    event = 'BufDelete',
    command = function(ev) _diag_cache[ev.buf] = nil; _lsp_cache[ev.buf] = nil end,
  }, {
    event = { 'WinEnter', 'WinLeave', 'BufWinEnter' },
    command = function() vim.cmd('redrawstatus') end,
  })

  -- }}}
end

-- }}}
--------------------------------------------------------------------------------

-- vim: ft=lua fdm=marker
