return {

  {
    'akinsho/bufferline.nvim',
    event = 'UIEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local bufferline = require('bufferline')
      bufferline.setup({
        highlights = {
          fill = {
            fg = '#ffffff',
            bg = '#000000',
          },
          background = {
            -- fg = '#000000',
            bg = '#000000',
          },
          tab = {
            -- fg = '#000000',
            bg = '#000000',
          },
          tab_selected = {
            fg = '#000000',
            bg = '#ffaa00',
          },
          tab_separator = {
            fg = '#00ff00',
            bg = '#00aa00',
          },
          tab_separator_selected = {
            fg = '#00ff00',
            bg = '#0000ff',
            -- sp = '<colour-value-here>',
            -- underline = '<colour-value-here>',
          },
        },
        options = {
          debug = { logging = true },
          style_preset = { bufferline.style_preset.minimal },
          mode = 'buffers',
          sort_by = 'insert_after_current',
          move_wraps_at_ends = true,
          right_mouse_command = 'vert sbuffer %d',
          show_close_icon = false,
          show_buffer_close_icons = false,
          indicator = {
            -- style = 'icon',
            style = 'none',
            icon = '▎', -- this should be omitted if indicator style is not 'icon'
          },
          -- diagnostics = 'nvim_lsp',
          -- diagnostics_indicator = function(count, level)
          --   level = level:match('warn') and 'warn' or level
          --   return (icons[level] or '?') .. ' ' .. count
          -- end,
          -- diagnostics_update_in_insert = false,
          hover = { enabled = true, reveal = { 'close' } },
          offsets = {
            {
              text = 'EXPLORER',
              filetype = 'neo-tree',
              highlight = 'PanelHeading',
              -- text_align = 'left',
              separator = false,
            },
            {
              text = 'UNDOTREE',
              filetype = 'undotree',
              highlight = 'PanelHeading',
              separator = false,
            },
            {
              text = '󰆼 DATABASE VIEWER',
              filetype = 'dbui',
              highlight = 'PanelHeading',
              separator = false,
            },
            {
              text = ' DIFF VIEW',
              filetype = 'DiffviewFiles',
              highlight = 'PanelHeading',
              separator = false,
            },
          },
          groups = {
            options = { toggle_hidden_on_enter = true },
            items = {
              bufferline.groups.builtin.pinned:with({ icon = '' }),
              bufferline.groups.builtin.ungrouped,
              {
                name = 'Dependencies',
                icon = '',
                highlight = { fg = '#ECBE7B' },
                matcher = function(buf)
                  return vim.startswith(buf.path, vim.env.VIMRUNTIME)
                end,
              },
              {
                name = 'Terraform',
                matcher = function(buf) return buf.name:match('%.tf') ~= nil end,
              },
              {
                name = 'Kubernetes',
                matcher = function(buf)
                  return buf.name:match('kubernetes')
                    and buf.name:match('%.yaml')
                end,
              },
              {
                name = 'SQL',
                matcher = function(buf) return buf.name:match('%.sql$') end,
              },
              {
                name = 'tests',
                icon = '',
                matcher = function(buf)
                  local name = buf.name
                  return name:match('[_%.]spec') or name:match('[_%.]test')
                end,
              },
              {
                name = 'docs',
                icon = '',
                matcher = function(buf)
                  if
                    vim.bo[buf.id].filetype == 'man' or buf.path:match('man://')
                  then
                    return true
                  end
                  for _, ext in ipairs({ 'md', 'txt', 'org', 'norg', 'wiki' }) do
                    if ext == vim.fn.fnamemodify(buf.path, ':e') then
                      return true
                    end
                  end
                end,
              },
              {
                name = 'git',
                icon = ' fugitive',
                matcher = function(buf)
                  if buf.path:match('fugitive://') then return true end
                end,
              },
            },
          },
        },
      })

      vim.keymap.set(
        'n',
        '[b',
        '<Cmd>BufferLineMoveNext<CR>',
        { desc = 'bufferline: move next' }
      )
      vim.keymap.set(
        'n',
        ']b',
        '<Cmd>BufferLineMovePrev<CR>',
        { desc = 'bufferline: move prev' }
      )
      vim.keymap.set(
        'n',
        'gbb',
        '<Cmd>BufferLinePick<CR>',
        { desc = 'bufferline: pick buffer' }
      )
      vim.keymap.set(
        'n',
        'gbd',
        '<Cmd>BufferLinePickClose<CR>',
        { desc = 'bufferline: delete buffer' }
      )
      vim.keymap.set(
        'n',
        '<S-tab>',
        '<Cmd>BufferLineCyclePrev<CR>',
        { desc = 'bufferline: prev' }
      )
      vim.keymap.set(
        'n',
        '<leader><tab>',
        '<Cmd>BufferLineCycleNext<CR>',
        { desc = 'bufferline: next' }
      )
    end,
  },
}
