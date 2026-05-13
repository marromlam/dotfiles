-- packs/lsp.lua

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

-- LspAttach: register keymaps per buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    -- Prevent duplicate keymap setup when multiple LSP servers attach
    if vim.b[event.buf].lsp_keymaps_attached then return end
    vim.b[event.buf].lsp_keymaps_attached = true

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
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

    -- Execute a code action
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    -- Opens a popup that displays documentation about the word under your cursor
    map('gh', vim.lsp.buf.hover, 'Hover Documentation')

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- DISABLED: Document highlight on CursorMove causes severe scrolling lag
    -- The CursorMoved autocmds fire on every scroll step, causing expensive LSP operations

    -- Enable inlay hints if the language server supports them
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
  group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
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

-- LSP capabilities (with blink.cmp)
local original_capabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities =
  require('blink.cmp').get_lsp_capabilities(original_capabilities)

-- Disable file watchers for performance (especially in large projects)
capabilities.workspace = capabilities.workspace or {}
capabilities.workspace.didChangeWatchedFiles = capabilities.workspace.didChangeWatchedFiles
  or {}
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

-- Language server configurations
local servers = {
  -- clangd = {},
  -- gopls = {},
  basedpyright = {
    on_attach = function(client, _bufnr)
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
  -- tsserver = {},

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
        -- diagnostics = { disable = { 'missing-fields' } },
      },
    },
  },
}

-- Mason setup
require('mason').setup({
  ui = {
    border = 'rounded',
    width = 0.8,
    height = 0.8,
    backdrop = 100,
  },
})

-- lazydev for Lua development
require('lazydev').setup({
  library = {
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    { path = 'wezterm-types', mods = { 'wezterm' } },
  },
  enabled = function(root_dir)
    return (vim.g.lazydev_enabled == nil or vim.g.lazydev_enabled)
      and not vim.uv.fs_stat(root_dir .. '/.luarc.json')
  end,
})

-- fidget for LSP progress
require('fidget').setup({})

-- Ensure the servers and tools are installed
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  -- Lua
  'stylua',
  -- Python
  'black',
  'isort',
  'flake8',
  'mypy',
  -- Shell
  'shfmt',
  -- JS/TS
  'prettier',
  'prettierd',
  'eslint_d',
  -- Misc linters
  'hadolint',
  'jsonlint',
  'vale',
  'tflint',
  -- Other
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
      -- by the server configuration above.
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

-- symbols-outline
vim.keymap.set('n', '<leader>cs', '<cmd>SymbolsOutline<cr>', { desc = 'Symbols Outline' })
require('symbols-outline').setup()

-- tiny-inline-diagnostic (on LspAttach)
vim.api.nvim_create_autocmd('LspAttach', {
  once = true,
  group = vim.api.nvim_create_augroup('MrlTinyInlineDiag', { clear = true }),
  callback = function()
    -- Don't error if linters aren't installed (common on fresh machines / WSL).
    pcall(function() require('lint').try_lint() end)
    require('tiny-inline-diagnostic').setup({
      -- "modern", "classic", "minimal", "powerline", "simple"
      preset = 'simple',
      transparent_bg = false,
      hi = {
        error = 'DiagnosticError',
        warn = 'DiagnosticWarn',
        info = 'DiagnosticInfo',
        hint = 'DiagnosticHint',
        arrow = 'NonText',
        background = 'CursorLine',
        mixing_color = 'None',
      },

      options = {
        show_source = true,
        use_icons_from_diagnostic = false,
        set_arrow_to_diag_color = false,
        add_messages = true,
        throttle = 100,
        softwrap = 30,
        multilines = {
          enabled = false,
          always_show = false,
        },
        show_all_diags_on_cursorline = false,
        enable_on_insert = false,
        enable_on_select = false,
        overflow = {
          mode = 'wrap',
          padding = 0,
        },
        break_line = {
          enabled = false,
          after = 30,
        },
        format = nil,
        virt_texts = {
          priority = 2048,
        },
        severity = {
          vim.diagnostic.severity.ERROR,
          vim.diagnostic.severity.WARN,
          vim.diagnostic.severity.INFO,
          vim.diagnostic.severity.HINT,
        },
        overwrite_events = nil,
      },
      disabled_ft = {},
    })
  end,
})

-- sonarqube.nvim (conditional on java being available)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  once = true,
  group = vim.api.nvim_create_augroup('MrlSonarqube', { clear = true }),
  callback = function()
    if vim.fn.executable('java') ~= 1 then return end

    local extension_path = vim.fn.stdpath('data')
      .. '/mason/packages/sonarlint-language-server/extension'

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
})

-- nvim-lightbulb (on LspAttach)
vim.api.nvim_create_autocmd('LspAttach', {
  once = true,
  group = vim.api.nvim_create_augroup('MrlLightbulb', { clear = true }),
  callback = function()
    require('nvim-lightbulb').setup({
      autocmd = { enabled = true },
      sign = { enabled = false },
      float = {
        enabled = true,
        win_opts = { border = 'none' },
      },
    })
  end,
})
vim.keymap.set('n', '<leader>lb', function()
  require('nvim-lightbulb').get_status_text()
end, { desc = 'LSP: Lightbulb status' })

-- glance.nvim (on LspAttach)
vim.api.nvim_create_autocmd('LspAttach', {
  once = true,
  group = vim.api.nvim_create_augroup('MrlGlance', { clear = true }),
  callback = function()
    require('glance').setup({
      preview_win_opts = { relativenumber = false },
      theme = { enable = true, mode = 'darken' },
    })
  end,
})
vim.keymap.set('n', 'gd', '<Cmd>Glance definitions<CR>', { desc = 'LSP: Glance definitions' })
vim.keymap.set('n', 'gr', '<Cmd>Glance references<CR>', { desc = 'LSP: Glance references' })
vim.keymap.set('n', 'gy', '<Cmd>Glance type_definitions<CR>', { desc = 'LSP: Glance type definitions' })
vim.keymap.set('n', 'gm', '<Cmd>Glance implementations<CR>', { desc = 'LSP: Glance implementations' })

-- inc-rename
require('inc_rename').setup({
  hl_group = 'Visual',
  preview_empty_name = true,
})
vim.keymap.set('n', '<leader>rn', function()
  return vim.fmt(':IncRename %s', vim.fn.expand('<cword>'))
end, { expr = true, silent = false, desc = 'lsp: incremental rename' })
