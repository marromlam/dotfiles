return {
  {
    'nvim-lua/plenary.nvim',
  },
  {
    'jghauser/fold-cycle.nvim',
    opts = {},
    keys = {
      {
        '<BS>',
        function() require('fold-cycle').open() end,
        desc = 'fold-cycle: toggle',
      },
    },
  },
  {

    'andrewferrier/debugprint.nvim',
    opts = { keymaps = false },
    dependencies = {
      'echasnovski/mini.hipatterns',
      'ibhagwan/fzf-lua',
    },
    version = '*',
    keys = {
      {
        '<leader>dp',
        function() return require('debugprint').debugprint({ variable = true }) end,
        desc = 'debugprint: cursor',
        expr = true,
      },
      {
        '<leader>do',
        function() return require('debugprint').debugprint({ motion = true }) end,
        desc = 'debugprint: operator',
        expr = true,
      },
      {
        '<leader>dC',
        '<Cmd>DeleteDebugPrints<CR>',
        desc = 'debugprint: clear all',
      },
    },
  },

  {
    'marromlam/sailor.vim',
    event = 'VimEnter',
    run = './install.sh',
  },

  {
    'bogado/file-line',
    keys = {
      'gF',
    },
  },

  {
    'will133/vim-dirdiff',
    cmd = { 'DirDiff' },
  },

  {
    'tpope/vim-sleuth',
    event = { 'BufReadPre', 'BufNewFile' },
  },
  { 'tpope/vim-surround', event = { 'BufReadPre', 'BufNewFile' } },

  {
    'tpope/vim-repeat',
    keys = { '.' },
  },
}
