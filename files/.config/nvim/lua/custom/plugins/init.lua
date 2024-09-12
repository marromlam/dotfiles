-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
function mrl.augroup(name, ...)
  local commands = { ... }
  assert(name ~= 'User', 'The name of an augroup CANNOT be User')
  assert(
    #commands > 0,
    string.format('You must specify at least one autocommand for %s', name)
  )
  local id = vim.api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in ipairs(commands) do
    --  validate_autocmd(name, autocmd)
    local is_callback = type(autocmd.command) == 'function'
    vim.api.nvim_create_autocmd(autocmd.event, {
      group = name,
      pattern = autocmd.pattern,
      desc = autocmd.desc,
      callback = is_callback and autocmd.command or nil,
      command = not is_callback and autocmd.command or nil,
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end
  return id
end

return {

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
    dir = '/Users/marcos/Projects/personal/tex-kitty',
    dev = true,
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
  },

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

  {
    'mbbill/undotree',
    keys = {
      {
        '<leader>u',
        vim.cmd.UndotreeToggle,
        'Toggle undotree',
      },
    },
  },

  --- }}}
  ------------------------------------------------------------------------
}

-- vim:foldmethod=marker
