-- packs/noice.lua

local fn = vim.fn
local L = vim.log.levels

local opts = {
  cmdline = {
    format = {
      IncRename = { title = ' Rename ' },
      substitute = {
        pattern = '^:%%?s/',
        icon = ' ',
        ft = 'regex',
        title = '',
      },
      input = {
        icon = ' ',
        lang = 'text',
        view = 'cmdline_popup',
        title = '',
      },
    },
  },
  popupmenu = {
    backend = 'nui',
  },
  lsp = {
    -- message = {
    --   enabled = true, -- Enable Noice to handle LSP messages
    -- },
    documentation = {
      enabled = false,
      opts = {
        border = { style = 'rounded' },
        position = { row = 2 },
      },
    },
    signature = {
      enabled = false,
      opts = {
        position = { row = 2 },
      },
    },
    hover = {
      enabled = false,
      silent = true,
    },
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = false,
      ['vim.lsp.util.stylize_markdown'] = false,
    },
  },
  views = {
    vsplit = { size = { width = 'auto' } },
    split = { win_options = { winhighlight = { Normal = 'Normal' } } },
    popup = {
      border = { style = 'rounded', padding = { 0, 1 } },
      win_options = { winblend = 0 },
    },
    cmdline_popup = {
      position = { row = 5, col = '50%' },
      size = { width = 'auto', height = 'auto' },
      border = { style = 'rounded', padding = { 0, 1 } },
      win_options = {
        winblend = 0,
        winhighlight = { Normal = 'NormalPopup', FloatBorder = 'PopupBorder' },
      },
    },
    confirm = {
      border = { style = 'rounded', padding = { 0, 1 }, text = { top = '' } },
      win_options = {
        winblend = 0,
        winhighlight = { Normal = 'NormalPopup', FloatBorder = 'PopupBorder' },
      },
    },
    popupmenu = {
      relative = 'editor',
      position = { row = 9, col = '50%' },
      size = { width = 60, height = 10 },
      border = { style = 'rounded', padding = { 0, 1 } },
      win_options = {
        winblend = 0,
        -- Treat cmdline/popupmenu as "popup-normal" (not float-normal)
        winhighlight = { Normal = 'NormalPopup', FloatBorder = 'PopupBorder' },
      },
    },
  },
  redirect = { view = 'popup', filter = { event = 'msg_show' } },
  routes = {
    {
      opts = { skip = true },
      filter = {
        any = {
          { event = 'msg_show', find = 'written' },
          { event = 'msg_show', find = '%d+ lines, %d+ bytes' },
          { event = 'msg_show', kind = 'search_count' },
          { event = 'msg_show', find = '%d+L, %d+B' },
          { event = 'msg_show', find = '^Hunk %d+ of %d' },
          { event = 'msg_show', find = '%d+ change' },
          { event = 'msg_show', find = '%d+ line' },
          { event = 'msg_show', find = '%d+ more line' },
        },
      },
    },
    {
      view = 'vsplit',
      filter = { event = 'msg_show', min_height = 20 },
    },
    {
      view = 'mini',
      filter = {
        any = {
          { event = 'msg_show', min_height = 10 },
          { event = 'msg_show', find = 'Treesitter' },
        },
      },
      opts = { timeout = 10000 },
    },
    {
      view = 'mini',
      filter = { event = 'notify', find = 'Type%-checking' },
      opts = { replace = true, merge = true, title = 'TSC' },
      stop = true,
    },
    {
      view = 'mini',
      filter = {
        any = {
          { event = 'msg_show', find = '^E486:' },
          { event = 'notify', max_height = 1 },
        },
      }, -- minimise pattern not found messages
    },
    {
      view = 'mini',
      filter = {
        any = {
          { warning = true },
          { event = 'msg_show', find = '^Warn' },
          { event = 'msg_show', find = '^W%d+:' },
          { event = 'msg_show', find = '^No hunks$' },
        },
      },
      opts = {
        title = 'Warning',
        level = L.WARN,
        merge = false,
        replace = false,
      },
    },
    {
      view = 'mini',
      opts = {
        title = 'Error',
        level = L.ERROR,
        merge = true,
        replace = false,
      },
      filter = {
        any = {
          { error = true },
          { event = 'msg_show', find = '^Error' },
          { event = 'msg_show', find = '^E%d+:' },
        },
      },
    },
    {
      view = 'mini',
      opts = { title = '' },
      filter = { kind = { 'emsg', 'echo', 'echomsg' } },
    },
  },
  commands = {
    history = { view = 'vsplit' },
  },
  presets = {
    inc_rename = true,
    long_message_to_split = true,
    lsp_doc_border = true,
  },
}

-- Folke's noice enhancements
opts.routes = opts.routes or {}
-- Skip "No information available" notifications
table.insert(opts.routes, {
  filter = {
    event = 'notify',
    find = 'No information available',
  },
  opts = { skip = true },
})
table.insert(opts.routes, {
  filter = {
    event = 'notify',
    find = 'LSP%[ruff%] Ruff failed to handle a request',
  },
  opts = { skip = true },
})
table.insert(opts.routes, {
  filter = {
    event = 'msg_show',
    find = 'client%.notify is deprecated',
  },
  opts = { skip = true },
})

-- Focus-aware notifications (send to notify_send when not focused)
local focused = true
vim.api.nvim_create_autocmd('FocusGained', {
  callback = function() focused = true end,
})
vim.api.nvim_create_autocmd('FocusLost', {
  callback = function() focused = false end,
})

table.insert(opts.routes, 1, {
  filter = {
    ['not'] = {
      event = 'lsp',
      kind = 'progress',
    },
    cond = function() return not focused and false end,
  },
  view = 'notify_send',
  opts = { stop = false, replace = true },
})

-- Markdown keybindings in markdown files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function(event)
    vim.schedule(
      function() require('noice.text.markdown').keys(event.buf) end
    )
  end,
})

require('noice').setup(opts)

vim.api.nvim_create_user_command(
  'NotifyTest',
  function()
    vim.notify(('Noice mini toast\n'):rep(6), vim.log.levels.INFO, {
      title = 'Noice Mini',
    })
  end,
  { desc = 'Test Noice mini notifications' }
)

-- Noice uses `winhighlight` to map FloatBorder -> NoiceCmdlinePopupBorder.
-- Force these border groups to link to PopupBorder immediately (no scheduling),
-- otherwise they may keep their default DiagnosticSign* colors.
for _, name in ipairs({
  'NoiceCmdlinePopupBorder',
  'NoiceCmdlinePopupBorderCmdline',
  'NoiceCmdlinePopupBorderSearch',
  'NoiceCmdlinePopupBorderFilter',
  'NoiceCmdlinePopupBorderHelp',
  'NoiceCmdlinePopupBorderSubstitute',
  'NoiceCmdlinePopupBorderIncRename',
  'NoiceCmdlinePopupBorderInput',
  'NoiceCmdlinePopupBorderLua',
  'NoiceConfirmBorder',
}) do
  pcall(vim.api.nvim_set_hl, 0, name, { link = 'PopupBorder' })
end

vim.keymap.set({ 'n', 'i', 's' }, '<c-f>', function()
  if not require('noice.lsp').scroll(4) then return '<c-f>' end
end, { silent = true, expr = true })

vim.keymap.set({ 'n', 'i', 's' }, '<c-b>', function()
  if not require('noice.lsp').scroll(-4) then return '<c-b>' end
end, { silent = true, expr = true })

vim.keymap.set(
  'c',
  '<M-CR>',
  function() require('noice').redirect(fn.getcmdline()) end,
  {
    desc = 'redirect Cmdline',
  }
)
