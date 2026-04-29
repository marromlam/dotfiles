-- packs/comment.lua

-- Patch ts_context_commentstring's update_commentstring to guard against
-- buffers where get_parser() throws (e.g. zip/docx buffers get ft=tar and
-- treesitter registers a parser, but it errors when actually called).
-- Root cause: BufReadCmd (used by vim-rzip) bypasses BufReadPre, so the
-- buffer gets ft=tar, is_treesitter_active() returns true, CursorHold is
-- registered, but get_parser() later throws on the rzip buffer content.
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  group = vim.api.nvim_create_augroup('MrlTsContextPatch', { clear = true }),
  callback = function()
    local ok, internal = pcall(require, 'ts_context_commentstring.internal')
    if not ok then return end
    local orig_update = internal.update_commentstring
    internal.update_commentstring = function(args)
      local guard_ok = pcall(function()
        -- Ensure get_parser() actually works before proceeding
        vim.treesitter.get_parser(0):trees()
      end)
      if not guard_ok then return end
      orig_update(args)
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlComment', { clear = true }),
  callback = function()
    require('ts_context_commentstring').setup({ enable_autocmd = false })

    local comment = require('Comment')
    local ts_context_commentstring =
      require('ts_context_commentstring.integrations.comment_nvim')

    local ts_pre_hook = ts_context_commentstring.create_pre_hook()
    comment.setup({
      pre_hook = function(ctx)
        local guard_ok = pcall(function()
          vim.treesitter.get_parser(0):trees()
        end)
        if not guard_ok then return end
        return ts_pre_hook(ctx)
      end,
    })
  end,
})
