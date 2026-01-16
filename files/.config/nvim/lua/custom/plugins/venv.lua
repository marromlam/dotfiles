return {
  {
    'linux-cultist/venv-selector.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'ibhagwan/fzf-lua',
      'mfussenegger/nvim-dap-python',
    },
    opts = {
      options = {
        -- Prefer fzf-lua instead of telescope.
        picker = 'fzf-lua',
      },
    },
    cmd = {
      'VenvSelect',
      'VenvSelectCached',
    },
    keys = {
      {
        -- Keymap to open VenvSelector to pick a venv.
        '<leader>vs',
        '<cmd>:VenvSelect<cr>',
      },
      {
        -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
        '<leader>vc',
        '<cmd>:VenvSelectCached<cr>',
      },
    },
  },
}
