return {
  {
    'github/copilot.vim',
    event = 'InsertEnter',
    -- dependencies = { "nvim-cmp" },
    init = function() vim.g.copilot_no_tab_map = true end,
    config = function()
      local function accept_word()
        vim.fn['copilot#Accept']('')
        local output = vim.fn['copilot#TextQueuedForInsertion']()
        return vim.fn.split(output, [[[ .]\zs]])[1]
      end

      local function accept_line()
        vim.fn['copilot#Accept']('')
        local output = vim.fn['copilot#TextQueuedForInsertion']()
        return vim.fn.split(output, [[[\n]\zs]])[1]
      end
      map('i', '<Plug>(as-copilot-accept)', "copilot#Accept('<C-a>')", {
        expr = true,
        remap = true,
        silent = true,
      })
      map('i', '<M-]>', '<Plug>(copilot-next)', { desc = 'next suggestion' })
      map(
        'i',
        '<M-[>',
        '<Plug>(copilot-previous)',
        { desc = 'previous suggestion' }
      )
      map(
        'i',
        '<C-§>',
        '<Cmd>vertical Copilot panel<CR>',
        { desc = 'open copilot panel' }
      )
      map(
        'i',
        '<M-w>',
        accept_word,
        { expr = true, remap = false, desc = 'accept word' }
      )
      map(
        'i',
        '<C-a>',
        accept_line,
        { expr = true, remap = false, desc = 'accept line' }
      )
      vim.g.copilot_filetypes = {
        ['*'] = true,
        gitcommit = false,
        NeogitCommitMessage = false,
        DressingInput = false,
        TelescopePrompt = false,
        ['neo-tree-popup'] = false,
        ['dap-repl'] = false,
      }
      -- highlight.plugin(
      --   "copilot",
      --   { { CopilotSuggestion = { link = "Comment" } } }
      -- )
    end,
  },
  -- ADD LATER -- {
  -- ADD LATER --   'CopilotC-Nvim/CopilotChat.nvim',
  -- ADD LATER --   -- 'github/copilot.vim',
  -- ADD LATER --   cmd = { 'CopilotChatExplain' },
  -- ADD LATER --   branch = 'canary',
  -- ADD LATER --   dependencies = {
  -- ADD LATER --     { 'github/copilot.lua' }, -- or github/copilot.vim
  -- ADD LATER --     { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
  -- ADD LATER --   },
  -- ADD LATER --   opts = {
  -- ADD LATER --     debug = true, -- Enable debugging
  -- ADD LATER --   },
  -- ADD LATER -- },
  {
    'olimorris/codecompanion.nvim',
    cmd = { 'CodeCompanion' },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-telescope/telescope.nvim', -- Optional
      {
        'stevearc/dressing.nvim', -- Optional: Improves the default Neovim UI
        opts = {},
      },
    },
    config = function()
      require('codecompanion').setup({
        strategies = {
          chat = {
            adapter = 'copilot',
          },
          inline = {
            adapter = 'copilot',
          },
          agent = {
            adapter = 'copilot',
          },
        },
      })
    end,
  },
}
