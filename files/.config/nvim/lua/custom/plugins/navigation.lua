return {

  {
    'stevearc/oil.nvim',
    lazy = true,
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ['<C-h>'] = false, -- don't shadow split navigation
        ['<C-l>'] = false,
      },
    },
    keys = {
      { '-', '<cmd>Oil<cr>', desc = 'oil: open parent directory' },
    },
  },

  {
    'cbochs/grapple.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      scope = 'git',
    },
    keys = {
      { '<leader>m', '<cmd>Grapple tag<cr>', desc = 'grapple: tag file' },
      { '<leader><leader>', '<cmd>Grapple toggle_tags<cr>', desc = 'grapple: open tags' },
      { '<leader>1', '<cmd>Grapple select index=1<cr>', desc = 'grapple: select 1' },
      { '<leader>2', '<cmd>Grapple select index=2<cr>', desc = 'grapple: select 2' },
      { '<leader>3', '<cmd>Grapple select index=3<cr>', desc = 'grapple: select 3' },
      { '<leader>4', '<cmd>Grapple select index=4<cr>', desc = 'grapple: select 4' },
      { '<leader>5', '<cmd>Grapple select index=5<cr>', desc = 'grapple: select 5' },
      { '[g', '<cmd>Grapple cycle_tags prev<cr>', desc = 'grapple: prev tag' },
      { ']g', '<cmd>Grapple cycle_tags next<cr>', desc = 'grapple: next tag' },
    },
  },
}
