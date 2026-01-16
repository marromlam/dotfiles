----------------------------------------------------------------------------------------------------
-- Styles
----------------------------------------------------------------------------------------------------

-- mrl.p_table is defined in tools.lua, which is loaded before this file in
-- init.lua
--
-- Theme palette (derived from active colorscheme).
-- NOTE: we mutate this table in-place so any modules that captured a reference
-- (e.g. `local P = mrl.ui.palette`) keep seeing updates after `:colorscheme`.
mrl.ui.palette = mrl.ui.palette or {}

local function hex_from_hl(name, attr, fallback)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok or not hl then return fallback end
  local v = hl[attr]
  if not v then return fallback end
  return ('#%06x'):format(v)
end

local function tint(color, percent)
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
  if not ok or not nightfox_palette or not nightfox_palette.load then return nil end
  return nightfox_palette.load(vim.g.colors_name or 'carbonfox')
end

-- Nightfox palette values can be "Color" objects (tables with `.base` and a
-- callable metatable). Normalize everything we store in `mrl.ui.palette` to a
-- hex string so other modules can safely use it.
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

--- Refresh palette from the active colorscheme.
function mrl.ui.refresh_palette()
  -- Prior hardcoded palette as last-resort defaults
  local defaults = {
    green = '#98c379',
    dark_green = '#10B981',
    blue = '#82AAFE',
    dark_blue = '#4e88ff',
    bright_blue = '#51afef',
    teal = '#15AABF',
    pale_pink = '#b490c0',
    magenta = '#c678dd',
    -- "red" should track the theme's git-delete color (see derived.red below)
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
    -- Nightfox palette naming (works across carbonfox/nightfox variants)
    derived.green = as_hex(pal.green, defaults.green)
    derived.blue = as_hex(pal.blue, defaults.blue)
    derived.teal = as_hex(pal.cyan or pal.teal, defaults.teal)
    derived.magenta = as_hex(pal.magenta, defaults.magenta)
    derived.pale_pink = as_hex(pal.pink or pal.magenta, defaults.pale_pink)
    derived.pale_red = as_hex(pal.red, defaults.pale_red)
    -- Prefer the actual GitSignsDelete highlight if available (theme-defined)
    derived.red = hex_from_hl('GitSignsDelete', 'fg', pal.red or defaults.red)
    derived.dark_orange = as_hex(pal.orange, defaults.dark_orange)
    derived.bright_yellow = as_hex(pal.yellow, defaults.bright_yellow)
    derived.light_yellow = as_hex(pal.yellow, defaults.light_yellow)
    derived.comment_grey = as_hex(pal.comment or pal.fg3, defaults.comment_grey)
    derived.whitesmoke = as_hex(pal.fg1 or pal.fg0, defaults.whitesmoke)
    derived.light_gray = as_hex(pal.fg3, defaults.light_gray)
    derived.grey = as_hex(pal.bg3 or pal.bg2, defaults.grey)
  else
    -- Generic fallback: derive from highlight groups
    derived.pale_red = hex_from_hl('DiagnosticError', 'fg', defaults.pale_red)
    derived.red = hex_from_hl('GitSignsDelete', 'fg', derived.pale_red or defaults.red)
    derived.dark_orange = hex_from_hl('DiagnosticWarn', 'fg', defaults.dark_orange)
    derived.teal = hex_from_hl('DiagnosticInfo', 'fg', defaults.teal)
    derived.bright_blue = hex_from_hl('DiagnosticHint', 'fg', defaults.bright_blue)
    derived.green = hex_from_hl('GitSignsAdd', 'fg', defaults.green)
    derived.blue = hex_from_hl('Function', 'fg', defaults.blue)
    derived.magenta = hex_from_hl('Statement', 'fg', defaults.magenta)
    derived.pale_pink = hex_from_hl('Special', 'fg', defaults.pale_pink)
    derived.bright_yellow = hex_from_hl('WarningMsg', 'fg', defaults.bright_yellow)
    derived.light_yellow = derived.bright_yellow
    derived.comment_grey = hex_from_hl('Comment', 'fg', defaults.comment_grey)
    derived.whitesmoke = hex_from_hl('Normal', 'fg', defaults.whitesmoke)
    derived.light_gray = tint(derived.comment_grey, 0.1)
    derived.grey = tint(hex_from_hl('Normal', 'bg', defaults.grey), 0.15)
  end

  derived.dark_green = tint(derived.green, -0.25)
  derived.dark_blue = tint(derived.blue, -0.25)
  derived.light_red = tint(derived.pale_red, -0.15)
  derived.dark_red = tint(derived.pale_red, -0.30)

  -- Write into the shared table in-place
  for k in pairs(mrl.ui.palette) do
    mrl.ui.palette[k] = nil
  end
  for k, v in pairs(defaults) do
    mrl.ui.palette[k] = derived[k] or v
  end
  for k, v in pairs(derived) do
    mrl.ui.palette[k] = v
  end

  -- Keep LSP colors in sync with the palette (if lsp table already exists)
  if mrl.ui.lsp and mrl.ui.lsp.colors then
    mrl.ui.lsp.colors.error = mrl.ui.palette.pale_red
    mrl.ui.lsp.colors.warn = mrl.ui.palette.dark_orange
    mrl.ui.lsp.colors.hint = mrl.ui.palette.bright_blue
    mrl.ui.lsp.colors.info = mrl.ui.palette.teal
  end
end

mrl.ui.border = {
  -- Custom border style:
  -- ▗▄▄▄▖
  -- ▐   ▌
  -- ▝▀▀▀▘
  box = { '▗', '▄', '▖', '▌', '▘', '▀', '▝', '▐' },
  line = { '▗', '▄', '▖', '▌', '▘', '▀', '▝', '▐' },
  rectangle = { '▗', '▄', '▖', '▌', '▘', '▀', '▝', '▐' },
}

mrl.ui.icons = {
  separators = {
    left_thin_block = '▏',
    right_thin_block = '▕',
    vert_bottom_half_block = '▄',
    vert_top_half_block = '▀',
    right_block = '🮉',
    -- right_block = "▕",
    light_shade_block = '░',
    right_chubby_block = '▓',
  },
  -- Unified scrollbar glyph (used by fzf-lua and other UIs).
  -- FULL BLOCK (U+2588) to match fzf-lua preview scrollbar look.
  scrollbar = '█',
  lsp = {
    error = '', -- '✗'
    warn = '', -- 
    info = '󰋼', --  ℹ 󰙎 
    hint = '󰌶', --  ⚑
  },
  git = {
    add = '󰐗', -- ' '', -- '',
    mod = '󰻂', -- '󱗜' --'',
    remove = '󰍶', --'', -- '',
    ignore = '', --'',
    rename = '', -- '',
    untracked = '', -- '',
    ignored = '󰙦', --  '',
    unstaged = '󰻂', --'󰄱',
    staged = '', --'',
    conflict = '',
    diff = '',
    repo = '',
    logo = '󰊢',
    branch = '', -- '',
  },
  documents = {
    file = '',
    files = '',
    folder = '',
    open_folder = '',
  },
  misc = {
    -- 
    plus = '',
    ellipsis = '…',
    up = '⇡',
    down = '⇣',
    line = '', -- 'ℓ'
    indent = 'Ξ',
    tab = '⇥',
    bug = '', --  '󰠭'
    question = '',
    clock = '',
    cmd = '⌘',
    lock = '',
    shaded_lock = '',
    circle = '',
    project = '',
    dashboard = '',
    history = '󰄉',
    comment = '󰅺',
    robot = '󰚩',
    copilot = '',
    lightbulb = '󰌵',
    search = '󰍉',
    code = '',
    telescope = '',
    gear = '',
    chat = '󰭻',
    package = '',
    list = '',
    sign_in = '',
    check = '󰄬',
    fire = '',
    note = '󰎞',
    bookmark = '',
    pencil = '', -- '󰏫',
    tools = '',
    arrow_right = '',
    caret_right = '',
    chevron_right = '',
    double_chevron_right = '»',
    table = '',
    calendar = '',
    -- block = "▌",
    block = '▏',
    clippy = '',
    puzzle = '',
    settings = '⚙',
    key = '',
    config = '',
    box = '',
    moon = '󰤄',
    source = '󰈙',
    sleep = '󰒲',
    rocket = '',
    task = '󰐃',
    runtime = '',
  },
}
mrl.ui.lsp = {
  colors = {
    error = mrl.ui.palette.pale_red,
    warn = mrl.ui.palette.dark_orange,
    hint = mrl.ui.palette.bright_blue,
    info = mrl.ui.palette.teal,
  },
  --- This is a mapping of LSP Kinds to highlight groups. LSP Kinds come via the LSP spec
  --- see: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
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

-- Keep palette synced to the active colorscheme.
vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
  group = vim.api.nvim_create_augroup('MrlUIPalette', { clear = true }),
  callback = function() mrl.ui.refresh_palette() end,
})
vim.schedule(mrl.ui.refresh_palette)

----------------------------------------------------------------------------------------------------
-- UI Settings
----------------------------------------------------------------------------------------------------
---@class Decorations {
---@field winbar 'ignore' | boolean
---@field number boolean
---@field statusline 'minimal' | boolean
---@field statuscolumn boolean
---@field colorcolumn boolean | string

---@alias DecorationType 'statuscolumn'|'winbar'|'statusline'|'number'|'colorcolumn'

---@class Decorations
local Preset = {}

---@param o Decorations
function Preset:new(o)
  assert(o, 'a preset must be defined')
  self.__index = self
  return setmetatable(o, self)
end

--- WARNING: deep extend does not copy lua meta methods
function Preset:with(o) return vim.tbl_deep_extend('force', self, o) end

---@type table<string, Decorations>
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

--- When searching through the filetypes table if a match can't be found then search
--- again but check if there is matching lua pattern. This is useful for filetypes for
--- plugins like Neogit which have a filetype of Neogit<something>.
local filetypes = mrl.p_table({
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

local filenames = mrl.p_table({
  ['option-window'] = presets.tool_panel,
})

mrl.ui.decorations = {}

---@alias ui.OptionValue (boolean | string)

---Get the mrl.ui setting for a particular filetype
---@param opts {ft: string?, bt: string?, fname: string?, setting: DecorationType}
---@return {ft: ui.OptionValue?, bt: ui.OptionValue?, fname: ui.OptionValue?}
function mrl.ui.decorations.get(opts)
  local ft, bt, fname, setting = opts.ft, opts.bt, opts.fname, opts.setting
  if (not ft and not bt and not fname) or not setting then return nil end
  return {
    ft = ft and filetypes[ft] and filetypes[ft][setting],
    bt = bt and buftypes[bt] and buftypes[bt][setting],
    fname = fname and filenames[fname] and filenames[fname][setting],
  }
end

---A helper to set the value of the colorcolumn option, to my preferences, this can be used
---in an autocommand to set the `vim.opt_local.colorcolumn` or by a plugin such as `virtcolumn.nvim`
---to set it's virtual column
---@param bufnr integer
---@param fn fun(virtcolumn: string)
function mrl.ui.decorations.set_colorcolumn(bufnr, fn)
  local buf = vim.bo[bufnr]
  local decor = mrl.ui.decorations.get({
    ft = buf.ft,
    bt = buf.bt,
    setting = 'colorcolumn',
  })
  if buf.ft == '' or buf.bt ~= '' or decor.ft == false or decor.bt == false then
    return
  end
  local ccol = decor.ft or decor.bt or ''
  local virtcolumn = not mrl.falsy(ccol) and ccol or '+1'
  if vim.is_callable(fn) then fn(virtcolumn) end
end

----------------------------------------------------------------------------------------------------
mrl.ui.current = {
  border = mrl.ui.border.box, -- Global border style
  -- Float/popup background color source of truth.
  -- Kept as a function so it always matches the active colorscheme's Normal bg.
  float_bg = function()
    -- Prefer our highlight helper (returns hex)
    if mrl and mrl.highlight and mrl.highlight.get then
      return mrl.highlight.get('Normal', 'bg')
    end

    -- Fallback to Neovim API (also returns hex)
    local ok, hl =
      pcall(vim.api.nvim_get_hl, 0, { name = 'Normal', link = false })
    if ok and hl and hl.bg then return ('#%06x'):format(hl.bg) end
    return 'NONE'
  end,
}
