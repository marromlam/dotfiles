local fn, env, ui, reqcall = vim.fn, vim.env, mrl.ui, mrl.require_for_later_call
local icons, lsp_hls = ui.icons, ui.lsp.highlights
local prompt = icons.misc.telescope .. '  '

local fzf_lua = reqcall('fzf-lua') ---@module 'fzf-lua'

-------------------------------------------------------------------------------
-- fzf-lua helpers {{{
-------------------------------------------------------------------------------
local function fzf_title(str, icon, icon_hl)
  return {
    { ' ', 'Bold' },
    { (icon and icon .. ' ' or ''), icon_hl or 'DevIconDefault' },
    { str, 'Bold' },
    { ' ', 'Bold' },
  }
end

local file_picker = function(cwd)
  fzf_lua.files({
    cwd = cwd,
    -- debug = true,
    actions = {
      ['ctrl-o'] = {
        function(_, args)
          if args.cmd:find('--hidden') then
            args.cmd = args.cmd:gsub('--hidden', '', 1)
          else
            args.cmd = args.cmd .. ' --hidden'
          end
          require('fzf-lua').files(args)
        end,
      },
    },
  })
end

local function dropdown(opts)
  opts = opts or { winopts = {} }
  local title = vim.tbl_get(opts, 'winopts', 'title') ---@type string?
  if title and type(title) == 'string' then
    opts.winopts.title = fzf_title(title)
  end
  return vim.tbl_deep_extend('force', {
    prompt = icons.misc.telescope .. '  ',
    fzf_opts = { ['--layout'] = 'reverse' },
    winopts = {
      title_pos = opts.winopts.title and 'center' or nil,
      height = 0.70,
      width = 0.45,
      row = 0.1,
      preview = { hidden = 'hidden', layout = 'vertical', vertical = 'up:50%' },
    },
  }, opts)
end

local function cursor_dropdown(opts)
  return dropdown(vim.tbl_deep_extend('force', {
    winopts = {
      row = 1,
      relative = 'cursor',
      height = 0.33,
      width = 0.25,
    },
  }, opts))
end

local function list_sessions()
  local fzf = require('fzf-lua')
  local ok, persisted = mrl.pcall(require, 'persisted')
  if not ok then return end
  local sessions = persisted.list()
  fzf.fzf_exec(
    vim.tbl_map(function(s) return s.name end, sessions),
    dropdown({
      winopts = {
        title = fzf_title('Sessions', '󰆔'),
        height = 0.33,
        row = 0.5,
      },
      previewer = false,
      debug = true,
      actions = {
        ['ctrl-h'] = {
          function(_, args)
            if args.cmd:find('--hidden') then
              args.cmd = args.cmd:gsub('--hidden', '', 1)
            else
              args.cmd = args.cmd .. ' --hidden'
            end
            require('fzf-lua').files(args)
          end,
        },
        ['default'] = function(selected)
          local session = vim
            .iter(sessions)
            :find(function(s) return s.name == selected[1] end)
          if not session then return end
          persisted.load({ session = session.file_path })
        end,
        ['ctrl-d'] = {
          function(selected)
            local session = vim
              .iter(sessions)
              :find(function(s) return s.name == selected[1] end)
            if not session then return end
            fn.delete(vim.fn.expand(session.file_path))
          end,
          fzf.actions.resume,
        },
      },
    })
  )
end

mrl.fzf = { dropdown = dropdown, cursor_dropdown = cursor_dropdown }
-- }}}
-------------------------------------------------------------------------------

return {
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    dependencies = {},
    keys = {
      {
        '<c-p>',
        fzf_lua.git_files,
        desc = 'fzf: [f]ind [f]iles',
      },
      {
        '<leader>fa',
        '<Cmd>FzfLua<CR>',
        desc = 'fzf: [f]ind [a]ll builtins',
      },
      {
        '<leader>ff',
        file_picker,
        desc = 'fzf: [f]ind [f]iles',
      },
      {
        '<leader>fb',
        fzf_lua.grep_curbuf,
        desc = 'fzf: [f]ind in current [b]uffer',
      },
      {
        '<leader>fr',
        fzf_lua.resume,
        desc = 'fzf: [f]ind [r]esume',
      },
      {
        '<leader>fva',
        fzf_lua.autocmds,
        desc = 'fzf: fin [a]utocommands',
      },
      {
        '<leader>fvh',
        fzf_lua.highlights,
        desc = 'fzf: find Highlights',
      },
      {
        '<leader>fvk',
        fzf_lua.keymaps,
        desc = 'fzf: find Keymaps',
      },
      {
        '<leader>fle',
        fzf_lua.diagnostics_workspace,
        desc = 'fzf: Lsp workspace Diagnostics',
      },
      {
        '<leader>fld',
        fzf_lua.lsp_document_symbols,
        desc = 'fzf: Lsp document Symbols',
      },
      {
        '<leader>fls',
        fzf_lua.lsp_live_workspace_symbols,
        desc = 'fzf: workspace symbols',
      },
      {
        '<leader>f?',
        fzf_lua.help_tags,
        desc = 'fzf: find ?help',
      },
      {
        '<leader>fh',
        fzf_lua.oldfiles,
        desc = 'fzf: Most (f)recently used files',
      },
      {
        '<leader>fgb',
        fzf_lua.git_branches,
        desc = 'fzf: [g]it [b]ranches',
      },
      {
        '<leader>fgc',
        fzf_lua.git_commits,
        desc = 'fzf: [g]it [c]ommits',
      },
      {
        '<leader>fgB',
        fzf_lua.git_bcommits,
        desc = 'fzf: [b]uffer commits',
      },
      {
        '<leader>fo',
        fzf_lua.buffers,
        desc = 'fzf: find [o]pen buffers',
      },
      {
        '<leader>fs',
        fzf_lua.live_grep,
        desc = 'fzf: [f] with live[g]rep',
      },
      {
        '<localleader>p',
        fzf_lua.registers,
        desc = 'fzf: [f]ind registers',
      },
      {
        '<leader>fd',
        function() file_picker(vim.env.DOTFILES) end,
        desc = 'fzf: [f]ind [d]otfiles',
      },
      {
        '<leader>fc',
        function() file_picker(vim.g.vim_dir) end,
        desc = 'fzf: [f]ind nvim [c]onfig',
      },
    },
    config = function()
      local lsp_kind = require('lspkind')
      local fzf = require('fzf-lua')
      local actions = require('fzf-lua.actions')

      fzf.setup({
        fzf_opts = {
          ['--info'] = 'inline', -- hidden OR inline:⏐
          ['--reverse'] = false,
          ['--layout'] = 'default',
          ['--scrollbar'] = icons.separators.right_block,
          ['--ellipsis'] = icons.misc.ellipsis,
          ['--pointer'] = '▸',
          ['--marker'] = '◆',
          ['--prompt'] = '󰍉 ',
          ['--separator'] = ' ',
        },
        fzf_colors = {
          --   ['fg'] = { 'fg', 'CursorLine' },
          --   ['bg'] = { 'bg', 'Normal' },
          --   ['hl'] = { 'fg', 'Comment' },
          --   ['fg+'] = { 'fg', 'Normal' },
          --   ['bg+'] = { 'bg', 'PmenuSel' },
          --   ['hl+'] = { 'fg', 'Statement', 'italic' },
          --   ['info'] = { 'fg', 'Comment', 'italic' },
          --   ['prompt'] = { 'fg', 'Underlined' },
          --   ['pointer'] = { 'fg', 'Exception' },
          --   ['marker'] = { 'fg', '@character' },
          --   ['spinner'] = { 'fg', 'DiagnosticOk' },
          --   ['header'] = { 'fg', 'Comment' },
          ['gutter'] = { 'bg', 'Normal' },
          --   ['separator'] = { 'fg', 'Comment' },
        },
        previewers = {
          builtin = { toggle_behavior = 'extend' },
        },
        winopts = {
          backdrop = 100,
          border = ui.border.rectangle,
        },
        keymap = {
          builtin = {
            ['<c-/>'] = 'toggle-help', -- FIXME: not working
            ['<c-e>'] = 'toggle-preview',
            ['<c-z>'] = 'toggle-fullscreen', -- FIXME: not working
            ['<c-f>'] = 'preview-page-down',
            ['<c-b>'] = 'preview-page-up',
            -- toggle hidden files
            ['<c-h>'] = {
              function(_, args)
                if args.cmd:find('--hidden') then
                  args.cmd = args.cmd:gsub('--hidden', '', 1)
                else
                  args.cmd = args.cmd .. ' --hidden'
                end
                require('fzf-lua').files(args)
              end,
            },
          },
          fzf = {
            ['esc'] = 'abort',
            ['ctrl-q'] = 'select-all+accept',
          },
        },
        -- customize prompts {{{
        highlights = {
          prompt = icons.misc.telescope .. '  ',
          winopts = { title = fzf_title('Highlights') },
        },
        helptags = {
          prompt = icons.misc.telescope .. '  ',
          winopts = { title = fzf_title('Help', '󰋖') },
        },
        oldfiles = dropdown({
          cwd_only = true,
          winopts = { title = fzf_title('History', '') },
        }),
        files = dropdown({
          winopts = { title = fzf_title('Files', '') },
        }),
        buffers = dropdown({
          fzf_opts = { ['--delimiter'] = ' ', ['--with-nth'] = '-1..' },
          winopts = { title = fzf_title('Buffers', '󰈙') },
        }),
        keymaps = dropdown({
          winopts = { title = fzf_title('Keymaps', ''), width = 0.7 },
        }),
        registers = cursor_dropdown({
          winopts = { title = fzf_title('Registers', ''), width = 0.6 },
        }),
        grep = {
          prompt = ' ',
          winopts = { title = fzf_title('Grep', '󰈭') },
          -- See: https://github.com/ibhagwan/fzf-lua/discussions/1288#discussioncomment-9844613
          -- RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH
          rg_opts = '--column --hidden --line-number --no-heading --color=always --smart-case --max-columns=4096 -e',
          fzf_opts = {
            ['--keep-right'] = '',
          },
        },
        lsp = {
          cwd_only = true,
          symbols = {
            symbol_style = 1,
            symbol_icons = lsp_kind.symbols,
            symbol_hl = function(s) return lsp_hls[s] end,
          },
          code_actions = cursor_dropdown({
            winopts = { title = fzf_title('Code Actions', '󰌵', '@type') },
          }),
        },
        jumps = dropdown({
          winopts = {
            title = fzf_title('Jumps', ''),
            preview = { hidden = 'nohidden' },
          },
        }),
        changes = dropdown({
          prompt = '',
          winopts = {
            title = fzf_title('Changes', '⟳'),
            preview = { hidden = 'nohidden' },
          },
        }),
        diagnostics = dropdown({
          winopts = {
            title = fzf_title('Diagnostics', '', 'DiagnosticError'),
          },
        }),
        git = {
          files = dropdown({
            path_shorten = false, -- this doesn't use any clever strategy unlike telescope so is somewhat useless
            cmd = 'git ls-files --others --cached --exclude-standard',
            winopts = { title = fzf_title('Git Files', '') },
          }),
          branches = dropdown({
            winopts = {
              title = fzf_title('Branches', ''),
              height = 0.3,
              row = 0.4,
            },
          }),
          status = {
            prompt = '',
            preview_pager = 'delta --width=$FZF_PREVIEW_COLUMNS',
            winopts = { title = fzf_title('Git Status', '') },
          },
          bcommits = {
            prompt = '',
            preview_pager = 'delta --width=$FZF_PREVIEW_COLUMNS',
            winopts = { title = fzf_title('', 'Buffer Commits') },
          },
          commits = {
            prompt = '',
            preview_pager = 'delta --width=$FZF_PREVIEW_COLUMNS',
            winopts = { title = fzf_title('', 'Commits') },
          },
          icons = {
            ['M'] = { icon = icons.git.mod, color = 'yellow' },
            ['D'] = { icon = icons.git.remove, color = 'red' },
            ['A'] = { icon = icons.git.staged, color = 'green' },
            ['R'] = { icon = icons.git.rename, color = 'yellow' },
            ['C'] = { icon = icons.git.conflict, color = 'yellow' },
            ['T'] = { icon = icons.git.mod, color = 'magenta' },
            ['?'] = { icon = icons.git.untracked, color = 'magenta' },
          },
        },
      })

      mrl.command('SessionList', list_sessions)
    end,
  },
}

-- vim: fdm=marker
