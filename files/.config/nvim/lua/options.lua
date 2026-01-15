-- Make all keymaps silent by default (Folke's pattern)
local keymap_set = vim.keymap.set
vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  return keymap_set(mode, lhs, rhs, opts)
end

-- Disable unused providers (Folke's pattern)
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Message output on vim actions {{{
vim.opt.shortmess = {
  t = true, -- truncate file messages at start
  A = true, -- ignore annoying swap file messages
  o = true, -- file-read message overwrites previous
  O = true, -- file-read message overwrites previous
  T = true, -- truncate non-file messages in middle
  f = true, -- (file x of x) instead of just (x of x
  F = true, -- Don't give file info when editing, NOTE: this breaks autocommand messages
  s = true,
  c = true,
  W = true, -- Don't show [w] or written when writing
}
vim.o.background = 'dark' -- or "light"
-- }}}

-- Timings {{{
vim.opt.updatetime = 500
vim.opt.timeout = true
vim.opt.timeoutlen = 500
-- }}}

-- Window splitting and buffers {{{

vim.opt.splitkeep = 'screen'
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.eadirection = 'hor'
-- exclude usetab pde we do not want to jump to buffers in already open tabs
--- do not use split or vsplit to ensure we don't open any new windows
vim.opt.switchbuf = 'useopen,uselast'
vim.opt.fillchars = {
  eob = ' ', -- suppress ~ at EndOfBuffer
  diff = '╱', -- alternatives = ⣿ ░ ─
  msgsep = ' ', -- alternatives: ‾ ─
  fold = ' ',
  foldopen = '▽', -- '▼'
  foldclose = '▷', -- '▶'
  foldsep = ' ',
}

-- do not show tabline
vim.opt.showtabline = 0

vim.opt.nu = true
vim.opt.relativenumber = true

-- }}}

-- Diff {{{
-- Use in vertical diff mode, blank lines to keep sides aligned, Ignore
-- whitespace changes
vim.opt.diffopt = vim.opt.diffopt
  + {
    'vertical',
    'iwhite',
    'hiddenoff',
    'foldcolumn:0',
    'context:4',
    'algorithm:histogram',
    'indent-heuristic',
    'linematch:60',
  }
-- }}}

-- Format Options {{{

vim.opt.formatoptions = {
  ['1'] = true,
  ['2'] = true, -- Use indent from 2nd line of a paragraph
  q = true, -- continue comments with gq"
  c = true, -- Auto-wrap comments using textwidth
  r = true, -- Continue comments when pressing Enter
  n = true, -- Recognize numbered lists
  t = false, -- autowrap lines using text width value
  j = true, -- remove a comment leader when joining lines.
  -- Only break if the line was not longer than 'textwidth' when the insert
  -- started and only at a white character that has been entered during the
  -- current insert command.
  l = true,
  v = true,
}

-- }}}

-- Folds {{{
-- unfortunately folding in (n)vim is a mess, if you set the fold level to start
-- at X then it will auto fold anything at that level, all good so far. If you then
-- try to edit the content of your fold and the foldmethod=manual then it will
-- recompute the fold which when using nvim-ufo means it will be closed again...

vim.opt.foldlevelstart = 999

-- Grepprg
vim.opt.grepprg = [[rg --glob "!.git" --no-heading --vimgrep --follow $*]]
vim.opt.grepformat = vim.opt.grepformat ^ { '%f:%l:%c:%m' }

-- Display
vim.opt.conceallevel = 2
vim.opt.breakindent = true
vim.opt.breakindentopt = 'sbr'
vim.opt.linebreak = true -- lines wrap at words rather than random characters
vim.opt.signcolumn = 'yes'
vim.opt.ruler = false
vim.opt.cmdheight = 0
vim.opt.showbreak = [[↪ ]] -- Options include -> '…', '↳ ', '→','↪ '

-- List chars
vim.opt.list = true -- invisible chars
vim.opt.listchars = {
  eol = nil,
  extends = '…', -- Alternatives: … » ›
  precedes = '░', -- Alternatives: … « ‹
  tab = '» ',
  trail = '·',
  nbsp = '␣',
}

-- Indentation
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.wrapmargin = 8
vim.opt.textwidth = 80
vim.opt.autoindent = true
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.opt.pumheight = 15
vim.opt.confirm = true -- make vim prompt me to save before doing destructive things
vim.opt.completeopt = { 'menuone', 'noselect' }
vim.opt.hlsearch = true
vim.opt.autowriteall = true -- automatically :write before running commands and changing files
-- Clipboard can be a major startup cost on some systems (notably WSL) because
-- the default clipboard provider does discovery work. Defer setup and prefer a
-- fast explicit provider when available.
vim.schedule(function()
  local fn = vim.fn

  local function set_opt()
    -- Use unnamedplus (system clipboard) once a provider is configured.
    vim.opt.clipboard = { 'unnamedplus' }
  end

  if fn.executable('win32yank.exe') == 1 then
    vim.g.clipboard = {
      name = 'win32yank',
      copy = {
        ['+'] = 'win32yank.exe -i --crlf',
        ['*'] = 'win32yank.exe -i --crlf',
      },
      paste = {
        ['+'] = 'win32yank.exe -o --lf',
        ['*'] = 'win32yank.exe -o --lf',
      },
      cache_enabled = 0,
    }
    set_opt()
  elseif fn.executable('wl-copy') == 1 and fn.executable('wl-paste') == 1 then
    vim.g.clipboard = {
      name = 'wl-clipboard',
      copy = {
        ['+'] = 'wl-copy --foreground --type text/plain',
        ['*'] = 'wl-copy --foreground --type text/plain',
      },
      paste = {
        ['+'] = 'wl-paste --no-newline',
        ['*'] = 'wl-paste --no-newline',
      },
      cache_enabled = 1,
    }
    set_opt()
  elseif fn.executable('xclip') == 1 then
    vim.g.clipboard = {
      name = 'xclip',
      copy = {
        ['+'] = 'xclip -quiet -i -selection clipboard',
        ['*'] = 'xclip -quiet -i -selection primary',
      },
      paste = {
        ['+'] = 'xclip -quiet -o -selection clipboard',
        ['*'] = 'xclip -quiet -o -selection primary',
      },
      cache_enabled = 1,
    }
    set_opt()
  else
    -- Fall back to the built-in provider (may be slower on some systems).
    set_opt()
  end
end)
vim.o.laststatus = 3
vim.o.termguicolors = true
vim.o.guifont = 'CartographCF Nerd Font Mono:h14,codicon'
vim.opt.inccommand = 'split'
vim.g.have_nerd_font = true

-- Emoji
vim.opt.emoji = false

-- Cursor
vim.opt.guicursor = {
  'n-v-c-sm:block-Cursor',
  'i-ci-ve:ver25-iCursor',
  'r-cr-o:hor20-Cursor',
  'a:blinkon0',
}
vim.opt.cursorlineopt = { 'both' }

-- Title
vim.opt.title = true
vim.opt.titlelen = 70

-- Utilities
vim.opt.showmode = false
vim.opt.sessionoptions = {
  'globals',
  'buffers',
  'curdir',
  'winpos',
  'winsize',
  'help',
  'tabpages',
  'terminal',
}
vim.opt.viewoptions = { 'cursor', 'folds' } -- save/restore just these (with `:{mk,load}view`)
vim.opt.virtualedit = 'block' -- allow cursor to move where there is no text in visual block mode

-- Jumplist
vim.opt.jumpoptions = { 'stack' } -- make the jumplist behave like a browser stack

-- Backup and swaps
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('state') .. '/undo'
vim.opt.swapfile = false

-- Match and search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true -- Searches wrap around the end of the file
vim.opt.scrolloff = 9
vim.opt.sidescrolloff = 10
vim.opt.sidescroll = 1

-- }}}

-------------------------------------------------------------------------------
-- Spelling {{{
-------------------------------------------------------------------------------

vim.opt.spellsuggest:prepend({ 12 })
vim.opt.spelloptions:append({ 'camel', 'noplainbuffer' })
vim.opt.spellcapcheck = '' -- don't check for capital letters at start of sentence

-- }}}
-------------------------------------------------------------------------------

-- Mouse {{{1
-----------------------------------------------------------------------------//
vim.opt.mouse = 'a'
vim.opt.mousefocus = true
vim.opt.mousemoveevent = true
vim.opt.mousescroll = 'ver:1,hor:4'
-- Netrw {{{
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
-- }}}

vim.opt.isfname:append('@-@')

-- Diagnostics
vim.diagnostic.config({ virtual_text = false })

-- Custom filetype detection (Folke's pattern)
vim.filetype.add({
  extension = {
    overlay = 'dts',
    keymap = 'dts',
  },
  filename = {
    Caddyfile = 'caddy',
  },
  pattern = {
    ['.*'] = {
      function(path, bufnr)
        local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
        if content:match('^%w+ %d+ %d%d:%d%d:') then return 'log' end
      end,
      { priority = -math.huge },
    },
  },
})
