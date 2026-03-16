return {
  {
    'tpope/vim-sleuth',
    event = { 'BufReadPre', 'BufNewFile' },
  },
  { 'tpope/vim-surround', event = { 'BufReadPre', 'BufNewFile' } },

  {
    'tpope/vim-repeat',
    keys = { '.' },
  },
}
