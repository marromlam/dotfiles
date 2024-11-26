local api, opt, fs, f, rep =
  vim.api, vim.opt_local, vim.fs, string.format, string.rep
-- local icons, highlight = as.ui.icons, as.highlight
local strwidth = api.nvim_strwidth

---@alias Session {dir_path: string, name: string, file_path: string, branch: string}

local function get_installed_plugins()
  local ok, lazy = pcall(require, 'lazy')
  if not ok then
    return 0
  end
  return lazy.stats().count
end

local M = {}

function M.config()
  local alpha = require 'alpha'
  local dashboard = require 'alpha.themes.dashboard'

  local button = function(h, ...)
    local btn = dashboard.button(...)
    local details = select(2, ...)
    local icon = details:match '[^%w%s]+' -- match non alphanumeric or space characters
    btn.opts.hl = { { h, 0, #icon + 1 } } -- add one space padding
    btn.opts.hl_shortcut = 'Title'
    return btn
  end

  local color_list = {
    '#333333',
    '#323232',
    '#333333',
    '#333333',
    '#333333',
    '#333333',
    '#333333',
    '#222222',
  }
  -- loop over the color list and set the colors
  for i, color in ipairs(color_list) do
    vim.api.nvim_set_hl(0, 'StartLogo' .. i, { fg = color })
  end

  ------------------------------------------------------------------------------------------------
  --  Components
  ------------------------------------------------------------------------------------------------

  local separator = {
    type = 'text',
    -- val = string.rep('─', vim.o.columns - 2),
    val = string.rep(' ', vim.o.columns - 2),
    opts = { position = 'center', hl = 'NonText' },
  }

  local header = {
    [[                                                                   ]],
    [[      ████ ██████           █████      ██                    ]],
    [[     ███████████             █████                            ]],
    [[     █████████ ███████████████████ ███   ███████████  ]],
    [[    █████████  ███    █████████████ █████ ██████████████  ]],
    [[   █████████ ██████████ █████████ █████ █████ ████ █████  ]],
    [[ ███████████ ███    ███ █████████ █████ █████ ████ █████ ]],
    [[██████  █████████████████████ ████ █████ █████ ████ ██████]],
  }

  local function neovim_header()
    return mrl.map(function(chars, i)
      return {
        type = 'text',
        val = chars,
        opts = {
          hl = 'StartLogo' .. i,
          shrink_margin = false,
          position = 'center',
        },
      }
    end, header)
  end

  local installed_plugins = {
    type = 'text',
    val = f(' %d plugins installed', get_installed_plugins()),
    opts = { position = 'center', hl = 'NonText' },
  }

  local v = vim.version() or {}
  local version = {
    type = 'text',
    val = f(
      ' v%d.%d.%d %s',
      v.major,
      v.minor,
      v.patch,
      v.prerelease and '(nightly)' or ''
    ),
    opts = { position = 'center', hl = 'NonText' },
  }

  -- the width of the buttons as well as the headers MUST be the same in order for centering
  -- to work. This is a workaround due to the lack of a proper mechanism in alpha.nvim
  local SESSION_WIDTH = 50

  ---Each session file that can be loaded
  ---@param item Session
  ---@param index integer
  ---@return table

  dashboard.section.buttons.val = {
    button('Title', 'p', '  Pick a session', '<Cmd>ListSessions<CR>'),
    button('Title', 'f', '  Find file', ':Telescope find_files<CR>'),
    button('Title', 'q', '  Quit', ':qa<CR>'),
  }

  dashboard.section.footer.val = require 'alpha.fortune'
  dashboard.section.footer.opts.hl = 'TSEmphasis'

  ------------------------------------------------------------------------------------------------
  --  Setup
  ------------------------------------------------------------------------------------------------
  alpha.setup {
    layout = {
      { type = 'padding', val = 5 },
      { type = 'group', val = neovim_header() },
      { type = 'padding', val = 3 },
      installed_plugins,
      version,
      { type = 'padding', val = 1 },
      separator,
      -- sessions(6),
      separator,
      { type = 'padding', val = 1 },
      dashboard.section.buttons,
      separator,
      dashboard.section.footer,
    },
    opts = { margin = 10 },
  }

  -- mrl.augroup('AlphaSettings', {
  --   event = 'User ',
  --   pattern = 'AlphaReady',
  --   command = function(args)
  --     opt.foldenable = false
  --     opt.laststatus, opt.showtabline = 0, 0
  --     map('n', 'q', '<Cmd>Alpha<CR>', { buffer = args.buf, nowait = true })

  --     api.nvim_create_autocmd('BufUnload', {
  --       buffer = args.buf,
  --       callback = function()
  --         opt.laststatus, opt.showtabline = 3, 2
  --         vim.cmd.SessionStart()
  --       end,
  --     })
  --   end,
  -- })
end

return M
