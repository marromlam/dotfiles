-- Unit tests for lua/tools.lua pure functions.
-- Requires: mini.test (bootstrapped by minimal_init.lua)

local T = MiniTest.new_set()
local eq = MiniTest.expect.equality

-- `tools` is on the rtp via minimal_init.lua
local tools = require('tools')

-- falsy {{{
T['falsy'] = MiniTest.new_set()

T['falsy']['nil returns true'] = function() eq(tools.falsy(nil), true) end
T['falsy']['false returns true'] = function() eq(tools.falsy(false), true) end
T['falsy']['true returns false'] = function() eq(tools.falsy(true), false) end
T['falsy']['empty string returns true'] = function()
  eq(tools.falsy(''), true)
end
T['falsy']['non-empty string returns false'] = function()
  eq(tools.falsy('hello'), false)
end
T['falsy']['zero returns true'] = function() eq(tools.falsy(0), true) end
T['falsy']['negative number returns true'] = function()
  eq(tools.falsy(-1), true)
end
T['falsy']['positive number returns false'] = function()
  eq(tools.falsy(1), false)
end
T['falsy']['empty table returns true'] = function()
  eq(tools.falsy({}), true)
end
T['falsy']['non-empty table returns false'] = function()
  eq(tools.falsy({ 1 }), false)
end

-- }}}

-- any {{{
T['any'] = MiniTest.new_set()

T['any']['matches item in list'] = function()
  eq(tools.any('foo', { 'foo', 'bar' }), true)
end
T['any']['returns false when no match'] = function()
  eq(tools.any('baz', { 'foo', 'bar' }), false)
end
T['any']['supports pattern matching'] = function()
  eq(tools.any('hello.lua', { '%.lua$' }), true)
end
T['any']['empty list returns false'] = function()
  eq(tools.any('foo', {}), false)
end

-- }}}

-- find {{{
T['find'] = MiniTest.new_set()

T['find']['returns matching item'] = function()
  local result = tools.find(function(x) return x > 2 end, { 1, 2, 3, 4 })
  eq(result, 3)
end
T['find']['returns nil when no match'] = function()
  local result = tools.find(function(x) return x > 10 end, { 1, 2, 3 })
  eq(result, nil)
end
T['find']['returns first match'] = function()
  local result = tools.find(function(x) return x % 2 == 0 end, { 1, 2, 4, 6 })
  eq(result, 2)
end

-- }}}

-- fold {{{
T['fold'] = MiniTest.new_set()

T['fold']['sums a list'] = function()
  local sum =
    tools.fold(function(acc, v) return acc + v end, { 1, 2, 3, 4 }, 0)
  eq(sum, 10)
end
T['fold']['concatenates strings'] = function()
  local result =
    tools.fold(function(acc, v) return acc .. v end, { 'a', 'b', 'c' }, '')
  eq(result, 'abc')
end
T['fold']['uses empty table as default accumulator'] = function()
  local result = tools.fold(function(acc, v)
    acc[#acc + 1] = v * 2
    return acc
  end, { 1, 2, 3 })
  eq(result, { 2, 4, 6 })
end

-- }}}

-- map {{{
T['map'] = MiniTest.new_set()

T['map']['doubles each element'] = function()
  local result = tools.map(function(v) return v * 2 end, { 1, 2, 3 })
  eq(result, { 2, 4, 6 })
end
T['map']['maps strings to uppercase'] = function()
  local result =
    tools.map(function(v) return v:upper() end, { 'a', 'b', 'c' })
  eq(result, { 'A', 'B', 'C' })
end
T['map']['returns empty table for empty input'] = function()
  local result = tools.map(function(v) return v end, {})
  eq(result, {})
end

-- }}}

return T
