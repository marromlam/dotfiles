local icons = mrl.ui.icons.lsp

return { -- LSP Configuration & Plugins
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre' },
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      {
        'mason-org/mason.nvim',
        opts = {
          ui = {
            border = 'rounded',
            width = 0.8,
            height = 0.8,
            backdrop = 100, -- 100 = fully transparent (no dimming), 0 = fully opaque
          },
        },
        config = function(_, opts)
          require('mason').setup(opts)
          -- Disable columns in Mason windows after setup
          vim.api.nvim_create_autocmd('FileType', {
            pattern = 'mason',
            callback = function()
              vim.schedule(function()
                local win = vim.api.nvim_get_current_win()
                vim.wo[win].statuscolumn = ''
                vim.wo[win].signcolumn = 'no'
                vim.wo[win].foldcolumn = '0'
                vim.wo[win].number = false
                vim.wo[win].relativenumber = false
              end)
            end,
          })
        end,
      },
      { 'mason-org/mason-lspconfig.nvim', opts = {} },
      { 'WhoIsSethDaniel/mason-tool-installer.nvim', opts = {} },

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },
      { 'folke/lazydev.nvim' },
      {
        'stevanmilic/nvim-lspimport',
      },
    },
    config = function()
      -- Floating UI (hover/signature/diagnostics) border styling
      -- Some plugins/LSP helpers call `vim.lsp.util.open_floating_preview` directly,
      -- so enforce a default border there too.
      do
        local orig = vim.lsp.util.open_floating_preview
        ---@diagnostic disable-next-line: duplicate-set-field
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
          opts = opts or {}
          opts.border = opts.border or 'rounded'
          -- Disable all columns in LSP floating windows
          local bufnr, winnr = orig(contents, syntax, opts, ...)
          if winnr and vim.api.nvim_win_is_valid(winnr) then
            vim.wo[winnr].statuscolumn = ''
            vim.wo[winnr].signcolumn = 'no'
            vim.wo[winnr].foldcolumn = '0'
            vim.wo[winnr].number = false
            vim.wo[winnr].relativenumber = false
          end
          return bufnr, winnr
        end
      end

      -- Prefer wrapping the existing handlers instead of `vim.lsp.with(...)`
      -- (some setups/tools flag `vim.lsp.with` / `vim.lsp.handlers.hover` as deprecated).
      local function with_border(handler)
        return function(err, result, ctx, config)
          config = config or {}
          config.border = config.border or 'rounded'
          return handler(err, result, ctx, config)
        end
      end

      vim.lsp.handlers['textDocument/hover'] =
        with_border(vim.lsp.handlers['textDocument/hover'])
      vim.lsp.handlers['textDocument/signatureHelp'] =
        with_border(vim.lsp.handlers['textDocument/signatureHelp'])

      -- Brief aside: **What is LSP?**  #234523
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup(
          'kickstart-lsp-attach',
          { clear = true }
        ),
        callback = function(event)
          -- Prevent duplicate keymap setup when multiple LSP servers attach
          if vim.b[event.buf].lsp_keymaps_attached then return end
          vim.b[event.buf].lsp_keymaps_attached = true

          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          vim.keymap.set(
            'n',
            '<leader>a',
            require('lspimport').import,
            { noremap = true }
          )
          local map = function(keys, func, desc)
            vim.keymap.set(
              'n',
              keys,
              func,
              { buffer = event.buf, desc = 'LSP: ' .. desc }
            )
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('gh', vim.lsp.buf.hover, 'Hover Documentation')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- DISABLED: Document highlight on CursorMove causes severe scrolling lag
          -- The CursorMoved autocmds fire on every scroll step, causing expensive LSP operations
          -- To re-enable, uncomment the code below and adjust updatetime for better performance
          --
          -- local client = vim.lsp.get_client_by_id(event.data.client_id)
          -- if
          --   client and client.server_capabilities.documentHighlightProvider
          -- then
          --   local highlight_augroup = vim.api.nvim_create_augroup(
          --     'kickstart-lsp-highlight',
          --     { clear = false }
          --   )
          --   vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          --     buffer = event.buf,
          --     group = highlight_augroup,
          --     callback = vim.lsp.buf.document_highlight,
          --   })
          --
          --   vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          --     buffer = event.buf,
          --     group = highlight_augroup,
          --     callback = vim.lsp.buf.clear_references,
          --   })
          -- end

          -- The following autocommand is used to enable inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if
            client
            and client.server_capabilities.inlayHintProvider
            and vim.lsp.inlay_hint
          then
            map(
              '<leader>th',
              function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
              end,
              '[T]oggle Inlay [H]ints'
            )
          end
        end,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup(
          'kickstart-lsp-detach',
          { clear = true }
        ),
        callback = function(event)
          vim.lsp.buf.clear_references()
          -- try to clear the highlights when the LSP detaches
          pcall(
            function()
              vim.api.nvim_clear_autocmds({
                group = 'kickstart-lsp-highlight',
                buffer = event.buf,
              })
            end
          )
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local original_capabilities = vim.lsp.protocol.make_client_capabilities()
      local capabilities =
        require('blink.cmp').get_lsp_capabilities(original_capabilities)

      -- Disable file watchers for performance (especially in large projects)
      capabilities.workspace = capabilities.workspace or {}
      capabilities.workspace.didChangeWatchedFiles = capabilities.workspace.didChangeWatchedFiles
        or {}
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        basedpyright = {
          on_attach = function(client, bufnr)
            -- Disable diagnostics from basedpyright
            client.server_capabilities.diagnosticProvider = false
          end,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = 'off',
                diagnosticMode = 'openFilesOnly',
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
            basedpyright = {
              disableOrganizeImports = true,
            },
          },
        },
        ruff = {},
        -- pylsp = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        -- tsserver = {},
        --

        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              diagnostics = {
                globals = { 'vim' },
              },
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'flake8',
        'mypy',
        'black',
        'sonarlint-language-server',
      })
      require('mason-tool-installer').setup({
        ensure_installed = ensure_installed,
      })

      require('mason-lspconfig').setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend(
              'force',
              {},
              capabilities,
              server.capabilities or {}
            )
            require('lspconfig')[server_name].setup(server)
          end,
        },
      })
    end,
  },
  {
    'simrat39/symbols-outline.nvim',
    cmd = 'SymbolsOutline',
    keys = {
      { '<leader>cs', '<cmd>SymbolsOutline<cr>', desc = 'Symbols Outline' },
    },
    config = true,
  },
  -- Disabled due to deprecated :LspStart command usage
  -- {
  --   'zeioth/garbage-day.nvim',
  --   dependencies = 'neovim/nvim-lspconfig',
  --   event = 'LspAttach',
  --   opts = {
  --     excluded_lsp_clients = {
  --       'null-ls',
  --       'jdtls',
  --       'marksman',
  --       'lua_ls',
  --       'copilot',
  --     },
  --     timout = 3000, -- Timeout in milliseconds for the garbage collection
  --   },
  -- },
  {
    'rachartier/tiny-inline-diagnostic.nvim',
    event = 'LspAttach',
    priority = 1000,
    dependencies = {
      'mfussenegger/nvim-lint',
    },
    config = function()
      -- Don't error if linters aren't installed (common on fresh machines / WSL).
      pcall(function() require('lint').try_lint() end)
      require('tiny-inline-diagnostic').setup({
        -- "modern", "classic", "minimal", "powerline", "simple"
        preset = 'simple',
        transparent_bg = false, -- Set the background of the diagnostic to transparent
        hi = {
          error = 'DiagnosticError', -- Highlight group for error messages
          warn = 'DiagnosticWarn', -- Highlight group for warning messages
          info = 'DiagnosticInfo', -- Highlight group for informational messages
          hint = 'DiagnosticHint', -- Highlight group for hint or suggestion messages
          arrow = 'NonText', -- Highlight group for diagnostic arrows
          -- Background color for diagnostics
          -- Can be a highlight group or a hexadecimal color (#RRGGBB)
          background = 'CursorLine',
          -- Color blending option for the diagnostic background
          -- Use "None" or a hexadecimal color (#RRGGBB) to blend with another color
          mixing_color = 'None',
        },

        options = {
          show_source = true,
          -- Use icons defined in the diagnostic configuration
          use_icons_from_diagnostic = false,

          -- Set the arrow icon to the same color as the first diagnostic severity
          set_arrow_to_diag_color = false,

          -- Add messages to diagnostics when multiline diagnostics are enabled
          -- If set to false, only signs will be displayed
          add_messages = true,

          -- Time (in milliseconds) to throttle updates while moving the cursor
          -- Increase this value for better performance if your computer is slow
          -- or set to 0 for immediate updates and better visual
          throttle = 100, -- Increased from 20 to reduce update frequency during scrolling

          -- Minimum message length before wrapping to a new line
          softwrap = 30,

          -- Configuration for multiline diagnostics
          -- Can either be a boolean or a table with the following options:
          --  multilines = {
          --      enabled = false,
          --      always_show = false,
          -- }
          -- If it set as true, it will enable the feature with this options:
          --  multilines = {
          --      enabled = true,
          --      always_show = false,
          -- }
          multilines = {
            enabled = false,
            always_show = false,
          },
          -- Display all diagnostic messages on the cursor line
          show_all_diags_on_cursorline = false,
          -- Disable diagnostics in Insert and Visual modes
          enable_on_insert = false,
          enable_on_select = false,
          overflow = {
            mode = 'wrap',
            padding = 0,
          },
          -- Configuration for breaking long messages into separate lines
          break_line = {
            enabled = false,
            after = 30,
          },

          -- Custom format function for diagnostic messages
          -- Example:
          -- format = function(diagnostic)
          --     return diagnostic.message .. " [" .. diagnostic.source .. "]"
          -- end
          format = nil,
          virt_texts = {
            -- Priority for virtual text display
            priority = 2048,
          },
          -- Filter diagnostics by severity
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
            vim.diagnostic.severity.INFO,
            vim.diagnostic.severity.HINT,
          },
          -- Events to attach diagnostics to buffers
          overwrite_events = nil,
        },
        disabled_ft = {}, -- List of filetypes to disable the plugin
      })
    end,
  },

  {
    'iamkarasik/sonarqube.nvim',
    ft = { 'python' },
    dependencies = {
      'mason-org/mason.nvim',
    },
    cond = function()
      -- Only load if Java is available (required for SonarLint)
      return vim.fn.executable('java') == 1
    end,
    config = function()
      -- Configure with Mason-installed sonarlint-language-server
      local extension_path = vim.fn.stdpath('data')
        .. '/mason/packages/sonarlint-language-server/extension'

      -- Check if extension exists
      if vim.fn.isdirectory(extension_path) == 0 then
        vim.notify(
          'SonarLint extension not found. Run :MasonInstall sonarlint-language-server',
          vim.log.levels.WARN
        )
        return
      end

      require('sonarqube').setup({
        lsp = {
          cmd = {
            vim.fn.exepath('java'),
            '-jar',
            extension_path .. '/server/sonarlint-ls.jar',
            '-stdio',
            '-analyzers',
            extension_path .. '/analyzers/sonargo.jar',
            extension_path .. '/analyzers/sonarhtml.jar',
            extension_path .. '/analyzers/sonariac.jar',
            extension_path .. '/analyzers/sonarjava.jar',
            extension_path .. '/analyzers/sonarjavasymbolicexecution.jar',
            extension_path .. '/analyzers/sonarjs.jar',
            extension_path .. '/analyzers/sonarphp.jar',
            extension_path .. '/analyzers/sonarpython.jar',
            extension_path .. '/analyzers/sonartext.jar',
            extension_path .. '/analyzers/sonarxml.jar',
          },
        },
        python = {
          enabled = true,
        },
      })
    end,
  },

  {
    'kosayoda/nvim-lightbulb',
    event = 'LspAttach',
    keys = {
      {
        '<leader>lb',
        ":lua require('nvim-lightbulb').get_status_text()<cr>",
        desc = 'LSP: Lightbulb status',
      },
    },
    opts = {
      autocmd = { enabled = true },
      sign = { enabled = false },
      float = {
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
      { 'gd', '<Cmd>Glance definitions<CR>', desc = 'LSP: Glance definitions' },
      { 'gr', '<Cmd>Glance references<CR>', desc = 'LSP: Glance references' },
      {
        'gy',
        '<Cmd>Glance type_definitions<CR>',
        desc = 'LSP: Glance type definitions',
      },
      {
        'gm',
        '<Cmd>Glance implementations<CR>',
        desc = 'LSP: Glance implementations',
      },
    },
  },
  {
    'smjonas/inc-rename.nvim',
    cmd = 'IncRename',
    opts = { hl_group = 'Visual', preview_empty_name = true },
    keys = {
      {
        '<leader>rn',
        function() return vim.fmt(':IncRename %s', vim.fn.expand('<cword>')) end,
        expr = true,
        silent = false,
        desc = 'lsp: incremental rename',
      },
    },
  },
}
