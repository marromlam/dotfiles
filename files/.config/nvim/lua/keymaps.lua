-- TODO: move me to other place
--
--
-- Commands {{{
--
---Create an nvim command
function mrl.command(name, rhs, opts)
  opts = opts or {}
  vim.api.nvim_create_user_command(name, rhs, opts)
end

---Determine if a value of any type is empty
function mrl.falsy(item)
  if not item then return true end
  local item_type = type(item)
  if item_type == 'boolean' then return not item end
  if item_type == 'string' then return item == '' end
  if item_type == 'number' then return item <= 0 end
  if item_type == 'table' then return vim.tbl_isempty(item) end
  return item ~= nil
end

-- }}}

-- Quickfix and Location List {{{

mrl.list = { qf = {}, loc = {} }

---@param list_type "loclist" | "quickfix"
---@return boolean
local function is_list_open(list_type)
  return mrl.find(
    function(win) return not mrl.falsy(win[list_type]) end,
    vim.fn.getwininfo()
  ) ~= nil
end

local silence = { mods = { silent = true, emsg_silent = true } }

---@param callback fun(...)
local function preserve_window(callback, ...)
  local win = vim.api.nvim_get_current_win()
  callback(...)
  if win ~= vim.api.nvim_get_current_win() then vim.cmd.wincmd('p') end
end

function mrl.list.qf.toggle()
  if is_list_open('quickfix') then
    vim.cmd.cclose(silence)
  elseif #vim.fn.getqflist() > 0 then
    preserve_window(vim.cmd.copen, silence)
  end
end

function mrl.list.loc.toggle()
  if is_list_open('loclist') then
    vim.cmd.lclose(silence)
  elseif #vim.fn.getloclist(0) > 0 then
    preserve_window(vim.cmd.lopen, silence)
  end
end

-- @see: https://vi.stackexchange.com/a/21255
-- using range-aware function
function mrl.list.qf.delete(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local list = vim.fn.getqflist()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local mode = vim.api.nvim_get_mode().mode
  if mode:match('[vV]') then
    local first_line = vim.fn.getpos("'<")[2]
    local last_line = vim.fn.getpos("'>")[2]
    list = mrl.fold(function(accum, item, i)
      if i < first_line or i > last_line then accum[#accum + 1] = item end
      return accum
    end, list)
  else
    table.remove(list, line)
  end
  -- replace items in the current list, do not make a new copy of it; this also preserves the list title
  vim.fn.setqflist({}, 'r', { items = list })
  vim.fn.setpos('.', { buf, line, 1, 0 }) -- restore current line
end

-- }}}

local fn, api, uv, cmd, command, fmt =
  vim.fn, vim.api, vim.loop, vim.cmd, mrl.command, string.format

if not mrl or not mrl.mappings.enable then return end

local fn, api, uv, cmd, fmt = vim.fn, vim.api, vim.loop, vim.cmd, string.format

-- Credit: Justinmk
vim.keymap.set('n', 'g>', [[<cmd>set nomore<bar>40messages<bar>set more<CR>]], {
  desc = 'show message history',
})

-- Evaluates whether there is a fold on the current line if so unfold it
-- else return a normal space
vim.keymap.set('n', '<BS>', [[@=(foldlevel('.')?'za':"\<Space>")<CR>]], {
  desc = 'toggle fold under cursor',
})
-- Refocus folds
vim.keymap.set('n', '<localleader>z', [[zMzvzz]], { desc = 'center viewport' })
-- Make zO recursively open whatever top level fold we're in, no matter
-- where the cursor happens to be.
vim.keymap.set('n', 'zO', [[zCzO]])

------------------------------------------------------------------------------
-- Buffers
------------------------------------------------------------------------------
vim.keymap.set(
  'n',
  '<leader>on',
  [[<cmd>w <bar> %bd <bar> e#<CR>]],
  { desc = 'close all other buffers' }
)
vim.keymap.set(
  'n',
  '<localleader><tab>',
  [[:b <Tab>]],
  { silent = false, desc = 'open buffer list' }
)

-- Windows and buffer management {{{

vim.keymap.set('n', '<localleader>wh', '<C-W>t <C-W>K', {
  desc = 'change two horizontally split windows to vertical splits',
})
vim.keymap.set('n', '<localleader>wv', '<C-W>t <C-W>H', {
  desc = 'change two vertically split windows to horizontal splits',
})
-- equivalent to gf but opens the window in a vertical split
-- vim doesn't have a native mapping for this as <C-w>f normally
-- opens a horizontal split
vim.keymap.set(
  'n',
  '<C-w>f',
  '<C-w>vgf',
  { desc = 'open file in vertical split' }
)
vim.keymap.set(
  'n',
  '<leader>qw',
  '<cmd>bd!<CR>',
  { desc = 'Close current buffer (and window)' }
)

-- }}}

-----------------------------------------------------------------------------//
vim.keymap.set('n', '<leader>nf', [[:e <C-R>=expand("%:p:h") . "/" <CR>]], {
  silent = false,
  desc = 'Open a new file in the same directory',
})
vim.keymap.set('n', '<leader>ns', [[:vsp <C-R>=expand("%:p:h") . "/" <CR>]], {
  silent = false,
  desc = 'Split to a new file in the same directory',
})
-----------------------------------------------------------------------------//
-- Window bindings
-----------------------------------------------------------------------------//

----------------------------------------------------------------------------------
-- Commandline mappings
----------------------------------------------------------------------------------
-- https://github.com/tpope/vim-rsi/blob/master/plugin/rsi.vim
-- c-a / c-e everywhere - RSI.vim provides these
-- cnoremap("<C-n>", "<Down>")
-- cnoremap("<C-p>", "<Up>")
-- -- <C-A> allows you to insert all matches on the command line e.g. bd *.js <c-a>
-- -- will insert all matching files e.g. :bd a.js b.js c.js
-- cnoremap("<c-x><c-a>", "<c-a>")
-- -- move cursor one character backwards unless at the end of the command line
-- cnoremap("<C-f>", function()
--   if fn.getcmdpos() == fn.strlen(fn.getcmdline()) then
--     return "<c-f>"
--   end
--   return "<Right>"
-- end, { expr = true })
-- cnoremap("<C-b>", "<Left>")
-- cnoremap("<C-d>", "<Del>")
-- -- see :h cmdline-editing
-- cnoremap("<Esc>b", [[<S-Left>]])
-- cnoremap("<Esc>f", [[<S-Right>]])

cmd.cabbrev('options', 'vert options')

-- smooth searching, allow tabbing between search results similar to using <c-g>
-- or <c-t> the main difference being tab is easier to hit and remapping those keys
-- to these would swallow up a tab mapping
-- local function search(direction_key, default)
-- 	local c_type = fn.getcmdtype()
-- 	return (c_type == "/" or c_type == "?") and fmt("<CR>%s<C-r>/", direction_key) or default
-- end
-- cnoremap("<Tab>", function()
-- 	return search("/", "<Tab>")
-- end, { expr = true })
-- cnoremap("<S-Tab>", function()
-- 	return search("?", "<S-Tab>")
-- end, { expr = true })
-- insert path of current file into a command
-- cnoremap("%%", "<C-r>=fnameescape(expand('%'))<cr>")
-- cnoremap("::", "<C-r>=fnameescape(expand('%:p:h'))<cr>/")
-----------------------------------------------------------------------------//
-- Save
-----------------------------------------------------------------------------//
-- NOTE: this uses write specifically because we need to trigger a filesystem event
-- even if the file isn't changed so that things like hot reload work
vim.keymap.set('n', '<c-s>', '<Cmd>silent! write ++p<CR>')
-- Write and quit all files, ZZ is NOT equivalent to this
vim.keymap.set('n', 'qa', '<cmd>qa<CR>')

-- Quickfix
vim.keymap.set('n', ']q', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '[q', '<cmd>cprev<CR>zz')
vim.keymap.set('n', ']l', '<cmd>lnext<cr>zz')
vim.keymap.set('n', '[l', '<cmd>lprev<cr>zz')
------------------------------------------------------------------------------
-- Tab navigation
------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>tn', '<cmd>tabedit %<CR>')
vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<CR>')
vim.keymap.set('n', '<leader>to', '<cmd>tabonly<cr>')
vim.keymap.set('n', '<leader>tm', '<cmd>tabmove<Space>')
vim.keymap.set('n', ']t', '<cmd>tabprev<CR>')
vim.keymap.set('n', '[t', '<cmd>tabnext<CR>')
-------------------------------------------------------------------------------
-- ?ie | entire object
-------------------------------------------------------------------------------
vim.keymap.set('x', 'ie', [[gg0oG$]])
-- onoremap("ie", [[<cmd>execute "normal! m`"<Bar>keepjumps normal! ggVG<CR>]])

-- center cursor
vim.keymap.set(
  'n',
  'zz',
  [[(winline() == (winheight (0) + 1)/ 2) ?  'zt' : (winline() == 1)? 'zb' : 'zz']],
  { expr = true }
)

-----------------------------------------------------------------------------//
-- Open Common files
-----------------------------------------------------------------------------//
vim.keymap.set(
  'n',
  '<leader>ev',
  [[<Cmd>edit $MYVIMRC<CR>]],
  { desc = 'open $VIMRC' }
)
vim.keymap.set(
  'n',
  '<leader>ez',
  '<Cmd>edit $ZDOTDIR/.zshrc<CR>',
  { desc = 'open zshrc' }
)
vim.keymap.set(
  'n',
  '<leader>et',
  '<Cmd>edit $XDG_CONFIG_HOME/tmux/tmux.conf<CR>',
  {
    desc = 'open tmux.conf',
  }
)
-- This line allows the current file to source the vimrc allowing me use bindings as they're added
vim.keymap.set(
  'n',
  '<leader>sv',
  [[<Cmd>source $MYVIMRC<cr> <bar> :lua vim.notify('Sourced init.vim')<cr>]],
  {
    desc = 'source $VIMRC',
  }
)
vim.keymap.set(
  'n',
  '<leader>yf',
  ":let @*=expand('%:p')<CR>",
  { desc = 'yank file path into the clipboard' }
)
-----------------------------------------------------------------------------//
-- Quotes
-----------------------------------------------------------------------------//
vim.keymap.set(
  'n',
  [[<leader>"]],
  [[ciw"<c-r>""<esc>]],
  { desc = 'surround with double quotes' }
)
vim.keymap.set(
  'n',
  '<leader>`',
  [[ciw`<c-r>"`<esc>]],
  { desc = 'surround with backticks' }
)
vim.keymap.set(
  'n',
  "<leader>'",
  [[ciw'<c-r>"'<esc>]],
  { desc = 'surround with single quotes' }
)
vim.keymap.set(
  'n',
  '<leader>)',
  [[ciw(<c-r>")<esc>]],
  { desc = 'surround with parentheses' }
)
vim.keymap.set(
  'n',
  '<leader>}',
  [[ciw{<c-r>"}<esc>]],
  { desc = 'surround with curly braces' }
)

-- gx implements the netrw style url opener
local function open(path)
  fn.jobstart({ vim.g.open_command, path }, { detach = true })
  vim.notify(fmt('Opening %s', path))
end

vim.keymap.set('n', 'gx', function()
  local file = fn.expand('<cfile>')
  if not file or fn.isdirectory(file) > 0 then return vim.cmd.edit(file) end

  if file:match('http[s]?://') then return open(file) end

  -- consider anything that looks like string/string a github link
  local link = file:match('[%a%d%-%.%_]*%/[%a%d%-%.%_]*')
  if link then return open(fmt('https://www.github.com/%s', link)) end
end)

vim.keymap.set('n', 'gf', '<Cmd>e <cfile><CR>')

-- quickfix list
vim.keymap.set(
  'n',
  '<C-q>',
  mrl.list.qf.toggle,
  { desc = 'toggle quickfix list' }
)
vim.keymap.set(
  'n',
  '<C-;>',
  mrl.list.loc.toggle,
  { desc = 'toggle location list' }
)

-----------------------------------------------------------------------------//
-- Completion
-----------------------------------------------------------------------------//
-- cycle the completion menu with <TAB>
vim.keymap.set(
  'i',
  '<tab>',
  [[pumvisible() ? "\<C-n>" : "\<Tab>"]],
  { expr = true }
)
vim.keymap.set(
  'i',
  '<s-tab>',
  [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]],
  { expr = true }
)

-----------------------------------------------------------------------------//
-- Commands
-----------------------------------------------------------------------------//
command(
  'ToggleBackground',
  function() vim.o.background = vim.o.background == 'dark' and 'light' or 'dark' end
)

vim.keymap.set(
  'n',
  '<leader>Ob',
  '<cmd>ToggleBackground<cr>',
  { desc = 'toggle background' }
)
vim.keymap.set('n', '<leader>Ow', function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify('wrap ' .. (vim.o.wrap and 'on' or 'off'))
end, { desc = 'toggle wrap' })
------------------------------------------------------------------------------
command('Todo', [[noautocmd silent! grep! 'TODO\|FIXME\|BUG\|HACK' | copen]])
command(
  'ReloadModule',
  function(tbl) require('plenary.reload').reload_module(tbl.args) end,
  {
    nargs = 1,
  }
)
-- source https://superuser.com/a/540519
-- write the visual selection to the filename passed in as a command argument then delete the
-- selection placing into the black hole register
command(
  'MoveWrite',
  [[<line1>,<line2>write<bang> <args> | <line1>,<line2>delete _]],
  {
    nargs = 1,
    bang = true,
    range = true,
    complete = 'file',
  }
)
command(
  'MoveAppend',
  [[<line1>,<line2>write<bang> >> <args> | <line1>,<line2>delete _]],
  {
    nargs = 1,
    bang = true,
    range = true,
    complete = 'file',
  }
)

command('Reverse', '<line1>,<line2>g/^/m<line1>-1', {
  range = '%',
  bar = true,
})

command('Exrc', function()
  local cwd = fn.getcwd()
  local p1, p2 = ('%s/.nvim.lua'):format(cwd), ('%s/.nvimrc'):format(cwd)
  local path = uv.fs_stat(p1) and p1 or uv.fs_stat(p2) and p2
  if not path then
    local _, err = io.open(p1, 'w')
    assert(err == nil, err)
    path = p1
  end
  if not path then return end
  local ok, err = pcall(vim.cmd.edit, path)
  if not ok then vim.notify(err, 'error', { title = 'Exrc Opener' }) end
end)

command('ClearRegisters', function()
  local regs =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-'
  for r in regs:gmatch('.') do
    fn.setreg(r, {})
  end
end)

vim.keymap.set(
  'n',
  '<leader>Tc',
  '<Cmd>ClearRegisters<CR>',
  { desc = 'clear registers' }
)
vim.keymap.set(
  'n',
  '<leader>Tr',
  '<Cmd>Reverse<CR>',
  { desc = 'reverse buffer' }
)
vim.keymap.set('n', '<C-t>', '<Cmd>Todo<CR>', { desc = 'reverse buffer' })

-----------------------------------------------------------------------------//
-- References
-----------------------------------------------------------------------------//
-- 1.) https://www.reddit.com/r/vim/comments/i2x8xc/i_want_gf_to_create_files_if_they_dont_exist/
-- 2.) https://github.com/kristijanhusak/neovim-config/blob/5474d932386c3724d2ce02a5963528fe5d5e1015/nvim/lua/partials/mappings.lua#L154

vim.keymap.set('n', '<leader>pp', '<Cmd>Lazy<CR>', { desc = 'Lazy lugins' })
vim.keymap.set('n', '<leader>pm', '<Cmd>Mason<CR>', { desc = 'Mason util' })

vim.keymap.set(
  'n',
  '<leader>o',
  '<Cmd>:only<CR>',
  { desc = 'this only buffer' }
)

-- closing buffers
vim.keymap.set('n', '<leader>x', '<Cmd>:bd<CR>', { desc = 'delete buffer' })
vim.keymap.set(
  'n',
  '<leader>X',
  '<Cmd>:bd!<CR>',
  { desc = 'Force delete buffer' }
)
vim.keymap.set(
  'n',
  '<leader>z',
  '<cmd>%bdelete<CR>',
  { desc = 'Close All Buffers' }
)
vim.keymap.set(
  'n',
  '<leader>Z',
  '<cmd>%bdelete!<CR>',
  { desc = 'Force Close All Buffers' }
)
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>W', '<cmd>w!<CR>', { desc = 'Save (force)' })
vim.keymap.set('n', '<leader>Q', '<cmd>q!<CR>', { desc = 'Quit (force)' })

-- naviagate buffers
vim.keymap.set('n', '<S-l>', ':bnext<CR>', opts)
vim.keymap.set('n', '<S-h>', ':bprevious<CR>', opts)
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { desc = 'Go to next buffer' })
vim.keymap.set(
  'n',
  '<S-Tab>',
  ':bprevious<CR>',
  { desc = 'Go to previous buffer' }
)

-- creating splits
vim.keymap.set(
  'n',
  '<leader>|',
  '<cmd>vsp<CR>',
  { desc = 'Create vertical split' }
)
vim.keymap.set(
  'n',
  '<leader>-',
  '<cmd>sp<CR>',
  { desc = 'Create horizontal split' }
)

-- resizing
vim.keymap.set(
  'n',
  '<Up>',
  ':resize -2<CR>',
  { silent = true, desc = 'resize window up' }
)
vim.keymap.set(
  'n',
  '<Down>',
  ':resize +2<CR>',
  { silent = true, desc = 'resize window down' }
)
vim.keymap.set(
  'n',
  '<Left>',
  ':vertical resize -2<CR>',
  { silent = true, desc = 'resize window left' }
)
vim.keymap.set(
  'n',
  '<Right>',
  ':vertical resize +2<CR>',
  { silent = true, desc = 'resize window right' }
)

-- toggle quickfix
-- vim.keymap.set("n", "<C-q>", ":call ToggleQFList()<CR>", { desc = "toggle quickfix list" })

-- Stay in indent mode
vim.keymap.set('x', '<', '<gv', { desc = 'indent left' })
vim.keymap.set('x', '>', '>gv', { desc = 'indent right' })
vim.keymap.set(
  'x',
  'p',
  '"_dP',
  { desc = 'paste without overwriting clipboard' }
)

-- switching buffers

-- vim.keymap.set("n", "]q", ":cnext<CR>", { noremap = true, silent = true })
-- vim.keymap.set("n", "[q", ":cprev<CR>", { noremap = true, silent = true })

-- -- --
-- -- -- -- map("n", "<Tab>", ':BufferLineCycleNext<CR>', {desc='Go to next buffer' })
-- -- -- -- map("n", "<S-Tab>", ':BufferLineCyclePrev<CR>', {desc='Go to previous buffer' })
-- -- -- mrl.map("n", "<A-j>", ":move .+1<CR>==", { desc = "Move line down" })
-- -- -- mrl.map("n", "<A-k>", ":move .-2<CR>==", { desc = "Move line down" })
-- -- -- mrl.map("n", "]q", ":cnext<CR>", { desc = "Next Quickfix element" })
-- -- -- mrl.map("n", "[q", ":cnext<CR>", { desc = "Previous Quickfix element" })
-- -- -- mrl.map("n", "<C-q>", ":call QuickFixToggle()<CR>", { desc = "Toggle Quickfix" })
-- -- --
-- -- --
-- -- -- -- yank to system keyboard
-- -- -- mrl.map("n", "<leader>y", "<cmd>OSCYank<CR>", { desc = "Yank using osc52" })
-- -- --
-- -- --
-- -- -- -- }}}
-- -- --
-- -- -- --
-- -- -- --   l = {
-- -- -- --     name = 'LSP',
-- -- -- --     a = { '<cmd>lua vim.lsp.buf.code_action()<cr>', 'Code Action' },
-- -- -- --     d = {
-- -- -- --       '<cmd>Telescope lsp_document_diagnostics<cr>',
-- -- -- --       'Document Diagnostics',
-- -- -- --     },
-- -- -- --     w = {
-- -- -- --       '<cmd>Telescope lsp_workspace_diagnostics<cr>',
-- -- -- --       'Workspace Diagnostics',
-- -- -- --     },
-- -- -- --     f = { '<cmd>lua vim.lsp.buf.formatting()<cr>', 'Format' },
-- -- -- --     i = { '<cmd>LspInfo<cr>', 'Info' },
-- -- -- --     I = { '<cmd>LspInstallInfo<cr>', 'Installer Info' },
-- -- -- --     j = {
-- -- -- --       '<cmd>lua vim.lsp.diagnostic.goto_next({ popup_opts = { border = "single" }})<CR>',
-- -- -- --       'Next Diagnostic',
-- -- -- --     },
-- -- -- --     k = {
-- -- -- --       "<cmd>lua vim.lsp.diagnostic.goto_prev({popup_opts = {border = 'single'}})<cr>",
-- -- -- --       'Prev Diagnostic',
-- -- -- --     },
-- -- -- --     l = { '<cmd>lua vim.lsp.codelens.run()<cr>', 'CodeLens Action' },
-- -- -- --     q = { '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>', 'Quickfix' },
-- -- -- --     r = { '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename' },
-- -- -- --     s = { '<cmd>Telescope lsp_document_symbols<cr>', 'Document Symbols' },
-- -- -- --     S = {
-- -- -- --       '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>',
-- -- -- --       'Workspace Symbols',
-- -- -- --     },
-- -- -- --   },
-- -- -- --   s = {
-- -- -- --     name = 'Search',
-- -- -- --     b = { '<cmd>Telescope git_branches<cr>', 'Checkout branch' },
-- -- -- --     c = { '<cmd>Telescope colorscheme<cr>', 'Colorscheme' },
-- -- -- --     f = { '<cmd>Telescope find_files<cr>', 'Find File' },
-- -- -- --     h = { '<cmd>Telescope help_tags<cr>', 'Find Help' },
-- -- -- --     M = { '<cmd>Telescope man_pages<cr>', 'Man Pages' },
-- -- -- --     r = { '<cmd>Telescope oldfiles<cr>', 'Open Recent File' },
-- -- -- --     R = { '<cmd>Telescope registers<cr>', 'Registers' },
-- -- -- --     t = { '<cmd>Telescope live_grep<cr>', 'Text' },
-- -- -- --     k = { '<cmd>Telescope keymaps<cr>', 'Keymaps' },
-- -- -- --     C = { '<cmd>Telescope commands<cr>', 'Commands' },
-- -- -- --   },
-- -- -- -- }
-- -- --
-- -- -- -- which_key.setup(setup)
-- -- -- -- which_key.register(mappings, opts)
-- -- -- -- which_key.register(vmappings, vopts)
-- -- --
-- -- -- -- local opts = { noremap = true, silent = true }
-- -- -- --
-- -- -- -- local term_opts = { silent = true }
-- -- -- --
-- -- -- -- -- Shorten function name
-- -- -- -- local keymap = vim.api.nvim_set_keymap
-- -- -- --
-- -- -- -- --Remap space as leader key
-- -- -- -- keymap("", "<Space>", "<Nop>", opts)
-- -- -- -- vim.g.mapleader = " "
-- -- -- -- vim.g.maplocalleader = " "
-- -- -- --
-- -- -- -- -- Modes
-- -- -- -- --   normal_mode = "n",
-- -- -- -- --   insert_mode = "i",
-- -- -- -- --   visual_mode = "v",
-- -- -- -- --   visual_block_mode = "x",
-- -- -- -- --   term_mode = "t",
-- -- -- -- --   command_mode = "c",
-- -- -- --
-- -- -- -- -- Normal --
-- -- -- -- -- Better window navigation
-- -- -- -- keymap("n", "<C-h>", "<C-w>h", opts)
-- -- -- -- keymap("n", "<C-j>", "<C-w>j", opts)
-- -- -- -- keymap("n", "<C-k>", "<C-w>k", opts)
-- -- -- -- keymap("n", "<C-l>", "<C-w>l", opts)
-- -- -- --
-- -- -- -- -- Resize with arrows
-- -- -- -- keymap("n", "<C-Up>", ":resize -2<CR>", opts)
-- -- -- -- keymap("n", "<C-Down>", ":resize +2<CR>", opts)
-- -- -- -- keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
-- -- -- -- keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)
-- -- -- --
-- -- -- --
-- -- -- -- -- Move text up and down
-- -- -- -- keymap("n", "<A-j>", "<Esc>:m .+1<CR>==gi", opts)
-- -- -- -- keymap("n", "<A-k>", "<Esc>:m .-2<CR>==gi", opts)
-- -- -- --
-- -- -- -- -- Insert --
-- -- -- -- -- Press jk fast to enter
-- -- -- -- keymap("i", "jk", "<ESC>", opts)
-- -- -- --
-- -- -- -- -- Visual --
-- -- -- -- -- Stay in indent mode
-- -- -- -- keymap("v", "<", "<gv", opts)
-- -- -- -- keymap("v", ">", ">gv", opts)
-- -- -- --
-- Editingh utils {{{

-- Capitalize word
vim.keymap.set('n', 'U', 'gUiw`]', { desc = 'capitalize word' })

-- make . work with visually selected lines
vim.keymap.set('v', '.', ':norm.<CR>')

-- }}}

-- move blocks of lines
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
-- keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
-- keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- join and split lines while keeping same position
vim.keymap.set('n', 'J', 'mzJ`z')
vim.cmd([[
nnoremap S :keeppatterns substitute/\s*\%#\s*/\r/e <bar> normal! ==<CR>
]])

-- move arround
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('n', "'", '`')

-- greatest remap ever
-- vim.keymap.set("x", "<leader>P", [["_dP]])

-- yank
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]])
vim.keymap.set('n', '<leader>Y', [["+Y]])

vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]])

-- -- -- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

vim.keymap.set(
  { 'n' },
  '<leader>lf',
  '<cmd>Format<CR>',
  { desc = 'lsp-format current buffer' }
)

-- Arrow mappings [OLD] {{{

-- core.noremap({ "n" }, "<Up>", ":resize -2<CR>")
-- core.noremap({ "n" }, "<Down>", ":resize +2<CR>")
-- core.noremap({ "n" }, "<Left>", ":vertical resize -2<CR>")
-- core.noremap({ "n" }, "<Right>", ":vertical resize +2<CR>")
--
-- core.noremap({ "n" }, "<C-q>", ":call ToggleQFList()<CR>")
--
-- Stay in indent mode - TESTED
vim.keymap.set({ 'v' }, '<', '<gv')
vim.keymap.set({ 'v' }, '>', '>gv')

-- Paste in visual mode multiple times - TESTED
vim.keymap.set('v', 'p', '"_dP')
vim.keymap.set('x', 'p', 'pgvy')
-- core.noremap({ "v" }, "p", '"_dP')
--
--
-- Some new
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set(
  'n',
  '[d',
  vim.diagnostic.goto_prev,
  { desc = 'Go to previous [D]iagnostic message' }
)
vim.keymap.set(
  'n',
  ']d',
  vim.diagnostic.goto_next,
  { desc = 'Go to next [D]iagnostic message' }
)
vim.keymap.set(
  'n',
  '<leader>e',
  vim.diagnostic.open_float,
  { desc = 'Show diagnostic [E]rror messages' }
)
vim.keymap.set(
  'n',
  '<leader>q',
  vim.diagnostic.setloclist,
  { desc = 'Open diagnostic [Q]uickfix list' }
)

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set(
  't',
  '<Esc><Esc>',
  '<C-\\><C-n>',
  { desc = 'Exit terminal mode' }
)

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
-- vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
-- vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Old maps and unused {{{
-- search visual selection
-- vim.keymap.set('v', '//', [[y/<C-R>"<CR>]])
-- }}}

-- vim: fdm=marker
