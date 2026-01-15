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

-- Ensure icons are available, use defaults if not
local icons = mrl.ui and mrl.ui.icons or nil

require('lazy').setup({
  { import = 'custom.plugins' },
}, {
  defaults = {
    lazy = true,
    cond = not vim.g.started_by_firenvim,
  },
  install = {
    missing = true,
    -- colorscheme = { 'gruvbox' },
    -- colorscheme = { 'horizon' },
    -- colorscheme = { 'rose-pine' },
  },
  browser = 'brave',
  diff = {
    cmd = 'diffview.nvim',
  },
  checker = {
    enabled = true,
    notify = false,
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
    border = (mrl.ui and mrl.ui.current and mrl.ui.current.border) or 'single',
    backdrop = 100,
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = {
      cmd = icons.cmd,
      config = icons.config,
      event = icons.calendar,
      ft = icons.folder,
      init = icons.settings,
      keys = icons.key,
      plugin = icons.box,
      runtime = icons.runtime,
      require = icons.moon,
      source = icons.source,
      start = icons.rocket,
      task = icons.task,
      lazy = icons.sleep,
    },
  },
})
