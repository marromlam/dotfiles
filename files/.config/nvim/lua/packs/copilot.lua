-- packs/copilot.lua

-- copilot.lua: setup on InsertEnter
vim.api.nvim_create_autocmd('InsertEnter', {
  once = true,
  group = vim.api.nvim_create_augroup('MrlCopilot', { clear = true }),
  callback = function()
    require('copilot').setup({
      panel = {
        enabled = true,
        auto_refresh = false,
        keymap = {
          jump_prev = '[[',
          jump_next = ']]',
          accept = '<CR>',
          refresh = 'gr',
          open = '<M-CR>',
        },
        layout = {
          position = 'bottom', -- | top | left | right
          ratio = 0.4,
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 75,
        keymap = {
          accept = '<C-a>',
          accept_word = false,
          accept_line = false,
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
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
        ['.'] = false,
      },
      copilot_node_command = 'node', -- Node.js version must be > 18.x
      server_opts_overrides = {},
    })
  end,
})

-- codecompanion: setup on command invocation (cmd-loaded)
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
  adapters = {
    my_openai = function()
      return require('codecompanion.adapters').extend(
        'openai_compatible',
        {
          env = {
            url = 'http://127.0.0.1:11434', -- optional: default value is ollama url http://127.0.0.1:11434
            -- api_key = 'OpenAI_API_KEY', -- optional: if your endpoint is authenticated
            -- chat_url = '/v1/chat/completions', -- optional: default value, override if different
            -- models_endpoint = '/v1/models', -- optional: attaches to the end of the URL to form the endpoint to retrieve models
          },
          schema = {
            model = {
              -- default = 'deepseek-r1:8b',
              default = 'deepseek-r1:1.5b',
            },
            temperature = {
              order = 2,
              mapping = 'parameters',
              type = 'number',
              optional = true,
              default = 0.8,
              desc = 'What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.',
              validate = function(n)
                return n >= 0 and n <= 2, 'Must be between 0 and 2'
              end,
            },
            max_completion_tokens = {
              order = 3,
              mapping = 'parameters',
              type = 'integer',
              optional = true,
              default = nil,
              desc = 'An upper bound for the number of tokens that can be generated for a completion.',
              validate = function(n)
                return n > 0, 'Must be greater than 0'
              end,
            },
            stop = {
              order = 4,
              mapping = 'parameters',
              type = 'string',
              optional = true,
              default = nil,
              desc = 'Sets the stop sequences to use. When this pattern is encountered the LLM will stop generating text and return. Multiple stop patterns may be set by specifying multiple separate stop parameters in a modelfile.',
              validate = function(s)
                return s:len() > 0, 'Cannot be an empty string'
              end,
            },
            logit_bias = {
              order = 5,
              mapping = 'parameters',
              type = 'map',
              optional = true,
              default = nil,
              desc = 'Modify the likelihood of specified tokens appearing in the completion. Maps tokens (specified by their token ID) to an associated bias value from -100 to 100. Use https://platform.openai.com/tokenizer to find token IDs.',
              subtype_key = {
                type = 'integer',
              },
              subtype = {
                type = 'integer',
                validate = function(n)
                  return n >= -100 and n <= 100,
                    'Must be between -100 and 100'
                end,
              },
            },
          },
        }
      )
    end,
  },
})

-- mcphub: lazy, only loaded when explicitly required
-- (setup happens on demand)

-- sidekick.nvim keymaps
vim.keymap.set('i', '<tab>', function()
  if not require('sidekick').nes_jump_or_apply() then return '<Tab>' end
end, { expr = true, desc = 'Goto/Apply Next Edit Suggestion' })

vim.keymap.set('n', '<leader>aa', function() require('sidekick.cli').toggle() end, {
  desc = 'Sidekick Toggle CLI',
})
vim.keymap.set('n', '<leader>as', function() require('sidekick.cli').select() end, {
  desc = 'Select CLI',
})
vim.keymap.set({ 'x', 'n' }, '<leader>at', function()
  require('sidekick.cli').send({ msg = '{this}' })
end, { desc = 'Send This' })
vim.keymap.set('x', '<leader>av', function()
  require('sidekick.cli').send({ msg = '{selection}' })
end, { desc = 'Send Visual Selection' })
vim.keymap.set({ 'n', 'x' }, '<leader>ap', function()
  require('sidekick.cli').prompt()
end, { desc = 'Sidekick Select Prompt' })
vim.keymap.set({ 'n', 'x', 'i', 't' }, '<c-.>', function()
  require('sidekick.cli').focus()
end, { desc = 'Sidekick Switch Focus' })
vim.keymap.set('n', '<leader>ac', function()
  require('sidekick.cli').toggle({ name = 'claude', focus = true })
end, { desc = 'Sidekick Toggle Claude' })

-- Defer sidekick setup slightly to keep startup fast
vim.defer_fn(function()
  require('sidekick').setup({
    cli = {
      mux = {
        enabled = true,
        create = 'terminal', -- Folke's pattern: create terminal instead of window
        backend = 'tmux', -- Using tmux (Folke commented out zellij)
      },
      tools = {},
    },
  })
end, 100)
