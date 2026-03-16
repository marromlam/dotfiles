-- Integration test: verify that key bindings from keymaps.lua are registered.
-- Boots a child Neovim with the real config root on rtp, loads options.lua
-- (which patches vim.keymap.set) then keymaps.lua, and checks that specific
-- maps exist.

local T = MiniTest.new_set()
local eq = MiniTest.expect.equality

local config_root = vim.fn.fnamemodify(
  debug.getinfo(1, 'S').source:sub(2),
  ':h:h:h'
)

T['keymaps'] = MiniTest.new_set({
  hooks = {
    pre_once = function()
      T.child = MiniTest.new_child_neovim()
      T.child.start({ '-u', 'NONE' })
      T.child.lua(('vim.opt.rtp:prepend(%q)'):format(config_root))
      -- options.lua patches vim.keymap.set; keymaps.lua uses it
      T.child.lua("require('options')")
      T.child.lua("require('keymaps')")
    end,
    post_once = function() T.child.stop() end,
  },
})

--- Check that a keymap is registered for the given mode and lhs.
local function has_map(mode, lhs)
  return T.child.lua_get(
    ('(function() '
      .. 'local maps = vim.fn.maparg(%q, %q, false, true); '
      .. 'return maps ~= nil and maps.lhs ~= nil '
      .. 'end)()'):format(lhs, mode)
  )
end

T['keymaps']['<c-s> saves in normal mode'] = function()
  eq(has_map('n', '<C-S>'), true)
end
T['keymaps'][']q moves to next quickfix item'] = function()
  eq(has_map('n', ']q'), true)
end
T['keymaps']['[q moves to prev quickfix item'] = function()
  eq(has_map('n', '[q'), true)
end
T['keymaps'][']l moves to next loclist item'] = function()
  eq(has_map('n', ']l'), true)
end
T['keymaps']['[l moves to prev loclist item'] = function()
  eq(has_map('n', '[l'), true)
end
T['keymaps']['g> shows messages'] = function()
  eq(has_map('n', 'g>'), true)
end

return T
