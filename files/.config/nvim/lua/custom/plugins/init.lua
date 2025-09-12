return {
  {
    'nvim-lua/plenary.nvim',
    lazy = false,
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
  -- NEEDED? §{
  -- NEEDED? §  'lvimuser/lsp-inlayhints.nvim',
  -- NEEDED? §  event = 'LspAttach',
  -- NEEDED? §  init = function()
  -- NEEDED? §    vim.api.nvim_create_augroup('LspAttach_inlayhints', {})
  -- NEEDED? §    vim.api.nvim_create_autocmd('LspAttach', {
  -- NEEDED? §      group = 'LspAttach_inlayhints',
  -- NEEDED? §      callback = function(args)
  -- NEEDED? §        if not (args.data and args.data.client_id) then
  -- NEEDED? §          return
  -- NEEDED? §        end

  -- NEEDED? §        local bufnr = args.buf
  -- NEEDED? §        local client = vim.lsp.get_client_by_id(args.data.client_id)
  -- NEEDED? §        require('lsp-inlayhints').on_attach(client, bufnr)
  -- NEEDED? §      end,
  -- NEEDED? §    })
  -- NEEDED? §  end,
  -- NEEDED? §  opts = {
  -- NEEDED? §    inlay_hints = {
  -- NEEDED? §      highlight = 'Comment',
  -- NEEDED? §      labels_separator = ' ⏐ ',
  -- NEEDED? §      parameter_hints = { prefix = '󰊕' },
  -- NEEDED? §      type_hints = { prefix = '=> ', remove_colon_start = true },
  -- NEEDED? §    },
  -- NEEDED? §  },
  -- NEEDED? §},
  -- },
  -- }}}
  ------------------------------------------------------------------------

  ------------------------------------------------------------------------
  --- filetype specific {{{
  ------------------------------------------------------------------------

  {
    -- vimtex
    'lervag/vimtex',
    ft = { 'tex' },
    config = function() require('custom.config.vimtex').config() end,
  },

  {
    'marromlam/tex-kitty',
    ft = 'tex',
    -- dir = '/Users/marcos/Projects/personal/tex-kitty',
    -- dev = true,
    dependencies = { 'lervag/vimtex' },
    config = function()
      require('tex-kitty').setup({
        tex_kitty_preview = 1,
      })
    end,
  },

  -- }}}
  ------------------------------------------------------------------------

  {
    'tpope/vim-repeat',
    disable = false,
    keys = { '.' },
  },

  {
    'noahfrederick/vim-skeleton',
    event = 'BufNewFile',
    disable = false,
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
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
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
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },

  {
    'will133/vim-dirdiff',
    cmd = { 'DirDiff' },
  },

  --- }}}
  ------------------------------------------------------------------------
}
