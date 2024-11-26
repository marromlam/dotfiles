-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
-- sdfdsfadsfasdfasdfsdff
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  { import = 'custom.plugins' },
}, {
  defaults = {
    lazy = true,
    cond = not vim.g.started_by_firenvim,
  },
  install = {
    missing = true,
    colorscheme = { 'gruvbox' },
    -- colorscheme = { 'horizon' },
  },
  browser = 'brave',
  diff = {
    cmd = 'diffview.nvim',
  },

  dev = {
    path = '/Users/marcos/Projects/personal/',
    patterns = { 'marromlam' },
    fallback = true,
  },
  -- profiling = {
  --   loader = true,
  --   require = true,
  -- },
  performance = {
    cache = {
      enabled = true,
      disable_events = { 'UiEnter' },
    },
    reset_packpath = true,
    rtp = {
      reset = true,
      disabled_plugins = {
        'matchit',
        'matchparen',
        'tarPlugin',
        'tohtml',
        'tutor',
        'man',
        'spellfile',
      },
    },
  },

  ui = {
    border = 'rounded',
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
