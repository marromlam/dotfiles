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
    event = 'VeryLazy',
    config = function()
      ---@type table
      local notify = require('notify')
      ---@diagnostic disable-next-line: undefined-field
      notify.setup({
        top_down = false,
        render = 'wrapped-compact',
        stages = 'fade_in_slide_out',
        -- Used by notify for blending/opacity calculations; keep aligned with float bg
        background_colour = (function()
          local configured = mrl.ui.current and mrl.ui.current.float_bg
          if vim.is_callable(configured) then return configured() end
          if type(configured) == 'string' then return configured end
          if mrl and mrl.highlight and mrl.highlight.get then
            return mrl.highlight.get('Normal', 'bg')
          end
          return 'NONE'
        end)(),
        on_open = function(win)
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_config(win, { border = mrl.ui.current.border })
          end
        end,
      })
      vim.keymap.set('n', '<leader>nd', function()
        ---@diagnostic disable-next-line: undefined-field
        notify.dismiss({ silent = true, pending = true })
      end, {
        desc = 'dismiss notifications',
      })
    end,
  },

  -- {
  --   'tpope/vim-sleuth',
  --   event = { 'BufReadPre', 'BufNewFile' },
  -- },

  {
    'SmiteshP/nvim-navic',
    event = 'LspAttach',
    config = function()
      require('nvim-navic').setup({
        highlight = true,
        separator = ' › ',
        depth_limit = 5,
        depth_limit_indicator = '..',
      })
      -- Attach navic to LSP clients
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.server_capabilities.documentSymbolProvider then
            require('nvim-navic').attach(client, args.buf)
          end
        end,
      })
    end,
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
    ---@diagnostic disable: undefined-field
    config = function()
      local symbol_usage = require('symbol-usage')
      symbol_usage.setup({
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
