return {
  {
    'numToStr/Comment.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    config = function()
      -- import comment plugin safely
      local comment = require 'Comment'

      local ts_context_commentstring = require 'ts_context_commentstring.integrations.comment_nvim'

      -- enable comment
      comment.setup {
        -- for commenting tsx, jsx, svelte, html files
        pre_hook = ts_context_commentstring.create_pre_hook(),
      }
    end,
  },

  {
    "danymat/neogen",
    cmd = "Neogen",
    keys = {
      {
        "<leader>cn",
        function()
          require("neogen").generate()
        end,
        desc = "Generate Annotations (Neogen)",
      },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "L3MON4D3/LuaSnip",
    },
    opts = function(_, opts)
      if opts.snippet_engine ~= nil then
        return
      end

      local map = {
        ["LuaSnip"] = "luasnip",
        ["nvim-snippy"] = "snippy",
        ["vim-vsnip"] = "vsnip",
      }

      opts.snippet_engine = 'luasnip'

      if vim.snippet then
        opts.snippet_engine = "nvim"
      end

    opts.languages = {
        lua = {
            template = {
                annotation_convention = "emmylua" -- for a full list of annotation_conventions, see supported-languages below,
                }
        },
        python = {
          template = {
            annotation_convention = "numpydoc"
          }

        }
    }

    
    end,
  },
}
