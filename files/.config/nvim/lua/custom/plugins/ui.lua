local icons = mrl.ui.icons
return {
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    main = 'ibl',
    opts = {
      indent = { char = '┊' },
      exclude = {
        filetypes = { 'notify', 'noice', 'noice_popup', 'noice_cmdline' },
      },
    },
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
    'HiPhish/rainbow-delimiters.nvim',
    -- Match Akinsho's load order: define `vim.g.rainbow_delimiters` early,
    -- then fill in strategy/query when the plugin loads.
    event = { 'BufReadPost', 'BufNewFile' },
    init = function()
      -- `vim.g` doesn't support mutating nested fields reliably; always reassign.
      local rd = vim.g.rainbow_delimiters or {}
      rd.highlight = rd.highlight
        or {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
        }
      vim.g.rainbow_delimiters = rd
    end,
    config = function()
      local ok, rainbow_delimiters = pcall(require, 'rainbow-delimiters')
      if not ok then return end

      -- Akinsho-style: global strategy + default query name.
      local rd = vim.g.rainbow_delimiters or {}
      rd.strategy = {
        [''] = rainbow_delimiters.strategy['global'],
      }
      rd.query = {
        [''] = 'rainbow-delimiters',
        html = 'rainbow-delimiters', -- enable our html tag query override
        svelte = 'rainbow-delimiters',
      }
      vim.g.rainbow_delimiters = rd

      -- Palette-driven colors for the delimiter groups.
      local api = vim.api
      local group =
        api.nvim_create_augroup('MrlRainbowDelimiters', { clear = true })

      local function set_hls()
        local pal = (mrl and mrl.ui and mrl.ui.palette) or {}
        local function as_hex(v, fallback)
          if type(v) == 'string' or type(v) == 'number' then return v end
          if type(v) == 'table' then return v.base or fallback end
          return fallback
        end
        local colors = {
          as_hex(pal.red, '#E06C75'),
          as_hex(pal.light_yellow, '#E5C07B'),
          as_hex(pal.blue, '#61AFEF'),
          as_hex(pal.dark_orange, '#D19A66'),
          as_hex(pal.green, '#98C379'),
          as_hex(pal.magenta, '#C678DD'),
          as_hex(pal.teal, '#56B6C2'),
        }
        local cur = vim.g.rainbow_delimiters or {}
        local names = cur.highlight or {}
        for i, name in ipairs(names) do
          api.nvim_set_hl(0, name, { fg = colors[i] })
        end
      end

      set_hls()
      api.nvim_create_autocmd('ColorScheme', {
        group = group,
        callback = set_hls,
      })
    end,
  },

  {
    'goolord/alpha-nvim',
    -- event = 'VimEnter',
    cond = false,
    disable = true,
    config = function() require('custom.config.alpha').config() end,
  },
}
