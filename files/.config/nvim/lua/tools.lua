local fn, api, fmt = vim.fn, vim.api, string.format

local M = {}

--------------------------------------------------------------------------------
-- Helpers {{{
--------------------------------------------------------------------------------

---check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function M.has(feature) return fn.has(feature) > 0 end

local LATEST_NIGHTLY_MINOR = 10
function M.nightly() return vim.version().minor >= LATEST_NIGHTLY_MINOR end

--- Call the given function and use `vim.notify` to notify of any errors.
---@param msg string
---@param func function
---@param ... any
---@return boolean, any
---@overload fun(func: function, ...): boolean, any
function M.pcall(msg, func, ...)
  local args = { ... }
  if type(msg) == 'function' then
    local arg = func --[[@as any]]
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

--- Require on index — defers the actual require until the first key access.
function M.require_for_later_index(require_path)
  return setmetatable({}, {
    __index = function(_, key) return require(require_path)[key] end,
    __newindex = function(_, key, value) require(require_path)[key] = value end,
  })
end

--- Require on call — wraps each exported function so the module is only loaded
--- when that function is first invoked.
---@param require_path string
---@return table<string, fun(...): any>
function M.require_for_later_call(require_path)
  return setmetatable({}, {
    __index = function(_, k)
      return function(...) return require(require_path)[k](...) end
    end,
  })
end

---Autosize a horizontal split to fit its content.
---@param min_height number
---@param max_height number
function M.adjust_split_height(min_height, max_height)
  api.nvim_win_set_height(
    0,
    math.max(math.min(fn.line('$'), max_height), min_height)
  )
end

function M.get_hi(name, id)
  id = id or 0
  local hi = vim.api.nvim_get_hl(0, { name = name })
  for k, v in pairs(hi) do
    if type(v) == 'number' then hi[k] = ('#%06x'):format(v) end
  end
  return hi
end

function M.command(name, rhs, opts)
  opts = opts or {}
  api.nvim_create_user_command(name, rhs, opts)
end

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Tables & functional {{{
--------------------------------------------------------------------------------

---Determine if a value of any type is empty / falsy.
---@param item any
---@return boolean?
function M.falsy(item)
  if not item then return true end
  local item_type = type(item)
  if item_type == 'boolean' then return not item end
  if item_type == 'string' then return item == '' end
  if item_type == 'number' then return item <= 0 end
  if item_type == 'table' then return vim.tbl_isempty(item) end
  return item ~= nil
end

---@generic T:table
---@param callback fun(item: T, key: any)
---@param list table<any, T>
function M.foreach(callback, list)
  for k, v in pairs(list) do
    callback(v, k)
  end
end

function M.fold(callback, list, accum)
  accum = accum or {}
  for k, v in pairs(list) do
    accum = callback(accum, v, k)
    assert(accum ~= nil, 'The accumulator must be returned on each iteration')
  end
  return accum
end

---@generic T
---@param callback fun(item: T, key: string | number, list: T[]): T
---@param list T[]
---@return T[]
function M.map(callback, list)
  return M.fold(function(accum, v, k)
    accum[#accum + 1] = callback(v, k, accum)
    return accum
  end, list, {})
end

--- Check if the target matches any item in the list (pattern-aware).
---@param target string
---@param list string[]
---@return boolean
function M.any(target, list)
  for _, item in ipairs(list) do
    if target:match(item) then return true end
  end
  return false
end

---Find an item in a list.
---@generic T
---@param matcher fun(arg: T):boolean
---@param haystack T[]
---@return T?
function M.find(matcher, haystack)
  for _, needle in ipairs(haystack) do
    if matcher(needle) then return needle end
  end
end

---Return a table whose missing-key lookup falls back to pattern matching.
---@generic T
---@param map T
---@return T
function M.p_table(map)
  return setmetatable(map, {
    __index = function(tbl, key)
      if not key then return end
      for k, v in pairs(tbl) do
        if key:match(k) then return v end
      end
    end,
  })
end

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Autocommands {{{
--------------------------------------------------------------------------------

local autocmd_keys =
  { 'event', 'buffer', 'pattern', 'desc', 'command', 'group', 'once', 'nested' }

---@param name string
---@param command Autocommand
local function validate_autocmd(name, command)
  local incorrect = M.fold(function(accum, _, key)
    if not vim.tbl_contains(autocmd_keys, key) then table.insert(accum, key) end
    return accum
  end, command, {})

  if #incorrect > 0 then
    vim.schedule(function()
      local msg = 'Incorrect keys: ' .. table.concat(incorrect, ', ')
      vim.notify(msg, 'error', { title = fmt('Autocmd: %s', name) })
    end)
  end
end

---Create an autocommand group and return its ID.
---@param name string
---@param ... Autocommand
---@return number
function M.augroup(name, ...)
  local commands = { ... }
  assert(name ~= 'User', 'The name of an augroup CANNOT be User')
  assert(
    #commands > 0,
    fmt('You must specify at least one autocommand for %s', name)
  )
  local id = api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in ipairs(commands) do
    validate_autocmd(name, autocmd)
    local is_callback = type(autocmd.command) == 'function'
    api.nvim_create_autocmd(autocmd.event, {
      group = name,
      pattern = autocmd.pattern,
      desc = autocmd.desc,
      callback = is_callback and autocmd.command or nil,
      command = not is_callback and autocmd.command or nil,
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end
  return id
end

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- String utilities {{{
--------------------------------------------------------------------------------

---Truncate a string to a maximum display-width, appending an ellipsis.
---@param str string
---@param max_len integer
---@return string
function M.truncate(str, max_len)
  assert(str and max_len, 'string and max_len must be provided')
  local ellipsis = M.ui.icons.misc.ellipsis
  return api.nvim_strwidth(str) > max_len and str:sub(1, max_len) .. ellipsis
    or str
end

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Color utilities {{{
--------------------------------------------------------------------------------

--- Change the brightness of a color, negative numbers darken and positive ones brighten.
---@param color string A hex color (#RRGGBB)
---@param percent number a negative number darkens and a positive one brightens
---@return string
function M.tint(color, percent)
  assert(
    color and percent,
    'cannot alter a color without specifying a color and percentage'
  )
  local r = tonumber(color:sub(2, 3), 16)
  local g = tonumber(color:sub(4, 5), 16)
  local b = tonumber(color:sub(6), 16)
  if not r or not g or not b then return 'NONE' end
  local blend = function(component)
    component = math.floor(component * (1 + percent))
    return math.min(math.max(component, 0), 255)
  end
  return fmt('#%02x%02x%02x', blend(r), blend(g), blend(b))
end

--- Blend two hex colors using an alpha for the foreground.
--- `alpha = 0` returns bg, `alpha = 1` returns fg.
---@param bg string hex color (#RRGGBB)
---@param fg string hex color (#RRGGBB)
---@param alpha number 0..1
---@return string
function M.blend(bg, fg, alpha)
  assert(bg and fg and alpha ~= nil, 'blend(bg, fg, alpha) requires 3 args')
  if type(bg) ~= 'string' or type(fg) ~= 'string' then return 'NONE' end
  if bg == 'NONE' or fg == 'NONE' then return 'NONE' end
  if not bg:match('^#%x%x%x%x%x%x$') or not fg:match('^#%x%x%x%x%x%x$') then
    return 'NONE'
  end
  alpha = math.min(math.max(alpha, 0), 1)

  local br, bgc, bb =
    tonumber(bg:sub(2, 3), 16),
    tonumber(bg:sub(4, 5), 16),
    tonumber(bg:sub(6, 7), 16)
  local fr, fgc, fb =
    tonumber(fg:sub(2, 3), 16),
    tonumber(fg:sub(4, 5), 16),
    tonumber(fg:sub(6, 7), 16)
  if not br or not bgc or not bb or not fr or not fgc or not fb then
    return 'NONE'
  end

  local function mix(b, f) return math.floor((1 - alpha) * b + alpha * f + 0.5) end
  return fmt('#%02x%02x%02x', mix(br, fr), mix(bgc, fgc), mix(bb, fb))
end

---@param hex string
---@return string?
local function normalize_hex(hex)
  if type(hex) ~= 'string' then return nil end
  hex = hex:gsub('#', '')
  if #hex ~= 6 then return nil end
  return hex:lower()
end

local function rgb_to_hsl(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local maxc, minc = math.max(r, g, b), math.min(r, g, b)
  local h, s, l = 0, 0, (maxc + minc) / 2

  if maxc ~= minc then
    local d = maxc - minc
    s = l > 0.5 and d / (2 - maxc - minc) or d / (maxc + minc)
    if maxc == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif maxc == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, l
end

local function hsl_to_rgb(h, s, l)
  local function hue_to_rgb(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1 / 6 then return p + (q - p) * 6 * t end
    if t < 1 / 2 then return q end
    if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
    return p
  end

  local r, g, b
  if s == 0 then
    r, g, b = l, l, l
  else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = hue_to_rgb(p, q, h + 1 / 3)
    g = hue_to_rgb(p, q, h)
    b = hue_to_rgb(p, q, h - 1 / 3)
  end

  return math.floor(r * 255 + 0.5),
    math.floor(g * 255 + 0.5),
    math.floor(b * 255 + 0.5)
end

--- Darken or lighten a hex color via HSL lightness while preserving hue/saturation.
--- Positive `lightness_factor` lightens, negative darkens.
---@param hex string hex color (#RRGGBB)
---@param lightness_factor number
---@return string
function M.darken_hsl(hex, lightness_factor)
  lightness_factor = lightness_factor or 0.0
  local h = normalize_hex(hex)
  if not h then return 'NONE' end
  local r = tonumber(h:sub(1, 2), 16)
  local g = tonumber(h:sub(3, 4), 16)
  local b = tonumber(h:sub(5, 6), 16)
  if not r or not g or not b then return 'NONE' end

  local hh, ss, ll = rgb_to_hsl(r, g, b)

  if lightness_factor > 0 then
    ll = ll + (1 - ll) * lightness_factor
  else
    ll = ll * (1 + lightness_factor)
  end

  ll = math.min(math.max(ll, 0), 1)
  r, g, b = hsl_to_rgb(hh, ss, ll)
  return fmt('#%02x%02x%02x', r, g, b)
end

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- UI {{{
--------------------------------------------------------------------------------

---@class UI
M.ui = {}

-- Icons {{{

M.ui.icons = {
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
    error = '', -- '✗'
    warn = '', --
    info = '󰋼', --  ℹ 󰙎
    hint = '󰌶', --  ⚑
  },
  git = {
    add = '󰐗',
    mod = '󰻂',
    remove = '󰍶',
    ignore = '',
    rename = '',
    untracked = '',
    ignored = '󰙦',
    unstaged = '󰻂',
    staged = '',
    conflict = '',
    diff = '',
    repo = '',
    logo = '󰊢',
    branch = '',
  },
  documents = {
    file = '',
    files = '',
    folder = '',
    open_folder = '',
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
    clock = '',
    cmd = '⌘',
    lock = '',
    shaded_lock = '',
    circle = '',
    project = '',
    dashboard = '',
    history = '󰄉',
    comment = '󰅺',
    robot = '󰚩',
    copilot = '',
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
    fire = '',
    note = '󰎞',
    bookmark = '',
    pencil = '',
    tools = '',
    arrow_right = '',
    caret_right = '',
    chevron_right = '',
    double_chevron_right = '»',
    table = '',
    calendar = '',
    block = '▏',
    clippy = '',
    puzzle = '',
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

-- Palette {{{

-- Mutated in-place so modules holding a reference keep seeing updates.
M.ui.palette = {}

local function hex_from_hl(name, attr, fallback)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok or not hl then return fallback end
  local v = hl[attr]
  if not v then return fallback end
  return ('#%06x'):format(v)
end

local function palette_tint(color, percent)
  local ok = type(color) == 'string' and color:match('^#%x%x%x%x%x%x$')
  if not ok then return color end
  local r = tonumber(color:sub(2, 3), 16)
  local g = tonumber(color:sub(4, 5), 16)
  local b = tonumber(color:sub(6, 7), 16)
  local function blend(component)
    component = math.floor(component * (1 + percent))
    return math.min(math.max(component, 0), 255)
  end
  return ('#%02x%02x%02x'):format(blend(r), blend(g), blend(b))
end

local function get_nightfox_palette()
  local ok, nightfox_palette = pcall(require, 'nightfox.palette')
  if not ok or not nightfox_palette or not nightfox_palette.load then
    return nil
  end
  return nightfox_palette.load(vim.g.colors_name or 'carbonfox')
end

local function as_hex(v, fallback)
  if type(v) == 'string' then return v end
  if type(v) == 'number' then return ('#%06x'):format(v) end
  if type(v) == 'table' then
    if type(v.base) == 'string' then return v.base end
    if vim.is_callable(v) then
      local ok, res = pcall(v)
      if ok then
        if type(res) == 'string' then return res end
        if type(res) == 'number' then return ('#%06x'):format(res) end
      end
    end
  end
  return fallback
end

--- Refresh the palette from the active colorscheme.
function M.ui.refresh_palette()
  local palette = M.ui.palette
  local defaults = {
    green = '#98c379',
    dark_green = '#10B981',
    blue = '#82AAFE',
    dark_blue = '#4e88ff',
    bright_blue = '#51afef',
    teal = '#15AABF',
    pale_pink = '#b490c0',
    magenta = '#c678dd',
    red = '#E06C75',
    pale_red = '#E06C75',
    light_red = '#c43e1f',
    dark_red = '#be5046',
    dark_orange = '#FF922B',
    bright_yellow = '#FAB005',
    light_yellow = '#e5c07b',
    whitesmoke = '#9E9E9E',
    light_gray = '#626262',
    comment_grey = '#5c6370',
    grey = '#3E4556',
  }

  local pal = get_nightfox_palette()
  local derived = {}

  if pal then
    derived.green = as_hex(pal.green, defaults.green)
    derived.blue = as_hex(pal.blue, defaults.blue)
    derived.teal = as_hex(pal.cyan or pal.teal, defaults.teal)
    derived.magenta = as_hex(pal.magenta, defaults.magenta)
    derived.pale_pink = as_hex(pal.pink or pal.magenta, defaults.pale_pink)
    derived.pale_red = as_hex(pal.red, defaults.pale_red)
    derived.red = hex_from_hl('GitSignsDelete', 'fg', pal.red or defaults.red)
    derived.dark_orange = as_hex(pal.orange, defaults.dark_orange)
    derived.bright_yellow = as_hex(pal.yellow, defaults.bright_yellow)
    derived.light_yellow = as_hex(pal.yellow, defaults.light_yellow)
    derived.comment_grey = as_hex(pal.comment or pal.fg3, defaults.comment_grey)
    derived.whitesmoke = as_hex(pal.fg1 or pal.fg0, defaults.whitesmoke)
    derived.light_gray = as_hex(pal.fg3, defaults.light_gray)
    derived.grey = as_hex(pal.bg3 or pal.bg2, defaults.grey)
  else
    derived.pale_red = hex_from_hl('DiagnosticError', 'fg', defaults.pale_red)
    derived.red =
      hex_from_hl('GitSignsDelete', 'fg', derived.pale_red or defaults.red)
    derived.dark_orange =
      hex_from_hl('DiagnosticWarn', 'fg', defaults.dark_orange)
    derived.teal = hex_from_hl('DiagnosticInfo', 'fg', defaults.teal)
    derived.bright_blue =
      hex_from_hl('DiagnosticHint', 'fg', defaults.bright_blue)
    derived.green = hex_from_hl('GitSignsAdd', 'fg', defaults.green)
    derived.blue = hex_from_hl('Function', 'fg', defaults.blue)
    derived.magenta = hex_from_hl('Statement', 'fg', defaults.magenta)
    derived.pale_pink = hex_from_hl('Special', 'fg', defaults.pale_pink)
    derived.bright_yellow =
      hex_from_hl('WarningMsg', 'fg', defaults.bright_yellow)
    derived.light_yellow = derived.bright_yellow
    derived.comment_grey = hex_from_hl('Comment', 'fg', defaults.comment_grey)
    derived.whitesmoke = hex_from_hl('Normal', 'fg', defaults.whitesmoke)
    derived.light_gray = palette_tint(derived.comment_grey, 0.1)
    derived.grey =
      palette_tint(hex_from_hl('Normal', 'bg', defaults.grey), 0.15)
  end

  derived.dark_green = palette_tint(derived.green, -0.25)
  derived.dark_blue = palette_tint(derived.blue, -0.25)
  derived.light_red = palette_tint(derived.pale_red, -0.15)
  derived.dark_red = palette_tint(derived.pale_red, -0.30)

  for k in pairs(palette) do palette[k] = nil end
  for k, v in pairs(defaults) do palette[k] = derived[k] or v end
  for k, v in pairs(derived) do palette[k] = v end

  -- Keep LSP colors in sync
  local lsp = M.ui.lsp
  if lsp and lsp.colors then
    lsp.colors.error = palette.pale_red
    lsp.colors.warn = palette.dark_orange
    lsp.colors.hint = palette.bright_blue
    lsp.colors.info = palette.teal
  end
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('UIPalette', { clear = true }),
  callback = function() M.ui.refresh_palette() end,
})
vim.schedule(M.ui.refresh_palette)

-- }}}

-- LSP {{{

M.ui.lsp = {
  colors = {
    error = M.ui.palette.pale_red,
    warn = M.ui.palette.dark_orange,
    hint = M.ui.palette.bright_blue,
    info = M.ui.palette.teal,
  },
  highlights = {
    File = 'Directory',
    Snippet = 'Label',
    Text = '@string',
    Method = '@method',
    Function = '@function',
    Constructor = '@constructor',
    Field = '@field',
    Variable = '@variable',
    Module = '@namespace',
    Property = '@property',
    Unit = '@constant',
    Value = '@variable',
    Enum = '@type',
    Keyword = '@keyword',
    Reference = '@parameter.reference',
    Constant = '@constant',
    Struct = '@structure',
    Event = '@variable',
    Operator = '@operator',
    Namespace = '@namespace',
    Package = '@include',
    String = '@string',
    Number = '@number',
    Boolean = '@boolean',
    Array = '@repeat',
    Object = '@type',
    Key = '@field',
    Null = '@symbol',
    EnumMember = '@field',
    Class = '@lsp.type.class',
    Interface = '@lsp.type.interface',
    TypeParameter = '@lsp.type.parameter',
  },
}

-- }}}

-- Border & floats {{{

M.ui.border = 'rounded'

M.ui.current = {
  border = 'rounded',
  float_bg = function()
    local ok, HL = pcall(require, 'highlight')
    if ok and HL and HL.get then return HL.get('Normal', 'bg') end
    local ok2, hl =
      pcall(vim.api.nvim_get_hl, 0, { name = 'Normal', link = false })
    if ok2 and hl and hl.bg then return ('#%06x'):format(hl.bg) end
    return 'NONE'
  end,
}

-- }}}

-- Decorations {{{

---@class Decorations
---@field winbar 'ignore' | boolean
---@field number boolean
---@field statusline 'minimal' | boolean
---@field statuscolumn boolean
---@field colorcolumn boolean | string

---@alias DecorationType 'statuscolumn'|'winbar'|'statusline'|'number'|'colorcolumn'

local Preset = {}
function Preset:new(o)
  assert(o, 'a preset must be defined')
  self.__index = self
  return setmetatable(o, self)
end
function Preset:with(o) return vim.tbl_deep_extend('force', self, o) end

local presets = {
  statusline_only = Preset:new({
    number = false,
    winbar = false,
    colorcolumn = false,
    statusline = true,
    statuscolumn = false,
  }),
  minimal_editing = Preset:new({
    number = false,
    winbar = true,
    colorcolumn = false,
    statusline = 'minimal',
    statuscolumn = false,
  }),
  tool_panel = Preset:new({
    number = false,
    winbar = false,
    colorcolumn = false,
    statusline = 'minimal',
    statuscolumn = false,
  }),
}

local commit_buffer =
  presets.minimal_editing:with({ colorcolumn = '50,72', winbar = false })

local buftypes = {
  ['quickfix'] = presets.tool_panel,
  ['nofile'] = presets.tool_panel,
  ['nowrite'] = presets.tool_panel,
  ['acwrite'] = presets.tool_panel,
  ['terminal'] = presets.tool_panel,
  ['.*fugitive.*'] = presets.tool_panel,
}

local filetypes = M.p_table({
  ['startuptime'] = presets.tool_panel,
  ['checkhealth'] = presets.tool_panel,
  ['log'] = presets.tool_panel,
  ['help'] = presets.tool_panel,
  ['^copilot.*'] = presets.tool_panel,
  ['dbout'] = presets.tool_panel,
  ['dbui'] = presets.tool_panel,
  ['dapui'] = presets.tool_panel,
  ['minimap'] = presets.tool_panel,
  ['Trouble'] = presets.tool_panel,
  ['tsplayground'] = presets.tool_panel,
  ['list'] = presets.tool_panel,
  ['netrw'] = presets.tool_panel,
  ['flutter.*'] = presets.tool_panel,
  ['NvimTree'] = presets.tool_panel,
  ['undotree'] = presets.tool_panel,
  ['dap-repl'] = presets.tool_panel:with({ winbar = 'ignore' }),
  ['neo-tree'] = presets.tool_panel:with({ winbar = 'ignore' }),
  ['toggleterm'] = presets.tool_panel:with({ winbar = 'ignore' }),
  ['neotest.*'] = presets.tool_panel,
  ['^Neogit.*'] = presets.tool_panel,
  ['.*fugitive.*'] = presets.tool_panel,
  ['query'] = presets.tool_panel,
  ['DiffviewFiles'] = presets.tool_panel,
  ['DiffviewFileHistory'] = presets.tool_panel,
  ['mail'] = presets.statusline_only,
  ['noice'] = presets.statusline_only,
  ['diff'] = presets.statusline_only,
  ['qf'] = presets.statusline_only,
  ['alpha'] = presets.tool_panel:with({ statusline = false }),
  ['fugitive'] = presets.statusline_only,
  ['startify'] = presets.statusline_only,
  ['man'] = presets.minimal_editing,
  ['org'] = presets.minimal_editing:with({ winbar = false }),
  ['norg'] = presets.minimal_editing:with({ winbar = false }),
  ['orgagenda'] = presets.minimal_editing:with({ winbar = false }),
  ['markdown'] = presets.minimal_editing,
  ['himalaya'] = presets.minimal_editing,
  ['gitcommit'] = commit_buffer,
  ['NeogitCommitMessage'] = commit_buffer,
})

local filenames = M.p_table({
  ['option-window'] = presets.tool_panel,
})

M.ui.decorations = {}

---Get the decoration setting for a buffer.
---@param opts {ft: string?, bt: string?, fname: string?, setting: DecorationType}
---@return {ft: any, bt: any, fname: any}?
function M.ui.decorations.get(opts)
  local ft, bt, fname, setting = opts.ft, opts.bt, opts.fname, opts.setting
  if (not ft and not bt and not fname) or not setting then return nil end
  return {
    ft = ft and filetypes[ft] and filetypes[ft][setting],
    bt = bt and buftypes[bt] and buftypes[bt][setting],
    fname = fname and filenames[fname] and filenames[fname][setting],
  }
end

---Set the colorcolumn for a buffer according to filetype/buftype decoration rules.
---@param bufnr integer
---@param fn fun(virtcolumn: string)
function M.ui.decorations.set_colorcolumn(bufnr, fn)
  local buf = vim.bo[bufnr]
  local decor = M.ui.decorations.get({
    ft = buf.ft,
    bt = buf.bt,
    setting = 'colorcolumn',
  })
  if buf.ft == '' or buf.bt ~= '' or decor.ft == false or decor.bt == false then
    return
  end
  local ccol = decor.ft or decor.bt or ''
  local virtcolumn = not M.falsy(ccol) and ccol or '+1'
  if vim.is_callable(fn) then fn(virtcolumn) end
end

-- }}}

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Statusline strings {{{
--------------------------------------------------------------------------------

---@alias StringComponent {component: string, length: integer, priority: integer}
---@alias Chunks {[1]: string | number, [2]: string, max_size: integer?}[]

local CLICK_END = '%X'

local function sl_separator()
  return { component = '%=', length = 0, priority = 0 }
end

local function sl_get_click_start(func_name, id)
  if not id then
    vim.schedule(
      function()
        vim.notify_once(
          fmt('An ID is needed to enable click handler %s to work', func_name),
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
  if not max_size or vim.api.nvim_strwidth(str) < max_size then return str end
  local match, count = str:gsub('([\'"]).*%1', '%1…%1')
  return count > 0 and match or str:sub(1, max_size - 1) .. '…'
end

local function sl_chunks_to_string(chunks)
  chunks = sl_normalize_chunks(chunks)
  if not chunks then return '' end
  local strings = {}
  for _, item in ipairs(chunks) do
    local text, hl = unpack(item)
    if not M.falsy(text) then
      if type(text) ~= 'string' then text = tostring(text) end
      if item.max_size then text = sl_truncate_string(text, item.max_size) end
      text = text:gsub('%%', '%%%1')
      strings[#strings + 1] = not M.falsy(hl)
          and ('%%#%s#%s%%*'):format(hl, text)
        or text
    end
  end
  return table.concat(strings, '')
end

--- @class ComponentOpts
--- @field [1] Chunks
--- @field priority number
--- @field click string
--- @field before string
--- @field after string
--- @field id number
--- @field max_size integer
--- @field cond boolean | number | table | string

local function sl_component(opts)
  assert(opts, 'component options are required')
  if opts.cond ~= nil and M.falsy(opts.cond) then return end

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
  if vim.api.nvim_strwidth(item_str) == 0 then return end

  local click_start = opts.click
      and sl_get_click_start(opts.click, tostring(opts.id))
    or ''
  local click_end = opts.click and CLICK_END or ''
  local component_str =
    table.concat({ click_start, '', item_str, '', click_end })
  return {
    component = component_str,
    length = api.nvim_eval_statusline(component_str, { maxwidth = 0 }).width,
    priority = opts.priority,
  }
end

local function sl_sum_lengths(list)
  return M.fold(
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
  local lowest, index_to_remove
  for idx, c in ipairs(statusline) do
    if sl_is_lowest(c, lowest) then
      lowest, index_to_remove = c, idx
    end
  end
  table.remove(statusline, index_to_remove)
  return sl_prioritize(statusline, space, length - lowest.length)
end

M.strings = {}

--- Creates a spacer statusline component.
---@param size integer?
---@param opts table<string, any>?
---@return ComponentOpts?
function M.strings.spacer(size, opts)
  opts = opts or {}
  local filler = opts.filler or ' '
  local priority = opts.priority or 0
  if not size or size < 1 then return end
  return {
    { { string.rep(filler, size) } },
    priority = priority,
    before = '',
    after = '',
  }
end

--- Render a list of sections into a statusline string, dropping lowest-priority
--- components when space is constrained.
---@param sections ComponentOpts[][]
---@param available_space number?
---@return string
function M.strings.display(sections, available_space)
  local components = M.fold(function(acc, section, count)
    if #section == 0 then
      table.insert(acc, sl_separator())
      return acc
    end
    M.foreach(function(args, index)
      if not args then return end
      local ok, str = M.pcall('Error creating component', sl_component, args)
      if not ok then return end
      table.insert(acc, str)
      if #section == index and count ~= #sections then
        table.insert(acc, sl_separator())
      end
    end, section)
    return acc
  end, sections)

  local items = available_space and sl_prioritize(components, available_space)
    or components
  local str = vim.tbl_map(function(item) return item.component end, items)
  return table.concat(str)
end

--- Section helper: collects StringComponents and supports `+` concatenation.
---@class Section
---@field new fun(...:StringComponent[]): Section
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
M.strings.section = section

-- }}}
--------------------------------------------------------------------------------

return M

-- vim:fdm=marker
