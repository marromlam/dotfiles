return {
  {
    'stevearc/conform.nvim',
    -- lazy = false,
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>lf',
        function()
          require('conform').format({ async = true, lsp_format = 'fallback' })
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    config = function()
      local conform = require('conform')
      conform.setup({
        notify_on_error = true,
        format_on_save = function(bufnr)
          -- Disable LSP fallback for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
          if not vim.bo[bufnr].modifiable then return nil end
          if vim.g.disable_autoformat or vim.g.formatting_disabled then
            return nil
          end
          if vim.b[bufnr] and vim.b[bufnr].formatting_disabled then
            return nil
          end
          local disable_filetypes =
            { c = true, cpp = true, xml = true, cnk = true, map = true }
          return {
            timeout_ms = 5000,
            lsp_format = disable_filetypes[vim.bo[bufnr].filetype] and 'never'
              or 'fallback',
          }
        end,
        formatters_by_ft = {
          bash = { 'shfmt' },
          javascript = { 'prettier' },
          typescript = { 'prettier' },
          javascriptreact = { 'prettier' },
          typescriptreact = { 'prettier' },
          svelte = { 'prettier' },
          css = { 'prettierd' },
          html = { 'prettier' },
          json = { 'prettier' },
          yaml = { 'prettier' },
          markdown = { 'prettier' },
          graphql = { 'prettier' },
          liquid = { 'prettier' },
          lua = { 'stylua' },
          python = { 'isort', 'black' },
          xml = { 'xmlformat' },
        },
        -- Set default options
        default_format_opts = {
          lsp_format = 'fallback',
        },
        -- Set up format-on-save
        -- format_on_save = { timeout_ms = 500 },
        -- Customize formatters
        formatters = {
          shfmt = {
            prepend_args = { '-i', '2' },
          },
          -- Only run prettier if config file exists
          prettier = {},
          prettierd = {},
          -- Only run isort if config file exists
          isort = {},
          -- Only run stylua if config file exists
          stylua = {},
        },
      })

      vim.api.nvim_create_user_command('Format', function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line =
            vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ['end'] = { args.line2, end_line:len() },
          }
        end
        conform.format({
          async = true,
          lsp_format = 'fallback',
          range = range,
        })
      end, { range = true })

      vim.api.nvim_create_user_command(
        'FormatDisable',
        function(args) vim.g.disable_autoformat = true end,
        {
          desc = 'Disable autoformat-on-save',
        }
      )

      vim.api.nvim_create_user_command(
        'FormatEnable',
        function() vim.g.disable_autoformat = false end,
        {
          desc = 'Re-enable autoformat-on-save',
        }
      )
    end,
  },
}
