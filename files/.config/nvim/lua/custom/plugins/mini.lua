-- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
return { -- Collection of various small independent plugins/modules
  -- Text objects and editing
  {
    'echasnovski/mini.ai',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() require('mini.ai').setup({ n_lines = 500 }) end,
  },
  {
    'echasnovski/mini.align',
    version = false,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mini.align').setup({
        -- Module mappings. Use `''` (empty string) to disable one.
        mappings = {
          start = 'ga', -- Start align mode
          start_with_preview = 'gA', -- Start align mode with preview
        },
        -- Options which control alignment process
        options = {
          split_pattern = '',
          justify_side = 'left',
          merge_delimiter = '',
        },
      })
    end,
  },
  {
    'echasnovski/mini.pairs',
    version = false,
    event = { 'InsertEnter' },
    config = function()
      require('mini.pairs').setup({
        -- In which modes mappings from this `config` set are enabled
        modes = { insert = true, command = false, terminal = false },
      })
    end,
    -- Note: mini.pairs doesn't have fast_wrap like nvim-autopairs
    -- You can use mini.surround's 'sa' command in visual mode instead
    -- Or keep nvim-autopairs enabled just for fast_wrap if needed
  },
  {
    'echasnovski/mini.surround',
    version = false,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mini.surround').setup({
        -- Number of lines within which surrounding is searched
        n_lines = 20,
        -- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
        highlight_duration = 500,
        -- Module mappings. Use `''` (empty string) to disable one.
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
    end,
  },
  {
    'echasnovski/mini.splitjoin',
    version = false,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mini.splitjoin').setup({
        -- Module mappings. Use `''` (empty string) to disable one.
        mappings = {
          toggle = 'gS',
          split = '',
          join = '',
        },
      })
    end,
  },
  {
    'echasnovski/mini.move',
    version = false,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mini.move').setup({
        -- Module mappings. Use `''` (empty string) to disable one.
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
        -- Options which control behavior of module
        options = {
          reindent_linewise = true, -- Re-indent selected lines during linewise vertical move
        },
      })
    end,
  },
  {
    'echasnovski/mini.jump',
    version = false,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mini.jump').setup({
        -- Delay values (in ms) for different functionalities. Set any to `false` to disable
        delay = {
          -- Delay between jump and highlighting all possible jumps
          highlight = 250,
          -- Delay between jump and automatic stop if idle (no jump key was pressed)
          idle_stop = 1000000,
        },
        -- Function to create labels for all available jumps
        -- For more information, see `:h mini.jump`
        mappings = {
          forward = 'f',
          backward = 'F',
          forward_till = 't',
          backward_till = 'T',
          repeat_jump = ';',
        },
      })
    end,
  },

  -- Icons
  {
    'echasnovski/mini.icons',
    version = false,
    -- This was a measurable startup cost (~10ms). None of your always-on startup
    -- plugins require devicons, so load it after UI is up.
    event = 'VeryLazy',
    config = function()
      -- Setup with optimized config
      require('mini.icons').setup({
        -- Customize which file extensions should use icons
        -- Optimized: cache string length to avoid repeated calculations
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
    end,
  },

  -- Git integration
  {
    'echasnovski/mini.diff',
    version = false,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mini.diff').setup({
        -- Options for overriding view
        view = {
          style = 'sign',
          signs = {
            add = '┃',
            change = '┃',
            delete = '┃',
          },
        },
        -- Options for overriding diff algorithm
        algorithm = 'histogram',
        -- Options for overriding highlight groups
        highlight = {
          additions = 'MiniDiffSignAdd',
          deletions = 'MiniDiffSignDelete',
          changes = 'MiniDiffSignChange',
          text = 'MiniDiffText',
        },
      })
    end,
  },

  -- Visual enhancements
  {
    'echasnovski/mini.hipatterns',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local hipatterns = require('mini.hipatterns')
      hipatterns.setup({
        highlighters = {
          -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
          fixme = {
            pattern = '%f[%w]()FIXME()%f[%W]',
            group = 'MiniHipatternsFixme',
          },
          hack = {
            pattern = '%f[%w]()HACK()%f[%W]',
            group = 'MiniHipatternsHack',
          },
          todo = {
            pattern = '%f[%w]()TODO()%f[%W]',
            group = 'MiniHipatternsTodo',
          },
          note = {
            pattern = '%f[%w]()NOTE()%f[%W]',
            group = 'MiniHipatternsNote',
          },

          -- Highlight hex color strings (`#rrggbb`) using that color
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      })
    end,
  },
  {
    'echasnovski/mini.indentscope',
    version = false,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mini.indentscope').setup({
        -- Draw options
        draw = {
          -- Delay (in ms) between event and start of drawing scope indicator
          delay = 0,
          -- Symbol priority. Increase to display on top of more symbols.
          priority = 2,
        },
        -- Options for scope computation
        options = {
          -- Type of scope's border: which line(s) with smaller indent to
          -- categorize as border. Can be one of: 'both', 'top', 'bottom', 'none'
          border = 'both',
          -- Whether to use cursor column when computing reference indent.
          -- Useful to see incremental scopes with horizontal cursor movements.
          indent_at_cursor = true,
          -- Whether to decrease indent level for empty lines. Useful when
          -- you want empty lines to have no indent scope. Requires setting
          -- `indent_at_cursor = true`.
          try_as_border = true,
        },
        -- Which character to use for drawing scope indicator
        symbol = '│',
        -- List of character patterns which should not have indentscope computed
        exclude = {
          '^diff',
          '^fugitive',
          '^git',
          '^help',
          '^lazy',
          '^neogitstatus',
          '^qf',
          '^query',
          '^spectre',
          '^starter',
          '^TelescopePrompt',
          '^Trouble',
          '^undotree',
          '^which-key',
        },
      })
    end,
  },
  {
    'echasnovski/mini.trailspace',
    version = false,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mini.trailspace').setup({
        -- Highlight only in normal buffers (ones with empty 'buftype'). This is
        -- useful to not show trailing whitespace where it usually doesn't matter.
        only_in_normal_buffers = true,
      })
    end,
  },

  -- UI enhancements
  {
    'echasnovski/mini.animate',
    version = false,
    event = 'VeryLazy',
    config = function()
      require('mini.animate').setup({
        -- Cursor path animation.  Displayed only when
        -- cursor is moved by j/k or arrow keys.
        cursor = {
          -- Whether to enable this animation
          enable = true,
          -- Timing of animation (how to animate)
          timing = require('mini.animate').gen_timing.linear({
            duration = 100,
            unit = 'total',
          }),
        },
        -- Vertical scroll animation. Displayed when moving window
        -- viewport up/down.
        scroll = {
          enable = true,
          timing = require('mini.animate').gen_timing.linear({
            duration = 150,
            unit = 'total',
          }),
        },
        -- Resize animation. Displayed when resizing splits.
        resize = {
          enable = true,
          timing = require('mini.animate').gen_timing.linear({
            duration = 100,
            unit = 'total',
          }),
        },
        -- Open window animation. Displayed when opening/closing windows.
        open = {
          enable = true,
          timing = require('mini.animate').gen_timing.linear({
            duration = 100,
            unit = 'total',
          }),
        },
        -- Close window animation. Displayed when opening/closing windows.
        close = {
          enable = true,
          timing = require('mini.animate').gen_timing.linear({
            duration = 100,
            unit = 'total',
          }),
        },
      })

      -- Disable animations for specific buffers and filetypes
      local ignore_buffers = { 'terminal', 'nofile', 'neorg://Quick Actions' }
      local ignore_filetypes = {
        'qf',
        'dap_watches',
        'dap_scopes',
        'neo-tree',
        'NeogitCommitMessage',
        'NeogitPopup',
        'NeogitStatus',
      }

      local function should_disable_animate()
        local buf_type = vim.bo.buftype
        local filetype = vim.bo.filetype
        local buf_name = vim.api.nvim_buf_get_name(0)

        -- Check buffer type
        for _, ignore_type in ipairs(ignore_buffers) do
          if buf_type == ignore_type or buf_name:match(ignore_type) then
            return true
          end
        end

        -- Check filetype
        for _, ignore_ft in ipairs(ignore_filetypes) do
          if filetype == ignore_ft then return true end
        end

        return false
      end

      -- Set up autocommands to disable animations for ignored buffers/filetypes
      vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
        callback = function()
          if should_disable_animate() then
            vim.b.minianimate_disable = true
          else
            vim.b.minianimate_disable = false
          end
        end,
        desc = 'Disable mini.animate for specific buffers/filetypes',
      })
    end,
  },
  {
    'echasnovski/mini.starter',
    version = false,
    event = 'VimEnter',
    config = function()
      require('mini.starter').setup({
        -- Whether to open starter buffer on VimEnter. Not opened if command
        -- line arguments are present.
        autoopen = true,
        -- Whether to evaluate action of single active item
        evaluate_single = false,
        -- Items to be displayed. Should be an array with the following elements:
        -- - Item: table with <action>, <name>, <section> keys.
        -- - Function: should return one of these three categories.
        -- - `nil`: empty line (applies `header` + `footer` settings)
        -- If `nil` (default), default items will be used.
        items = nil,
        -- Header to be displayed before items. Converted to single string via
        -- `tostring` (use `\n` to display several lines). If function, it is
        -- evaluated first. If `nil` (default), polite greeting will be used.
        header = nil,
        -- Footer to be displayed after items. Converted to single string via
        -- `tostring`. If function, it is evaluated first. If `nil` (default),
        -- default usage help will be shown.
        footer = nil,
        -- Characters to update query. Each character will have special buffer
        -- mapping overriding your global ones. `:` will be treated specially
        -- (see command section in the main readme).
        query_updaters = '',
        -- Whether to disable showing non-error feedback
        silent = false,
      })
    end,
  },

  -- Utility modules
  {
    'echasnovski/mini.misc',
    version = false,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mini.misc').setup({
        -- Module mappings. Use `''` (empty string) to disable one.
        mappings = {
          -- Put global mappings here
        },
        -- Various options
        options = {
          -- Whether to use global statusline
          use_global_statusline = true,
        },
      })
    end,
  },
}
