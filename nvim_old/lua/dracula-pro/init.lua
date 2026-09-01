-- Dracula Pro Neovim theme
-- Main entry point

local M = {}

function M.load()
  local config = require('dracula-pro.config')
  local colors = require('dracula-pro.colors').setup(config.options)

  -- Clear existing highlights
  if vim.g.colors_name then vim.cmd('hi clear') end

  vim.o.termguicolors = true
  vim.g.colors_name = 'dracula-pro'

  -- Load highlight groups
  local groups = {
    require('dracula-pro.groups.base').get(colors, config.options),
    require('dracula-pro.groups.treesitter').get(colors, config.options),
    require('dracula-pro.groups.plugins').get(colors, config.options),
  }

  for _, group in ipairs(groups) do
    for hl, spec in pairs(group) do
      if type(spec) == 'string' then
        vim.api.nvim_set_hl(0, hl, { link = spec })
      else
        -- Resolve style table into highlight attributes
        if type(spec.style) == 'table' then
          for k, v in pairs(spec.style) do
            spec[k] = v
          end
          spec.style = nil
        end
        vim.api.nvim_set_hl(0, hl, spec)
      end
    end
  end

  -- Terminal colors
  if config.options.terminal_colors then
    vim.g.terminal_color_0 = '#22212C'
    vim.g.terminal_color_1 = '#FF9580'
    vim.g.terminal_color_2 = '#8AFF80'
    vim.g.terminal_color_3 = '#FFFF80'
    vim.g.terminal_color_4 = '#9580FF'
    vim.g.terminal_color_5 = '#FF80BF'
    vim.g.terminal_color_6 = '#80FFEA'
    vim.g.terminal_color_7 = '#F8F8F2'
    vim.g.terminal_color_8 = '#504C67'
    vim.g.terminal_color_9 = '#FFAA99'
    vim.g.terminal_color_10 = '#A2FF99'
    vim.g.terminal_color_11 = '#FFFF99'
    vim.g.terminal_color_12 = '#AA99FF'
    vim.g.terminal_color_13 = '#FF99CC'
    vim.g.terminal_color_14 = '#99FFEE'
    vim.g.terminal_color_15 = '#FFFFFF'
  end
end

function M.setup(opts) require('dracula-pro.config').setup(opts) end

return M
