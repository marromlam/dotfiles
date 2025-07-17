local highlight, ui = mrl.highlight, mrl.ui
local fn = vim.fn
local border = ui.current.border

return {
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    cond = not vim.g.use_cmp,
    disable = vim.g.use_cmp,
    dependencies = {
      'rafamadriz/friendly-snippets',
      'onsails/lspkind.nvim', -- vs-code like pictograms
      'Kaiser-Yang/blink-cmp-avante',
    },
    version = '*',
    init = function()
      highlight.plugin('blink', {
        { BlinkCmpMenuBorder = { link = 'PickerBorder' } },
        { BlinkCmpDocBorder = { link = 'PickerBorder' } },
        { BlinkCmpMenu = { link = 'Normal' } },
      })
    end,
    opts = {
      keymap = { preset = 'enter' },
      appearance = {
        nerd_font_variant = 'mono',
        use_nvim_cmp_as_default = true,
      },
      sources = {
        default = { 'avante', 'lsp', 'path', 'snippets', 'buffer' },

        per_filetype = {
          codecompanion = { 'codecompanion' },
        },

        providers = {
          avante = {
            module = 'blink-cmp-avante',
            name = 'Avante',
            opts = {
              -- options for blink-cmp-avante
            },
          },
          markdown = {
            name = 'RenderMarkdown',
            module = 'render-markdown.integ.blink',
            fallbacks = { 'lsp' },
          },
        },
      },
      signature = { window = { border = border } },
      completion = {
        menu = { border = border },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          window = { border = border },
        },
        list = {
          selection = {
            auto_insert = function(ctx)
              return ctx.mode == 'cmdline' and false or true
            end,
          },
        },
      },
    },
    opts_extend = { 'sources.default' },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    cond = vim.g.use_cmp,
    disable = not vim.g.use_cmp,
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has('win32') == 1 or vim.fn.executable('make') == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
      },
      'saadparwaiz1/cmp_luasnip', -- for autocompletion
      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'lukas-reineke/cmp-rg',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer', -- source for text in buffer
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'onsails/lspkind.nvim', -- vs-code like pictograms
      'kristijanhusak/vim-dadbod-completion',
      -- { 'hrsh7th/cmp-emoji' },
      {
        'petertriho/cmp-git',
        opts = { filetypes = { 'gitcommit', 'NeogitCommitMessage' } },
      },
      {
        'abecodes/tabout.nvim',
        opts = { ignore_beginning = false, completion = false },
      },
    },
    config = function()
      -- See `:help cmp`
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local lspkind = require('lspkind')

      -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
      require('luasnip.loaders.from_vscode').lazy_load()

      luasnip.config.setup({})

      cmp.setup({
        completion = {
          completeopt = 'menu,menuone,preview,noselect',
        },
        -- completion = { completeopt = 'menu,menuone,noinsert' },
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert({
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm({ select = false }),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          --['<CR>'] = cmp.mapping.confirm { select = true },
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete({}),

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then luasnip.jump(-1) end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'luasnip' },
          { name = 'dadbod-completion' },
          { name = 'buffer' }, -- text within current buffer
          { name = 'path' },
          { name = 'rg', keyword_length = 3 },
        },
        formatting = {
          format = lspkind.cmp_format({
            maxwidth = 50,
            ellipsis_char = '...',
          }),
        },
      })
    end,
  },

  -- {
  --   'StanAngeloff/claudius.nvim',
  --   opts = {},
  --   lazy = false,
  -- },
}
