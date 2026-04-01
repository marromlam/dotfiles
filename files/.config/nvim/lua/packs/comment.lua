-- packs/comment.lua

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlComment', { clear = true }),
  callback = function()
    -- Disable the default CursorHold autocmd; Comment.nvim calls it via pre_hook only
    require('ts_context_commentstring').setup({ enable_autocmd = false })

    local comment = require('Comment')
    local ts_context_commentstring =
      require('ts_context_commentstring.integrations.comment_nvim')

    -- enable comment with tsx/jsx/svelte/html support
    comment.setup({
      pre_hook = ts_context_commentstring.create_pre_hook(),
    })
  end,
})
