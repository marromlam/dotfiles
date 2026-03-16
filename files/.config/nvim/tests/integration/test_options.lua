-- Integration test: verify vim options are set by options.lua.
-- Boots a child Neovim, loads options.lua from the config root, then asserts
-- key option values.

local T = MiniTest.new_set()
local eq = MiniTest.expect.equality

-- Resolve the config root relative to this file's location:
-- this file lives at  <config_root>/tests/integration/test_options.lua
local config_root = vim.fn.fnamemodify(
  debug.getinfo(1, 'S').source:sub(2), -- strip leading '@'
  ':h:h:h'
)

T['options'] = MiniTest.new_set({
  hooks = {
    pre_once = function()
      T.child = MiniTest.new_child_neovim()
      T.child.start({ '-u', 'NONE' })
      -- Put the config lua/ directory on rtp so require() works
      T.child.lua(
        ('vim.opt.rtp:prepend(%q)'):format(config_root)
      )
      T.child.lua("require('options')")
    end,
    post_once = function() T.child.stop() end,
  },
})

local function get_opt(name)
  return T.child.lua_get(('vim.o[%q]'):format(name))
end

T['options']['number is set'] = function()
  eq(get_opt('number'), true)
end
T['options']['relativenumber is set'] = function()
  eq(get_opt('relativenumber'), true)
end
T['options']['splitbelow is set'] = function()
  eq(get_opt('splitbelow'), true)
end
T['options']['splitright is set'] = function()
  eq(get_opt('splitright'), true)
end
T['options']['undofile is set'] = function()
  eq(get_opt('undofile'), true)
end
T['options']['termguicolors is set'] = function()
  eq(get_opt('termguicolors'), true)
end
T['options']['ignorecase is set'] = function()
  eq(get_opt('ignorecase'), true)
end
T['options']['smartcase is set'] = function()
  eq(get_opt('smartcase'), true)
end
T['options']['expandtab is set'] = function()
  eq(get_opt('expandtab'), true)
end
T['options']['showtabline is 0'] = function()
  eq(get_opt('showtabline'), 0)
end

return T
