return {

  {
    'akinsho/bufferline.nvim',
    event = 'UIEnter',
    dependencies = { 'echasnovski/mini.icons' },
    config = function()
      local bufferline = require('bufferline')
      local UI = require('tools').ui

      -- Derive colours from live highlight groups so every theme looks great.
      local function hl_hex(name, attr, fallback)
        local ok, h =
          pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        if ok and h and h[attr] then return ('#%06x'):format(h[attr]) end
        return fallback
      end

      local NUMS =
        { '➊', '➋', '➌', '➍', '➎', '➏', '➐', '➑', '➒', '➓' }

      local function setup()
        local pal = UI.palette or {}
        local bg = hl_hex('StatusLine', 'bg', 'NONE')
        local bg_sel = hl_hex('Normal', 'bg', '#1e1e2e')
        local fg_sel = hl_hex('Normal', 'fg', '#cdd6f4')
        local fg_dim = pal.comment_grey or hl_hex('Comment', 'fg', '#6c7086')
        local accent = pal.blue or hl_hex('Function', 'fg', '#82aaff')

        bufferline.setup({
          highlights = {
            -- Tabline gutter & inactive tabs share the statusline bg
            fill = { bg = bg },
            background = { bg = bg, fg = fg_dim },
            tab = { bg = bg, fg = fg_dim },
            tab_close = { bg = bg, fg = fg_dim },
            close_button = { bg = bg, fg = fg_dim },

            -- Selected buffer pops out with normal bg
            buffer_selected = {
              bg = bg_sel,
              fg = fg_sel,
              bold = true,
              italic = false,
            },
            close_button_selected = { bg = bg_sel, fg = fg_dim },
            tab_selected = { bg = bg, fg = fg_sel, bold = true },

            -- Visible (non-focused split) buffer
            buffer_visible = { bg = bg, fg = fg_dim },

            -- Separators are invisible (same bg) — no clutter
            separator = { bg = bg, fg = bg },
            separator_selected = { bg = bg, fg = bg },
            separator_visible = { bg = bg, fg = bg },
            offset_separator = { bg = bg, fg = bg },

            -- Indicator line under selected tab uses the accent colour
            indicator_selected = { fg = accent, bg = bg_sel },

            -- Group labels
            group_separator = { bg = bg, fg = fg_dim },
            group_label = { bg = bg, fg = accent },

            -- Numbers
            numbers = { bg = bg, fg = fg_dim },
            numbers_selected = { bg = bg_sel, fg = fg_sel },

            -- Pick
            pick = { bg = bg, fg = accent, bold = true, italic = true },
            pick_selected = {
              bg = bg_sel,
              fg = accent,
              bold = true,
              italic = true,
            },
          },

          options = {
            style_preset = bufferline.style_preset.minimal,
            mode = 'buffers',
            custom_areas = {
              right = function()
                local tabs = vim.api.nvim_list_tabpages()
                if #tabs <= 1 then return {} end
                local result = {}
                local cur = vim.api.nvim_get_current_tabpage()
                for i, tab in ipairs(tabs) do
                  local sym = NUMS[i] or tostring(i)
                  local hl = tab == cur and 'BufferLineTabSelected'
                    or 'BufferLineTab'
                  table.insert(result, { text = ' ' .. sym .. '  ', link = hl })
                end
                return result
              end,
            },
            sort_by = 'insert_after_current',
            move_wraps_at_ends = true,
            right_mouse_command = 'vert sbuffer %d',
            show_close_icon = false,
            show_buffer_close_icons = false,
            show_tab_indicators = false,

            -- Top-bar indicator for the selected buffer
            -- indicator = { style = 'icon', icon = '▀' },

            hover = { enabled = true, delay = 150, reveal = { 'close' } },

            offsets = {
              {
                text = '  EXPLORER',
                filetype = 'neo-tree',
                highlight = 'PanelHeading',
                separator = false,
                text_align = 'left',
              },
              {
                text = '  UNDOTREE',
                filetype = 'undotree',
                highlight = 'PanelHeading',
                separator = false,
                text_align = 'left',
              },
              {
                text = '󰆼  DATABASE',
                filetype = 'dbui',
                highlight = 'PanelHeading',
                separator = false,
                text_align = 'left',
              },
              {
                text = '  DIFF VIEW',
                filetype = 'DiffviewFiles',
                highlight = 'PanelHeading',
                separator = false,
                text_align = 'left',
              },
            },

            groups = {
              options = { toggle_hidden_on_enter = true },
              items = {
                bufferline.groups.builtin.pinned:with({ icon = '' }),
                bufferline.groups.builtin.ungrouped,
                {
                  name = 'Dependencies',
                  icon = '',
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
                  name = 'Tests',
                  icon = '',
                  matcher = function(buf)
                    local name = buf.name
                    return name:match('[_%.]spec') or name:match('[_%.]test')
                  end,
                },
                {
                  name = 'Docs',
                  icon = '',
                  matcher = function(buf)
                    if
                      vim.bo[buf.id].filetype == 'man'
                      or buf.path:match('man://')
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
                  name = 'Git',
                  icon = '',
                  matcher = function(buf)
                    if buf.path:match('fugitive://') then return true end
                  end,
                },
              },
            },
          },
        })
      end

      setup()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('MrlBufferline', { clear = true }),
        callback = setup,
      })

      -- Keymaps
      local map = function(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { desc = desc })
      end
      map('[b', '<Cmd>BufferLineMoveNext<CR>', 'bufferline: move next')
      map(']b', '<Cmd>BufferLineMovePrev<CR>', 'bufferline: move prev')
      map('gbb', '<Cmd>BufferLinePick<CR>', 'bufferline: pick buffer')
      map('gbd', '<Cmd>BufferLinePickClose<CR>', 'bufferline: delete buffer')
      map('<S-tab>', '<Cmd>BufferLineCyclePrev<CR>', 'bufferline: prev')
      map('<leader><tab>', '<Cmd>BufferLineCycleNext<CR>', 'bufferline: next')
    end,
  },
}
