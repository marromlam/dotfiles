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

            -- Powerline triangle separators
            separator = { bg = bg, fg = bg_sel },
            separator_selected = { bg = bg_sel, fg = bg },
            separator_visible = { bg = bg, fg = bg_sel },
            offset_separator = { bg = bg, fg = bg_sel },

            -- Indicator line under selected tab uses the accent colour
            indicator_selected = { fg = accent, bg = bg_sel },

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
            separator_style = { '', '' },
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
                  table.insert(result, { text = ' ' .. sym .. ' ', link = hl })
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
            indicator = { style = 'none' },

            custom_filter = function(buf_number)
              local name = vim.api.nvim_buf_get_name(buf_number)
              if name:match('^fugitive://') then return false end
              if name == '' then return false end
              return true
            end,

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
