-- COLORSCHEME
--
local enable_italics = true
return {

  {
    'ellisonleao/gruvbox.nvim',
    -- Keep available, but don't pay startup cost unless you re-enable it.
    enabled = false,
    cond = false,
    -- enabled = false,
    priority = 1000,
    config = function()
      -- Setup basic colorscheme first (fast path)
      require('gruvbox').setup({
        contrast = 'hard',
        -- palette_overrides = {
        --   dark0_hard = '#0E1018',
        -- },
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = enable_italics,
          emphasis = enable_italics,
          comments = enable_italics,
          operators = false,
          folds = enable_italics,
        },
        strikethrough = true,
        invert_selection = true,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true,
        overrides = {
          Comment = { fg = '#81878f', italic = enable_italics, bold = true },
          Define = { link = 'GruvboxPurple' },
          Macro = { link = 'GruvboxPurple' },
          ['@constant.builtin'] = { link = 'GruvboxPurple' },
          ['@storageclass.lifetime'] = { link = 'GruvboxAqua' },
          ['@text.note'] = { link = 'TODO' },
          ['@namespace.rust'] = { link = 'Include' },
          ['@punctuation.bracket'] = { link = 'GruvboxOrange' },
          texMathDelimZoneLI = { link = 'GruvboxOrange' },
          texMathDelimZoneLD = { link = 'GruvboxOrange' },
          luaParenError = { link = 'luaParen' },
          luaError = { link = 'NONE' },
          ContextVt = { fg = '#878788' },
          CopilotSuggestion = { fg = '#878787' },
          CocCodeLens = { fg = '#878787' },
          CocWarningFloat = { fg = '#dfaf87' },
          CocInlayHint = { fg = '#ABB0B6' },
          CocPumShortcut = { fg = '#fe8019' },
          CocPumDetail = { fg = '#fe8019' },
          DiagnosticVirtualTextWarn = { fg = '#dfaf87' },
          Folded = { fg = '#fe8019', bg = '#0E1018', italic = enable_italics },
          SignColumn = { bg = '#2d2021' },
          DiffAdd = { bold = true, reverse = false, fg = '', bg = '#2a4333' },
          DiffChange = { bold = true, reverse = false, fg = '', bg = '#333841' },
          DiffDelete = {
            bold = true,
            reverse = false,
            fg = '#442d30',
            bg = '#442d30',
          },
          DiffText = { bold = true, reverse = false, fg = '', bg = '#213352' },
          StLine = { bg = '#ff0000' },
        },
        dim_inactive = false,
        transparent_mode = false,
      })

      -- Defer expensive highlight lookups (after colorscheme is applied)
      vim.schedule(function()
        vim.api.nvim_set_hl(0, 'StGitAdd', {
          fg = mrl.get_hi('GitSignsAdd').fg,
          bg = mrl.get_hi('Statusline').bg,
        })
        local cursor_bg = mrl.get_hi('CursorLine').bg
        local comment_fg = mrl.get_hi('Comment').fg
        vim.api.nvim_set_hl(
          0,
          'SymbolUsageRounding',
          { fg = cursor_bg, italic = enable_italics }
        )
        vim.api.nvim_set_hl(
          0,
          'SymbolUsageContent',
          { bg = cursor_bg, fg = comment_fg, italic = enable_italics }
        )
        vim.api.nvim_set_hl(0, 'SymbolUsageRef', {
          fg = mrl.get_hi('Function').fg,
          bg = cursor_bg,
          italic = enable_italics,
        })
        vim.api.nvim_set_hl(0, 'SymbolUsageDef', {
          fg = mrl.get_hi('Type').fg,
          bg = cursor_bg,
          italic = enable_italics,
        })
        vim.api.nvim_set_hl(0, 'SymbolUsageImpl', {
          fg = mrl.get_hi('@keyword').fg,
          bg = cursor_bg,
          italic = enable_italics,
        })
      end)

      vim.cmd('colorscheme gruvbox')
    end,
  },
  -- First, install the plugin (using lazy.nvim as an example)
  {
    'EdenEast/nightfox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('nightfox').setup({
        options = {
          -- Optional: customize settings
          transparent = false,
          terminal_colors = true,
          dim_inactive = false,
          -- styles = {
          --   comments = 'italic',
          --   keywords = 'bold',
          --   types = 'italic,bold',
          -- },
        },
      })

      -- Set the colorscheme
      vim.cmd('colorscheme carbonfox')
    end,
  },
}
