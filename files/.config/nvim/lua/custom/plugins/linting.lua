return {
  'mfussenegger/nvim-lint',
  events = { 'BufWritePost', 'BufReadPost', 'InsertLeave', 'LspAttach' },
  keys = {
    {
      '<leader>ll',
      function() require('lint').try_lint() end,
      desc = 'Try linting for current file',
    },
  },
  config = function()
    local lint = require('lint')
    local fn = vim.fn

    local function exe(cmd)
      return type(cmd) == 'string' and cmd ~= '' and fn.executable(cmd) == 1
    end

    ---Return true if nvim-lint should run for this buffer.
    ---Avoids noisy errors in fugitive/diff/virtual buffers and when tools aren't installed.
    ---@param bufnr integer
    local function can_lint(bufnr)
      if not vim.api.nvim_buf_is_valid(bufnr) then return false end
      if vim.bo[bufnr].buftype ~= '' then return false end
      local ft = vim.bo[bufnr].filetype or ''
      if ft == '' then return false end
      -- Fugitive/diff buffers often have virtual paths; skip lint.
      if ft:match('^fugitive') or ft == 'diff' then return false end

      local names = lint.linters_by_ft[ft]
      if type(names) ~= 'table' or #names == 0 then return false end

      for _, name in ipairs(names) do
        local linter = lint.linters and lint.linters[name] or nil
        local cmd = linter and (linter.cmd or linter.command) or nil
        if exe(cmd) then
          return true
        end
      end
      return false
    end

    lint.linters_by_ft = {
      javascript = { 'eslint_d' },
      typescript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      python = { 'flake8', 'mypy' },
      -- Only enable if installed; otherwise nvim-lint will error (ENOENT).
      lua = exe('luacheck') and { 'luacheck' } or nil,
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
      callback = function(args)
        if not can_lint(args.buf) then return end
        pcall(lint.try_lint)
      end,
    })
  end,
}
