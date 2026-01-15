local fn, env, ui = vim.fn, vim.env, mrl.ui
local icons, lsp_hls = ui.icons, ui.lsp.highlights
local prompt = icons.misc.telescope .. '  '

-- Lazy-load fzf-lua only when needed
local function fzf_lua() return require('fzf-lua') end

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
  fzf_lua().files({
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

-- Setup flag to ensure config only runs once when needed
local fzf_setup_done = false
local function ensure_fzf_setup()
  if fzf_setup_done then return end
  fzf_setup_done = true

  local lsp_kind = require('lspkind')
  local fzf = require('fzf-lua')

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
      preview = {
        border = ui.border.rectangle,
      },
    },
    keymap = {
      builtin = {
        ['<c-e>'] = 'toggle-preview',
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
end

-- Wrapper functions that ensure setup runs before calling fzf-lua
local function wrap_fzf_call(fn)
  return function(...)
    ensure_fzf_setup()
    return fn(...)
  end
end

return {
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    config = function() ensure_fzf_setup() end,
    init = function()
      -- Use fzf-lua as the default `vim.ui.select` picker (small dropdown).
      -- Lazy-load fzf-lua on first use.
      local orig_select = vim.ui.select
      vim.ui.select = function(items, opts, on_choice)
        ensure_fzf_setup()

        local ok, fzf = pcall(require, 'fzf-lua')
        if not ok then
          pcall(require('lazy').load, { plugins = { 'fzf-lua' } })
          ok, fzf = pcall(require, 'fzf-lua')
        end

        if ok and fzf and type(fzf.register_ui_select) == 'function' then
          -- Register once with a compact UI similar to your dropdown pickers.
          -- Args: (opts, silent, opts_once)
          pcall(fzf.register_ui_select, {
            winopts = {
              height = 0.33,
              width = 0.45,
              row = 0.15,
              col = 0.50,
              title_pos = 'center',
              preview = { hidden = 'hidden' },
            },
            fzf_opts = {
              ['--layout'] = 'reverse',
              ['--info'] = 'inline',
            },
          }, true)
          return vim.ui.select(items, opts, on_choice)
        end

        return orig_select(items, opts, on_choice)
      end
    end,
    keys = {
      {
        '<c-p>',
        wrap_fzf_call(function() fzf_lua().git_files() end),
        desc = 'fzf: [f]ind [f]iles',
      },
      {
        '<leader>fa',
        function()
          ensure_fzf_setup()
          vim.cmd('FzfLua')
        end,
        desc = 'fzf: [f]ind [a]ll builtins',
      },
      {
        '<leader>ff',
        wrap_fzf_call(file_picker),
        desc = 'fzf: [f]ind [f]iles',
      },
      {
        '<leader>fb',
        wrap_fzf_call(function() fzf_lua().grep_curbuf() end),
        desc = 'fzf: [f]ind in current [b]uffer',
      },
      {
        '<leader>fr',
        wrap_fzf_call(function() fzf_lua().resume() end),
        desc = 'fzf: [f]ind [r]esume',
      },
      {
        '<leader>fva',
        wrap_fzf_call(function() fzf_lua().autocmds() end),
        desc = 'fzf: fin [a]utocommands',
      },
      {
        '<leader>fvh',
        wrap_fzf_call(function() fzf_lua().highlights() end),
        desc = 'fzf: find Highlights',
      },
      {
        '<leader>fvk',
        wrap_fzf_call(function() fzf_lua().keymaps() end),
        desc = 'fzf: find Keymaps',
      },
      {
        '<leader>fle',
        wrap_fzf_call(function() fzf_lua().diagnostics_workspace() end),
        desc = 'fzf: Lsp workspace Diagnostics',
      },
      {
        '<leader>fld',
        wrap_fzf_call(function() fzf_lua().lsp_document_symbols() end),
        desc = 'fzf: Lsp document Symbols',
      },
      {
        '<leader>fls',
        wrap_fzf_call(function() fzf_lua().lsp_live_workspace_symbols() end),
        desc = 'fzf: workspace symbols',
      },
      {
        '<leader>f?',
        wrap_fzf_call(function() fzf_lua().help_tags() end),
        desc = 'fzf: find ?help',
      },
      {
        '<leader>fh',
        wrap_fzf_call(function() fzf_lua().oldfiles() end),
        desc = 'fzf: Most (f)recently used files',
      },
      {
        '<leader>fgb',
        wrap_fzf_call(function() fzf_lua().git_branches() end),
        desc = 'fzf: [g]it [b]ranches',
      },
      {
        '<leader>fgc',
        wrap_fzf_call(function() fzf_lua().git_commits() end),
        desc = 'fzf: [g]it [c]ommits',
      },
      {
        '<leader>fgB',
        wrap_fzf_call(function() fzf_lua().git_bcommits() end),
        desc = 'fzf: [b]uffer commits',
      },
      {
        '<leader>fo',
        wrap_fzf_call(function() fzf_lua().buffers() end),
        desc = 'fzf: find [o]pen buffers',
      },
      {
        '<leader>fs',
        wrap_fzf_call(function() fzf_lua().live_grep() end),
        desc = 'fzf: [f] with live[g]rep',
      },
      {
        '<localleader>p',
        wrap_fzf_call(function() fzf_lua().registers() end),
        desc = 'fzf: [f]ind registers',
      },
      {
        '<leader>fd',
        wrap_fzf_call(function() file_picker(vim.env.DOTFILES) end),
        desc = 'fzf: [f]ind [d]otfiles',
      },
      {
        '<leader>fc',
        wrap_fzf_call(function() file_picker(vim.g.vim_dir) end),
        desc = 'fzf: [f]ind nvim [c]onfig',
      },
    },
    -- No config - setup happens lazily when first called
  },
}

-- vim: fdm=marker
