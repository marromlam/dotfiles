if not mrl then return end
local highlight = mrl.highlight

local function general_overrides(dim_factor)
  local is_dark = vim.g.high_contrast_theme
  local normal_bg = highlight.get('Normal', 'bg')
  local bg_color = highlight.tint(normal_bg, -dim_factor)
  local bg_color2 = highlight.tint(normal_bg, 0.5 * dim_factor)
  highlight.all({
    -- { PanelSt = { link = 'StatusLine' } },
    { TabLineSel = { fg = { from = 'Normal' }, bg = '#ff0000' } },
    -- Status line {{{
    -- Search count
    { Statusline = { fg = { from = 'Normal', attr = 'fg' }, bg = bg_color } },
    -- { StatuslineNC = { fg = { from = 'Normal', attr = 'fg' }, fg = bg_color } },
    { StatusLine = { fg = { from = 'Normal', attr = 'fg' }, bg = bg_color } },
    -- { StatusLineNC = { bg = { from = 'Normal', attr = 'fg' }, fg = bg_color } },
    { StSeparator = { fg = 'NONE', bg = 'NONE' } },
    {
      StSearchCount = {
        fg = { from = 'Normal', attr = 'bg' },
        bg = { from = 'Normal', attr = 'fg' },
      },
    },
    -- { StSeparator = { bg = '#00aaff', fg = bg_color } },
    { StModified = { fg = '#ffaaff', bg = bg_color } },
    { StTitle = { fg = { from = 'Normal', attr = 'fg' }, bg = bg_color } },
    { StFaded = { fg = { from = 'Comment', attr = 'fg' }, bg = bg_color } },
    -- { StGit = { fg = '#ff0000', bg = '#00ff00' } },
    {
      StBranch = {
        fg = { from = 'DiagnosticInfo', attr = 'fg' },
        bg = bg_color,
      },
    },
    {
      StGitAdd = { fg = { from = 'GitSignsAdd', attr = 'fg' }, bg = bg_color },
    },
    {
      StGitDelete = {
        fg = { from = 'GitSignsDelete', attr = 'fg' },
        bg = bg_color,
      },
    },
    {
      StGitModified = {
        fg = { from = 'DiagnosticWarn', attr = 'fg' },
        bg = bg_color,
      },
    },
    {
      StInfo = { fg = { from = 'DiagnosticInfo', attr = 'fg' }, bg = bg_color },
    },
    {
      StWarn = { fg = { from = 'DiagnosticWarn', attr = 'fg' }, bg = bg_color },
    },
    {
      StError = {
        fg = { from = 'DiagnosticError', attr = 'fg' },
        bg = bg_color,
      },
    },
    {
      StFilename = {
        fg = { from = 'Normal', attr = 'fg' },
        bg = bg_color,
        bold = true,
      },
    },
    {
      StEnv = {
        fg = { from = 'DiagnosticError', attr = 'fg' },
        bg = bg_color,
        bold = true,
        italic = true,
      },
    },
    {
      StDirectory = {
        fg = { from = 'Comment', attr = 'fg' },
        bg = bg_color,
        italic = true,
      },
    },
    -- { StFilename = { fg = '#0000ff', bg = bg_color } },
    {
      StParent = {
        fg = { from = 'DiagnosticWarn', attr = 'fg' },
        bg = bg_color,
        italic = true,
      },
    },
    -- }}}
    -- Neotree {{{
    { NeoTreeStatusLine = { link = 'Statusline' } },
    { NeoTreeNormal = { bg = bg_color, fg = { from = 'Normal' } } },
    { NeoTreeNormalNC = { bg = bg_color, fg = { from = 'Normal' } } },
    { NeoTreeCursorLine = { bg = bg_color2 } },
    { NeoTreeWinSeparator = { fg = { from = 'Normal', attr = 'bg' } } },
    { NeoTreeWinSeparatorNC = { fg = { from = 'Normal', attr = 'bg' } } },
    -- { NeoTreeCursorLine = { link = 'Visual' } },
    { NeoTreeRootName = { underline = true } },
    { NeoTreeTabActive = { bg = bg_color, bold = true } },
    { NeoTreeTabInactive = { bg = bg_color, fg = { from = 'Comment' } } },
    {
      NeoTreeTabSeparatorActive = {
        inherit = 'PanelBackground',
        fg = { from = 'Comment' },
      },
    },
    { NeoTreeDirectoryIcon = { link = 'WarningMsg' } },
    { NeoTreeTabSeparatorActive = { bg = bg_color, fg = bg_color } },
    { NeoTreeTabSeparatorInactive = { bg = bg_color, fg = bg_color } },
    -- }}}
    -- Symbol Usage {{{
    { SymbolUsageLeft = { fg = bg_color } },
    { SymbolUsageRight = { fg = bg_color } },
    {
      SymbolUsageContent = {
        bg = bg_color,
        fg = { from = 'Comment' },
      },
    },
    -- }}}
    -- xxx {{{
    { VertSplit = { fg = { from = 'Comment' } } },
    { WinSeparator = { fg = { from = 'Comment' } } },
    { CursorLine = { bg = { from = 'Normal', alter = dim_factor } } },
    { CursorLineNr = { bg = 'NONE' } },
    { iCursor = { bg = '#00aaff' } },
    { PmenuSbar = { link = 'Normal' } },
    {
      Folded = {
        fg = { from = 'Normal' },
        bg = { from = 'Normal', alter = is_dark and 0.3 or 0.1 },
      },
    },
    -- }}}
    -- Floats {{{
    { NormalFloat = { bg = { from = 'Normal', alter = -0.15 } } },
    {
      FloatBorder = { bg = { from = 'NormalFloat' }, fg = { from = 'Comment' } },
    },
    {
      FloatTitle = {
        bold = true,
        fg = 'white',
        bg = { from = 'FloatBorder', attr = 'fg' },
      },
    },
    -- }}}
    -- Created highlights {{{
    { Dim = { fg = { from = 'Normal', attr = 'bg', alter = dim_factor } } },
    { PickerBorder = { link = 'Normal' } },
    { UnderlinedTitle = { bold = true, underline = true } },
    { StatusColSep = { link = 'Dim' } },
    { CodeBlock = { bg = { from = 'Normal', alter = 0.3 } } },
    { markdownCode = { link = 'CodeBlock' } },
    { markdownCodeBlock = { link = 'CodeBlock' } },
    -- }}}
    --  Spell {{{
    { SpellBad = { undercurl = true, bg = 'NONE', fg = 'NONE', sp = 'green' } },
    { SpellRare = { undercurl = true } },
    -- }}}
    -- Diff {{{
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
    -- }}}
    -- colorscheme overrides {{{
    { Type = { italic = true, bold = true } },
    { Include = { italic = true, bold = false } },
    { QuickFixLine = { inherit = 'CursorLine', fg = 'NONE', italic = true } },
    -- Neither the sign column or end of buffer highlights require an explicit bg
    -- they should both just use the bg that is in the window they are in.
    -- if either are specified this can lead to issues when a winhighlight is set
    { SignColumn = { bg = 'NONE' } },
    { EndOfBuffer = { bg = 'NONE' } },
    -- }}}
    --  Semantic tokens {{{
    --  lsp
    { ['@lsp.type.variable'] = { clear = true } },
    { ['@lsp.type.parameter'] = { italic = true, fg = { from = 'Normal' } } },
    { ['@lsp.typemod.method'] = { link = '@method' } },
    {
      ['@lsp.typemod.variable.global'] = {
        bold = true,
        inherit = '@constant.builtin',
      },
    },
    { ['@lsp.typemod.variable.defaultLibrary'] = { italic = true } },
    { ['@lsp.typemod.variable.readonly.typescriptreact'] = { clear = true } },
    { ['@lsp.typemod.variable.readonly.typescript'] = { clear = true } },
    { ['@lsp.type.type.lua'] = { clear = true } },
    { ['@lsp.typemod.number.injected'] = { link = '@number' } },
    { ['@lsp.typemod.operator.injected'] = { link = '@operator' } },
    { ['@lsp.typemod.keyword.injected'] = { link = '@keyword' } },
    { ['@lsp.typemod.string.injected'] = { link = '@string' } },
    { ['@lsp.typemod.variable.injected'] = { link = '@variable' } },
    -- Treesitter
    { ['@keyword.return'] = { italic = true, fg = { from = 'Keyword' } } },
    { ['@type.qualifier'] = { inherit = '@keyword', italic = true } },
    { ['@variable'] = { clear = true } },
    { ['@parameter'] = { italic = true, bold = true, fg = 'NONE' } },
    { ['@error'] = { fg = 'fg', bg = 'NONE' } },
    { ['@text.diff.add'] = { link = 'DiffAdd' } },
    { ['@text.diff.delete'] = { link = 'DiffDelete' } },
    { ['@text.title.markdown'] = { underdouble = true } },
    -- }}}
    -- LSP {{{
    {
      LspReferenceWrite = {
        inherit = 'LspReferenceText',
        bold = true,
        italic = true,
        underline = true,
      },
    },
    { LspSignatureActiveParameter = { link = 'Visual' } },
    -- Sign column line
    {
      DiagnosticSignInfoLine = {
        inherit = 'DiagnosticVirtualTextInfo',
        fg = 'NONE',
      },
    },
    {
      DiagnosticSignHintLine = {
        inherit = 'DiagnosticVirtualTextHint',
        fg = 'NONE',
      },
    },
    {
      DiagnosticSignErrorLine = {
        inherit = 'DiagnosticVirtualTextError',
        fg = 'NONE',
      },
    },
    {
      DiagnosticSignWarnLine = {
        inherit = 'DiagnosticVirtualTextWarn',
        fg = 'NONE',
      },
    },
    -- Floating windows
    { DiagnosticFloatingWarn = { link = 'DiagnosticWarn' } },
    { DiagnosticFloatingInfo = { link = 'DiagnosticInfo' } },
    { DiagnosticFloatingHint = { link = 'DiagnosticHint' } },
    { DiagnosticFloatingError = { link = 'DiagnosticError' } },
    { DiagnosticFloatTitle = { inherit = 'FloatTitle', bold = true } },
    {
      DiagnosticFloatTitleIcon = {
        inherit = 'FloatTitle',
        fg = { from = '@character' },
      },
    },
    ---------------------------------------------------------------------------
    --- Avante Color Configuration
    ---------------------------------------------------------------------------

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
    -- }}}
    -- FzfLua {{{
    -- FzfLuaNormal Normal  hls.normal  Main win fg/bg
    {
      FzfLuaNormal = {
        bg = { from = 'Normal', attr = 'bg' },
        fg = { from = 'Normal', attr = 'fg' },
      },
    },
    -- FzfLuaBorder Normal  hls.border  Main win border
    -- FzfLuaTitle  FzfLuaNormal    hls.title   Main win title
    -- FzfLuaBackdrop   *bg=Black   hls.backdrop    Backdrop color
    -- FzfLuaPreviewNormal  FzfLuaNormal    hls.preview_normal  Builtin preview fg/bg
    -- FzfLuaPreviewBorder  FzfLuaBorder    hls.preview_border  Builtin preview border
    -- FzfLuaPreviewTitle   FzfLuaTitle hls.preview_title   Builtin preview title
    -- { FzfLuaCursor = { bg = "#ff00ff", fg = "#00ff00"} },
    -- { FzfLuaCursor = { bg =  "#ff00ff" , fg = { from = 'Normal', attr = 'fg' } } },
    -- { FzfLuaCursorLine = { bg = "#ffff00", fg = "#00ff00"} },
    -- FzfLuaCursor Cursor  hls.cursor  Builtin preview Cursor
    -- FzfLuaCursorLine CursorLine  hls.cursorline  Builtin preview Cursorline
    -- FzfLuaCursorLineNr   CursorLineNr    hls.cursorlinenr    Builtin preview CursorLineNr
    -- FzfLuaSearch IncSearch   hls.search  Builtin preview search matches
    -- FzfLuaScrollBorderEmpty  FzfLuaBorder    hls.scrollborder_e  Builtin preview border scroll empty
    -- FzfLuaScrollBorderFull   FzfLuaBorder    hls.scrollborder_f  Builtin preview border scroll full
    -- FzfLuaScrollFloatEmpty   PmenuSbar   hls.scrollfloat_e   Builtin preview float scroll empty
    -- FzfLuaScrollFloatFull    PmenuThumb  hls.scrollfloat_f   Builtin preview float scroll full
    -- FzfLuaHelpNormal FzfLuaNormal    hls.help_normal Help win fg/bg
    -- FzfLuaHelpBorder FzfLuaBorder    hls.help_border Help win border
    -- FzfLuaHeaderBind *BlanchedAlmond hls.header_bind Header keybind
    -- FzfLuaHeaderText *Brown1 hls.header_text Header text
    -- FzfLuaPathColNr  *CadetBlue1 hls.path_colnr  Path col nr (lines,qf,lsp,diag)
    -- FzfLuaPathLineNr *LightGreen hls.path_linenr Path line nr (lines,qf,lsp,diag)
    -- FzfLuaBufName    *LightMagenta   hls.buf_name    Buffer name (lines)
    -- FzfLuaBufNr  *BlanchedAlmond hls.buf_nr  Buffer number (all buffers)
    -- FzfLuaBufFlagCur *Brown1 hls.buf_flag_cur    Buffer line (buffers)
    -- FzfLuaBufFlagAlt *CadetBlue1 hls.buf_flag_alt    Buffer line (buffers)
    -- FzfLuaTabTitle   *LightSkyBlue1  hls.tab_title   Tab title (tabs)
    -- FzfLuaTabMarker  *BlanchedAlmond hls.tab_marker  Tab marker (tabs)
    -- FzfLuaDirIcon    Directory   hls.dir_icon    Paths directory icon
    -- FzfLuaDirPart    Comment hls.dir_part    Path formatters directory hl group
    -- FzfLuaFilePart   @none   hls.file_part   Path formatters file hl group
    -- FzfLuaLiveSym    *Brown1 hls.live_sym    LSP live symbols query match
    { FzfLuaFzfNormal = { bg = '#ffff00', fg = '#00ff00' } },
    -- { FzfLuaFzfCursorLine = { bg = "#ffff00", fg = "#00ff00"} },
    -- { FzfLuaFzfPrompt = { bg = "#ff0000", fg = "#00ff00"} },
    { ['@fzf.normal'] = { bg = '#ff0000', fg = '#00ff00' } },
    -- FzfLuaFzfNormal  FzfLuaNormal    fzf.normal  fzf's fg|bg
    -- FzfLuaFzfCursorLine  FzfLuaCursorLine    fzf.cursorline  fzf's fg+|bg+
    -- FzfLuaFzfMatch   Special fzf.match   fzf's hl+
    -- FzfLuaFzfBorder  FzfLuaBorder    fzf.border  fzf's border
    -- FzfLuaFzfScrollbar   FzfLuaFzfBorder fzf.scrollbar   fzf's scrollbar
    -- FzfLuaFzfSeparator   FzfLuaFzfBorder fzf.separator   fzf's separator
    -- FzfLuaFzfGutter  FzfLuaNormal    fzf.gutter  fzf's gutter (hl bg is used)
    -- FzfLuaFzfHeader  FzfLuaTitle fzf.header  fzf's header
    -- FzfLuaFzfInfo    NonText fzf.info    fzf's info
    -- FzfLuaFzfPointer Special fzf.pointer fzf's pointer
    -- FzfLuaFzfMarker  FzfLuaFzfPointer    fzf.marker  fzf's marker
    -- FzfLuaFzfSpinner FzfLuaFzfPointer    fzf.spinner fzf's spinner
    -- FzfLuaFzfPrompt  Special fzf.prompt  fzf's prompt
    -- FzfLuaFzfQuery   FzfLuaNormal    fzf.query   fzf's header
    -- }}}
  })
end

local function set_sidebar_highlight(dim_factor)
  highlight.all({
    {
      PanelDarkBackground = { bg = { from = 'Normal', alter = dim_factor } },
    },
    { PanelDarkHeading = { inherit = 'PanelDarkBackground', bold = true } },
    { PanelBackground = { bg = { from = 'Normal', alter = -0.8 } } },
    { PanelHeading = { inherit = 'PanelBackground', bold = true } },
    {
      PanelWinSeparator = {
        inherit = 'PanelBackground',
        fg = { from = 'WinSeparator' },
      },
    },
    { PanelStNC = { link = 'PanelWinSeparator' } },
    { PanelSt = { bg = { from = 'Normal', alter = -0.2 } } },

    -- Avanté Panel colors
    {
      AvanteSidebarNormal = { link = 'PanelDarkBackground' },
    },
    {
      AvanteTitle = {
        bg = { from = 'PanelDarkBackground', attr = 'bg' },
        -- fg = '#00ff00',
      },
    },
    {
      AvanteReversedTitle = {
        fg = { from = 'PanelDarkBackground', attr = 'bg' },
        bg = { from = 'PanelDarkBackground', attr = 'bg' },
      },
    },
    {
      AvanteSubtitle = {
        -- fg = '#ff0000',
        bg = { from = 'PanelDarkBackground', attr = 'bg' },
      },
    },
    {
      AvanteThirdTitle = {
        -- fg = '#ff0000',
        bg = { from = 'PanelDarkBackground', attr = 'bg' },
      },
    },
    {
      AvanteReversedSubtitle = { link = 'AvanteReversedTitle' },
    },
    {
      AvanteReversedThirdTitle = { link = 'AvanteReversedTitle' },
    },
    {
      AvanteSidebarWinHorizontalSeparator = {
        -- bg = '#ff0000',
        -- fg = '#ff0000',
        fg = { from = 'PanelDarkBackground', attr = 'bg' },
        bg = { from = 'PanelDarkBackground', attr = 'bg' },
      },
    },
    {
      AvanteSidebarWinSeparator = {
        -- bg = '#ff0000',
        -- fg = '#ff0000',
        fg = { from = 'PanelDarkBackground', attr = 'bg' },
        bg = { from = 'PanelDarkBackground', attr = 'bg' },
      },
    },
  })
end

local sidebar_fts = {
  'undotree',
  'Outline',
  'dbui',
  'neotest-summary',
}

local function on_sidebar_enter()
  vim.opt_local.winhighlight:append({
    Normal = 'PanelBackground',
    EndOfBuffer = 'PanelBackground',
    -- StatusLine = 'PanelSt',
    -- StatusLineNC = 'PanelStNC',
    SignColumn = 'PanelBackground',
    VertSplit = 'PanelVertSplit',
    WinSeparator = 'PanelWinSeparator',
  })
end

local function colorscheme_overrides(dim_factor)
  local overrides = {
    ['github_dark_default'] = {
      { TabLineSel = { link = 'Todo' } },
    },
  }
  local hls = overrides[vim.g.colors_name]
  if hls then highlight.all(hls) end
end

local function user_highlights()
  local dim_factor = 0.5
  if vim.g.colors_name == 'gruvbox' then
    dim_factor = 0.25
  elseif vim.g.colors_name == 'horizon' then
    dim_factor = 0.75
  elseif vim.g.colors_name == 'github_dark_default' then
    dim_factor = -1
  end

  general_overrides(dim_factor)
  set_sidebar_highlight(dim_factor)
  colorscheme_overrides(dim_factor)
end

mrl.augroup('UserHighlights', {
  event = 'ColorScheme',
  command = function() user_highlights() end,
}, {
  event = 'FileType',
  pattern = sidebar_fts,
  command = function() on_sidebar_enter() end,
})

-- vim: foldmethod=marker
