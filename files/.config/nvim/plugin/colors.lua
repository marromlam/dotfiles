if not mrl then return end
local P = mrl.ui.palette
local highlight = mrl.highlight


function mrl.get_hi(name, id)
  id = id or 0
  local hi = vim.api.nvim_get_hl(0, { name = name })
  -- hi is a table with bg and fg keys. for those we want to return the hex
  -- value with ('#%06x'):format(num)
  for k, v in pairs(hi) do
    if type(v) == 'number' then hi[k] = ('#%06x'):format(v) end
  end
  return hi
end

local function general_overrides()
  local is_dark = vim.g.high_contrast_theme
  local dim_factor = is_dark and 0.75 or 0.25
  local normal_bg = highlight.get('Normal', 'bg')
  local bg_color = highlight.tint(normal_bg, -dim_factor)
  local bg_color2 = highlight.tint(normal_bg, -1.5 * dim_factor)
  highlight.all({
    ---------------------------------------------------------------------------
    -- Native
    ---------------------------------------------------------------------------
    { VertSplit = { fg = { from = 'Comment' } } },
    { StatusLine = { fg = bg_color, bg = { from = 'Comment' } } },
    -- { PanelSt = { link = 'StatusLine' } },
    -- Neotree
    { NeoTreeNormal = { bg = bg_color, fg = { from = 'Normal' } } },
    { NeoTreeNormalNC = { bg = bg_color, fg = { from = 'Normal' } } },
    { NeoTreeCursorLine = { bg = bg_color2 }},
    { NeoTreeWinSeparator = { fg = { from = 'Normal', attr = 'bg' } } },
    { NeoTreeWinSeparatorNC = { fg = { from = 'Normal', attr = 'bg' } } },
    -- { NeoTreeCursorLine = { link = 'Visual' } },
    { NeoTreeRootName = { underline = true } },
    { NeoTreeStatusLine = { link = 'PanelSt' } },
    { NeoTreeTabActive = { bg = bg_color, bold = true } },
    { NeoTreeTabInactive = { bg = bg_color, fg = { from = 'Comment' } } },
    { NeoTreeTabSeparatorActive = { inherit = 'PanelBackground', fg = { from = 'Comment' } } },
    { NeoTreeDirectoryIcon = { link = 'WarningMsg' } },
    { NeoTreeTabSeparatorActive = { bg=bg_color, fg=bg_color }},
    { NeoTreeTabSeparatorInactive = { bg=bg_color, fg=bg_color }},
    -- Search count
    { StSearchCount = { fg = "#333333", bg = "#dddddd" } },
    { StSeparator = { fg = "#00aaff", bg = bg_color } },
    { StModified = { fg = "#ffaaff", bg = bg_color } },
    -- { Statusline = { fg = bg_color, bg="#4aa2b4" } },
    { WinSeparator = { fg = { from = 'Comment' } } },
    { CursorLine = { bg = { from = 'Normal', alter = dim_factor } } },
    { CursorLineNr = { bg = 'NONE' } },
    { iCursor = { bg = P.dark_blue } },
    { PmenuSbar = { link = 'Normal' } },
    { Folded = { fg = { from = 'Normal' }, bg = { from = 'Normal', alter = is_dark and 0.3 or 0.1 } } },
    ---------------------------------------------------------------------------
    -- Floats
    ---------------------------------------------------------------------------
    { NormalFloat = { bg = { from = 'Normal', alter = -0.15 } } },
    { FloatBorder = { bg = { from = 'NormalFloat' }, fg = { from = 'Comment' } } },
    { FloatTitle = { bold = true, fg = 'white', bg = { from = 'FloatBorder', attr = 'fg' } } },
    ---------------------------------------------------------------------------
    -- Created highlights
    ---------------------------------------------------------------------------
    { Dim = { fg = { from = 'Normal', attr = 'bg', alter = dim_factor } } },
    { PickerBorder = { link = 'Normal' } },
    { UnderlinedTitle = { bold = true, underline = true } },
    { StatusColSep = { link = 'Dim' } },
    ---------------------------------------------------------------------------
    { CodeBlock = { bg = { from = 'Normal', alter = 0.3 } } },
    { markdownCode = { link = 'CodeBlock' } },
    { markdownCodeBlock = { link = 'CodeBlock' } },
    ---------------------------------------------------------------------------
    --  Spell
    ---------------------------------------------------------------------------
    { SpellBad = { undercurl = true, bg = 'NONE', fg = 'NONE', sp = 'green' } },
    { SpellRare = { undercurl = true } },
    ---------------------------------------------------------------------------
    -- Diff
    ---------------------------------------------------------------------------
    -- { DiffAdd = { bg = '#26332c', fg = 'NONE', underline = false } },
    -- { DiffDelete = { bg = '#572E33', fg = '#5c6370', underline = false } },
    -- { DiffChange = { bg = '#273842', fg = 'NONE', underline = false } },
    -- { DiffText = { bg = '#314753', fg = 'NONE' } },
    -- these highlights are syntax groups that are set in diff.vim
    { diffAdded = { inherit = 'DiffAdd' } },
    { diffChanged = { inherit = 'DiffChange' } },
    { diffRemoved = { link = 'DiffDelete' } },
    { diffBDiffer = { link = 'WarningMsg' } },
    { diffCommon = { link = 'WarningMsg' } },
    { diffDiffer = { link = 'WarningMsg' } },
    { diffFile = { link = 'Directory' } },
    { diffIdentical = { link = 'WarningMsg' } },
    { diffIndexLine = { link = 'Number' } },
    { diffIsA = { link = 'WarningMsg' } },
    { diffNoEOL = { link = 'WarningMsg' } },
    { diffOnly = { link = 'WarningMsg' } },
    ---------------------------------------------------------------------------
    -- colorscheme overrides
    ---------------------------------------------------------------------------
    { Type = { italic = true, bold = true } },
    { Include = { italic = true, bold = false } },
    { QuickFixLine = { inherit = 'CursorLine', fg = 'NONE', italic = true } },
    -- Neither the sign column or end of buffer highlights require an explicit bg
    -- they should both just use the bg that is in the window they are in.
    -- if either are specified this can lead to issues when a winhighlight is set
    { SignColumn = { bg = 'NONE' } },
    { EndOfBuffer = { bg = 'NONE' } },
    ----------------------------------------------------------------------------
    --  Semantic tokens
    ----------------------------------------------------------------------------
    { ['@lsp.type.variable'] = { clear = true } },
    { ['@lsp.type.parameter'] = { italic = true, fg = { from = 'Normal' } } },
    { ['@lsp.typemod.method'] = { link = '@method' } },
    { ['@lsp.typemod.variable.global'] = { bold = true, inherit = '@constant.builtin' } },
    { ['@lsp.typemod.variable.defaultLibrary'] = { italic = true } },
    { ['@lsp.typemod.variable.readonly.typescriptreact'] = { clear = true } },
    { ['@lsp.typemod.variable.readonly.typescript'] = { clear = true } },
    { ['@lsp.type.type.lua'] = { clear = true } },
    { ['@lsp.typemod.number.injected'] = { link = '@number' } },
    { ['@lsp.typemod.operator.injected'] = { link = '@operator' } },
    { ['@lsp.typemod.keyword.injected'] = { link = '@keyword' } },
    { ['@lsp.typemod.string.injected'] = { link = '@string' } },
    { ['@lsp.typemod.variable.injected'] = { link = '@variable' } },
    ---------------------------------------------------------------------------
    -- Treesitter
    ---------------------------------------------------------------------------
    { ['@keyword.return'] = { italic = true, fg = { from = 'Keyword' } } },
    { ['@type.qualifier'] = { inherit = '@keyword', italic = true } },
    { ['@variable'] = { clear = true } },
    { ['@parameter'] = { italic = true, bold = true, fg = 'NONE' } },
    { ['@error'] = { fg = 'fg', bg = 'NONE' } },
    { ['@text.diff.add'] = { link = 'DiffAdd' } },
    { ['@text.diff.delete'] = { link = 'DiffDelete' } },
    { ['@text.title.markdown'] = { underdouble = true } },
    ---------------------------------------------------------------------------
    -- LSP
    ---------------------------------------------------------------------------
    { LspReferenceWrite = { inherit = 'LspReferenceText', bold = true, italic = true, underline = true } },
    { LspSignatureActiveParameter = { link = 'Visual' } },
    -- Sign column line
    { DiagnosticSignInfoLine = { inherit = 'DiagnosticVirtualTextInfo', fg = 'NONE' } },
    { DiagnosticSignHintLine = { inherit = 'DiagnosticVirtualTextHint', fg = 'NONE' } },
    { DiagnosticSignErrorLine = { inherit = 'DiagnosticVirtualTextError', fg = 'NONE' } },
    { DiagnosticSignWarnLine = { inherit = 'DiagnosticVirtualTextWarn', fg = 'NONE' } },
    -- Floating windows
    { DiagnosticFloatingWarn = { link = 'DiagnosticWarn' } },
    { DiagnosticFloatingInfo = { link = 'DiagnosticInfo' } },
    { DiagnosticFloatingHint = { link = 'DiagnosticHint' } },
    { DiagnosticFloatingError = { link = 'DiagnosticError' } },
    { DiagnosticFloatTitle = { inherit = 'FloatTitle', bold = true } },
    { DiagnosticFloatTitleIcon = { inherit = 'FloatTitle', fg = { from = '@character' } } },
    ---------------------------------------------------------------------------
    --- Diagnostic Signa
    ---------------------------------------------------------------------------
    -- {DiagnosticSignWarnLine = { bg = mrl.get_hi('SignColumn').bg, fg = mrl.get_hi('GitSignsDelete').fg }},
    -- { DiagnosticSignWarn = { bg = mrl.get_hi('Normal').bg, fg = mrl.get_hi('DiagnosticWarn').fg } },
    -- {DiagnosticSignErrorLine = { bg = mrl.get_hi('SignColumn').bg }},
    -- { DiagnosticSignError = { bg = mrl.get_hi('Normal').bg, fg = mrl.get_hi('GitSignsDelete').fg } },
    -- {DiagnosticSignHintLine = { bg = mrl.get_hi('SignColumn').bg }},
    -- { DiagnosticSignHint = { bg = mrl.get_hi('Normal').bg, fg = mrl.get_hi('MoreMsg').fg } },
    -- {DiagnosticSignInfoLine = { bg = mrl.get_hi('SignColumn').bg }},
    -- { DiagnosticSignInfo = { bg = mrl.get_hi('Normal').bg, fg = mrl.get_hi('MoreMsg').fg } },
    ---------------------------------------------------------------------------
    -- FzfLua {{{
    ---------------------------------------------------------------------------
    -- FzfLuaNormal	Normal	hls.normal	Main win fg/bg
    { FzfLuaNormal = { bg = { from = 'Normal', attr = 'bg' }, fg = { from = 'Normal', attr = 'fg' }}},
    -- FzfLuaBorder	Normal	hls.border	Main win border
    -- FzfLuaTitle	FzfLuaNormal	hls.title	Main win title
    -- FzfLuaBackdrop	*bg=Black	hls.backdrop	Backdrop color
    -- FzfLuaPreviewNormal	FzfLuaNormal	hls.preview_normal	Builtin preview fg/bg
    -- FzfLuaPreviewBorder	FzfLuaBorder	hls.preview_border	Builtin preview border
    -- FzfLuaPreviewTitle	FzfLuaTitle	hls.preview_title	Builtin preview title
    -- { FzfLuaCursor = { bg = "#ff00ff", fg = "#00ff00"} },
    -- { FzfLuaCursor = { bg =  "#ff00ff" , fg = { from = 'Normal', attr = 'fg' }}},
    -- { FzfLuaCursorLine = { bg = "#ffff00", fg = "#00ff00"} },
    -- FzfLuaCursor	Cursor	hls.cursor	Builtin preview Cursor
    -- FzfLuaCursorLine	CursorLine	hls.cursorline	Builtin preview Cursorline
    -- FzfLuaCursorLineNr	CursorLineNr	hls.cursorlinenr	Builtin preview CursorLineNr
    -- FzfLuaSearch	IncSearch	hls.search	Builtin preview search matches
    -- FzfLuaScrollBorderEmpty	FzfLuaBorder	hls.scrollborder_e	Builtin preview border scroll empty
    -- FzfLuaScrollBorderFull	FzfLuaBorder	hls.scrollborder_f	Builtin preview border scroll full
    -- FzfLuaScrollFloatEmpty	PmenuSbar	hls.scrollfloat_e	Builtin preview float scroll empty
    -- FzfLuaScrollFloatFull	PmenuThumb	hls.scrollfloat_f	Builtin preview float scroll full
    -- FzfLuaHelpNormal	FzfLuaNormal	hls.help_normal	Help win fg/bg
    -- FzfLuaHelpBorder	FzfLuaBorder	hls.help_border	Help win border
    -- FzfLuaHeaderBind	*BlanchedAlmond	hls.header_bind	Header keybind
    -- FzfLuaHeaderText	*Brown1	hls.header_text	Header text
    -- FzfLuaPathColNr	*CadetBlue1	hls.path_colnr	Path col nr (lines,qf,lsp,diag)
    -- FzfLuaPathLineNr	*LightGreen	hls.path_linenr	Path line nr (lines,qf,lsp,diag)
    -- FzfLuaBufName	*LightMagenta	hls.buf_name	Buffer name (lines)
    -- FzfLuaBufNr	*BlanchedAlmond	hls.buf_nr	Buffer number (all buffers)
    -- FzfLuaBufFlagCur	*Brown1	hls.buf_flag_cur	Buffer line (buffers)
    -- FzfLuaBufFlagAlt	*CadetBlue1	hls.buf_flag_alt	Buffer line (buffers)
    -- FzfLuaTabTitle	*LightSkyBlue1	hls.tab_title	Tab title (tabs)
    -- FzfLuaTabMarker	*BlanchedAlmond	hls.tab_marker	Tab marker (tabs)
    -- FzfLuaDirIcon	Directory	hls.dir_icon	Paths directory icon
    -- FzfLuaDirPart	Comment	hls.dir_part	Path formatters directory hl group
    -- FzfLuaFilePart	@none	hls.file_part	Path formatters file hl group
    -- FzfLuaLiveSym	*Brown1	hls.live_sym	LSP live symbols query match
    { FzfLuaFzfNormal = { bg = "#ffff00", fg = "#00ff00"} },
    -- { FzfLuaFzfCursorLine = { bg = "#ffff00", fg = "#00ff00"} },
    -- { FzfLuaFzfPrompt = { bg = "#ff0000", fg = "#00ff00"} },
    { ['@fzf.normal'] = { bg = "#ff0000", fg = "#00ff00"} },
    -- FzfLuaFzfNormal	FzfLuaNormal	fzf.normal	fzf's fg|bg
    -- FzfLuaFzfCursorLine	FzfLuaCursorLine	fzf.cursorline	fzf's fg+|bg+
    -- FzfLuaFzfMatch	Special	fzf.match	fzf's hl+
    -- FzfLuaFzfBorder	FzfLuaBorder	fzf.border	fzf's border
    -- FzfLuaFzfScrollbar	FzfLuaFzfBorder	fzf.scrollbar	fzf's scrollbar
    -- FzfLuaFzfSeparator	FzfLuaFzfBorder	fzf.separator	fzf's separator
    -- FzfLuaFzfGutter	FzfLuaNormal	fzf.gutter	fzf's gutter (hl bg is used)
    -- FzfLuaFzfHeader	FzfLuaTitle	fzf.header	fzf's header
    -- FzfLuaFzfInfo	NonText	fzf.info	fzf's info
    -- FzfLuaFzfPointer	Special	fzf.pointer	fzf's pointer
    -- FzfLuaFzfMarker	FzfLuaFzfPointer	fzf.marker	fzf's marker
    -- FzfLuaFzfSpinner	FzfLuaFzfPointer	fzf.spinner	fzf's spinner
    -- FzfLuaFzfPrompt	Special	fzf.prompt	fzf's prompt
    -- FzfLuaFzfQuery	FzfLuaNormal	fzf.query	fzf's header
    -- }}}
    ---------------------------------------------------------------------------
  })
end

local function set_sidebar_highlight()
  highlight.all({
    { PanelDarkBackground = { bg = { from = 'Normal', alter = -0.42 } } },
    { PanelDarkHeading = { inherit = 'PanelDarkBackground', bold = true } },
    { PanelBackground = { bg = { from = 'Normal', alter = -0.8 } } },
    { PanelHeading = { inherit = 'PanelBackground', bold = true } },
    { PanelWinSeparator = { inherit = 'PanelBackground', fg = { from = 'WinSeparator' } } },
    { PanelStNC = { link = 'PanelWinSeparator' } },
    { PanelSt = { bg = { from = 'Normal', alter = -0.2 } } },
  })
end

local sidebar_fts = {
  'flutterToolsOutline',
  'undotree',
  'Outline',
  'dbui',
  'neotest-summary',
}

local function on_sidebar_enter()
  vim.opt_local.winhighlight:append({
    Normal = 'PanelBackground',
    EndOfBuffer = 'PanelBackground',
    StatusLine = 'PanelSt',
    StatusLineNC = 'PanelStNC',
    SignColumn = 'PanelBackground',
    VertSplit = 'PanelVertSplit',
    WinSeparator = 'PanelWinSeparator'
  })
end

local function colorscheme_overrides()
  local overrides = {
    ['horizon'] = {
      { Constant = { bold = true } },
      { NonText = { fg = { from = 'Comment' } } },
      { TabLineSel = { fg = { from = 'SpecialKey' } } },
      { ['@variable'] = { fg = { from = 'Normal' } } },
      { ['@constant.comment'] = { inherit = 'Constant', bold = true } },
      { ['@constructor.lua'] = { inherit = 'Type', italic = false, bold = false } },
      { ['@lsp.type.parameter'] = { fg = { from = 'Normal' } } },
      { VisibleTab = { bg = { from = 'Normal', alter = 0.4 }, bold = true } },
      { PanelBackground = { link = 'Normal' } },
      { PanelWinSeparator = { inherit = 'PanelBackground', fg = { from = 'WinSeparator' } } },
      { PanelHeading = { bg = 'bg', bold = true, fg = { from = 'Normal', alter = -0.3 } } },
      { PanelDarkBackground = { bg = { from = 'Normal', alter = -0.25 } } },
      { PanelDarkHeading = { inherit = 'PanelDarkBackground', bold = true } },
    },
    ['github_dark_default'] = {
      { TabLineSel = { link = 'Todo' } },
    },
  }
  local hls = overrides[vim.g.colors_name]
  if hls then highlight.all(hls) end
end

local function user_highlights()
  general_overrides()
  set_sidebar_highlight()
  colorscheme_overrides()
end

mrl.augroup('UserHighlights', {
  event = 'ColorScheme',
  command = function() user_highlights() end,
}, {
  event = 'FileType',
  pattern = sidebar_fts,
  command = function() on_sidebar_enter() end,
})
