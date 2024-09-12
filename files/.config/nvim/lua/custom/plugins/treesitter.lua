return {

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPre', 'BufNewFile' },
    build = ':TSUpdate',
    dependencies = {
      'windwp/nvim-ts-autotag',
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'bash',
          'c',
          'html',
          'lua',
          'luadoc',
          'markdown',
          'vim',
          'vimdoc',
          'json',
          'javascript',
          'typescript',
          'tsx',
          'yaml',
          'html',
          'css',
          'prisma',
          'markdown',
          'markdown_inline',
          'svelte',
          'graphql',
          'bash',
          'lua',
          'vim',
          'dockerfile',
          'gitignore',
          'query',
          'vimdoc',
          'c',
        },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
          -- enable = true,
          enable = false,
          disable = { 'tex' },
          -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
          --  If you are experiencing weird indenting issues, add the language to
          --  the list of additional_vim_regex_highlighting and disabled languages for indent.
          -- additional_vim_regex_highlighting = { 'ruby', 'tex' },
        },
        -- indent = { enable = true, disable = { 'ruby', 'tex' } },
        incremental_selection = {
          enable = true,
          disable = { 'tex' },
          keymaps = {
            init_selection = '<C-space>',
            node_incremental = '<C-space>',
            scope_incremental = false,
            node_decremental = '<bs>',
          },
        },
      })
    end,
  },
}
