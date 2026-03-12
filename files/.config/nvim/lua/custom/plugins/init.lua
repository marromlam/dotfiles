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
    'noahfrederick/vim-skeleton',
    event = 'BufNewFile',
    config = function()
      vim.g.skeleton_template_dir = vim.fn.expand('~/.config/nvim')
        .. '/templates'
      vim.cmd([[
        let g:skeleton_replacements = {}
        function! g:skeleton_replacements.TITLE()
          return toupper(expand("%:t:r"))
        endfunction
      ]])
    end,
  },

  {
    'rlch/github-notifications.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'ibhagwan/fzf-lua' },
    keys = {
      {
        '<leader>gn',
        function() require('custom.gh_notifications').open() end,
        desc = 'github notifications (fzf)',
      },
    },
  },

  {
    'szw/vim-maximizer',
    keys = {
      {
        '<leader>sm',
        '<cmd>MaximizerToggle<CR>',
        desc = '[win] Split Maximize/minimize',
      },
    },
  },

  {
    'marromlam/sailor.vim',
    event = 'VimEnter',
    run = './install.sh',
  },

  { 'meznaric/key-analyzer.nvim', opts = {}, cmd = 'KeyAnalyzer' },

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

  --- }}}
  ------------------------------------------------------------------------
}
