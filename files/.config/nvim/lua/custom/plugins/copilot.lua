return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
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
      -- vim.keymap.set('i', '<C-a>', require("copilot.suggestion").accept_line(), {decsc='copilot accept'} )
    end,
  },

  {
    'olimorris/codecompanion.nvim',
    cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionAgent' },
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
    end,
  },

  {
    'yetone/avante.nvim',
    cmd = { 'Avante', 'AvanteAsk' },
    keys = { '<leader>aa', '<leader>aq', '<leader>ae' },
    opts = {
      -- The provider used in Aider mode or in the planning phase of
      -- Cursor Planning Mode
      -- provider = 'ollama',
      provider = 'copilot',
      providers = {
        -- The provider used in the auto-suggestions phase of Cursor Planning Mode
        -- and the provider used in the auto-suggestions phase of Aider mode.
        -- Defaults to 'openai', which is the OpenAI API.
        -- You can also use 'claude' or 'ollama' as the provider.
        -- Note that 'ollama' is not supported in Cursor Planning Mode yet.
        -- You can also use 'copilot' as the provider, but it is not recommended
        -- because it is not designed for auto-suggestions.
        -- WARNING: Since auto-suggestions are a high-frequency operation and
        -- therefore expensive, currently designating it as `copilot` provider is
        -- dangerous because: https://github.com/yetone/avante.nvim/issues/1048
        -- Of course, you can reduce the request frequency by increasing
        -- `suggestion.debounce`.
        auto_suggestions_provider = 'claude',
        -- The provider used in the applying phase of Cursor Planning Mode,
        -- defaults to nil, when nil uses Config.provider as the provider for the
        -- applying phase
        cursor_applying_provider = nil,
        claude = {
          endpoint = 'https://api.anthropic.com',
          model = 'claude-3-5-sonnet-20241022',
          extra_request_body = {
            temperature = 0,
            max_tokens = 4096,
          },
        },
        ollama = {
          endpoint = 'http://127.0.0.1:11434', -- Note that there is no /v1 at the end.
          model = 'deepseek-r1:8b',
          -- model = 'deepseek-r1:1.5b',
        },
        -- configure copilot provider to use claude as the auto-suggestions
        copilot = {
          -- model = 'claude-3.5-sonnet',
          -- model = 'claude-3.7-sonnet',
        },
        ---Specify the special dual_boost mode
        ---1. enabled: Whether to enable dual_boost mode. Default to false.
        ---2. first_provider: The first provider to generate response. Default to "openai".
        ---3. second_provider: The second provider to generate response. Default to "claude".
        ---4. prompt: The prompt to generate response based on the two reference outputs.
        ---5. timeout: Timeout in milliseconds. Default to 60000.
        ---How it works:
        --- When dual_boost is enabled, avante will generate two responses from the first_provider and second_provider respectively. Then use the response from the first_provider as provider1_output and the response from the second_provider as provider2_output. Finally, avante will generate a response based on the prompt and the two reference outputs, with the default Provider as normal.
        ---Note: This is an experimental feature and may not work as expected.
        dual_boost = {
          enabled = false,
          first_provider = 'openai',
          second_provider = 'claude',
          prompt = 'Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]',
          timeout = 60000, -- Timeout in milliseconds
        },
        behaviour = {
          auto_suggestions = false, -- Experimental stage
          auto_set_highlight_group = true,
          auto_set_keymaps = true,
          auto_apply_diff_after_generation = false,
          support_paste_from_clipboard = false,
          minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
          enable_token_counting = true, -- Whether to enable token counting. Default to true.
          enable_cursor_planning_mode = false, -- Whether to enable Cursor Planning Mode. Default to false.
          enable_claude_text_editor_tool_mode = false, -- Whether to enable Claude Text Editor Tool Mode.
        },
      },
      mappings = {
        --- @class AvanteConflictMappings
        diff = {
          ours = 'co',
          theirs = 'ct',
          all_theirs = 'ca',
          both = 'cb',
          cursor = 'cc',
          next = ']x',
          prev = '[x',
        },
        suggestion = {
          accept = '<M-l>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
        },
        jump = {
          next = ']]',
          prev = '[[',
        },
        submit = {
          normal = '<CR>',
          insert = '<C-s>',
        },
        sidebar = {
          apply_all = 'A',
          apply_cursor = 'a',
          retry_user_request = 'r',
          edit_user_request = 'e',
          switch_windows = '<Tab>',
          reverse_switch_windows = '<S-Tab>',
          remove_file = 'd',
          add_file = '@',
          close = { '<Esc>', 'q' },
          close_from_input = nil, -- e.g., { normal = "<Esc>", insert = "<C-d>" }
        },
      },
      hints = { enabled = true },
      windows = {
        ---@type "right" | "left" | "top" | "bottom"
        position = 'right', -- the position of the sidebar
        wrap = true, -- similar to vim.o.wrap
        width = 40, -- default % based on available width
        sidebar_header = {
          enabled = true, -- true, false to enable/disable the header
          align = 'center', -- left, center, right for title
          rounded = true,
        },
        input = {
          prefix = '▷',
          height = 8, -- Height of the input window in vertical layout
        },
        edit = {
          border = 'rounded',
          start_insert = true, -- Start insert mode when opening the edit window
        },
        ask = {
          floating = false, -- Open the 'AvanteAsk' prompt in a floating window
          start_insert = true, -- Start insert mode when opening the ask window
          border = 'rounded',
          ---@type "ours" | "theirs"
          focus_on_apply = 'ours', -- which diff to focus after applying
        },
      },
      highlights = {
        ---@type AvanteConflictHighlights
        diff = {
          current = 'DiffText',
          incoming = 'DiffAdd',
        },
      },
      --- @class AvanteConflictUserConfig
      diff = {
        autojump = true,
        ---@type string | fun(): any
        list_opener = 'copen',
        --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
        --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
        --- Disable by setting to -1.
        override_timeoutlen = 500,
      },
      suggestion = {
        debounce = 600,
        throttle = 600,
      },
    },
    build = 'make',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
      'zbirenbaum/copilot.lua',
      {
        'HakonHarnes/img-clip.nvim', -- support for image pasting
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = { insert_mode = true },
          },
        },
      },
      {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = {
          'nvim-treesitter/nvim-treesitter',
          'nvim-tree/nvim-web-devicons',
        }, -- if you prefer nvim-web-devicons
        opts = { file_types = { 'markdown', 'Avante' } },
        ft = { 'markdown', 'Avante' },
      },
    },
    config = function()
      require('avante').setup({
        -- system_prompt as function ensures LLM always has latest MCP server state
        -- This is evaluated for every message, even in existing chats
        system_prompt = function()
          local hub = require('mcphub').get_hub_instance()
          return hub and hub:get_active_servers_prompt() or ''
        end,
        -- Using function prevents requiring mcphub before it's loaded
        custom_tools = function()
          return {
            require('mcphub.extensions.avante').mcp_tool(),
          }
        end,
      })
    end,
  },

  {
    'ravitemer/mcphub.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    build = 'npm install -g mcp-hub@latest', -- Installs `mcp-hub` node binary globally
    config = function() require('mcphub').setup() end,
  },
}
