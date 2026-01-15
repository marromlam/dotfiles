local fn = vim.fn
local border, highlight, L =
  mrl.ui.current.border, mrl.highlight, vim.log.levels

return {
  'folke/noice.nvim',
  -- Defer until you actually enter the command-line (big startup win).
  event = 'CmdlineEnter',
  cmd = { 'Noice', 'NoiceHistory', 'NoiceLast', 'NoiceDismiss', 'NoiceErrors' },
  dependencies = { 'MunifTanjim/nui.nvim' },
  -- cond = false,
  -- disable = true,
  opts = {
    cmdline = {
      format = {
        IncRename = { title = ' Rename ' },
        substitute = {
          pattern = '^:%%?s/',
          icon = ' ',
          ft = 'regex',
          title = '',
        },
        input = {
          icon = ' ',
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
      documentation = {
        enabled = false,
        opts = {
          border = { style = border },
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
        border = { style = border, padding = { 0, 1 } },
        win_options = { winblend = 0 },
      },
      cmdline_popup = {
        position = { row = 5, col = '50%' },
        size = { width = 'auto', height = 'auto' },
        border = { style = border, padding = { 0, 1 } },
        win_options = { winblend = 0 },
      },
      confirm = {
        border = { style = border, padding = { 0, 1 }, text = { top = '' } },
        win_options = { winblend = 0 },
      },
      popupmenu = {
        relative = 'editor',
        position = { row = 9, col = '50%' },
        size = { width = 60, height = 10 },
        border = { style = border, padding = { 0, 1 } },
        win_options = {
          winblend = 0,
          winhighlight = { Normal = 'NormalFloat', FloatBorder = 'FloatBorder' },
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
        view = 'notify',
        filter = {
          any = {
            { event = 'msg_show', min_height = 10 },
            { event = 'msg_show', find = 'Treesitter' },
          },
        },
        opts = { timeout = 10000 },
      },
      {
        view = 'notify',
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
        view = 'notify',
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
        view = 'notify',
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
        view = 'notify',
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
  },
  config = function(_, opts)
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

    highlight.plugin('noice', {
      { NoiceMini = { inherit = 'MsgArea', bg = { from = 'Normal' } } },
      {
        NoicePopupBaseGroup = {
          inherit = 'NormalFloat',
          fg = { from = 'DiagnosticSignInfo' },
        },
      },
      {
        NoicePopupWarnBaseGroup = {
          inherit = 'NormalFloat',
          fg = { from = 'Float' },
        },
      },
      {
        NoicePopupInfoBaseGroup = {
          inherit = 'NormalFloat',
          fg = { from = 'Conditional' },
        },
      },
      { NoiceCmdlinePopup = { bg = { from = 'NormalFloat' } } },
      { NoiceCmdlinePopupBorder = { link = 'FloatBorder' } },
      {
        NoiceCmdlinePopupTitleCmdline = {
          inherit = 'NoicePopupBaseGroup',
          reverse = true,
        },
      },
      { NoiceCmdlinePopupBorderCmdline = { link = 'NoicePopupBaseGroup' } },
      { NoiceCmdlinePopupBorderSearch = { link = 'NoicePopupWarnBaseGroup' } },
      {
        NoiceCmdlinePopupTitleSearch = {
          inherit = 'NoicePopupWarnBaseGroup',
          reverse = true,
        },
      },
      { NoiceCmdlinePopupBorderFilter = { link = 'NoicePopupWarnBaseGroup' } },
      {
        NoiceCmdlinePopupTitleFilter = {
          inherit = 'NoicePopupWarnBaseGroup',
          reverse = true,
        },
      },
      { NoiceCmdlinePopupBorderHelp = { link = 'NoicePopupInfoBaseGroup' } },
      {
        NoiceCmdlinePopupTitleHelp = {
          inherit = 'NoicePopupInfoBaseGroup',
          reverse = true,
        },
      },
      {
        NoiceCmdlinePopupBorderSubstitute = { link = 'NoicePopupWarnBaseGroup' },
      },
      {
        NoiceCmdlinePopupTitleSubstitute = {
          inherit = 'NoicePopupWarnBaseGroup',
          reverse = true,
        },
      },
      {
        NoiceCmdlinePopupBorderIncRename = { link = 'NoicePopupWarnBaseGroup' },
      },
      {
        NoiceCmdlinePopupTitleIncRename = {
          inherit = 'NoicePopupWarnBaseGroup',
          reverse = true,
        },
      },
      { NoiceCmdlinePopupBorderInput = { link = 'NoicePopupBaseGroup' } },
      { NoiceCmdlinePopupBorderLua = { link = 'NoicePopupBaseGroup' } },
      { NoiceCmdlineIconCmdline = { link = 'NoicePopupBaseGroup' } },
      { NoiceCmdlineIconSearch = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlineIconFilter = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlineIconHelp = { link = 'NoicePopupInfoBaseGroup' } },
      { NoiceCmdlineIconIncRename = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlineIconSubstitute = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlineIconInput = { link = 'NoicePopupBaseGroup' } },
      { NoiceCmdlineIconLua = { link = 'NoicePopupBaseGroup' } },
      { NoiceConfirm = { bg = { from = 'NormalFloat' } } },
      { NoiceConfirmBorder = { link = 'NoicePopupBaseGroup' } },
    })

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
  end,
}
