local icons = mrl.ui.icons.separators

local gitlinker = mrl.require_for_later_index('gitlinker')
local function browser_open()
  return { action_callback = require('gitlinker.actions').open_in_browser }
end

return {
  -----------------------------------------------------------------------------
  -- git signs {{{
  -----------------------------------------------------------------------------
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = icons.right_block },
        change = { text = icons.right_block },
        delete = { text = icons.right_block },
        topdelete = { text = icons.right_block },
        changedelete = { text = icons.right_block },
        untracked = { text = icons.light_shade_block },
      },
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gitsigns.nav_hunk('next')
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gitsigns.nav_hunk('prev')
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mode
        map(
          'v',
          '<leader>hs',
          function() gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
          { desc = 'stage git hunk' }
        )
        map(
          'v',
          '<leader>hr',
          function() gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
          { desc = 'reset git hunk' }
        )
        -- normal mode
        map(
          'n',
          '<leader>hs',
          gitsigns.stage_hunk,
          { desc = 'git [s]tage hunk' }
        )
        map(
          'n',
          '<leader>hr',
          gitsigns.reset_hunk,
          { desc = 'git [r]eset hunk' }
        )
        map(
          'n',
          '<leader>hS',
          gitsigns.stage_buffer,
          { desc = 'git [S]tage buffer' }
        )
        map(
          'n',
          '<leader>hu',
          gitsigns.undo_stage_hunk,
          { desc = 'git [u]ndo stage hunk' }
        )
        map(
          'n',
          '<leader>hR',
          gitsigns.reset_buffer,
          { desc = 'git [R]eset buffer' }
        )
        map(
          'n',
          '<leader>hp',
          gitsigns.preview_hunk,
          { desc = 'git [p]review hunk' }
        )
        map(
          'n',
          '<leader>hb',
          gitsigns.blame_line,
          { desc = 'git [b]lame line' }
        )
        map(
          'n',
          '<leader>hd',
          gitsigns.diffthis,
          { desc = 'git [d]iff against index' }
        )
        map(
          'n',
          '<leader>hD',
          function() gitsigns.diffthis('@') end,
          { desc = 'git [D]iff against last commit' }
        )
        -- Toggles
        map(
          'n',
          '<leader>tb',
          gitsigns.toggle_current_line_blame,
          { desc = '[T]oggle git show [b]lame line' }
        )
        map(
          'n',
          '<leader>tD',
          gitsigns.toggle_deleted,
          { desc = '[T]oggle git show [D]eleted' }
        )
      end,
    },
  },

  {
    'ruifm/gitlinker.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      {
        '<localleader>gu',
        function() gitlinker.get_buf_range_url('n') end,
        desc = 'gitlinker: copy line to clipboard',
        mode = 'n',
      },
      {
        '<localleader>gu',
        function() gitlinker.get_buf_range_url('v') end,
        desc = 'gitlinker: copy range to clipboard',
        mode = 'v',
      },
      {
        '<leader>go',
        function() gitlinker.get_repo_url(browser_open()) end,
        desc = 'gitlinker: open in browser',
      },
      {
        '<leader>go',
        function() gitlinker.get_buf_range_url('n', browser_open()) end,
        desc = 'gitlinker: open current line in browser',
      },
      {
        '<leader>go',
        function() gitlinker.get_buf_range_url('v', browser_open()) end,
        desc = 'gitlinker: open current selection in browser',
        mode = 'v',
      },
    },
    opts = {
      mappings = nil,
      callbacks = {
        ['github-work'] = function(url_data) -- Resolve the host for work repositories
          url_data.host = 'github.com'
          return require('gitlinker.hosts').get_github_type_url(url_data)
        end,
      },
    },
  },
  -- }}}
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- fugitive {{{
  -----------------------------------------------------------------------------
  {
    'tpope/vim-fugitive',
    cmd = { 'Git' },
    keys = {
      {
        '<leader>gs',
        '<Cmd>Git<CR>',
        desc = '[git] Status',
        mode = 'n',
      },
      {
        '<leader>g-',
        "<cmd>lua require 'gitsigns'.blame_line()<cr>",
        desc = '[git] Blame',
      },
      { '<leader>gB', '<cmd>Git blame<cr>', desc = 'Git Blame' },
      {
        '<leader>gb',
        -- '<cmd>FzfLua git_branches<cr>',
        '<cmd>Telescope git_branches<cr>',
        desc = '[git] Checkout branch',
      },
      {
        '<leader>gc',
        '<cmd>Telescope git_commits<cr>',
        desc = '[git] Checkout commit',
      },
      {
        '<leader>gC',
        '<cmd>Telescope git_bcommits<cr>',
        desc = '[git] Checkout commit(for current file)',
      },
      {
        '<leader>gf',
        '<cmd>Git fall<cr>',
        desc = '[git] Git fetch all branches',
      },
      {
        '<leader>gh',
        '<cmd>diffget //2<cr>',
        desc = '[git] Get diff from left',
      },
      {
        '<leader>gl',
        '<cmd>diffget //3<cr>',
        desc = '[git] Get diff from right',
      },
      {
        '<leader>gj',
        "<cmd>lua require 'gitsigns'.next_hunk()<cr>",
        desc = '[git] Next Hunk',
      },
      {
        '<leader>gk',
        "<cmd>lua require 'gitsigns'.prev_hunk()<cr>",
        desc = '[git] Prev Hunk',
      },
      {
        '<leader>gP',
        '<cmd>Git push<cr>',
        desc = '[git] Git push commited changes',
      },
      {
        '<leader>gp',
        '<cmd>Git pull --rebase<cr>',
        desc = '[git] Git pull and rebase',
      },
      {
        '<leader>gt',
        ':Git push -u origin ',
        desc = '[git] set target branch <name>',
      },
    },
  },
  -- }}}
  -----------------------------------------------------------------------------

  -- Other fancy plugins {{{
  --

  {
    'sindrets/diffview.nvim',
  },

  -- }}}
}

-- vim: fdm=marker
