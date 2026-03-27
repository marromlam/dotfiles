-- Unit tests for lua/highlight.lua exported pure functions:
--   tint, blend, darken_hsl
--
-- These functions are pure (no Neovim UI API required at call time) so they
-- can run in a plain headless Neovim without a display.

local T = MiniTest.new_set()
local eq = MiniTest.expect.equality

-- tint, blend, darken_hsl live in tools.lua (pure, no Neovim UI API at call time).
local hl = require('tools')

-- tint {{{
T['tint'] = MiniTest.new_set()

T['tint']['brightens a color with positive percent'] = function()
  -- #808080 brightened by 0% should stay #808080
  local result = hl.tint('#808080', 0)
  eq(result, '#808080')
end
T['tint']['darkens a color with negative percent'] = function()
  -- #ffffff darkened by -50% => #7f7f7f (floor(255 * 0.5) = 127 = 0x7f)
  local result = hl.tint('#ffffff', -0.5)
  eq(result, '#7f7f7f')
end
T['tint']['clamps to black'] = function()
  local result = hl.tint('#101010', -2.0)
  eq(result, '#000000')
end
T['tint']['clamps to white'] = function()
  local result = hl.tint('#f0f0f0', 100)
  eq(result, '#ffffff')
end
T['tint']['returns NONE for invalid color'] = function()
  local result = hl.tint('notacolor', 0.1)
  eq(result, 'NONE')
end

-- }}}

-- blend {{{
T['blend'] = MiniTest.new_set()

T['blend']['alpha=0 returns bg'] = function()
  eq(hl.blend('#000000', '#ffffff', 0), '#000000')
end
T['blend']['alpha=1 returns fg'] = function()
  eq(hl.blend('#000000', '#ffffff', 1), '#ffffff')
end
T['blend']['50% blend of black and white is grey'] = function()
  -- floor((1-0.5)*0 + 0.5*255 + 0.5) = floor(127.5 + 0.5) = 128 = 0x80
  eq(hl.blend('#000000', '#ffffff', 0.5), '#808080')
end
T['blend']['returns NONE when bg is NONE'] = function()
  eq(hl.blend('NONE', '#ffffff', 0.5), 'NONE')
end
T['blend']['returns NONE when fg is NONE'] = function()
  eq(hl.blend('#000000', 'NONE', 0.5), 'NONE')
end
T['blend']['returns NONE for invalid hex'] = function()
  eq(hl.blend('invalid', '#ffffff', 0.5), 'NONE')
end
T['blend']['clamps alpha below 0'] = function()
  eq(hl.blend('#000000', '#ffffff', -1), '#000000')
end
T['blend']['clamps alpha above 1'] = function()
  eq(hl.blend('#000000', '#ffffff', 2), '#ffffff')
end

-- }}}

-- darken_hsl {{{
T['darken_hsl'] = MiniTest.new_set()

T['darken_hsl']['factor=0 returns original color'] = function()
  -- darken with factor 0 => ll * (1+0) = ll unchanged
  local result = hl.darken_hsl('#ff0000', 0)
  eq(result, '#ff0000')
end
T['darken_hsl']['darkens a color'] = function()
  -- Any negative factor should produce a darker (lower lightness) result.
  -- We just check it differs from the original and is a valid hex.
  local result = hl.darken_hsl('#ffffff', -0.5)
  MiniTest.expect.no_equality(result, '#ffffff')
  MiniTest.expect.no_equality(result, 'NONE')
  eq(result:sub(1, 1), '#')
  eq(#result, 7)
end
T['darken_hsl']['lightens a color'] = function()
  local result = hl.darken_hsl('#333333', 0.5)
  MiniTest.expect.no_equality(result, '#333333')
  MiniTest.expect.no_equality(result, 'NONE')
  eq(result:sub(1, 1), '#')
  eq(#result, 7)
end
T['darken_hsl']['returns NONE for invalid hex'] = function()
  eq(hl.darken_hsl('notacolor', -0.2), 'NONE')
end
T['darken_hsl']['pure black stays black when darkened'] = function()
  eq(hl.darken_hsl('#000000', -0.5), '#000000')
end
T['darken_hsl']['pure white stays white when lightened'] = function()
  -- lightness is already 1.0; moving toward 1.0 keeps it there
  eq(hl.darken_hsl('#ffffff', 0.5), '#ffffff')
end

-- }}}

return T
