local T = require('tools')
local icons = require('tools').ui.icons.separators

local gitlinker = T.require_for_later_index('gitlinker')
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
      -- signcolumn = false, -- Disable icons in sign column
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
        silent = true,
      },
      {
        '<localleader>gu',
        function() gitlinker.get_buf_range_url('v') end,
        desc = 'gitlinker: copy range to clipboard',
        mode = 'v',
        silent = true,
      },
      {
        '<leader>go',
        function() gitlinker.get_repo_url(browser_open()) end,
        desc = 'gitlinker: open in browser',
        silent = true,
      },
      {
        '<leader>go',
        function() gitlinker.get_buf_range_url('n', browser_open()) end,
        desc = 'gitlinker: open current line in browser',
        silent = true,
      },
      {
        '<leader>go',
        function() gitlinker.get_buf_range_url('v', browser_open()) end,
        desc = 'gitlinker: open current selection in browser',
        mode = 'v',
        silent = true,
      },
    },
    opts = {
      mappings = nil,
      callbacks = {
        ['github-work.com'] = function(url_data) -- Resolve the host for work repositories
          url_data.host = 'github.com'
          return require('gitlinker.hosts').get_github_type_url(url_data)
        end,
        -- callbacks = {
        --   ["github.com"] = function(url_data)
        --       local url = require"gitlinker.hosts".get_base_https_url(url_data) ..
        --         url_data.repo .. "/blob/" .. url_data.rev .. "/" .. url_data.file
        --       if url_data.lstart then
        --         url = url .. "#L" .. url_data.lstart
        --         if url_data.lend then url = url .. "-L" .. url_data.lend end
        --       end
        --       return url
        --     end
        -- }
      },
    },
  },
  -- }}}
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- git-conflict {{{
  -----------------------------------------------------------------------------
  {
    'akinsho/git-conflict.nvim',
    event = 'BufReadPre',
    opts = {
      default_mappings = true,
      default_commands = true,
      disable_diagnostics = true,
      list_opener = 'copen',
      highlights = {
        incoming = 'DiffAdd',
        current = 'DiffText',
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
    event = 'BufReadPre',
    init = function()
      vim.api.nvim_create_autocmd('DirChanged', {
        group = vim.api.nvim_create_augroup('FugitiveWorktreeDetect', { clear = true }),
        callback = function()
          vim.fn.FugitiveDetect(vim.fn.getcwd())
        end,
      })
    end,
    keys = {
      {
        '<leader>gs',
        function()
          -- FugitiveCommonDir returns the shared .bare dir for all worktrees of the same repo
          local cur_common = vim.fn.FugitiveCommonDir(vim.api.nvim_get_current_buf())
          if cur_common == '' then
            vim.cmd('tab Git')
            return
          end
          for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
            for _, winnr in ipairs(vim.api.nvim_tabpage_list_wins(tabnr)) do
              local buf = vim.api.nvim_win_get_buf(winnr)
              local name = vim.api.nvim_buf_get_name(buf)
              if name:match('^fugitive://') then
                local tab_common = vim.fn.FugitiveCommonDir(buf)
                if tab_common ~= '' and tab_common == cur_common then
                  vim.api.nvim_set_current_tabpage(tabnr)
                  return
                end
              end
            end
          end
          vim.cmd('tab Git')
        end,
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
        '<cmd>FzfLua git_branches<cr>',
        desc = '[git] Checkout branch',
      },
      {
        '<leader>gc',
        '<cmd>FzfLua git_commits<cr>',
        desc = '[git] Checkout commit',
      },
      {
        '<leader>gC',
        '<cmd>FzfLua git_bcommits<cr>',
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
        '<leader>gH',
        '<cmd>0Gclog<cr>',
        desc = '[git] Get history for current file',
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
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles' },
    opts = {
      enhanced_diff_hl = true,
      signs = {
        fold_closed = '',
        fold_open = '',
        done = '✓',
      },
      view = {
        merge_tool = { layout = 'diff3_mixed' },
      },
    },
  },
  {
    'isakbm/gitgraph.nvim',
    dependencies = { 'sindrets/diffview.nvim' },
    opts = {
      symbols = {
        merge_commit = 'M',
        commit = '*',
      },
      format = {
        timestamp = '%H:%M:%S %d-%m-%Y',
        fields = { 'hash', 'timestamp', 'author', 'branch_name', 'tag' },
      },

      hooks = {
        -- Check diff of a commit
        on_select_commit = function(commit)
          vim.notify('DiffviewOpen ' .. commit.hash .. '^!')
          vim.cmd(':DiffviewOpen ' .. commit.hash .. '^!')
        end,
        -- Check diff from commit a -> commit b
        on_select_range_commit = function(from, to)
          vim.notify('DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
          vim.cmd(':DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
        end,
      },
    },
    keys = {
      {
        '<leader>gG',
        function()
          require('gitgraph').draw({}, { all = true, max_count = 5000 })
        end,
        desc = 'GitGraph',
      },
    },
  },

  {
    'ldelossa/gh.nvim',
    lazy = false,
    cond = false,
    disabled = true,
    dependencies = {
      {
        'ldelossa/litee.nvim',
        config = function() require('litee.lib').setup() end,
      },
    },
    config = function() require('litee.gh').setup() end,
  },

  -- }}}

  {
    -- 'marromlam/git-worktree.nvim',
    'ThePrimeagen/git-worktree.nvim',
    -- dev = true,
    -- dir = '~/Workspaces/personal/git-worktree.nvim',

    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = {
      'GitWorktreeCreate',
      'GitWorktreeDelete',
      'GitWorktreeList',
      'GitWorktreeSwitch',
    },
    keys = {
      {
        '<leader>gwl',
        function()
          require('fzf-lua').fzf_exec(function(cb)
            local lines = vim.fn.systemlist('git worktree list --porcelain')
            local worktrees = {}
            local cur = {}
            for _, line in ipairs(lines) do
              local path = line:match('^worktree (.+)')
              local branch = line:match('^branch refs/heads/(.+)')
              if path then cur = { path = path } end
              if branch then cur.branch = branch end
              if line == '' and cur.path then
                table.insert(worktrees, cur)
                cur = {}
              end
            end
            if cur.path then table.insert(worktrees, cur) end
            for _, wt_entry in ipairs(worktrees) do
              cb(string.format('%s\t%s', wt_entry.branch or '(detached)', wt_entry.path))
            end
            cb(nil)
          end, {
            prompt = 'Worktrees> ',
            actions = {
              ['default'] = function(selected)
                local path = selected[1]:match('\t(.+)$')
                if path then
                  require('git-worktree').switch_worktree(path)
                end
              end,
            },
          })
        end,
        desc = '[git] List/switch worktree',
      },
      {
        '<leader>gwd',
        function()
          require('fzf-lua').fzf_exec(function(cb)
            local lines = vim.fn.systemlist('git worktree list --porcelain')
            local worktrees = {}
            local cur = {}
            for _, line in ipairs(lines) do
              local path = line:match('^worktree (.+)')
              local branch = line:match('^branch refs/heads/(.+)')
              if path then cur = { path = path } end
              if branch then cur.branch = branch end
              if line == '' and cur.path then
                table.insert(worktrees, cur)
                cur = {}
              end
            end
            if cur.path then table.insert(worktrees, cur) end
            -- skip the main worktree (first entry)
            for i, wt_entry in ipairs(worktrees) do
              if i > 1 then
                cb(string.format('%s\t%s', wt_entry.branch or '(detached)', wt_entry.path))
              end
            end
            cb(nil)
          end, {
            prompt = 'Delete worktree> ',
            fzf_opts = { ['--header'] = 'CTRL-D: force delete branch | ENTER: remove worktree only' },
            actions = {
              ['default'] = function(selected)
                local path = selected[1]:match('\t(.+)$')
                if not path then return end
                vim.ui.input(
                  { prompt = 'Flags ([-f] [-d|-D], or enter to confirm): ' },
                  function(flags)
                    if flags == nil then return end -- cancelled
                    local cmd = 'gwrm ' .. (flags ~= '' and flags .. ' ' or '') .. vim.fn.shellescape(path)
                    local out = vim.fn.system(cmd)
                    if vim.v.shell_error ~= 0 then
                      vim.notify(out, vim.log.levels.ERROR)
                    else
                      vim.notify('Removed worktree: ' .. path)
                    end
                  end
                )
              end,
            },
          })
        end,
        desc = '[git] Delete worktree',
      },
      {
        '<leader>gwc',
        function()
          vim.ui.input({ prompt = 'New branch name: ' }, function(branch)
            if not branch or branch == '' then return end
            vim.ui.input(
              { prompt = 'Path (default: ' .. branch .. '): ' },
              function(path)
                path = (path and path ~= '') and path or branch
                vim.ui.input({ prompt = 'Base branch (default: HEAD): ' }, function(base)
                  base = (base and base ~= '') and base or 'HEAD'
                  require('git-worktree').create_worktree(path, branch, base)
                end)
              end
            )
          end)
        end,
        desc = '[git] Create worktree',
      },
    },
    config = function()
      require('git-worktree').setup()
      require('git-worktree').on_tree_change(function(op, metadata)
        if op == require('git-worktree').Operations.Switch then
          vim.fn.FugitiveDetect(metadata.path)
        end
      end)
    end,
  },
}

-- vim: fdm=marker
