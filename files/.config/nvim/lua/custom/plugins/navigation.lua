return {

  {
    'tpope/vim-vinegar',
    keys = { '-' },
  },

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    -- dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    keys = {

      {
        '<leader>1',
        function() require('harpoon'):list():select(1) end,
        'Go to buffer 1',
      },
      {
        '<leader>2',
        '<cmd>BufferLineGoToBuffer 2<cr>',
        'Go to buffer 2',
      },
      {
        '<leader>3',
        '<cmd>BufferLineGoToBuffer 3<cr>',
        'Go to buffer 3',
      },
      {
        '<leader>4',
        '<cmd>BufferLineGoToBuffer 4<cr>',
        'Go to buffer 4',
      },
      {
        '<leader>5',
        '<cmd>BufferLineGoToBuffer 5<cr>',
        'Go to buffer 5',
      },
      {
        '<leader>6',
        '<cmd>BufferLineGoToBuffer 6<cr>',
        'Go to buffer 6',
      },
      {
        '<leader>7',
        '<cmd>BufferLineGoToBuffer 7<cr>',
        'Go to buffer 7',
      },
      {
        '<leader>8',
        '<cmd>BufferLineGoToBuffer 8<cr>',
        'Go to buffer 8',
      },
      {
        '<leader>9',
        '<cmd>BufferLineGoToBuffer 9<cr>',
        'Go to buffer 9',
      },
      {
        '<leader>0',
        '<cmd>BufferLineGoToBuffer 10<cr>',
        'Go to buffer 10',
      },
    },
    config = function()
      local harpoon = require('harpoon')
      harpoon:setup({})

      -- basic telescope configuration
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        -- require('telescope.pickers')
        --   .new({}, {
        --     prompt_title = 'Harpoon',
        --     finder = require('telescope.finders').new_table({
        --       results = file_paths,
        --     }),
        --     previewer = conf.file_previewer({}),
        --     sorter = conf.generic_sorter({}),
        --   })
        --   :find()
        print(vim.inspect(file_paths))
        require('fzf-lua').buffers(file_paths, {
          winopts = {
            title = 'Harpoon',
            height = 0.33,
            row = 0.5,
          },
          previewer = false,
          actions = {
            ['default'] = function(selected)
              local session = vim.iter(file_paths):find(
                function(s) return s.name == selected[1] end
              )
              if not session then return end
              -- persisted.load({ session = session.file_path })
            end,
            ['ctrl-d'] = {
              function(selected)
                local session = vim.iter(file_paths):find(
                  function(s) return s.name == selected[1] end
                )
                if not session then return end
                vim.fn.delete(vim.fn.expand(session.file_path))
              end,
            },
          },
        })
      end

      vim.keymap.set(
        'n',
        '<leader><leader>',
        function() toggle_telescope(harpoon:list()) end,
        { desc = 'Open harpoon window' }
      )
    end,
  },
}
