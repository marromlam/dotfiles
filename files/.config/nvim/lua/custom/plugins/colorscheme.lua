
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


local function h(name) return vim.api.nvim_get_hl(0, { name = name }) end
return {

  -- mini base 16
  -- {
  --   "echasnovski/mini.base16",
  --   branch = "stable",
  -- },

  {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    priority = 1000,
enabled = true,
    config = function()
      require('gruvbox').setup({
        contrast = 'hard',
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
        palette_overrides = {
          -- dark0_hard = '#0E1018',
          dark0_hard = '#1d2021'
        },
        overrides = {
          -- SignColumn = { bg = '#0E1018' },
          -- Statusline = { bg = '#ff1018' },
          -- StatusLine = { fg = '#ff1018' },
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




          SymbolUsageRounding = { fg = mrl.get_hi('CursorLine').bg, italic = true, },
          SymbolUsageContent = { bg = mrl.get_hi('CursorLine').bg, fg = mrl.get_hi('Comment').fg, italic = true },
          SymbolUsageRef = { fg = mrl.get_hi('Function').fg, bg = mrl.get_hi('CursorLine').bg, italic = true },
          SymbolUsageDef = { fg = mrl.get_hi('Type').fg, bg = mrl.get_hi('CursorLine').bg, italic = true },
          --         NormalFloat = {
          --           fg = mrl.get_hi('NormalFloat').fg,
          --           -- bg = mrl.get_hi('Normal').bg,
          --           bg = "#191724",
          --         },
          --         FloatBorder = {
          --         NormalFloat = {
          --           fg = mrl.get_hi('NormalFloat').fg,
          --           -- bg = mrl.get_hi('Normal').bg,
          --           bg = "#191724",
          --         },
          --         FloatBorder = {
          --           fg = mrl.get_hi('FloatBorder').fg,
          --           -- bg = mrl.get_hi('Normal').bg,
          --           bg = "#191724",
          --         },
          --           fg = mrl.get_hi('FloatBorder').fg,
          --           -- bg = mrl.get_hi('Normal').bg,
          --           bg = "#191724",
          --         },
          SymbolUsageImpl = { fg = mrl.get_hi('@keyword').fg, bg = mrl.get_hi('CursorLine').bg, italic = true },
          StLine = { bg = "#ff0000" }
        },
        dim_inactive = false,
        transparent_mode = false,
      })
      -- require('gruvbox').setup({
      --   contrast = 'hard',
      --   palette_overrides = {
      --     dark0_hard = '#0E1018',
      --   },
      --   overrides = {
      --     -- SignColumn = { bg = '#ff9900' },
      --     SignColumn = { bg = '#0E1018' },
      --     StatusLine = { bg = '#ffff00', fg = '#213352' },
      --     Define = { link = 'GruvboxPurple' },
      --     Macro = { link = 'GruvboxPurple' },
      --     Comment = { fg = '#fe8019', italic = true },
      --
      --     -- ['@constant.builtin'] = { link = 'GruvboxPurple' },
      --     -- ['@storageclass.lifetime'] = { link = 'GruvboxAqua' },
      --     -- ['@text.note'] = { link = 'TODO' },
      --     -- ['@namespace.latex'] = { link = 'Include' },
      --
      --     Folded = { italic = true, fg = '#fe8019', bg = '#3c3836' },
      --     FoldColumn = { fg = '#fe8019', bg = '#0E1018' },
      --     DiffAdd = { bold = true, reverse = false, fg = '', bg = '#2a4333' },
      --     DiffChange = { bold = true, reverse = false, fg = '', bg = '#333841' },
      --     DiffDelete = {
      --       bold = true,
      --       reverse = false,
      --       fg = '#442d30',
      --       bg = '#442d30',
      --     },
      --     DiffText = { bold = true, reverse = false, fg = '', bg = '#213352' },
      --
      --     DiagnosticVirtualTextWarn = { fg = '#dfaf87' },
      --     GruvboxOrangeSign = { fg = '#dfaf87', bg = '' },
      --     GruvboxAquaSign = { fg = '#8EC07C', bg = '' },
      --     GruvboxGreenSign = { fg = '#b8bb26', bg = '' },
      --     GruvboxRedSign = { fg = '#fb4934', bg = '' },
      --     GruvboxBlueSign = { fg = '#83a598', bg = '' },
      --   },
      -- })
      vim.cmd("colorscheme gruvbox")
      -- require('custom.config.colors')
    end,
  },
  -- {
  --   'akinsho/horizon.nvim',
  --   dev = true,
  --   lazy = false,
  --   priority = 1000,
  -- },

  -- {
  --   'rose-pine/neovim',
  --   name = 'rose-pine',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require('rose-pine').setup({
  --       variant = "main",  -- auto, main, moon, or dawn
  --       dark_variant = "main", -- main, moon, or dawn
  --   enable = {
  --       terminal = true,
  --       legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
  --       migrations = true, -- Handle deprecated options automatically
  --   },
  --   styles = {
  --       bold = true,
  --       italic = true,
  --       transparency = false,
  --   },
  --       dim_inactive_windows = false,
  --       highlight_groups = {
  --         -- SignColumn = { bg = '#ff9900' },
  --         Statusline = { fg = '#00ff00', bg = '#ff0000' },
  --         -- LineNr = { fg = '#ff0000', bg = '#0000ff' },
  --         StGitAdd = {
  --           fg = mrl.get_hi('GitSignsAdd').fg,
  --           bg = mrl.get_hi('Statusline').bg,
  --         },
  --         NormalFloat = {
  --           fg = mrl.get_hi('NormalFloat').fg,
  --           -- bg = mrl.get_hi('Normal').bg,
  --           bg = "#191724",
  --         },
  --         FloatBorder = {
  --           fg = mrl.get_hi('FloatBorder').fg,
  --           -- bg = mrl.get_hi('Normal').bg,
  --           bg = "#191724",
  --         },
  --         TelescopeNormal = {
  --           fg = mrl.get_hi('NormalFloat').fg,
  --           -- bg = mrl.get_hi('LineNr').bg,
  --           bg = "#191724",
  --         },
  --         TelescopeBorder = {
  --           fg = mrl.get_hi('FloatBorder').fg,
  --           -- bg = mrl.get_hi('LineNr').bg,
  --           bg = "#191724",
  --         },
  --         SymbolUsageRounding = { fg = mrl.get_hi('CursorLine').bg, italic = true, },
  --         SymbolUsageContent = { bg = mrl.get_hi('CursorLine').bg, fg = mrl.get_hi('Comment').fg, italic = true },
  --         SymbolUsageRef = { fg = mrl.get_hi('Function').fg, bg = mrl.get_hi('CursorLine').bg, italic = true },
  --         SymbolUsageDef = { fg = mrl.get_hi('Type').fg, bg = mrl.get_hi('CursorLine').bg, italic = true },
  --         SymbolUsageImpl = { fg = mrl.get_hi('@keyword').fg, bg = mrl.get_hi('CursorLine').bg, italic = true },
  --       },
  --     })
  --   end,
  -- },


}
