-- packs/mini.lua
-- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).

-- ---------------------------------------------------------------------------
-- Text objects and editing (on BufReadPre)
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlMiniTextObjects', { clear = true }),
  callback = function()
    require('mini.ai').setup({ n_lines = 500 })

    require('mini.align').setup({
      mappings = {
        start = 'ga', -- Start align mode
        start_with_preview = 'gA', -- Start align mode with preview
      },
      options = {
        split_pattern = '',
        justify_side = 'left',
        merge_delimiter = '',
      },
    })

    require('mini.surround').setup({
      n_lines = 20,
      highlight_duration = 500,
      mappings = {
        add = 'sa', -- Add surrounding in Normal and Visual modes
        delete = 'sd', -- Delete surrounding
        find = 'sf', -- Find surrounding (to the right)
        find_left = 'sF', -- Find surrounding (to the left)
        highlight = 'sh', -- Highlight surrounding
        replace = 'sr', -- Replace surrounding
        update_n_lines = 'sn', -- Update `n_lines`
      },
    })

    require('mini.splitjoin').setup({
      mappings = {
        toggle = 'gS',
        split = '',
        join = '',
      },
    })

    require('mini.move').setup({
      mappings = {
        -- Move visual selection in Visual mode
        left = '<M-h>',
        right = '<M-l>',
        down = '<M-j>',
        up = '<M-k>',
        -- Move current line in Normal mode
        line_left = '<M-h>',
        line_right = '<M-l>',
        line_down = '<M-j>',
        line_up = '<M-k>',
      },
      options = {
        reindent_linewise = true,
      },
    })

    require('mini.diff').setup({
      view = {
        style = 'sign',
        signs = {
          add = '┃',
          change = '┃',
          delete = '┃',
        },
      },
      algorithm = 'histogram',
      highlight = {
        additions = 'MiniDiffSignAdd',
        deletions = 'MiniDiffSignDelete',
        changes = 'MiniDiffSignChange',
        text = 'MiniDiffText',
      },
    })

    require('mini.trailspace').setup({
      only_in_normal_buffers = true,
    })

    require('mini.misc').setup({
      mappings = {},
      options = {
        use_global_statusline = true,
      },
    })
  end,
})

-- mini.pairs on InsertEnter
vim.api.nvim_create_autocmd('InsertEnter', {
  once = true,
  group = vim.api.nvim_create_augroup('MrlMiniPairs', { clear = true }),
  callback = function()
    require('mini.pairs').setup({
      modes = { insert = true, command = false, terminal = false },
    })
  end,
})

-- ---------------------------------------------------------------------------
-- Icons (deferred - VeryLazy equivalent)
-- ---------------------------------------------------------------------------
vim.defer_fn(function()
  require('mini.icons').setup({
    use_file_extension = function(ext, _)
      if not ext or ext == '' then return true end
      local len = #ext
      if len >= 3 then
        local suf3 = ext:sub(-3)
        if suf3 == 'scm' or suf3 == 'txt' or suf3 == 'yml' then
          return false
        end
      end
      if len >= 4 then
        local suf4 = ext:sub(-4)
        if suf4 == 'json' or suf4 == 'yaml' then return false end
      end
      return true
    end,
  })

  -- Mock nvim-web-devicons API immediately (needed early for other plugins)
  require('mini.icons').mock_nvim_web_devicons()

  -- Defer LSP kind tweak (less critical, can happen after startup)
  vim.schedule(function() require('mini.icons').tweak_lsp_kind() end)
end, 100)

-- ---------------------------------------------------------------------------
-- mini.animate is disabled (cond = false)
-- ---------------------------------------------------------------------------
-- if false then
--   require('mini.animate').setup({...})
-- end

-- ---------------------------------------------------------------------------
-- mini.indentscope is disabled (cond = false)
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- mini.bufremove keymaps
-- ---------------------------------------------------------------------------
require('mini.bufremove').setup()
vim.keymap.set('n', '<leader>bD', '<cmd>lua MiniBufremove.unshow()<cr>', {
  desc = 'buffer: close buffer',
})
