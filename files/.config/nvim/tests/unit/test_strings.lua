-- Unit tests for statusline string utilities (tools.strings).
--   spacer, section

local T = MiniTest.new_set()
local eq = MiniTest.expect.equality

local S = require('tools').strings

-- spacer {{{
T['spacer'] = MiniTest.new_set()

T['spacer']['returns nil for size < 1'] = function()
  eq(S.spacer(0), nil)
  eq(S.spacer(-1), nil)
end
T['spacer']['returns nil when size is absent'] = function() eq(S.spacer(), nil) end
T['spacer']['returns a component with correct padding'] = function()
  local result = S.spacer(3)
  MiniTest.expect.no_equality(result, nil)
  local chunks = result[1]
  MiniTest.expect.no_equality(chunks, nil)
  eq(chunks[1][1], '   ')
end
T['spacer']['respects custom filler'] = function()
  local result = S.spacer(2, { filler = '-' })
  local chunks = result[1]
  eq(chunks[1][1], '--')
end

-- }}}

-- section {{{
T['section'] = MiniTest.new_set()

T['section']['new creates a table with provided args'] = function()
  local s = S.section:new('a', 'b', 'c')
  eq(s[1], 'a')
  eq(s[2], 'b')
  eq(s[3], 'c')
end
T['section']['addition concatenates two sections'] = function()
  local s1 = S.section:new('a', 'b')
  local s2 = S.section:new('c', 'd')
  local combined = s1 + s2
  eq(combined[1], 'a')
  eq(combined[2], 'b')
  eq(combined[3], 'c')
  eq(combined[4], 'd')
end

-- }}}

return T
