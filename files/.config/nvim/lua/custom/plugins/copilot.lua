-- this file is 

return {
  {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
require('copilot').setup({
  panel = {
    enabled = true,
    auto_refresh = false,
    keymap = {
      jump_prev = "[[",
      jump_next = "]]",
      accept = "<CR>",
      refresh = "gr",
      open = "<M-CR>"
    },
    layout = {
      position = "bottom", -- | top | left | right
      ratio = 0.4
    },
  },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    hide_during_completion = true,
    debounce = 75,
    keymap = {
      accept = "<C-a>",
      accept_word = false,
      accept_line = false,
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
  },
  filetypes = {
    yaml = false,
    markdown = false,
    help = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    ["."] = false,
  },
  copilot_node_command = 'node', -- Node.js version must be > 18.x
  server_opts_overrides = {},
})
    -- vim.keymap.set('i', '<C-a>', require("copilot.suggestion").accept_line(), {decsc='copilot accept'} )
  end,

  },

  {
    'github/copilot.vim',
    event = {'InsertEnter', 'InsertLeave'},
    cond = false, disable=true,
    -- dependencies = { "nvim-cmp" },
    init = function() vim.g.copilot_no_tab_map = true end,
    config = function()
      local function accept_word()
        vim.fn['copilot#Accept']('')
        local output = vim.fn['copilot#TextQueuedForInsertion']()
        return vim.fn.split(output, [[[ .]\zs]])[1]
      end

      -- new CopilotSuggestion bbb


      local function accept_line()
        vim.fn['copilot#Accept']('')
        local output = vim.fn['copilot#TextQueuedForInsertion']()
        return vim.fn.split(output, [[[\n]\zs]])[1]
      end
      vim.keymap.set('i', '<Plug>(as-copilot-accept)', "copilot#Accept('<C-a>')", {
        expr = true,
        remap = true,
        silent = true,
      })
      vim.keymap.set('i', '<M-]>', '<Plug>(copilot-next)', { desc = 'next suggestion' })
      vim.keymap.set(
        'i',
        '<M-[>',
        '<Plug>(copilot-previous)',
        { desc = 'previous suggestion' }
      )
      vim.keymap.set(
        'i',
        '<C-§>',
        '<Cmd>vertical Copilot panel<CR>',
        { desc = 'open copilot panel' }
      )
      vim.keymap.set(
        'i',
        '<M-w>',
        accept_word,
        { expr = true, remap = false, desc = 'accept word' }
      )
      vim.keymap.set(
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
