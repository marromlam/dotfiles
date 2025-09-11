-- COLORSCHEME
return {

  {
    'projekt0n/github-nvim-theme',
    name = 'github-theme',
    disabled = true,
    cond = false,
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function() require('github-theme').setup({}) end,
  },

  {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    -- cond = false,
    -- enabled = false,
    priority = 1000,
    enabled = true,
    config = function()
      require('gruvbox').setup({
        contrast = 'hard',
        palette_overrides = {
          dark0_hard = '#0E1018',
        },
        terminal_colors = true, -- add neovim terminal colors
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = true,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true, -- invert background for search, diffs, statuslines and errors
        overrides = {

          NormalFloat = { fg = '#ebdbb2', bg = '#504945' },
          Comment = { fg = '#81878f', italic = true, bold = true },
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
          -- fold
          Folded = { fg = '#fe8019', bg = '#0E1018', italic = true },
          SignColumn = { bg = '#fe8019' },
          -- new git colors
          DiffAdd = {
            bold = true,
            reverse = false,
            fg = '',
            bg = '#2a4333',
          },
          DiffChange = {
            bold = true,
            reverse = false,
            fg = '',
            bg = '#333841',
          },
          DiffDelete = {
            bold = true,
            reverse = false,
            fg = '#442d30',
            bg = '#442d30',
          },
          DiffText = {
            bold = true,
            reverse = false,
            fg = '',
            bg = '#213352',
          },

          -- SignColumn = { bg = '#0E1018' },
          SignColumn = { bg = '#2d2021' },
          StGitAdd = {
            fg = mrl.get_hi('GitSignsAdd').fg,
            bg = mrl.get_hi('Statusline').bg,
          },
          NormalFloat = {
            fg = mrl.get_hi('NormalFloat').fg,
            bg = mrl.get_hi('Normal').bg,
            -- bg = "#191724",
          },
          FloatBorder = {
            fg = mrl.get_hi('FloatBorder').fg,
            bg = mrl.get_hi('Normal').bg,
            -- bg = "#191724",
          },

          SymbolUsageRounding = {
            fg = mrl.get_hi('CursorLine').bg,
            italic = true,
          },
          SymbolUsageContent = {
            bg = mrl.get_hi('CursorLine').bg,
            fg = mrl.get_hi('Comment').fg,
            italic = true,
          },
          SymbolUsageRef = {
            fg = mrl.get_hi('Function').fg,
            bg = mrl.get_hi('CursorLine').bg,
            italic = true,
          },
          SymbolUsageDef = {
            fg = mrl.get_hi('Type').fg,
            bg = mrl.get_hi('CursorLine').bg,
            italic = true,
          },
          SymbolUsageImpl = {
            fg = mrl.get_hi('@keyword').fg,
            bg = mrl.get_hi('CursorLine').bg,
            italic = true,
          },
          StLine = { bg = '#ff0000' },
        },
        dim_inactive = false,
        transparent_mode = false,
      })

      -- require("gruvbox").setup({
      --     contrast = "hard",
      --     palette_overrides = {dark0_hard = "#0E1018"},
      --     overrides = {
      --         NormalFloat = {fg = "#ebdbb2", bg = "#504945"},
      --         Comment = {fg = "#81878f", italic = true, bold = true},
      --         Define = {link = "GruvboxPurple"},
      --         Macro = {link = "GruvboxPurple"},
      --         ["@constant.builtin"] = {link = "GruvboxPurple"},
      --         ["@storageclass.lifetime"] = {link = "GruvboxAqua"},
      --         ["@text.note"] = {link = "TODO"},
      --         ["@namespace.rust"] = {link = "Include"},
      --         ["@punctuation.bracket"] = {link = "GruvboxOrange"},
      --         texMathDelimZoneLI = {link = "GruvboxOrange"},
      --         texMathDelimZoneLD = {link = "GruvboxOrange"},
      --         luaParenError = {link = "luaParen"},
      --         luaError = {link = "NONE"},
      --         ContextVt = {fg = "#878788"},
      --         CopilotSuggestion = {fg = "#878787"},
      --         CocCodeLens = {fg = "#878787"},
      --         CocWarningFloat = {fg = "#dfaf87"},
      --         CocInlayHint = {fg = "#ABB0B6"},
      --         CocPumShortcut = {fg = "#fe8019"},
      --         CocPumDetail = {fg = "#fe8019"},
      --         DiagnosticVirtualTextWarn = {fg = "#dfaf87"},
      --         -- fold
      --         Folded = {fg = "#fe8019", bg = "#0E1018", italic = true},
      --         SignColumn = {bg = "#fe8019"},
      --         -- new git colors
      --         DiffAdd = {
      --             bold = true,
      --             reverse = false,
      --             fg = "",
      --             bg = "#2a4333"
      --         },
      --         DiffChange = {
      --             bold = true,
      --             reverse = false,
      --             fg = "",
      --             bg = "#333841"
      --         },
      --         DiffDelete = {
      --             bold = true,
      --             reverse = false,
      --             fg = "#442d30",
      --             bg = "#442d30"
      --         },
      --         DiffText = {
      --             bold = true,
      --             reverse = false,
      --             fg = "",
      --             bg = "#213352"
      --         },
      --         -- statusline
      --         StatusLine = {bg = "#ffffff", fg = "#0E1018"},
      --         StatusLineNC = {bg = "#3c3836", fg = "#0E1018"},
      --         CursorLineNr = {fg = "#fabd2f", bg = ""},
      --         GruvboxOrangeSign = {fg = "#dfaf87", bg = "#0E1018"},
      --         GruvboxAquaSign = {fg = "#8EC07C", bg = "#0E1018"},
      --         GruvboxGreenSign = {fg = "#b8bb26", bg = "#0E1018"},
      --         GruvboxRedSign = {fg = "#fb4934", bg = "#0E1018"},
      --         GruvboxBlueSign = {fg = "#83a598", bg = "#0E1018"},
      --         WilderMenu = {fg = "#ebdbb2", bg = ""},
      --         WilderAccent = {fg = "#f4468f", bg = ""},
      --         -- coc semantic token
      --         CocSemStruct = {link = "GruvboxYellow"},
      --         CocSemKeyword = {fg = "", bg = "#0E1018"},
      --         CocSemEnumMember = {fg = "", bg = "#0E1018"},
      --         CocSemTypeParameter = {fg = "", bg = "#0E1018"},
      --         CocSemComment = {fg = "", bg = "#0E1018"},
      --         CocSemMacro = {fg = "", bg = "#0E1018"},
      --         CocSemVariable = {fg = "", bg = "#0E1018"},
      --         CocSemFunction = {fg = "", bg = "#0E1018"},
      --         SnacksPicker = {fg = "#ebdbb2", bg = "#0E1018"},
      --         SnacksPickerBorder = {fg = "#ebdbb2", bg = "#0E1018"},
      --         SnacksPickerBoxBorder = {fg = "#ebdbb2", bg = "#0E1018"},
      --         SnacksNormal = {fg = "#ebdbb2", bg = "#0E1018"},
      --         -- neorg
      --         ["@neorg.markup.inline_macro"] = {link = "GruvboxGreen"}
      --     }
      -- })

      vim.cmd('colorscheme gruvbox')
    end,
  },
}
