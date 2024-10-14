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
    'tpope/vim-sleuth',
    event = { 'BufReadPre', 'BufNewFile' },
  },

  {
    'Bekaboo/dropbar.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
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
    ft = {
      'lua',
      'vim',
      'typescript',
      'typescriptreact',
      'javascriptreact',
      'svelte',
    },
    cmd = { 'CccHighlighterToggle' },
  },

  {
    'Wansmer/symbol-usage.nvim',
    event = 'LspAttach',
    config = {
      text_format = function(symbol)
        local res = {}
        local ins = table.insert

        local round_start = { '', 'SymbolUsageRounding' }
        local round_end = { '', 'SymbolUsageRounding' }

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
          ins(res, { symbol.implementation .. ' impls', 'SymbolUsageContent' })
          ins(res, round_end)
        end

        return res
      end,
    },
  },

  {
    'rainbowhxch/beacon.nvim',
    event = 'CursorMoved',
    opts = {
      minimal_jump = 20,
      ignore_buffers = { 'terminal', 'nofile', 'neorg://Quick Actions' },
      ignore_filetypes = {
        'qf',
        'dap_watches',
        'dap_scopes',
        'neo-tree',
        'NeogitCommitMessage',
        'NeogitPopup',
        'NeogitStatus',
      },
    },
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
    event = 'VimEnter',
    config = function() require('custom.config.alpha').config() end,
  },
}
