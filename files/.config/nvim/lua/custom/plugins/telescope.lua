return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    lazy = true,
    disable = true,
    cond = false,
    cmd = 'Telescope',
    keys = {
      -- { '<leader>fh',       require('telescope.builtin').help_tags,   desc = '[S]earch [H]elp' },
      -- { '<leader>fk',       require('telescope.builtin').keymaps,     desc = '[S]earch [K]eymaps' },
      -- { '<leader>ff',       require('telescope.builtin').find_files,  desc = '[S]earch [F]iles' },
      -- { '<leader>fs',       require('telescope.builtin').builtin,     desc = '[S]earch [S]elect Telescope' },
      -- { '<leader>fw',       require('telescope.builtin').grep_string, desc = '[S]earch current [W]ord' },
      -- { '<leader>fg',       require('telescope.builtin').live_grep,   desc = '[S]earch by [G]rep' },
      -- { '<leader>fd',       require('telescope.builtin').diagnostics, desc = '[S]earch [D]iagnostics' },
      -- { '<leader>fr',       require('telescope.builtin').resume,      desc = '[S]earch [R]esume' },
      -- { '<leader>f.',       require('telescope.builtin').oldfiles,    desc = '[S]earch Recent Files ("." for repeat)' },
      -- { '<leader><leader>', require('telescope.builtin').buffers,     desc = '[ ] Find existing buffers' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable('make') == 1 end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons' },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup({
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        pickers = {
          live_grep = {
            file_ignore_patterns = { 'node_modules', '.git', '.venv' },
            additional_args = function(_) return { '--hidden' } end,
          },
          find_files = {
            file_ignore_patterns = { 'node_modules', '.git', '.venv' },
            hidden = true,
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      })

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require('telescope.builtin')
      -- vim.keymap.set(
      --   'n',
      --   '<leader>fh',
      --   builtin.help_tags,
      --   { desc = '[S]earch [H]elp' }
      -- )
      -- vim.keymap.set(
      --   'n',
      --   '<leader>fk',
      --   builtin.keymaps,
      --   { desc = '[S]earch [K]eymaps' }
      -- )
      -- vim.keymap.set(
      --   'n',
      --   '<leader>ff',
      --   builtin.find_files,
      --   { desc = '[S]earch [F]iles' }
      -- )
      -- vim.keymap.set(
      --   'n',
      --   '<leader>fs',
      --   builtin.builtin,
      --   { desc = '[S]earch [S]elect Telescope' }
      -- )
      vim.keymap.set(
        'n',
        '<leader>fw',
        builtin.grep_string,
        { desc = '[S]earch current [W]ord' }
      )
      vim.keymap.set(
        'n',
        '<leader>fg',
        builtin.live_grep,
        { desc = '[S]earch by [G]rep' }
      )
      vim.keymap.set(
        'n',
        '<leader>fd',
        builtin.diagnostics,
        { desc = '[S]earch [D]iagnostics' }
      )
      vim.keymap.set(
        'n',
        '<leader>fr',
        builtin.resume,
        { desc = '[S]earch [R]esume' }
      )
      vim.keymap.set(
        'n',
        '<leader>f.',
        builtin.oldfiles,
        { desc = '[S]earch Recent Files ("." for repeat)' }
      )
      vim.keymap.set(
        'n',
        '<leader><leader>',
        builtin.buffers,
        { desc = '[ ] Find existing buffers' }
      )

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(
          require('telescope.themes').get_dropdown({
            winblend = 10,
            previewer = false,
          })
        )
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set(
        'n',
        '<leader>f/',
        function()
          builtin.live_grep({
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          })
        end,
        { desc = '[S]earch [/] in Open Files' }
      )

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set(
        'n',
        '<leader>fn',
        function() builtin.find_files({ cwd = vim.fn.stdpath('config') }) end,
        { desc = '[S]earch [N]eovim files' }
      )
    end,
  },

  {
    'MagicDuck/grug-far.nvim',
    cmd = { 'GrugFar' },
    config = function()
      require('grug-far').setup({
        -- options, see Configuration section below
        -- there are no required options atm
        -- engine = 'ripgrep' is default, but 'astgrep' can be specified
      })
    end,
  },
}
