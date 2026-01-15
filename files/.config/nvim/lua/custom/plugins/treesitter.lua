return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'VeryLazy',
    build = ':TSUpdate',
    dependencies = { { 'nvim-treesitter/nvim-treesitter-textobjects' } },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup({
        -- NOTE: Keep your broader list, but add Akinsho's core parsers too.
        -- stylua: ignore
        ensure_installed = {
          'c', 'vim', 'vimdoc', 'query', 'lua', 'luadoc', 'luap',
          'diff', 'regex', 'gitcommit', 'git_config', 'git_rebase', 'markdown', 'markdown_inline',
          -- Your stack
          'bash', 'html', 'json', 'javascript', 'typescript', 'tsx', 'yaml', 'css', 'prisma',
          'svelte', 'graphql', 'dockerfile', 'gitignore',
        },
        auto_install = true,
        highlight = {
          -- enable = true,
          enable = false,
          disable = { 'tex', 'latex', 'applescript' },
          -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
          --  If you are experiencing weird indenting issues, add the language to
          --  the list of additional_vim_regex_highlighting and disabled languages for indent.
          additional_vim_regex_highlighting = { 'org', 'sql' },
        },
        incremental_selection = {
          enable = true,
          disable = { 'tex', 'latex', 'help' },
          keymaps = {
            init_selection = '<C-space>',
            node_incremental = '<C-space>',
            scope_incremental = false,
            node_decremental = '<bs>',
          },
        },
        indent = {
          enable = true,
          disable = { 'yaml' },
        },
        textobjects = {
          lookahead = true,
          select = {
            enable = true,
            include_surrounding_whitespace = true,
            keymaps = {
              ['af'] = { query = '@function.outer', desc = 'ts: all function' },
              ['if'] = {
                query = '@function.inner',
                desc = 'ts: inner function',
              },
              ['ac'] = { query = '@class.outer', desc = 'ts: all class' },
              ['ic'] = { query = '@class.inner', desc = 'ts: inner class' },
              ['aC'] = {
                query = '@conditional.outer',
                desc = 'ts: all conditional',
              },
              ['iC'] = {
                query = '@conditional.inner',
                desc = 'ts: inner conditional',
              },
              ['aL'] = {
                query = '@assignment.lhs',
                desc = 'ts: assignment lhs',
              },
              ['aR'] = {
                query = '@assignment.rhs',
                desc = 'ts: assignment rhs',
              },
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [']m'] = '@function.outer',
              [']M'] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[M'] = '@class.outer',
            },
          },
        },
        autopairs = { enable = true },
        playground = { persist_queries = true },
        query_linter = {
          enable = true,
          use_virtual_text = true,
          lint_events = { 'BufWrite', 'CursorHold' },
        },
      })
    end,
  },

  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter' },
    opts = {
      use_default_keymaps = false,
    },
    keys = {
      {
        'gS',
        '<Cmd>TSJSplit<CR>',
        desc = 'split expression to multiple lines',
      },
      { 'gJ', '<Cmd>TSJJoin<CR>', desc = 'join expression to single line' },
    },
  },
  {
    'windwp/nvim-ts-autotag',
    dependencies = { 'nvim-treesitter' },
    event = 'VeryLazy',
    ft = {
      'html',
      'xml',
      'javascript',
      'typescript',
      'javascriptreact',
      'typescriptreact',
      'svelte',
      'vue',
      'markdown',
    },
    opts = {},
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'VeryLazy',
    init = function()
      local highlight = mrl.highlight
      highlight.plugin('treesitter-context', {
        { TreesitterContextSeparator = { link = 'Dim' } },
        { TreesitterContext = { inherit = 'Normal' } },
        { TreesitterContextLineNumber = { inherit = 'LineNr' } },
      })
    end,
    opts = {
      multiline_threshold = 4,
      separator = '─',
      mode = 'cursor',
    },
  },
}
