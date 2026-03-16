local highlight = require('highlight')
local augroup = require('tools').augroup

local function general_overrides(dim_factor)
  local is_dark = vim.g.high_contrast_theme
  local normal_bg = highlight.get('Normal', 'bg')
  local normal_fg = highlight.get('Normal', 'fg', '#ffffff')
  local bg_color = highlight.tint(normal_bg, -dim_factor)
  local bg_color2 = highlight.tint(normal_bg, 0.5 * dim_factor)
  -- local stl_bg = highlight.darken_hsl(normal_bg, -0.20)
  local stl_bg = highlight.get('Statusline', 'bg')
  local float_bg = highlight.darken_hsl(normal_bg, 0)
  local popup_bg = highlight.darken_hsl(normal_bg, -0.20)
  local pal = require('tools').ui.palette or {}
  -- Deleted-line diff background should track the theme's GitSignsDelete color.
  -- Fall back to palette red/pale_red if GitSignsDelete isn't available yet.
  local diff_delete_fg = highlight.get(
    'GitSignsDelete',
    'fg',
    type(pal.red) == 'string' and pal.red
      or type(pal.pale_red) == 'string' and pal.pale_red
      or '#ff0000'
  )
  -- Added-line diff background should track the theme's GitSignsAdd color.
  local diff_add_fg = highlight.get(
    'GitSignsAdd',
    'fg',
    type(pal.green) == 'string' and pal.green or '#00ff00'
  )
  local diff_change_fg = highlight.get(
    'GitSignsChange',
    'fg',
    type(pal.bright_yellow) == 'string' and pal.bright_yellow
      or type(pal.light_yellow) == 'string' and pal.light_yellow
      or '#0000ff'
  )

  -- fzf-lua scrollbar thumb color (used for both preview + fzf list scrollbar)
  local popup_thumb =
    highlight.blend(popup_bg, highlight.get('Comment', 'fg', normal_fg), 0.30)

  -- Statuscolumn git bar colors (subtle bg tint from GitSigns fg colors)
  local git_bar_alpha = 0.28
  local git_add_bar_bg = highlight.blend(normal_bg, diff_add_fg, git_bar_alpha)
  local git_change_bar_bg =
    highlight.blend(normal_bg, diff_change_fg, git_bar_alpha)
  local git_delete_bar_bg =
    highlight.blend(normal_bg, diff_delete_fg, git_bar_alpha)
  local git_untracked_bar_bg =
    highlight.blend(normal_bg, highlight.get('Comment', 'fg', normal_fg), 0.20)

  -- VSCode-ish: keep original text colors, just tint backgrounds.
  -- Use HSL darkening to keep hue/saturation consistent across themes.
  local diff_bg_factor = 0.3
  local diff_add_bg = highlight.darken_hsl(diff_add_fg, -1 + 0.15)
  local diff_delete_bg = highlight.darken_hsl(diff_delete_fg, -1 + 0.15)
  local diff_change_bg = highlight.darken_hsl(diff_change_fg, -1 + 0.20)
  local diff_text_bg = highlight.darken_hsl(diff_change_fg, -1 + 0.30)
  -- Diff filler lines use the `fillchars.diff` glyph (you set it to '╱').
  -- This glyph is highlighted with `DiffDelete` and can look too bright, so
  -- keep it as a subtle dark grey, just above the background.
  local diff_delete_filler_fg = highlight.darken_hsl(normal_fg, -0.8)
  -- do
  --   local configured = mrl.ui.current and mrl.ui.current.float_bg
  --   if vim.is_callable(configured) then
  --     float_bg = configured()
  --   elseif type(configured) == 'string' then
  --     float_bg = configured
  --   end
  -- end
  -- -- Make float background exactly match the border color.
  -- do
  --   local border_fg = highlight.get('Comment', 'fg', normal_fg)
  --   if border_fg ~= 'NONE' then float_bg = border_fg end
  -- end
  highlight.all({
    -- Status line
    { PanelSt = { link = 'Normal' } },
    { TabLineSel = { fg = { from = 'Normal' }, bg = '#ff0000' } },
    -- { StatuslineNC = { fg = { from = 'Normal', attr = 'fg' }, fg = bg_color } },
    -- { StatusLine = { fg = { from = 'Normal', attr = 'fg' }, bg = stl_bg } },
    -- { StatusLineNC = { bg = { from = 'Normal', attr = 'fg' }, fg = bg_color } },
    {
      StDevEnv = {
        fg = { from = 'StatusLine', attr = 'bg' },
        bg = { from = 'Comment', attr = 'fg' },
      },
    },
    { StSeparator = { fg = 'NONE', bg = 'NONE' } },
    {
      StSearchCount = {
        fg = { from = 'Normal', attr = 'bg' },
        bg = { from = 'Normal', attr = 'fg' },
      },
    },
    -- { StSeparator = { bg = '#00aaff', fg = bg_color } },
    { StModified = { fg = '#ffaaff', bg = stl_bg } },
    { StTitle = { fg = { from = 'Normal', attr = 'fg' }, bg = stl_bg } },
    { StFaded = { fg = { from = 'Comment', attr = 'fg' }, bg = stl_bg } },
    -- { StGit = { fg = '#ff0000', bg = '#00ff00' } },
    {
      StBranch = {
        fg = { from = 'DiagnosticInfo', attr = 'fg' },
        bg = stl_bg,
      },
    },
    {
      StGitAdd = { fg = { from = 'GitSignsAdd', attr = 'fg' }, bg = stl_bg },
    },
    {
      StGitDelete = {
        fg = { from = 'GitSignsDelete', attr = 'fg' },
        bg = stl_bg,
      },
    },
    {
      StGitModified = {
        fg = { from = 'DiagnosticWarn', attr = 'fg' },
        bg = stl_bg,
      },
    },
    {
      StInfo = { fg = { from = 'DiagnosticInfo', attr = 'fg' }, bg = stl_bg },
    },
    {
      StWarn = { fg = { from = 'DiagnosticWarn', attr = 'fg' }, bg = stl_bg },
    },
    {
      StError = {
        fg = { from = 'DiagnosticError', attr = 'fg' },
        bg = stl_bg,
      },
    },
    {
      StFilename = {
        fg = { from = 'Normal', attr = 'fg' },
        bg = stl_bg,
        bold = true,
      },
    },
    {
      StEnv = {
        fg = { from = 'DiagnosticError', attr = 'fg' },
        bg = stl_bg,
        bold = true,
        italic = true,
      },
    },
    {
      StDirectory = {
        fg = { from = 'Comment', attr = 'fg' },
        bg = stl_bg,
        italic = true,
      },
    },
    -- { StFilename = { fg = '#0000ff', bg = stl_bg } },
    {
      StParent = {
        fg = { from = 'DiagnosticWarn', attr = 'fg' },
        bg = stl_bg,
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
      SymbolUsageRef = {
        bg = bg_color,
        fg = { from = 'Comment' },
      },
    },
    {
      SymbolUsageContent = {
        bg = bg_color,
        fg = { from = 'Comment' },
      },
    },
    -- }}}
    -- xxx {{{
    -- Make window split lines match the statusline background.
    { VertSplit = { fg = { from = 'StatusLine', attr = 'bg' } } },
    { WinSeparator = { fg = { from = 'StatusLine', attr = 'bg' } } },
    { CursorLine = { bg = { from = 'Normal', alter = dim_factor } } },
    { CursorLineNr = { bg = 'NONE' } },
    { iCursor = { bg = '#00aaff' } },
    { PmenuSbar = { link = 'Normal' } },
    -- Terminal windows should match the main editor background.
    -- Neovim uses these groups (when defined) for :terminal buffers.
    { TermNormal = { link = 'Normal' } },
    { TermNormalNC = { link = 'NormalNC' } },
    {
      Folded = {
        fg = { from = 'Normal' },
        bg = { from = 'Normal', alter = is_dark and 0.3 or 0.1 },
      },
    },
    -- }}}
    -- Floats {{{
    -- Ensure no highlight-level transparency ("blend") affects floats.
    { NormalFloat = { bg = float_bg, blend = 0 } },
    -- A popup background that matches the main editor (`Normal`) background.
    -- Use this for UIs that should not look like "floats" (e.g. fzf-lua, Mason, Lazy).
    {
      NormalPopup = {
        bg = { from = 'Normal', attr = 'bg' },
        fg = { from = 'Normal', attr = 'fg' },
        blend = 0,
      },
    },
    {
      PopupBorder = {
        -- Border background: Normal bg
        -- Border foreground: Normal fg
        bg = { from = 'Normal', attr = 'bg' },
        fg = { from = 'Normal', attr = 'fg' },
        blend = 0,
      },
    },
    {
      FloatBorder = {
        -- Border background: Normal bg
        -- Border foreground: Normal fg
        bg = { from = 'Normal', attr = 'bg' },
        fg = { from = 'Normal', attr = 'fg' },
        blend = 0,
      },
    },
    {
      FloatTitle = {
        bold = true,
        fg = 'white',
        bg = { from = 'FloatBorder', attr = 'fg' },
      },
    },
    -- Mason (doesn't necessarily use NormalFloat directly)
    { MasonNormal = { link = 'NormalPopup' } },
    { MasonNormalNC = { link = 'NormalPopup' } },
    { MasonBorder = { clear = true, link = 'PopupBorder' } },
    { MasonBackdrop = { bg = { from = 'Normal', attr = 'bg' }, blend = 100 } },
    { MasonHeading = { inherit = 'MasonNormal', bold = true } },
    { MasonHeader = { inherit = 'MasonNormal', bold = true } },
    { MasonHeaderSecondary = { inherit = 'MasonNormal', bold = true } },
    {
      MasonHighlight = {
        fg = { from = 'DiagnosticInfo', attr = 'fg' },
        bg = { from = 'Normal', attr = 'bg' },
      },
    },
    {
      MasonHighlightSecondary = {
        fg = { from = 'DiagnosticHint', attr = 'fg' },
        bg = { from = 'Normal', attr = 'bg' },
      },
    },
    {
      MasonMuted = {
        fg = { from = 'Comment', attr = 'fg' },
        bg = { from = 'Normal', attr = 'bg' },
      },
    },
    {
      MasonWarning = {
        fg = { from = 'DiagnosticWarn', attr = 'fg' },
        bg = { from = 'Normal', attr = 'bg' },
      },
    },
    {
      MasonError = {
        fg = { from = 'DiagnosticError', attr = 'fg' },
        bg = { from = 'Normal', attr = 'bg' },
      },
    },
    -- Lazy.nvim UI (doesn't necessarily use NormalFloat directly)
    { LazyNormal = { link = 'NormalPopup' } },
    { LazyBorder = { clear = true, link = 'PopupBorder' } },
    { LazyButton = { bg = { from = 'Normal', attr = 'bg' } } },
    { LazyButtonActive = { bg = { from = 'Normal', attr = 'bg' } } },
    { LazyH1 = { bg = { from = 'Normal', attr = 'bg' } } },
    { LazyH2 = { bg = { from = 'Normal', attr = 'bg' } } },
    { LazyBackdrop = { bg = { from = 'Normal', attr = 'bg' }, blend = 100 } },
    -- Notify (rcarriga/nvim-notify)
    { NotifyBackground = { bg = float_bg } },
    { NotifyERRORBody = { bg = float_bg } },
    { NotifyWARNBody = { bg = float_bg } },
    { NotifyINFOBody = { bg = float_bg } },
    { NotifyDEBUGBody = { bg = float_bg } },
    { NotifyTRACEBody = { bg = float_bg } },
    {
      NotifyERRORBorder = {
        bg = { from = 'Normal', attr = 'bg' },
        fg = { from = 'Normal', attr = 'fg' },
      },
    },
    {
      NotifyWARNBorder = {
        bg = { from = 'Normal', attr = 'bg' },
        fg = { from = 'Normal', attr = 'fg' },
      },
    },
    {
      NotifyINFOBorder = {
        bg = { from = 'Normal', attr = 'bg' },
        fg = { from = 'Normal', attr = 'fg' },
      },
    },
    {
      NotifyDEBUGBorder = {
        bg = { from = 'Normal', attr = 'bg' },
        fg = { from = 'Normal', attr = 'fg' },
      },
    },
    {
      NotifyTRACEBorder = {
        bg = { from = 'Normal', attr = 'bg' },
        fg = { from = 'Normal', attr = 'fg' },
      },
    },
    { NotifyERRORTitle = { bg = float_bg } },
    { NotifyWARNTitle = { bg = float_bg } },
    { NotifyINFOTitle = { bg = float_bg } },
    { NotifyDEBUGTitle = { bg = float_bg } },
    { NotifyTRACETitle = { bg = float_bg } },
    -- which-key (popup window)
    { WhichKeyFloat = { link = 'NormalFloat' } },
    { WhichKeyBorder = { link = 'FloatBorder' } },
    -- }}}
    -- Created highlights {{{
    { Dim = { fg = { from = 'Normal', attr = 'bg', alter = dim_factor } } },
    { PickerBorder = { link = 'Normal' } },
    { UnderlinedTitle = { bold = true, underline = true } },
    { StatusColSep = { link = 'Dim' } },
    -- Statuscolumn: git indicator as a colored bar (│).
    -- When there is no change, use the separator grey.
    { StatusColGitAdd = { fg = diff_add_fg, bg = 'NONE' } },
    { StatusColGitChange = { fg = diff_change_fg, bg = 'NONE' } },
    { StatusColGitDelete = { fg = diff_delete_fg, bg = 'NONE' } },
    {
      StatusColGitUntracked = {
        fg = { from = 'Comment', attr = 'fg' },
        bg = 'NONE',
      },
    },
    { StatusColGitNone = { link = 'StatusColSep' } },
    -- fzf-lua preview scrollbar (float) colors
    { FzfLuaScrollFloatEmpty = { clear = true, link = 'NormalFloat' } },
    { FzfLuaScrollFloatFull = { bg = popup_thumb } },
    -- fzf-lua list scrollbar (fzf --scrollbar): uses the fg color of this hl group
    { FzfLuaFzfScrollbar = { fg = popup_thumb, bg = 'NONE' } },
    { CodeBlock = { bg = { from = 'Normal', alter = 0.3 } } },
    { markdownCode = { link = 'CodeBlock' } },
    { markdownCodeBlock = { link = 'CodeBlock' } },
    -- }}}
    --  Spell {{{
    { SpellBad = { undercurl = true, bg = 'NONE', fg = 'NONE', sp = 'green' } },
    { SpellRare = { undercurl = true } },
    -- }}}
    -- Diff {{{
    -- Diff (VSCode-ish): only change backgrounds
    -- {
    --   DiffAdd = {
    --     bg = diff_add_bg,
    --   },
    -- },
    -- { DiffAddText = { inherit = 'DiffAdd', bold = true } },
    -- {
    --   DiffChange = {
    --     bg = diff_change_bg,
    --   },
    -- },
    -- {
    --   DiffDelete = {
    --     bg = diff_delete_bg,
    --     fg = diff_delete_filler_fg,
    --   },
    -- },
    -- { DiffDeleteText = { inherit = 'DiffDelete', bold = true } },
    -- {
    --   DiffText = {
    --     bg = diff_text_bg,
    --   },
    -- },
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
    { DiagnosticSignWarn = { bg = 'NONE', fg = { from = 'DiagnosticWarn' } } },
    {
      DiagnosticSignError = { bg = 'NONE', fg = { from = 'DiagnosticError' } },
    },
    { DiagnosticSignHint = { bg = 'NONE', fg = { from = 'DiagnosticHint' } } },
    { DiagnosticSignInfo = { bg = 'NONE', fg = { from = 'DiagnosticInfo' } } },
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
  })
end

local function set_sidebar_highlight(dim_factor)
  highlight.all({
    {
      -- Panels should match the main window background.
      PanelDarkBackground = { bg = { from = 'Normal', attr = 'bg' } },
    },
    { PanelDarkHeading = { inherit = 'PanelDarkBackground', bold = true } },
    { PanelBackground = { bg = { from = 'Normal', attr = 'bg' } } },
    { PanelHeading = { inherit = 'PanelBackground', bold = true } },
    {
      PanelWinSeparator = {
        bg = { from = 'PanelDarkBackground', attr = 'bg' },
        -- fg = { from = 'PanelDarkBackground', attr = 'bg' },
        -- inherit = 'PanelBackground',
        fg = { from = 'WinSeparator' },
      },
    },
    { PanelStNC = { link = 'PanelWinSeparator' } },
    { PanelSt = { bg = { from = 'Normal', attr = 'bg' } } },
  })
end

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

local function on_diffview_enter()
  local stl = vim.api.nvim_get_hl(0, { name = 'StatusLine', link = false })
  local norm = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  local bg = stl.bg and ('#%06x'):format(stl.bg) or 'NONE'
  local fg = norm.fg and ('#%06x'):format(norm.fg) or 'NONE'
  local nbg = norm.bg and ('#%06x'):format(norm.bg) or 'NONE'

  -- Use our own hl groups that diffview doesn't touch
  vim.api.nvim_set_hl(0, 'DvPanelBg', { bg = bg, fg = fg })
  vim.api.nvim_set_hl(0, 'DvPanelEob', { bg = bg })
  vim.api.nvim_set_hl(0, 'DvPanelCursor', { bg = nbg })

  -- Point diffview windows directly at our groups via winhighlight
  local winhl = table.concat({
    'Normal:DvPanelBg',
    'EndOfBuffer:DvPanelEob',
    'SignColumn:DvPanelBg',
    'CursorLine:DvPanelCursor',
    'WinSeparator:DiffviewWinSeparator',
  }, ',')

  -- Apply to the diffview tab (it opens in a new tabpage)
  local tabpage = vim.api.nvim_get_current_tabpage()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft == 'DiffviewFiles' or ft == 'DiffviewFileHistory' then
      vim.api.nvim_set_option_value('winhighlight', winhl, { win = win })
    end
  end
end

local function on_sidebar_enter()
  -- Panels should feel like sidebars: no line numbers.
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.winhighlight:append({
    Normal = 'PanelDarkBackground',
    EndOfBuffer = 'PanelDarkBackground',
    SignColumn = 'PanelDarkBackground',
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
  local dim_factor = 0.25
  general_overrides(dim_factor)
  set_sidebar_highlight(dim_factor)
  colorscheme_overrides(dim_factor)
end

-------------------------------------------------------------------------------
-- Auto-commands to apply highlights at the right time. {{{
-------------------------------------------------------------------------------
augroup('UserHighlights', {
  event = 'ColorScheme',
  command = function() user_highlights() end,
}, {
  -- Run once after plugins load, so plugin highlight overrides don't win.
  event = 'User',
  pattern = 'LazyDone',
  once = true,
  command = function() user_highlights() end,
}, {
  event = 'FileType',
  pattern = sidebar_fts,
  command = function() on_sidebar_enter() end,
}, {
  -- diffview fires this after its own hl.setup() completes, so our groups win.
  event = 'User',
  pattern = 'DiffviewViewPostLayout',
  command = function() on_diffview_enter() end,
})

-- }}}
-------------------------------------------------------------------------------

-- vim: fdm=marker
