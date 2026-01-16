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
  -- {
  --   'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  --   event = { 'BufNewFile', 'BufReadPre' },
  -- },
  ------------------------------------------------------------------------
  --- filetype specific {{{
  ------------------------------------------------------------------------
  -- {
  --   -- null-ls
  --   'jose-elias-alvarez/null-ls.nvim',
  --   ft = { 'javascript', 'typescript', 'lua', 'python', 'sh', 'css', 'html' },
  --   config = function()
  --     -- require('config.null-ls').config()
  --   end,
  {
    'kosayoda/nvim-lightbulb',
    event = 'LspAttach',
    keys = {
      {
        '<leader>lb',
        ":lua require('nvim-lightbulb').get_status_text()<cr>",
        desc = 'lsp: lightbulb',
      },
    },
    opts = {
      autocmd = { enabled = true },
      sign = { enabled = false },
      float = {
        -- text = icons.misc.lightbulb,
        enabled = true,
        win_opts = { border = 'none' },
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
    'DNLHC/glance.nvim',
    event = 'LspAttach',
    opts = {
      preview_win_opts = { relativenumber = false },
      theme = { enable = true, mode = 'darken' },
    },
    keys = {
      { 'gd', '<Cmd>Glance definitions<CR>', desc = 'lsp: glance definitions' },
      { 'gr', '<Cmd>Glance references<CR>', desc = 'lsp: glance references' },
      {
        'gy',
        '<Cmd>Glance type_definitions<CR>',
        desc = 'lsp: glance type definitions',
      },
      {
        'gm',
        '<Cmd>Glance implementations<CR>',
        desc = 'lsp: glance implementations',
      },
    },
  },
  {
    'tpope/vim-repeat',
    keys = { '.' },
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
    'willothy/flatten.nvim',
    lazy = false,
    priority = 1001,
    config = {
      window = { open = 'alternate' },
      hooks = {
        block_end = function() require('toggleterm').toggle() end,
        post_open = function(_, winnr, _, is_blocking)
          if is_blocking then
            require('toggleterm').toggle()
          else
            vim.api.nvim_set_current_win(winnr)
          end
        end,
      },
    },
  },

  -- {
  --   'fresh2dev/zellij.vim',
  --   lazy = false,
  -- },

  {
    'marromlam/sailor.vim',
    event = 'VimEnter',
    run = './install.sh',
  },

  {
    'echasnovski/mini.bufremove',
    version = '*',
    keys = {
      {
        '<leader>bd',
        '<cmd> lua MiniBufremove.unshow()<cr>',
        'buffer: close buffer',
      },
    },
    config = function() require('mini.bufremove').setup() end,
  },

  { 'meznaric/key-analyzer.nvim', opts = {}, cmd = 'KeyAnalyzer' },

  {
    'bogado/file-line',
    keys = {
      'gF',
    },
  },

  {
    'm4xshen/hardtime.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {},
    lazy = true,
  },



  {
    'will133/vim-dirdiff',
    cmd = { 'DirDiff' },
  },

  --- }}}
  ------------------------------------------------------------------------
}
