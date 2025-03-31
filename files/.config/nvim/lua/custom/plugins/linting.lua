return {
  'mfussenegger/nvim-lint',
  events = { 'BufWritePost', 'BufReadPost', 'InsertLeave', 'LspAttach' },
  keys = {
    {
      '<leader>ll',
      function() require('lint').try_lint() end,
      desc = 'Trigger linting for current file',
    },
  },
  config = function()
    local lint = require('lint')

    lint.linters_by_ft = {
      javascript = { 'eslint_d' },
      typescript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      python = { 'flake8', 'mypy' },
      dockerfile = { 'hadolint' },
      json = { 'jsonlint' },
      markdown = { 'vale' },
      rst = { 'vale' },
      ruby = { 'ruby' },
      terraform = { 'tflint' },
      text = { 'vale' },
    }
    lint.linters_by_ft['clojure'] = nil -- example on how to disable

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function() require('lint').try_lint() end,
    })
  end,
}
