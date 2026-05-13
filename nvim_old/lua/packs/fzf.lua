-- packs/fzf.lua

local UI = require('tools').ui
local icons = UI.icons or {}
local lsp_hls = (UI.lsp and UI.lsp.highlights) or {}

local function has_exec(bin) return vim.fn.executable(bin) == 1 end

local function trim(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end

local function toggle_cli_flag(args, flag)
  args.cmd = args.cmd or ''
  local escaped = vim.pesc(flag)
  local pattern = '(%s*)' .. escaped .. '(%s*)'
  if args.cmd:find(escaped) then
    args.cmd = args.cmd:gsub(pattern, ' ', 1)
  else
    args.cmd = trim(args.cmd .. ' ' .. flag)
  end
end

local function restart_files(args)
  local ok, fzf = pcall(require, 'fzf-lua')
  if ok then fzf.files(args) end
end

local function open_files_in_cwd(cwd, label)
  local dir = type(cwd) == 'string' and cwd or ''
  if dir ~= '' and vim.fn.isdirectory(dir) == 1 then
    require('fzf-lua').files({ cwd = dir })
    return
  end

  local where = label and (' for ' .. label) or ''
  vim.notify(
    'Invalid directory' .. where .. ': ' .. tostring(dir),
    vim.log.levels.WARN
  )
  require('fzf-lua').files()
end

local function current_buffer_dir()
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' then return vim.loop.cwd() end
  local dir = vim.fn.fnamemodify(name, ':p:h')
  if dir == '' then return vim.loop.cwd() end
  return dir
end

-- Setup fzf-lua
local ok_lspkind, lspkind = pcall(require, 'lspkind')
local lsp_symbols = ok_lspkind and lspkind.symbols or {}
local has_bat = has_exec('bat') or has_exec('batcat')
local has_delta = has_exec('delta')

require('fzf-lua').setup({
  winopts = {
    split = 'botright new', -- Full-width horizontal split at bottom
    -- Alternative: 'topleft new' for full-width at top
    preview = {
      default = has_bat and 'bat' or 'builtin',
      scrollbar = 'float',
    },
  },
  -- Native integration for vim.ui.select (replaces custom wrapper).
  ui_select = {
    winopts = {
      split = 'botright new',
      height = 0.35,
      preview = { hidden = true },
    },
    fzf_opts = {
      ['--info'] = 'default',
    },
  },
  fzf_opts = {
    ['--info'] = 'default',
  },
  files = {
    hidden = false,
    no_ignore = false,
    follow = false,
    -- --hidden lets rg/fd see dotfiles; .gitignore still filters untracked ones,
    -- so git-tracked hidden files are listed while junk (caches, etc.) stays out.
    rg_opts = [[--color=never --files --hidden -g "!.git"]],
    fd_opts = [[--color=never --type f --type l --hidden --exclude .git]],
  },
  grep = {
    rg_opts = '--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden -e',
  },
  keymap = {
    builtin = {
      ['<c-e>'] = 'toggle-preview',
      ['<c-f>'] = 'preview-page-down',
      ['<c-b>'] = 'preview-page-up',
      ['<c-h>'] = {
        function(_, args)
          toggle_cli_flag(args, '--hidden')
          restart_files(args)
        end,
      },
      ['<a-i>'] = {
        function(_, args)
          toggle_cli_flag(args, '--no-ignore')
          restart_files(args)
        end,
      },
    },
    fzf = {
      ['esc'] = 'abort',
      ['ctrl-q'] = 'select-all+accept',
    },
  },
  lsp = {
    symbols = {
      symbol_style = 1,
      symbol_icons = lsp_symbols,
      symbol_hl = function(s) return lsp_hls[s] end,
    },
  },
  git = {
    status = {
      preview_pager = has_delta and 'delta --width=$FZF_PREVIEW_COLUMNS'
        or nil,
    },
    bcommits = {
      preview_pager = has_delta and 'delta --width=$FZF_PREVIEW_COLUMNS'
        or nil,
    },
    commits = {
      preview_pager = has_delta and 'delta --width=$FZF_PREVIEW_COLUMNS'
        or nil,
    },
    icons = {
      ['M'] = {
        icon = (icons.git and icons.git.mod) or 'M',
        color = 'yellow',
      },
      ['D'] = {
        icon = (icons.git and icons.git.remove) or 'D',
        color = 'red',
      },
      ['A'] = {
        icon = (icons.git and icons.git.staged) or 'A',
        color = 'green',
      },
      ['R'] = {
        icon = (icons.git and icons.git.rename) or 'R',
        color = 'yellow',
      },
      ['C'] = {
        icon = (icons.git and icons.git.conflict) or 'C',
        color = 'yellow',
      },
      ['T'] = {
        icon = (icons.git and icons.git.mod) or 'T',
        color = 'magenta',
      },
      ['?'] = {
        icon = (icons.git and icons.git.untracked) or '?',
        color = 'magenta',
      },
    },
  },
})

-- Restore full custom statusline for fzf windows
vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter' }, {
  group = vim.api.nvim_create_augroup('FzfLuaStatusline', { clear = true }),
  pattern = 'fzf',
  callback = function()
    -- Use defer_fn to run after fzf-lua sets its statusline
    vim.defer_fn(function()
      if vim.bo.filetype == 'fzf' then
        if
          type(_G.Stl) == 'table' and type(_G.Stl.render) == 'function'
        then
          vim.opt_local.statusline = '%{%v:lua.Stl.render()%}'
        end
      end
    end, 0)
  end,
})

-- Keymaps
vim.keymap.set('n', '<c-p>', '<cmd>FzfLua git_files<cr>', { desc = 'fzf: [f]ind [f]iles' })
vim.keymap.set('n', '<leader>fa', '<cmd>FzfLua<cr>', { desc = 'fzf: [f]ind [a]ll builtins' })
vim.keymap.set('n', '<leader>ff', function()
  -- In a git repo: use git ls-files so tracked hidden files appear.
  -- Outside a git repo: fall back to regular files picker.
  local ok = vim.fn.systemlist(
    'git rev-parse --is-inside-work-tree 2>/dev/null'
  )[1]
  if ok == 'true' then
    require('fzf-lua').git_files({ show_untracked = true })
  else
    require('fzf-lua').files()
  end
end, { desc = 'fzf: [f]ind [f]iles' })
vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua grep_curbuf<cr>', { desc = 'fzf: [f]ind in current [b]uffer' })
vim.keymap.set('n', '<leader>fr', '<cmd>FzfLua resume<cr>', { desc = 'fzf: [f]ind [r]esume' })
vim.keymap.set('n', '<leader>fva', '<cmd>FzfLua autocmds<cr>', { desc = 'fzf: fin [a]utocommands' })
vim.keymap.set('n', '<leader>fvh', '<cmd>FzfLua highlights<cr>', { desc = 'fzf: find Highlights' })
vim.keymap.set('n', '<leader>fvk', '<cmd>FzfLua keymaps<cr>', { desc = 'fzf: find Keymaps' })
vim.keymap.set('n', '<leader>fle', '<cmd>FzfLua diagnostics_workspace<cr>', { desc = 'fzf: Lsp workspace Diagnostics' })
vim.keymap.set('n', '<leader>fld', '<cmd>FzfLua lsp_document_symbols<cr>', { desc = 'fzf: Lsp document Symbols' })
vim.keymap.set('n', '<leader>fls', '<cmd>FzfLua lsp_live_workspace_symbols<cr>', { desc = 'fzf: workspace symbols' })
vim.keymap.set('n', '<leader>f?', '<cmd>FzfLua help_tags<cr>', { desc = 'fzf: find ?help' })
vim.keymap.set('n', '<leader>fh', '<cmd>FzfLua oldfiles<cr>', { desc = 'fzf: Most (f)recently used files' })
vim.keymap.set('n', '<leader>fgb', '<cmd>FzfLua git_branches<cr>', { desc = 'fzf: [g]it [b]ranches' })
vim.keymap.set('n', '<leader>fgs', '<cmd>FzfLua git_status<cr>', { desc = 'fzf: [g]it [s]tatus' })
vim.keymap.set('n', '<leader>fgc', '<cmd>FzfLua git_commits<cr>', { desc = 'fzf: [g]it [c]ommits' })
vim.keymap.set('n', '<leader>fgB', '<cmd>FzfLua git_bcommits<cr>', { desc = 'fzf: [b]uffer commits' })
vim.keymap.set('n', '<leader>fo', '<cmd>FzfLua buffers<cr>', { desc = 'fzf: find [o]pen buffers' })
vim.keymap.set('n', '<leader>fs', '<cmd>FzfLua live_grep<cr>', { desc = 'fzf: [f] with live[g]rep' })
vim.keymap.set('n', '<localleader>p', '<cmd>FzfLua registers<cr>', { desc = 'fzf: [f]ind registers' })
vim.keymap.set('n', '<leader>fd', function()
  open_files_in_cwd(vim.g.dotfiles, 'dotfiles')
end, { desc = 'fzf: [f]ind [d]otfiles' })
vim.keymap.set('n', '<leader>fp', function()
  open_files_in_cwd(vim.g.projects_directory, 'projects')
end, { desc = 'fzf: [f]ind in [p]rojects' })
vim.keymap.set('n', '<leader>f.', function()
  open_files_in_cwd(current_buffer_dir(), 'current buffer')
end, { desc = 'fzf: find in current file dir' })
vim.keymap.set('n', '<leader>fc', function()
  open_files_in_cwd(vim.g.vim_dir, 'nvim config')
end, { desc = 'fzf: [f]ind nvim [c]onfig' })
