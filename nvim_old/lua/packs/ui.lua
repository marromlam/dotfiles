-- packs/ui.lua

local UI = require('tools').ui
local icons = UI.icons

-- ---------------------------------------------------------------------------
-- indent-blankline (on BufReadPre)
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlIndentBlankline', { clear = true }),
  callback = function()
    require('ibl').setup({
      indent = { char = '┊' },
      exclude = {
        filetypes = { 'notify', 'noice', 'noice_popup', 'noice_cmdline' },
      },
    })
  end,
})

-- ---------------------------------------------------------------------------
-- nvim-navic (on LspAttach)
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
  once = true,
  group = vim.api.nvim_create_augroup('MrlNavic', { clear = true }),
  callback = function(args)
    require('nvim-navic').setup({
      highlight = true,
      separator = ' › ',
      depth_limit = 5,
      depth_limit_indicator = '..',
    })
    -- Attach navic to the first LSP client that triggers this
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.documentSymbolProvider then
      require('nvim-navic').attach(client, args.buf)
    end
    -- Also register the general autocmd for future LSP attaches
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(inner_args)
        local c = vim.lsp.get_client_by_id(inner_args.data.client_id)
        if c and c.server_capabilities.documentSymbolProvider then
          require('nvim-navic').attach(c, inner_args.buf)
        end
      end,
    })
  end,
})

-- ---------------------------------------------------------------------------
-- incline.nvim (deferred - VeryLazy equivalent)
-- ---------------------------------------------------------------------------
vim.defer_fn(function()
  local incline = require('incline')

  local function set_hls()
    local pal = UI.palette or {}
    local bg = '#121212'
    vim.api.nvim_set_hl(0, 'InclineNormal', {
      fg = pal.whitesmoke or 'NONE',
      bg = bg,
    })
    vim.api.nvim_set_hl(0, 'InclineNormalNC', {
      fg = pal.light_gray or pal.comment_grey or 'NONE',
      bg = bg,
    })
    vim.api.nvim_set_hl(0, 'InclineTitle', {
      fg = pal.bright_blue or pal.blue or 'NONE',
      bg = bg,
      bold = true,
    })
    vim.api.nvim_set_hl(0, 'InclineModified', {
      fg = pal.dark_orange or 'NONE',
      bg = bg,
    })
    vim.api.nvim_set_hl(0, 'InclineGit', {
      fg = pal.teal or pal.green or 'NONE',
      bg = bg,
    })
  end

  set_hls()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('MrlIncline', { clear = true }),
    callback = set_hls,
  })

  local devicons_ok, devicons = pcall(require, 'nvim-web-devicons')

  -- Use incline's render function so we can style per-window content.
  incline.setup({
    window = {
      placement = { horizontal = 'right', vertical = 'top' },
      margin = { vertical = 1, horizontal = 1 },
      padding = 1,
      winhighlight = {
        Normal = 'InclineNormal',
        NormalNC = 'InclineNormalNC',
      },
    },
    ignore = {
      buftypes = { 'terminal', 'nofile', 'prompt', 'quickfix' },
      filetypes = {
        'neo-tree',
        'NvimTree',
        'undotree',
        'toggleterm',
        'Trouble',
        'noice',
        'notify',
        'qf',
        'diff',
        'alpha',
        'startify',
        'help',
        'gitcommit',
        'NeogitStatus',
        'NeogitCommitMessage',
        'DiffviewFiles',
        'DiffviewFileHistory',
      },
    },
    render = function(props)
      local buf = props.buf
      local ft = vim.bo[buf].ft
      local bt = vim.bo[buf].bt
      local decor = UI.decorations.get({
        ft = ft,
        bt = bt,
        setting = 'winbar',
      })
      if
        (decor and (decor.ft == false or decor.bt == false))
        or (decor and (decor.ft == 'ignore' or decor.bt == 'ignore'))
      then
        return {}
      end

      local name = vim.api.nvim_buf_get_name(buf)
      if name == '' then
        name = '[No Name]'
      else
        name = vim.fn.fnamemodify(name, ':t')
      end

      local parts = {}
      if devicons_ok then
        local ext = vim.fn.fnamemodify(name, ':e')
        local icon, icon_color =
          devicons.get_icon_color(name, ext, { default = true })
        if icon then
          table.insert(parts, { icon .. ' ', guifg = icon_color })
        end
      else
        table.insert(
          parts,
          { icons.documents.file .. ' ', group = 'InclineTitle' }
        )
      end

      table.insert(parts, { name, group = 'InclineTitle' })

      if vim.bo[buf].modified then
        table.insert(parts, {
          ' ' .. icons.misc.circle,
          group = 'InclineModified',
        })
      end

      return parts
    end,
  })
end, 100)

-- ---------------------------------------------------------------------------
-- ccc.nvim (cmd-loaded, setup immediately)
-- ---------------------------------------------------------------------------
do
  local ok, ccc = pcall(require, 'ccc')
  if ok then
    ccc.setup({
      -- win_opts = { border = UI.border },
      highlighter = {
        auto_enable = false,
        excludes = {
          'dart',
          'lazy',
          'orgagenda',
          'org',
          'NeogitStatus',
          'toggleterm',
        },
      },
    })
  end
end

-- ---------------------------------------------------------------------------
-- symbol-usage.nvim (on LspAttach)
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
  once = true,
  group = vim.api.nvim_create_augroup('MrlSymbolUsage', { clear = true }),
  callback = function()
    ---@diagnostic disable: undefined-field
    local symbol_usage = require('symbol-usage')
    symbol_usage.setup({
      vt_position = 'end_of_line',
      text_format = function(symbol)
        local res = {}
        local ins = table.insert

        local round_start = { '', 'SymbolUsageLeft' }
        local round_end = { '', 'SymbolUsageRight' }

        if symbol.references then
          local usage = symbol.references <= 1 and 'usage' or 'usages'
          local num = symbol.references == 0 and 'no' or symbol.references
          ins(res, round_start)
          ins(res, { '󰌹 ', 'SymbolUsageRef' })
          ins(res, { ('%s %s'):format(num, usage), 'SymbolUsageContent' })
          ins(res, round_end)
        end

        if symbol.definition then
          if #res > 0 then table.insert(res, { ' ', 'NonText' }) end
          ins(res, round_start)
          ins(res, { '󰳽 ', 'SymbolUsageDef' })
          ins(res, { symbol.definition .. ' defs', 'SymbolUsageContent' })
          ins(res, round_end)
        end

        if symbol.implementation then
          if #res > 0 then table.insert(res, { ' ', 'NonText' }) end
          ins(res, round_start)
          ins(res, { '󰡱 ', 'SymbolUsageImpl' })
          ins(
            res,
            { symbol.implementation .. ' impls', 'SymbolUsageContent' }
          )
          ins(res, round_end)
        end

        return res
      end,
    })
  end,
})

-- ---------------------------------------------------------------------------
-- undotree
-- ---------------------------------------------------------------------------
vim.keymap.set('n', '<leader>u', '<Cmd>UndotreeToggle<CR>', { desc = 'undotree: toggle' })
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  group = vim.api.nvim_create_augroup('MrlUndotree', { clear = true }),
  callback = function()
    vim.g.undotree_TreeNodeShape = '◉' -- Alternative: '◉' ◦
    vim.g.undotree_SetFocusWhenToggle = 1
  end,
})

-- ---------------------------------------------------------------------------
-- numb.nvim (on CmdlineEnter)
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd('CmdlineEnter', {
  once = true,
  group = vim.api.nvim_create_augroup('MrlNumb', { clear = true }),
  callback = function()
    require('numb').setup({})
  end,
})

-- ---------------------------------------------------------------------------
-- rainbow-delimiters (on BufReadPost)
-- ---------------------------------------------------------------------------

-- init equivalent: set up rainbow_delimiters global early
do
  local rd = vim.g.rainbow_delimiters or {}
  rd.highlight = rd.highlight
    or {
      'RainbowDelimiterRed',
      'RainbowDelimiterYellow',
      'RainbowDelimiterBlue',
      'RainbowDelimiterOrange',
      'RainbowDelimiterGreen',
      'RainbowDelimiterViolet',
      'RainbowDelimiterCyan',
    }
  vim.g.rainbow_delimiters = rd
end

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlRainbowDelimiters', { clear = true }),
  callback = function()
    local ok, rainbow_delimiters = pcall(require, 'rainbow-delimiters')
    if not ok then return end

    -- Akinsho-style: global strategy + default query name.
    local rd = vim.g.rainbow_delimiters or {}
    rd.strategy = {
      [''] = rainbow_delimiters.strategy['global'],
    }
    rd.query = {
      [''] = 'rainbow-delimiters',
      html = 'rainbow-delimiters', -- enable our html tag query override
      svelte = 'rainbow-delimiters',
    }
    vim.g.rainbow_delimiters = rd

    -- Palette-driven colors for the delimiter groups.
    local api = vim.api
    local group =
      api.nvim_create_augroup('MrlRainbowDelimitersColors', { clear = true })

    local function set_hls()
      local pal = UI.palette or {}
      local function as_hex(v, fallback)
        if type(v) == 'string' or type(v) == 'number' then return v end
        if type(v) == 'table' then return v.base or fallback end
        return fallback
      end
      local colors = {
        as_hex(pal.red, '#E06C75'),
        as_hex(pal.light_yellow, '#E5C07B'),
        as_hex(pal.blue, '#61AFEF'),
        as_hex(pal.dark_orange, '#D19A66'),
        as_hex(pal.green, '#98C379'),
        as_hex(pal.magenta, '#C678DD'),
        as_hex(pal.teal, '#56B6C2'),
      }
      local cur = vim.g.rainbow_delimiters or {}
      local names = cur.highlight or {}
      for i, name in ipairs(names) do
        api.nvim_set_hl(0, name, { fg = colors[i] })
      end
    end

    set_hls()
    api.nvim_create_autocmd('ColorScheme', {
      group = group,
      callback = set_hls,
    })
  end,
})
