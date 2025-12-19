local icons = mrl.ui.icons
return {
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    main = 'ibl',
    opts = {
      indent = { char = '┊' },
    },
  },

  {
    'rcarriga/nvim-notify',
    lazy = false,
    config = function()
      local notify = require('notify')
      notify.setup({
        top_down = false,
        render = 'wrapped-compact',
        stages = 'fade_in_slide_out',
        on_open = function(win)
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_config(win, { border = 'single' })
          end
        end,
      })
      map(
        'n',
        '<leader>nd',
        function() notify.dismiss({ silent = true, pending = true }) end,
        {
          desc = 'dismiss notifications',
        }
      )
    end,
  },

  -- {
  --   'tpope/vim-sleuth',
  --   event = { 'BufReadPre', 'BufNewFile' },
  -- },

  {
    'Bekaboo/dropbar.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    -- cond = false,
    -- disable = true,
    keys = {
      {
        '<leader>wp',
        function() require('dropbar.api').pick() end,
        desc = 'winbar: pick',
      },
    },
  },

  {
    'uga-rosa/ccc.nvim',
    cmd = { 'CccPick' },
    tag = 'v2.0.3',
    opts = function()
      local ccc = require('ccc')
      local p = ccc.picker
      ccc.setup({
        -- win_opts = { border = mrl.ui.border },
        highlighter = {
          auto_enable = false,
          excludes = {
            'dart',
            'lazy',
            'orgagenda',
            'org',
            'NeogitStatus',
            'toggleterm',
          },
        },
      })
    end,
  },

  {
    'Wansmer/symbol-usage.nvim',
    event = 'LspAttach',
    config = function()
      require('symbol-usage').setup({
        vt_position = 'end_of_line',
        text_format = function(symbol)
          local res = {}
          local ins = table.insert

          local round_start = { '', 'SymbolUsageLeft' }
          local round_end = { '', 'SymbolUsageRight' }

          if symbol.references then
            local usage = symbol.references <= 1 and 'usage' or 'usages'
            local num = symbol.references == 0 and 'no' or symbol.references
            ins(res, round_start)
            ins(res, { '󰌹 ', 'SymbolUsageRef' })
            ins(res, { ('%s %s'):format(num, usage), 'SymbolUsageContent' })
            ins(res, round_end)
          end

          if symbol.definition then
            if #res > 0 then table.insert(res, { ' ', 'NonText' }) end
            ins(res, round_start)
            ins(res, { '󰳽 ', 'SymbolUsageDef' })
            ins(res, { symbol.definition .. ' defs', 'SymbolUsageContent' })
            ins(res, round_end)
          end

          if symbol.implementation then
            if #res > 0 then table.insert(res, { ' ', 'NonText' }) end
            ins(res, round_start)
            ins(res, { '󰡱 ', 'SymbolUsageImpl' })
            ins(
              res,
              { symbol.implementation .. ' impls', 'SymbolUsageContent' }
            )
            ins(res, round_end)
          end

          return res
        end,
      })
    end,
  },

  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>u', '<Cmd>UndotreeToggle<CR>', desc = 'undotree: toggle' },
    },
    config = function()
      vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },

  -- preview line
  { 'nacro90/numb.nvim', event = 'CmdlineEnter', opts = {} },

  {
    'goolord/alpha-nvim',
    -- event = 'VimEnter',
    cond = false,
    disable = true,
    config = function() require('custom.config.alpha').config() end,
  },
}
