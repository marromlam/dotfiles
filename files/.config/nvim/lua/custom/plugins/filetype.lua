return {

  -- markdown support
  {
    'plasticboy/vim-markdown',
    disable = false,
    ft = { 'markdown', 'rst' },
  },

  { '3rd/image.nvim', ft = { 'markdown', 'neorg', 'org' }, opts = {} },

  -- syntax highlighting for log files
  {
    'mtdl9/vim-log-highlighting',
    disable = false,
    ft = 'log',
  },

  {
    'raivivek/vim-snakemake',
    ft = 'snakemake',
  },

  -- syntax highlighting for kitty conf file
  {
    'fladson/vim-kitty',
    disable = false,
    ft = 'conf',
  },

  -- sets searchable path for filetypes like go so 'gf' works
  {
    'tpope/vim-apathy',
    disable = false,
    ft = { 'go', 'python', 'javascript', 'typescript' },
  },

  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    requires = { { 'nvim-lua/plenary.nvim' } },
    config = function() require('crates').setup() end,
  },

  {
    'lbrayner/vim-rzip',
    disable = false,
    ft = { 'zip', 'docx', 'xlsx', 'pptx' },
    config = function()
      vim.cmd([[
        " let g:rzipPlugin_extra_ext = '*.docx'
      ]])
    end,
  },

  -- {
  --   'tpope/vim-surround',
  --   event = 'InsertEnter',
  -- },

  -- {
  --   'chrisbra/csv.vim',
  --   ft = 'csv',
  -- },

  {
    'hat0uma/csvview.nvim',
    ft = 'csv',
    opts = {
      parser = { comments = { '#', '//' } },
      keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { 'if', mode = { 'o', 'x' } },
        textobject_field_outer = { 'af', mode = { 'o', 'x' } },
        -- Excel-like navigation:
        -- Use <Tab> and <S-Tab> to move horizontally between fields.
        -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
        -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
        jump_next_field_end = { '<Tab>', mode = { 'n', 'v' } },
        jump_prev_field_end = { '<S-Tab>', mode = { 'n', 'v' } },
        jump_next_row = { '<Enter>', mode = { 'n', 'v' } },
        jump_prev_row = { '<S-Enter>', mode = { 'n', 'v' } },
      },
    },
    cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
  },

  {
    'lifepillar/pgsql.vim',
    lazy = true,
    disable = true,
    cond = false,
  },
  {
    'ledger/vim-ledger',
    ft = 'ledger',
    config = function()
      vim.cmd([[
          " For ledger
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
  },

  {
    'Kicamon/markdown-table-mode.nvim',
    ft = { 'markdown', 'neorg', 'org' },
    config = function()
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
  },

  {
    'marromlam/nvim-docx.nvim',
    name = 'nvim-docx',
    dir = '~/Workspaces/personal/nvim-docx',
    dev = true,
    lazy = false,
    keys = {
      -- '<S-CR>',
      '<leader>X',
      ':ReloadXMLFromZip<CR>',
      desc = 'Reload MS Word',
    },
  },

  ------------------------------------------------------------------------
  --- LaTeX {{{
  ------------------------------------------------------------------------

  {
    -- vimtex
    'lervag/vimtex',
    ft = { 'tex' },
    config = function() require('custom.config.vimtex').config() end,
  },

  {
    'marromlam/tex-kitty',
    ft = 'tex',
    dir = '/Users/marcos/Projects/personal/tex-kitty',
    dev = true,
    dependencies = { 'lervag/vimtex' },
    config = function()
      require('tex-kitty').setup({
        tex_kitty_preview = 1,
      })
    end,
  },

  {
    'marromlam/livetex.nvim',
    ft = 'tex',
    dir = '/Users/marcos/Projects/personal/livetex.nvim',
    dev = true,
    dependencies = { 'lervag/vimtex' },
    config = function()
      require('livetex').setup({
        engine = 'pdflatex', -- or "lualatex"
        fmt = 'fastfmt.fmt', -- path to your precompiled preamble
        -- out_dir = '/dev/shm/livetex', -- RAM disk for fast output
        out_dir = '/Users/marcos/tmp/livetex', -- or any writable path
        live = true,
        reload_cmd = '', -- auto reload PDF
        -- reload_cmd = 'osascript -e \'tell application "Skim" to revert front document\'', -- auto reload PDF
        debounce_ms = 600,
        show_spinner = true,
        pdf_target = 'same', -- (default) copy next to .tex
      })
    end,
  },

  -- }}}
  ------------------------------------------------------------------------
}
