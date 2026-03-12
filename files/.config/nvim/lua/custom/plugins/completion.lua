local highlight, ui = mrl.highlight, mrl.ui

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
      {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = {
          'nvim-treesitter/nvim-treesitter',
        },
        opts = {
          file_types = { 'markdown', 'Avante' },
          completions = {
            blink = { enabled = true },
          },
        },
      },
    },
    version = '*',
    init = function()
      highlight.plugin('blink', {
        -- Keep completion popups consistent with float styling
        { BlinkCmpMenuBorder = { link = 'FloatBorder' } },
        { BlinkCmpDocBorder = { link = 'FloatBorder' } },
        { BlinkCmpMenu = { link = 'NormalFloat' } },
        { BlinkCmpDoc = { link = 'NormalFloat' } },
        { BlinkCmpDocCursorLine = { link = 'CursorLine' } },
      })

      -- User command to toggle ghost text
      vim.api.nvim_create_user_command('BlinkToggleGhostText', function()
        local blink = require('blink.cmp')
        local enabled = blink.config.completion.ghost_text.enabled
        blink.config.completion.ghost_text.enabled = not enabled
        vim.notify(
          'Ghost text ' .. (enabled and 'disabled' or 'enabled'),
          vim.log.levels.INFO
        )
      end, { desc = 'Toggle blink.cmp ghost text' })
    end,
    opts = {
      -- Custom keymap
      keymap = {
        preset = 'none',

        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },

        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },

        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },

        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      },

      appearance = {
        nerd_font_variant = 'mono',
        use_nvim_cmp_as_default = true,
      },

      -- Rust fuzzy matcher with typo resistance and frecency
      fuzzy = {
        frecency = { enabled = true },
        use_proximity = true,
        sorts = { 'score', 'sort_text' },
      },

      sources = {
        default = { 'avante', 'lsp', 'path', 'snippets', 'buffer' },

        -- Per-filetype source configuration
        per_filetype = {
          lua = { 'lsp', 'path', 'snippets', 'buffer' },
          python = { 'lsp', 'path', 'snippets', 'buffer' },
          codecompanion = { 'codecompanion' },
          sql = { 'snippets', 'dadbod', 'buffer' },
          gitcommit = { 'buffer' },
          markdown = { 'markdown', 'lsp', 'path', 'snippets', 'buffer' },
        },

        providers = {
          -- LSP with highest priority
          lsp = {
            name = 'LSP',
            module = 'blink.cmp.sources.lsp',
            min_keyword_length = 2, -- Reduce noise while typing
            score_offset = 100, -- Prioritize LSP
            fallbacks = { 'snippets' },
          },

          -- Path completion
          path = {
            name = 'Path',
            module = 'blink.cmp.sources.path',
            score_offset = 3,
            opts = {
              trailing_slash = true,
              label_trailing_slash = false,
              get_cwd = function(context)
                return vim.fn.expand(('#%d:p:h'):format(context.bufnr))
              end,
            },
          },

          -- Snippets
          snippets = {
            name = 'Snippets',
            module = 'blink.cmp.sources.snippets',
            min_keyword_length = 2,
            score_offset = -3,
          },

          -- Buffer completion with reduced noise
          buffer = {
            name = 'Buffer',
            module = 'blink.cmp.sources.buffer',
            min_keyword_length = 5, -- Keep buffer suggestions low-noise
            max_items = 5,
          },

          -- Avante AI completion
          avante = {
            module = 'blink-cmp-avante',
            name = 'Avante',
            opts = {},
          },

          -- Markdown rendering
          markdown = {
            name = 'RenderMarkdown',
            module = 'render-markdown.integ.blink',
            fallbacks = { 'lsp' },
          },

          -- Database completion
          dadbod = {
            name = 'Dadbod',
            module = 'vim_dadbod_completion.blink',
          },
        },
      },

      -- Enable cmdline completion
      cmdline = {
        sources = function()
          local type = vim.fn.getcmdtype()
          if type == '/' or type == '?' then return { 'buffer' } end
          if type == ':' then return { 'cmdline' } end
          return {}
        end,
      },

      signature = {
        enabled = true,
        window = { border = 'rounded' },
      },

      completion = {
        -- Enable ghost text (inline preview)
        ghost_text = { enabled = true },

        -- Trigger settings
        trigger = {
          show_in_snippet = true,
          show_on_keyword = true,
          show_on_trigger_character = true,
          show_on_insert_on_trigger_character = true,
        },

        -- List behavior with cycling
        list = {
          max_items = 200, -- Performance limit
          cycle = {
            from_bottom = true,
            from_top = true,
          },
          selection = {
            preselect = true,
            auto_insert = function(ctx) return ctx.mode == 'cmdline' end,
          },
        },

        menu = {
          border = 'rounded',
          cmdline_position = function()
            if vim.g.ui_cmdline_pos ~= nil then
              local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
              return { pos[1] - 1, pos[2] }
            end
            local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
            return { vim.o.lines - height, 0 }
          end,

          -- Better menu drawing with lspkind icons
          draw = {
            columns = {
              { 'kind_icon', 'label', gap = 1 },
              { 'kind' },
            },
            components = {
              kind_icon = {
                text = function(item)
                  local kind = require('lspkind').symbol_map[item.kind] or ''
                  return kind .. ' '
                end,
                highlight = 'CmpItemKind',
              },
              label = {
                width = { fill = true, max = 60 },
                text = function(item)
                  return item.label .. (item.label_detail or '')
                end,
                highlight = 'CmpItemAbbr',
              },
              kind = {
                width = { max = 20 },
                text = function(item) return item.kind end,
                highlight = 'CmpItemKind',
              },
            },
          },
        },

        -- Enhanced documentation window
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200, -- Faster than 500ms
          update_delay_ms = 50,
          treesitter_highlighting = true,
          window = {
            max_width = 80,
            max_height = 20,
            border = 'rounded',
            winblend = 0,
            winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None',
            scrollbar = true,
          },
        },

        -- Accept with auto-brackets
        accept = {
          auto_brackets = { enabled = true },
        },
      },
    },
    opts_extend = { 'sources.default' },
  },
}
