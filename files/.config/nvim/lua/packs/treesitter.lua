-- packs/treesitter.lua

-- treesitter-context highlight init (runs immediately, before plugin loads)
do
  local highlight = require('highlight')
  highlight.plugin('treesitter-context', {
    { TreesitterContextSeparator = { link = 'Dim' } },
    { TreesitterContext = { inherit = 'Normal' } },
    { TreesitterContextLineNumber = { inherit = 'LineNr' } },
  })
end

-- treesj keymap (registered immediately)
vim.keymap.set('n', 'gS', '<Cmd>TSJSplit<CR>', { desc = 'split expression to multiple lines' })
vim.keymap.set('n', 'gJ', '<Cmd>TSJJoin<CR>', { desc = 'join expression to single line' })

-- treesitter-context keymap
vim.keymap.set('n', '<leader>sc', '<cmd>TSContext toggle<CR>', {
  desc = 'Toggle [s]cope [c]ontext',
})

-- Main treesitter setup (on BufReadPost)
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlTreesitter', { clear = true }),
  callback = function()
    -- nvim-treesitter v1 API: configs module is gone
    require('nvim-treesitter').setup({
      -- stylua: ignore
      ensure_installed = {
        'c', 'vim', 'vimdoc', 'query', 'lua', 'luadoc', 'luap',
        'diff', 'regex', 'gitcommit', 'git_config', 'git_rebase', 'markdown', 'markdown_inline',
        'bash', 'html', 'json', 'javascript', 'typescript', 'tsx', 'yaml', 'css', 'prisma',
        'svelte', 'graphql', 'dockerfile', 'gitignore', 'python', 'go', 'rust',
      },
    })

    -- textobjects (nvim-treesitter-textobjects still works with v1)
    require('nvim-treesitter-textobjects').setup({
      select = {
        enable = true,
        lookahead = true,
        include_surrounding_whitespace = true,
        keymaps = {
          ['af'] = { query = '@function.outer', desc = 'ts: all function' },
          ['if'] = { query = '@function.inner', desc = 'ts: inner function' },
          ['ac'] = { query = '@class.outer', desc = 'ts: all class' },
          ['ic'] = { query = '@class.inner', desc = 'ts: inner class' },
          ['aC'] = { query = '@conditional.outer', desc = 'ts: all conditional' },
          ['iC'] = { query = '@conditional.inner', desc = 'ts: inner conditional' },
          ['aL'] = { query = '@assignment.lhs', desc = 'ts: assignment lhs' },
          ['aR'] = { query = '@assignment.rhs', desc = 'ts: assignment rhs' },
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
    })

    -- treesj setup
    require('treesj').setup({
      use_default_keymaps = false,
    })

    -- nvim-ts-autotag setup
    require('nvim-ts-autotag').setup({})

    -- treesitter-context setup
    require('treesitter-context').setup({
      enable = false,
      multiline_threshold = 10,
      separator = '─',
      mode = 'cursor',
    })
  end,
})
