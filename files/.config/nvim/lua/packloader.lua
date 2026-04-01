-- lua/packloader.lua

-- Firenvim: skip the full plugin stack
if vim.g.started_by_firenvim then return end

vim.g.db_ui_use_nerd_fonts = 1

-- ---------------------------------------------------------------------------
-- Plugin installation via vim.pack
-- ---------------------------------------------------------------------------
vim.pack.add({
  -- Colorschemes
  'https://github.com/vague2k/vague.nvim',

  -- LSP
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/j-hui/fidget.nvim',
  'https://github.com/folke/lazydev.nvim',
  'https://github.com/stevanmilic/nvim-lspimport',
  'https://github.com/simrat39/symbols-outline.nvim',
  'https://github.com/rachartier/tiny-inline-diagnostic.nvim',
  'https://github.com/iamkarasik/sonarqube.nvim',
  'https://github.com/kosayoda/nvim-lightbulb',
  'https://github.com/DNLHC/glance.nvim',
  'https://github.com/smjonas/inc-rename.nvim',

  -- Completion
  'https://github.com/saghen/blink.cmp',
  'https://github.com/rafamadriz/friendly-snippets',
  'https://github.com/onsails/lspkind.nvim',
  'https://github.com/Kaiser-Yang/blink-cmp-avante',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',

  -- Treesitter
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
  'https://github.com/JoosepAlviste/nvim-ts-context-commentstring',
  'https://github.com/Wansmer/treesj',
  'https://github.com/windwp/nvim-ts-autotag',

  -- Fuzzy finder
  'https://github.com/ibhagwan/fzf-lua',

  -- Git
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/ruifm/gitlinker.nvim',
  'https://github.com/akinsho/git-conflict.nvim',
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/sindrets/diffview.nvim',
  'https://github.com/isakbm/gitgraph.nvim',
  'https://github.com/ThePrimeagen/git-worktree.nvim',

  -- UI
  'https://github.com/akinsho/bufferline.nvim',
  'https://github.com/lukas-reineke/indent-blankline.nvim',
  'https://github.com/SmiteshP/nvim-navic',
  'https://github.com/b0o/incline.nvim',
  'https://github.com/uga-rosa/ccc.nvim',
  'https://github.com/Wansmer/symbol-usage.nvim',
  'https://github.com/mbbill/undotree',
  'https://github.com/nacro90/numb.nvim',
  'https://github.com/HiPhish/rainbow-delimiters.nvim',

  -- Noice
  'https://github.com/folke/noice.nvim',
  'https://github.com/MunifTanjim/nui.nvim',

  -- Mini
  'https://github.com/echasnovski/mini.ai',
  'https://github.com/echasnovski/mini.align',
  'https://github.com/echasnovski/mini.pairs',
  'https://github.com/echasnovski/mini.surround',
  'https://github.com/echasnovski/mini.splitjoin',
  'https://github.com/echasnovski/mini.move',
  'https://github.com/echasnovski/mini.icons',
  'https://github.com/echasnovski/mini.diff',
  'https://github.com/echasnovski/mini.trailspace',
  'https://github.com/echasnovski/mini.misc',
  'https://github.com/echasnovski/mini.bufremove',

  -- Format / Lint
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/mfussenegger/nvim-lint',

  -- Debug
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  'https://github.com/leoluz/nvim-dap-go',

  -- Testing
  'https://github.com/nvim-neotest/neotest',
  'https://github.com/rcarriga/neotest-plenary',
  'https://github.com/nvim-neotest/neotest-python',

  -- Navigation
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/cbochs/grapple.nvim',

  -- Terminal
  'https://github.com/akinsho/toggleterm.nvim',

  -- Copilot / AI
  'https://github.com/zbirenbaum/copilot.lua',
  'https://github.com/olimorris/codecompanion.nvim',
  'https://github.com/ravitemer/mcphub.nvim',
  'https://github.com/folke/sidekick.nvim',

  -- Database
  'https://github.com/tpope/vim-dadbod',
  'https://github.com/kristijanhusak/vim-dadbod-ui',
  'https://github.com/kristijanhusak/vim-dadbod-completion',

  -- Todo / Folke
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/folke/trouble.nvim',

  -- Whichkey
  'https://github.com/folke/which-key.nvim',

  -- Comment
  'https://github.com/numToStr/Comment.nvim',

  -- Obsidian
  'https://github.com/epwalsh/obsidian.nvim',

  -- REPL
  'https://github.com/marromlam/kitty-repl.nvim',

  -- Remote / containers
  'https://codeberg.org/esensar/nvim-dev-container',

  -- Filetype support
  'https://github.com/plasticboy/vim-markdown',
  'https://github.com/3rd/image.nvim',
  'https://github.com/mtdl9/vim-log-highlighting',
  'https://github.com/raivivek/vim-snakemake',
  'https://github.com/fladson/vim-kitty',
  'https://github.com/tpope/vim-apathy',
  'https://github.com/saecki/crates.nvim',
  'https://github.com/lbrayner/vim-rzip',
  'https://github.com/hat0uma/csvview.nvim',
  'https://github.com/ledger/vim-ledger',
  'https://github.com/Kicamon/markdown-table-mode.nvim',
  'https://github.com/lervag/vimtex',

  -- Gaming / misc
  'https://github.com/meznaric/key-analyzer.nvim',

  -- Init / misc plugins
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/jghauser/fold-cycle.nvim',
  'https://github.com/andrewferrier/debugprint.nvim',
  'https://github.com/marromlam/sailor.vim',
  'https://github.com/bogado/file-line',
  'https://github.com/will133/vim-dirdiff',
  'https://github.com/tpope/vim-sleuth',
  'https://github.com/tpope/vim-surround',
  'https://github.com/tpope/vim-repeat',

  -- Bufferline dep
  'https://github.com/nvim-lua/plenary.nvim',
})

-- ---------------------------------------------------------------------------
-- Load configuration for each pack (imperative setup)
-- ---------------------------------------------------------------------------

-- Always-on / UI (load immediately)
require('packs.colorscheme')
require('packs.mini')
require('packs.noice')
require('packs.bufferline')
require('packs.whichkey')

-- Fuzzy finder (load immediately for keymaps)
require('packs.fzf')

-- Navigation (keymaps registered immediately)
require('packs.navigation')

-- Terminal
require('packs.terminal')

-- REPL
require('packs.repl')

-- Copilot / AI (deferred setup via autocmd in each file)
require('packs.copilot')

-- Database
require('packs.dadbod')

-- Gaming / misc
require('packs.gaming')

-- Obsidian (keymaps only, lazy setup)
require('packs.obsidian')

-- Remote
require('packs.remote')

-- Comment (on BufReadPre)
require('packs.comment')

-- Todo / Trouble
require('packs.todo')

-- Filetype plugins
require('packs.filetype')

-- Treesitter (on BufReadPost)
require('packs.treesitter')

-- Heavy plugins: load on BufReadPre/BufNewFile
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('MrlPackloaderHeavy', { clear = true }),
  callback = function()
    require('packs.lsp')
    require('packs.git')
    require('packs.ui')
    require('packs.format')
    require('packs.linting')
    require('packs.testing')
    require('packs.debug')
    require('packs.init')
  end,
})

-- vim: ts=2 sts=2 sw=2 et fdm=marker
