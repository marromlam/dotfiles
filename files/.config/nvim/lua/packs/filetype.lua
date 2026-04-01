-- packs/filetype.lua

-- markdown support (plasticboy/vim-markdown) - ft triggered by vim automatically

-- image.nvim for markdown/neorg/org
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'neorg', 'org' },
  once = true,
  group = vim.api.nvim_create_augroup('MrlImage', { clear = true }),
  callback = function()
    require('image').setup({})
  end,
})

-- crates.nvim for Cargo.toml
vim.api.nvim_create_autocmd('BufRead', {
  pattern = 'Cargo.toml',
  once = true,
  group = vim.api.nvim_create_augroup('MrlCrates', { clear = true }),
  callback = function()
    require('crates').setup()
  end,
})

-- csvview.nvim for csv files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'csv',
  once = true,
  group = vim.api.nvim_create_augroup('MrlCsvView', { clear = true }),
  callback = function()
    require('csvview').setup({
      parser = { comments = { '#', '//' } },
      keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { 'if', mode = { 'o', 'x' } },
        textobject_field_outer = { 'af', mode = { 'o', 'x' } },
        -- Excel-like navigation:
        jump_next_field_end = { '<Tab>', mode = { 'n', 'v' } },
        jump_prev_field_end = { '<S-Tab>', mode = { 'n', 'v' } },
        jump_next_row = { '<Enter>', mode = { 'n', 'v' } },
        jump_prev_row = { '<S-Enter>', mode = { 'n', 'v' } },
      },
    })
  end,
})

-- ledger.vim for ledger filetypes
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'ledger',
  once = true,
  group = vim.api.nvim_create_augroup('MrlLedger', { clear = true }),
  callback = function()
    vim.cmd([[
      au BufNewFile,BufRead *.ldg,*.ledger setf ledger | comp ledger
      let g:ledger_maxwidth = 120
      let g:ledger_fold_blanks = 1
      function LedgerSort()
          :%! ledger -f - print --sort 'date, amount'
          :%LedgerAlign
      endfunction
      command LedgerSort call LedgerSort()
    ]])
  end,
})

-- markdown-table-mode for markdown/neorg/org
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'neorg', 'org' },
  once = true,
  group = vim.api.nvim_create_augroup('MrlMarkdownTable', { clear = true }),
  callback = function()
    require('markdown-table-mode').setup({
      filetype = {
        '*.md',
      },
      options = {
        insert = true, -- when typing "|"
        insert_leave = true, -- when leaving insert
        pad_separator_line = false, -- add space in separator line
        alig_style = 'default', -- default, left, center, right
      },
    })
  end,
})

-- nvim-docx (dev plugin, lazy=false in original - load immediately)
-- vim.keymap.set('n', '<S-CR>', ':ReloadXMLFromZip<CR>', { desc = 'Reload MS Word' })

-- vimtex for tex files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'tex',
  once = true,
  group = vim.api.nvim_create_augroup('MrlVimtex', { clear = true }),
  callback = function()
    require('packs.vimtex').config()
    -- tex-kitty setup
    require('tex-kitty').setup({
      tex_kitty_preview = 1,
    })
  end,
})

-- pgsql.vim is disabled (cond = false)
-- livetex.nvim is disabled (cond = false)
