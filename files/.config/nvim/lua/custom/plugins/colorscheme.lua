return {

  -- mini base 16
  -- {
  --   "echasnovski/mini.base16",
  --   branch = "stable",
  -- },

  {
    'ellisonleao/gruvbox.nvim',
    -- 'SeniorMars/gruvbox.nvim',
    priority = 1000,
    config = function()
      -- require('gruvbox').setup({
      --   terminal_colors = true, -- add neovim terminal colors
      --   undercurl = true,
      --   underline = true,
      --   bold = true,
      --   italic = {
      --     strings = true,
      --     emphasis = true,
      --     comments = true,
      --     operators = false,
      --     folds = true,
      --   },
      --   strikethrough = true,
      --   invert_selection = true,
      --   invert_signs = false,
      --   invert_tabline = false,
      --   invert_intend_guides = false,
      --   inverse = true, -- invert background for search, diffs, statuslines and errors
      --   contrast = 'hard', -- can be "hard", "soft" or empty string
      --   palette_overrides = {},
      --   overrides = {
      --     SignColumn = { bg = '#1d2021' },
      --   },
      --   dim_inactive = false,
      --   transparent_mode = false,
      -- })
      require('gruvbox').setup({
        contrast = 'hard',
        palette_overrides = {
          dark0_hard = '#0E1018',
        },
        overrides = {
          -- SignColumn = { bg = '#ff9900' },
          SignColumn = { bg = '#0E1018' },
          StatusLine = { bg = '#ffff00', fg = '#213352' },
          Define = { link = 'GruvboxPurple' },
          Macro = { link = 'GruvboxPurple' },
          Comment = { fg = '#fe8019', italic = true },

          -- ['@constant.builtin'] = { link = 'GruvboxPurple' },
          -- ['@storageclass.lifetime'] = { link = 'GruvboxAqua' },
          -- ['@text.note'] = { link = 'TODO' },
          -- ['@namespace.latex'] = { link = 'Include' },

          Folded = { italic = true, fg = '#fe8019', bg = '#3c3836' },
          FoldColumn = { fg = '#fe8019', bg = '#0E1018' },
          DiffAdd = { bold = true, reverse = false, fg = '', bg = '#2a4333' },
          DiffChange = { bold = true, reverse = false, fg = '', bg = '#333841' },
          DiffDelete = {
            bold = true,
            reverse = false,
            fg = '#442d30',
            bg = '#442d30',
          },
          DiffText = { bold = true, reverse = false, fg = '', bg = '#213352' },

          DiagnosticVirtualTextWarn = { fg = '#dfaf87' },
          GruvboxOrangeSign = { fg = '#dfaf87', bg = '' },
          GruvboxAquaSign = { fg = '#8EC07C', bg = '' },
          GruvboxGreenSign = { fg = '#b8bb26', bg = '' },
          GruvboxRedSign = { fg = '#fb4934', bg = '' },
          GruvboxBlueSign = { fg = '#83a598', bg = '' },
        },
      })
      -- vim.cmd.colorscheme('gruvbox')
    end,
  },
}
